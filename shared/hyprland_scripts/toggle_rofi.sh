#!/bin/bash
# FoxML Rofi Toggle & Positioning Wrapper
# 1. Kills Rofi if already running (toggle behavior).
# 2. For direct `rofi …` invocations, injects positioning derived from
#    ROFI_ZONE (nw|ne|center) via _rofi_zone.sh. Default zone is `nw`
#    (launcher cluster — drun, window list, etc.).
# 3. For script invocations (e.g. hub.sh, network.sh), the script is
#    expected to source _rofi_zone.sh itself; we just exec it.

if pkill -x rofi; then
    exit 0
fi

ROFI_ZONE="${ROFI_ZONE:-nw}"
source ~/.config/hypr/scripts/_rofi_zone.sh
export ROFI_ZONE ROFI_X ROFI_Y

if [[ "$1" == "rofi" ]]; then
    cmd="$1"; shift
    exec "$cmd" -theme-str "$ROFI_POS_THEME" "$@"
else
    exec "$@"
fi
