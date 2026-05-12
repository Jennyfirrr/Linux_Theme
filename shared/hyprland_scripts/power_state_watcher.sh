#!/usr/bin/env bash
# Watches AC/battery state and runs hypridle with the right config.
# Replaces a static `exec-once = hypridle` so DPMS timing tightens on battery.
set -euo pipefail

HYPR_DIR="${HOME}/.config/hypr"
LIVE_CONF="${HYPR_DIR}/hypridle.conf"
AC_CONF="${HYPR_DIR}/hypridle-ac.conf"
BAT_CONF="${HYPR_DIR}/hypridle-battery.conf"

current_state() {
    local online
    for f in /sys/class/power_supply/A{C,DP}*/online; do
        [[ -r "$f" ]] || continue
        online="$(cat "$f")"
        [[ "$online" == "1" ]] && { echo ac; return; }
    done
    echo battery
}

apply_state() {
    local state="$1" src
    case "$state" in
        ac)      src="$AC_CONF"  ;;
        battery) src="$BAT_CONF" ;;
        *)       return 1        ;;
    esac
    [[ -f "$src" ]] || { echo "missing $src" >&2; return 1; }
    cp "$src" "$LIVE_CONF"
    # Wait for hypridle to actually exit before launching a new one.
    # The old `pkill + sleep 0.2 + setsid hypridle` raced — under load
    # hypridle held its socket >200ms and the new instance failed to
    # bind, leaving the user with NO auto-lock/dpms — a security gap.
    # Poll the PID, then SIGKILL as a fallback before launching.
    if pgrep -x hypridle >/dev/null 2>&1; then
        pkill -x hypridle 2>/dev/null || true
        for _ in $(seq 1 30); do
            pgrep -x hypridle >/dev/null 2>&1 || break
            sleep 0.1
        done
        # Still around after 3s? Force it.
        pgrep -x hypridle >/dev/null 2>&1 && pkill -KILL -x hypridle 2>/dev/null
        # Small breather for any leftover socket cleanup.
        sleep 0.1
    fi
    setsid hypridle >/dev/null 2>&1 < /dev/null &
    disown
    # Sanity-check the new instance actually came up; if it didn't, log
    # loudly so the user notices instead of silently losing auto-lock.
    sleep 0.3
    if ! pgrep -x hypridle >/dev/null 2>&1; then
        echo "! hypridle failed to start after $state profile swap — auto-lock disabled" >&2
        notify-send -u critical -t 5000 "Power state" \
            "hypridle failed to restart — auto-lock OFF" 2>/dev/null || true
        return 1
    fi
    echo "hypridle profile: $state"
}

trap 'pkill -x hypridle 2>/dev/null || true; exit 0' TERM INT

last=""
while :; do
    now="$(current_state)"
    if [[ "$now" != "$last" ]]; then
        apply_state "$now" || true
        last="$now"
    fi
    sleep 30
done
