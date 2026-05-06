#!/bin/bash

# A simple themed power menu using Rofi
# Matches FoxML sharp corners and earthy colors

chosen=$(printf "󰐥  Shutdown\n󰜉  Reboot\n󰤄  Suspend\n  Lock\n󰗼  Logout" | rofi -dmenu -i -p "Power Menu" -theme-str 'window {width: 400px;}')

case "$chosen" in
    "󰐥  Shutdown") systemctl poweroff ;;
    "󰜉  Reboot") systemctl reboot ;;
    "󰤄  Suspend") systemctl suspend ;;
    "  Lock") ~/.config/hypr/scripts/lock.sh ;;
    "󰗼  Logout") hyprctl dispatch exit ;;
esac
