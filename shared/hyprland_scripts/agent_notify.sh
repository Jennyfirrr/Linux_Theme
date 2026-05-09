#!/usr/bin/env bash
# agent_notify.sh — themed notify-send + JSONL queue append for AI agent hooks.
# Invoked by Claude Code / Gemini CLI hooks. Reads hook payload JSON on stdin.
#
# Usage:
#   agent_notify.sh <source> <event>
#     <source>: claude | gemini
#     <event>:  stop | subagent | notification
#
# Theme: hex colors are sourced from ~/.config/hypr/modules/border_colors.sh
# (rendered by render.sh from the active palette), so a palette swap takes
# effect on the next hook fire — no need to re-run install.sh.

# Hooks must never surface a non-zero exit (Claude Code marks the turn with a
# red "stop hook error" banner if they do, even though the failure is harmless
# from the user's perspective). Trap any unexpected error and exit 0 with the
# real reason logged to a sidecar so we can debug without polluting the TUI.
LOG_FILE="${XDG_RUNTIME_DIR:-/tmp}/foxml-agent-notify.log"
trap 'echo "[$(date -Iseconds)] $0 ${LINENO} ${BASH_COMMAND}" >> "$LOG_FILE" 2>/dev/null; exit 0' ERR

src="${1:-claude}"
event="${2:-stop}"

# Read hook payload (Claude and Gemini both pass JSON on stdin). Bounded read
# so this never wedges if a hook fires without piping anything.
input=""
if [[ ! -t 0 ]]; then
    input="$(timeout 0.2 cat 2>/dev/null || true)"
fi

# Theme palette (rendered hex strings, no leading '#').
if [[ -r "$HOME/.config/hypr/modules/border_colors.sh" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.config/hypr/modules/border_colors.sh"
fi
C_PRIMARY="${C_PRIMARY:-c4956e}"
C_SECONDARY="${C_SECONDARY:-b8967a}"
C_ACCENT="${C_ACCENT:-8a9a7a}"
C_RED="${C_RED:-b05555}"
C_OK="${C_OK:-7aab88}"
C_WARN="${C_WARN:-c4b48a}"

# Pull a usable message + cwd out of whatever shape the payload is in.
msg=""
cwd=""
tool_name=""
if [[ -n "$input" ]] && command -v jq >/dev/null 2>&1; then
    msg="$(printf '%s' "$input" | jq -r '
        .message //
        .subagent.description //
        .description //
        empty
    ' 2>/dev/null)" || msg=""
    cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)" || cwd=""
    tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)" || tool_name=""
fi

# Gemini ships no SubagentStop event — its closest analog is AfterTool,
# which fires for *every* tool call. Filter out built-in primitives and
# MCP tools so only subagent invocations notify. Subagents register as
# tools under their own name, so anything outside this list is treated
# as a subagent (covers the built-in codebase_investigator plus any
# custom agent under ~/.gemini/agents/).
if [[ "$src" == "gemini" && "$event" == "subagent" ]]; then
    case "$tool_name" in
        ""|read_file|write_file|replace|edit|run_shell_command|list_directory|ls|search_file_content|grep|glob|web_fetch|web_search|save_memory|read_many_files|mcp_*)
            exit 0
            ;;
    esac
    [[ -z "$msg" ]] && msg="$tool_name"
fi

# Idle pings — both Claude Code and Gemini CLI fire Notification hooks for
# real permission prompts ("Claude needs your permission to use Bash") AND
# for after-N-seconds "waiting for your input" idle reminders. The idle
# variant is noise during multi-pane work — same critical urgency as a
# real prompt, but no action is required. Drop them at the source so they
# don't notify or land in the rofi triage queue.
if [[ "$event" == "notification" ]]; then
    msg_lower="${msg,,}"
    case "$msg_lower" in
        *"waiting for your input"*|*"waiting for input"*|*"waiting for user input"*)
            exit 0
            ;;
    esac
fi

[[ -z "$cwd" ]] && cwd="$PWD"
project="$(basename "$cwd" 2>/dev/null)"
[[ -z "$project" ]] && project="?"

# tmux target — populated when the hook is invoked from inside a tmux pane,
# which is the common case (claude/gemini run in a tmux pane). Format S:W.P.
tmux_target=""
if [[ -n "${TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
    tmux_target="$(tmux display-message -p '#S:#I.#P' 2>/dev/null || true)"
fi

case "$src" in
    claude) src_label="Claude"; src_color="$C_PRIMARY" ;;
    gemini) src_label="Gemini"; src_color="$C_ACCENT"  ;;
    *)      src_label="$src";   src_color="$C_PRIMARY" ;;
esac

case "$event" in
    notification)
        urgency="critical"
        title="$src_label needs input · $project"
        body_text="${msg:-Awaiting your decision}"
        body_color="$C_RED"
        ;;
    subagent)
        urgency="normal"
        title="$src_label subagent · $project"
        body_text="${msg:-Subagent finished}"
        body_color="$C_WARN"
        ;;
    stop|*)
        urgency="low"
        title="$src_label · $project"
        body_text="${msg:-Turn complete — ready for next message}"
        body_color="$src_color"
        ;;
esac

# Pango-escape user-controlled strings before splicing into markup.
pango_escape() {
    printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}
esc_body="$(pango_escape "$body_text")"
esc_target="$(pango_escape "$tmux_target")"

body="<span foreground=\"#${body_color}\">${esc_body}</span>"
if [[ -n "$tmux_target" ]]; then
    body="${body}
<span foreground=\"#${C_SECONDARY}\" font_size=\"smaller\">tmux: ${esc_target}</span>"
fi

# Notification: -a sets app-name (mako/dunst route on this). Stderr is
# swallowed so a transient D-Bus issue (e.g. agent started outside the
# graphical session) doesn't paint a hook error in the TUI; details land
# in $LOG_FILE if you need them.
if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "$src_label" -u "$urgency" -i dialog-information \
        "$title" "$body" 2>>"$LOG_FILE" || true
fi

# Append to the triage queue (JSONL). flock serializes concurrent appends
# from multiple panes.
queue_dir="${XDG_RUNTIME_DIR:-/tmp}"
mkdir -p "$queue_dir" 2>/dev/null || true
queue_file="$queue_dir/foxml-agent-queue.jsonl"

if command -v jq >/dev/null 2>&1; then
    entry="$(jq -cn \
        --arg ts "$(date -Iseconds)" \
        --arg src "$src" \
        --arg event "$event" \
        --arg project "$project" \
        --arg cwd "$cwd" \
        --arg target "$tmux_target" \
        --arg msg "$body_text" \
        --arg urgency "$urgency" \
        '{ts:$ts, source:$src, event:$event, project:$project, cwd:$cwd, tmux:$target, message:$msg, urgency:$urgency}' \
        2>/dev/null)" || entry=""
    if [[ -n "$entry" ]]; then
        (
            flock -n 9 || flock 9
            printf '%s\n' "$entry" >> "$queue_file"
        ) 9>"${queue_file}.lock"
    fi
fi

exit 0
