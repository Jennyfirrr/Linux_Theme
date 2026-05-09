#!/bin/bash

# A simple themed power menu using Rofi
# Matches FoxML sharp corners and earthy colors

ROFI_ZONE="${ROFI_ZONE:-ne}"
source ~/.config/hypr/scripts/_rofi_zone.sh

chosen=$(printf "󰐥  Shutdown\n󰜉  Reboot\n󰤄  Suspend\n  Lock\n󰗼  Logout" | rofi -dmenu -i -p "Power Menu" \
    -kb-row-up "k,Up" \
    -kb-row-down "j,Down" \
    -kb-accept-entry "l,Return" \
    -kb-cancel "Escape,h" \
    -theme-str "$ROFI_POS_THEME inputbar {enabled: false;} window {width: 25%;}")

case "$chosen" in
    "󰐥  Shutdown") systemctl poweroff ;;
    "󰜉  Reboot") systemctl reboot ;;
    "󰤄  Suspend") systemctl suspend ;;
    "  Lock") ~/.config/hypr/scripts/lock.sh ;;
    "󰗼  Logout") hyprctl dispatch exit ;;
esac
