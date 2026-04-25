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
    pkill -x hypridle 2>/dev/null || true
    sleep 0.2
    setsid hypridle >/dev/null 2>&1 < /dev/null &
    disown
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
