#!/bin/bash

# A simple themed power menu using Rofi
# Matches FoxML sharp corners and earthy colors

chosen=$(printf "󰐥  Shutdown\n󰜉  Reboot\n󰤄  Suspend\n  Lock\n󰗼  Logout" | rofi -dmenu -i -p "Power Menu" \
    -kb-row-up "k,Up" \
    -kb-row-down "j,Down" \
    -kb-accept-entry "l,Return" \
    -kb-custom-1 "h" \
    -theme-str 'inputbar {enabled: false;} window {width: 25%;}')
rofi_exit=$?

if [[ $rofi_exit -eq 10 ]]; then
    exit 10
fi

case "$chosen" in
    "󰐥  Shutdown") systemctl poweroff ;;
    "󰜉  Reboot") systemctl reboot ;;
    "󰤄  Suspend") systemctl suspend ;;
    "  Lock") ~/.config/hypr/scripts/lock.sh ;;
    "󰗼  Logout") hyprctl dispatch exit ;;
esac
