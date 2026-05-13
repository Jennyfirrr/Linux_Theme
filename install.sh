#!/usr/bin/env bash
# FoxML Theme Hub — installer entry point.
#
# As of the C++ orchestrator migration, install.sh is a thin wrapper:
#
#   1. (Optionally) self-update from origin/main.
#   2. Cache sudo + keep the credential alive across the long-running
#      module sequence.
#   3. Build fox-install if it isn't already on disk.
#   4. exec fox-install with the same argv. Every install step lives in
#      src/fox-install/modules/ now — adding new functionality means
#      writing one .cpp and adding one line to core/modules.def.
#
# The previous 2400-line bash implementation is preserved as
# install.sh.legacy for one-version-rollback safety; mappings.sh stays
# as the source of truth for modules still bridged to bash (security,
# personalize, monitors, github — see CLAUDE.md "install.sh migration
# status").

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOX_INSTALL_BIN="$SCRIPT_DIR/src/fox-install/fox-install"

# ─────────────────────────────────────────
# Self-update — fast-forward from origin/main + re-exec.
#
# Flow:
#   1. Quietly fetch origin/main (15s timeout — silent if offline).
#   2. If local HEAD == origin/main → no-op, continue with current code.
#   3. If there are new commits AND we're on main + clean → show the
#      commit list and ask y/n before pulling (TTY mode).
#   4. --yes / -y / ASSUME_YES=1 / no-TTY skip the prompt and update.
#   5. After pull, re-exec ourselves so the new wrapper code runs;
#      `make` then rebuilds whatever the new commits touched.
#
# Skip the whole thing with FOXML_NO_UPDATE=1 (offline / dev / explicit
# pin) or FOXML_UPDATED=1 (already re-execed; prevents an update loop).
# ─────────────────────────────────────────
if [[ "${FOXML_NO_UPDATE:-0}" != "1" && "${FOXML_UPDATED:-0}" != "1" ]] \
    && git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch="$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo)"
    dirty="$(git -C "$SCRIPT_DIR" status --porcelain 2>/dev/null | head -c 1 || echo)"
    if [[ "$branch" == "main" && -z "$dirty" ]]; then
        if timeout 15 git -C "$SCRIPT_DIR" fetch --quiet origin main 2>/dev/null; then
            local_sha="$(git -C "$SCRIPT_DIR" rev-parse HEAD)"
            remote_sha="$(git -C "$SCRIPT_DIR" rev-parse origin/main)"
            if [[ "$local_sha" != "$remote_sha" ]] \
                && git -C "$SCRIPT_DIR" merge-base --is-ancestor HEAD origin/main 2>/dev/null; then
                # Show what's coming. `git log --oneline` is one line per commit;
                # we cap at 10 so a long-stale checkout doesn't flood the prompt.
                _new=$(git -C "$SCRIPT_DIR" log --oneline HEAD..origin/main | head -10)
                _n=$(printf '%s\n' "$_new" | wc -l)
                echo ""
                echo "╭──────────────────────────────────────────────────────────────────╮"
                echo "│   Update available — ${_n} new commit(s) on origin/main           "
                echo "╰──────────────────────────────────────────────────────────────────╯"
                printf '%s\n' "$_new" | sed 's/^/  /'
                echo ""

                _do_update=1
                # Auto-yes if --yes / -y is in argv, $ASSUME_YES=1, or no TTY
                # (bootstrap curl-pipe path, CI, unattended re-installs).
                _autoyes=0
                for _a in "$@"; do
                    case "$_a" in -y|--yes) _autoyes=1 ;; esac
                done
                [[ "${ASSUME_YES:-0}" == "1" ]] && _autoyes=1
                [[ ! -t 0 ]] && _autoyes=1

                if (( ! _autoyes )); then
                    read -r -p "  Download + install latest? [Y/n] " _reply || true
                    case "${_reply:-y}" in
                        n|N|no|NO) _do_update=0 ;;
                        *)         _do_update=1 ;;
                    esac
                fi

                if (( _do_update )); then
                    echo ":: Self-update: pulling origin/main (fast-forward only)"
                    git -C "$SCRIPT_DIR" pull --ff-only --quiet
                    export FOXML_UPDATED=1
                    exec "$SCRIPT_DIR/install.sh" "$@"
                else
                    echo ":: Skipping update; continuing with current version."
                fi
            fi
        fi
    fi
fi

