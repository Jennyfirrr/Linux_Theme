#!/usr/bin/env bash
# agent_rofi.sh — centered rofi triage list of pending AI agent notifications.
# Reads the JSONL queue written by agent_notify.sh, renders themed entries,
# hjkl navigation. Selecting an entry tmux-routes to the originating pane and
# removes the entry from the queue. The first item clears the whole queue.
#
# Permission prompts are still answered inside the agent's TUI — this is a
# "where is it?" router, not a remote-control panel.

set -u

ROFI_ZONE="${ROFI_ZONE:-center}"
# shellcheck source=/dev/null
source ~/.config/hypr/scripts/_rofi_zone.sh

if [[ -r "$HOME/.config/hypr/modules/border_colors.sh" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.config/hypr/modules/border_colors.sh"
fi
C_PRIMARY="${C_PRIMARY:-c4956e}"
C_SECONDARY="${C_SECONDARY:-b8967a}"
C_ACCENT="${C_ACCENT:-8a9a7a}"
C_RED="${C_RED:-b05555}"
C_OK="${C_OK:-7aab88}"

queue_dir="${XDG_RUNTIME_DIR:-/tmp}"
queue_file="$queue_dir/foxml-agent-queue.jsonl"

if [[ ! -s "$queue_file" ]]; then
    rofi -e "No pending agent notifications" \
        -theme-str "$ROFI_POS_THEME"
    exit 0
fi

mapfile -t lines < "$queue_file"
total=${#lines[@]}

pango_escape() {
    printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

entries=()
indices=()  # parallel: file line number (1-based) for each menu row; 0 = clear-all

entries+=("<span foreground=\"#${C_RED}\"></span>  Clear all (${total})")
indices+=("0")

for (( raw=total-1; raw>=0; raw-- )); do
    line="${lines[$raw]}"
    [[ -z "$line" ]] && continue

    src="$(printf '%s' "$line" | jq -r '.source // ""' 2>/dev/null)"
    event="$(printf '%s' "$line" | jq -r '.event // ""' 2>/dev/null)"
    project="$(printf '%s' "$line" | jq -r '.project // "?"' 2>/dev/null)"
    target="$(printf '%s' "$line" | jq -r '.tmux // ""' 2>/dev/null)"
    msg="$(printf '%s' "$line" | jq -r '.message // ""' 2>/dev/null)"

    project_e="$(pango_escape "$project")"
    msg_e="$(pango_escape "$msg")"
    target_e="$(pango_escape "$target")"

    case "$src" in
        claude) src_color="$C_PRIMARY";   src_label="Claude" ;;
        gemini) src_color="$C_ACCENT";    src_label="Gemini" ;;
        *)      src_color="$C_SECONDARY"; src_label="${src:-?}" ;;
    esac

    case "$event" in
        notification) ev_color="$C_RED";       ev_glyph="" ;;
        subagent)     ev_color="$C_SECONDARY"; ev_glyph="" ;;
        stop|*)       ev_color="$C_OK";        ev_glyph="" ;;
    esac

    label="<span foreground=\"#${ev_color}\">${ev_glyph}</span>  <span foreground=\"#${src_color}\"><b>${src_label}</b></span> · ${project_e}"
    if [[ -n "$target_e" ]]; then
        label="${label}  <span foreground=\"#${C_SECONDARY}\" font_size=\"smaller\">[${target_e}]</span>"
    fi
    if [[ -n "$msg_e" ]]; then
        label="${label} — ${msg_e}"
    fi

    entries+=("$label")
    indices+=("$((raw + 1))")
done

chosen="$(printf '%s\n' "${entries[@]}" | \
    rofi -dmenu -i -no-custom -markup-rows -p "Agents" \
        -kb-row-up "k,Up" \
        -kb-row-down "j,Down" \
        -kb-accept-entry "l,Return" \
        -kb-cancel "Escape,h" \
        -theme-str "$ROFI_POS_THEME inputbar {enabled: false;} window {width: 50%;} listview {lines: 12;}" \
        -format 'i')"

[[ -z "$chosen" ]] && exit 0

idx="$chosen"
file_line="${indices[$idx]}"

if [[ "$file_line" == "0" ]]; then
    : > "$queue_file"
    exit 0
fi

chosen_line="${lines[$((file_line - 1))]}"
target="$(printf '%s' "$chosen_line" | jq -r '.tmux // ""' 2>/dev/null)"
cwd="$(printf '%s' "$chosen_line" | jq -r '.cwd // ""' 2>/dev/null)"

(
    flock -n 9 || flock 9
    sed -i "${file_line}d" "$queue_file"
) 9>"${queue_file}.lock"

# Route to the originating tmux pane.
if [[ -n "$target" ]] && command -v tmux >/dev/null 2>&1; then
    sess="${target%%:*}"
    rest="${target#*:}"
    win="${rest%%.*}"
    pane="${rest#*.}"

    if tmux has-session -t "$sess" 2>/dev/null; then
        tmux select-window -t "${sess}:${win}" 2>/dev/null || true
        tmux select-pane -t "${sess}:${win}.${pane}" 2>/dev/null || true

        if [[ -n "${TMUX:-}" ]]; then
            tmux switch-client -t "${sess}:${win}.${pane}" 2>/dev/null || true
        else
            # Outside tmux (Hyprland keybind): switch any attached client
            # whose current session differs, then nudge focus to a kitty
            # window so the user actually sees it.
            while read -r tty cur_sess; do
                [[ "$cur_sess" != "$sess" ]] && \
                    tmux switch-client -c "$tty" -t "${sess}:${win}.${pane}" 2>/dev/null
            done < <(tmux list-clients -F '#{client_tty} #{session_name}' 2>/dev/null)

            if command -v hyprctl >/dev/null 2>&1; then
                hyprctl dispatch focuswindow "kitty" >/dev/null 2>&1 || true
            fi
        fi
    fi
elif [[ -n "$cwd" ]]; then
    notify-send -a "Agent" "Agent triage" "Working dir: $cwd" || true
fi

exit 0
