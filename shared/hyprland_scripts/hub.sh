#!/bin/bash

# The FoxML Hub
# A unified control center for managing your earthy desktop

chosen=$(printf "󰐥  Power Menu\n󰂯  Bluetooth\n󰖩  Network\n󰸉  Next Wallpaper\n🦊  System Cleanup\n  Lock Screen" | rofi -dmenu -i -p "FoxML Hub" \
    -kb-row-up "k,Up" \
    -kb-row-down "j,Down" \
    -kb-accept-entry "l,Return" \
    -theme-str 'mainbox {children: [listview];} window {width: 400px;}')

case "$chosen" in
    "󰐥  Power Menu") ~/.config/hypr/scripts/powermenu.sh ;;
    "󰂯  Bluetooth") ~/.config/hypr/scripts/bluetooth.sh ;;
    "󰖩  Network") ~/.config/hypr/scripts/network.sh ;;
    "󰸉  Next Wallpaper") ~/.config/hypr/scripts/rotate_wallpaper.sh --cycle ;;
    "🦊  System Cleanup") kitty -e zsh -c "source ~/.zshrc && fox-clean; echo -e '\nPress enter to close...'; read" ;;
    "  Lock Screen") ~/.config/hypr/scripts/lock.sh ;;
esac