# ─────────────────────────────────────────
# Sudo cache + keepalive. Long installs (--full with --models pulling
# multi-GB Ollama models) easily exceed sudo's 5-minute default TTL.
# Background loop refreshes the cache every 50s; trap kills it on exit.
# ─────────────────────────────────────────
if [[ -t 0 ]] || [[ "${1:-}" == *"--yes"* ]] || [[ "${ASSUME_YES:-0}" == "1" ]]; then
    if sudo -v 2>/dev/null; then
        ( while true; do sudo -n true 2>/dev/null || exit; sleep 50; done ) &
        SUDO_KEEPALIVE_PID=$!
        trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
    else
        echo "warning: sudo cache cold — privileged steps will prompt or fail." >&2
    fi
fi

# ─────────────────────────────────────────
# Build / rebuild the native orchestrator.
# ─────────────────────────────────────────

# Ensure we have build tools. bootstrap.sh handles this for curl-pipe users,
# but manual git-cloners might be missing base-devel.
if ! command -v make >/dev/null 2>&1 || ! command -v g++ >/dev/null 2>&1; then
    echo ":: Build tools missing — installing base-devel..."
    sudo pacman -S --needed --noconfirm base-devel
fi

# nlohmann json.hpp is a fox-intel build dep. Network-dependent, so we
# still gate the fetch on "is the file missing?" rather than re-fetching
# every run.
if [[ ! -f "$SCRIPT_DIR/src/fox-intel/json.hpp" ]]; then
    echo ":: Fetching nlohmann/json header..."
    curl -fsSL \
        https://github.com/nlohmann/json/releases/latest/download/json.hpp \
        -o "$SCRIPT_DIR/src/fox-intel/json.hpp"
fi

if [[ ! -x "$FOX_INSTALL_BIN" ]]; then
    echo ":: Building native orchestrator (fox-install + libfox-intel + ~10 fox-* tools)"
elif [[ "${FOXML_UPDATED:-0}" == "1" ]]; then
    echo ":: Recompiling after self-update"
fi

# ─────────────────────────────────────────
# Pacman-style progress bar for the C++ build. Pre-counts compile steps
# via `make -n`, runs the real make in the background writing to a log,
# polls every 200ms and renders a bar based on how many g++/ar/cp steps
# have completed. On failure dumps the tail of the log so the error is
# never hidden.
# ─────────────────────────────────────────
build_total=$(make -C "$SCRIPT_DIR" -n install 2>/dev/null \
              | grep -cE '^(g\+\+|ar |cp )' || true)
[[ -z "$build_total" || "$build_total" -lt 1 ]] && build_total=1
build_log=$(mktemp -t foxml-build.XXXXXX.log)
trap 'rm -f "$build_log"' EXIT

if [[ -t 1 ]]; then
    make -C "$SCRIPT_DIR" install >"$build_log" 2>&1 &
    build_pid=$!
    width=40
    while kill -0 "$build_pid" 2>/dev/null; do
        done_n=$(grep -cE '^(g\+\+|ar |cp )' "$build_log" 2>/dev/null || echo 0)
        pct=$(( done_n * 100 / build_total ))
        (( pct > 100 )) && pct=100
        filled=$(( pct * width / 100 ))
        bar=$(printf '%*s' "$filled" | tr ' ' '#')
        empty=$(printf '%*s' $(( width - filled )) | tr ' ' '-')
        printf '\r   building [%s%s] %3d%% (%d/%d)  ' "$bar" "$empty" "$pct" "$done_n" "$build_total"
        sleep 0.2
    done
    wait "$build_pid"; build_rc=$?
    # Render final 100% so the bar doesn't visually freeze partway.
    bar=$(printf '%*s' "$width" | tr ' ' '#')
    printf '\r   building [%s] 100%% (%d/%d)  \n' "$bar" "$build_total" "$build_total"
else
    # Non-TTY (CI, piped): just run quietly, dump on error.
    make -C "$SCRIPT_DIR" install >"$build_log" 2>&1
    build_rc=$?
fi

if [[ "$build_rc" -ne 0 ]]; then
    echo "" >&2
    echo "error: native orchestrator build failed:" >&2
    tail -50 "$build_log" >&2
    exit 1
fi

# ─────────────────────────────────────────
# Hand control to the native orchestrator.
# ─────────────────────────────────────────
exec "$FOX_INSTALL_BIN" "$@"
