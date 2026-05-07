#!/bin/bash

# Simple Rofi Network Manager wrapper using nmcli
# Matches FoxML sharp corners and earthy colors

msg="Select Network"
# Get list of SSIDs
options=$(nmcli -t -f SSID dev wifi list | grep -v '^--' | sort -u)

chosen=$(echo -e "$options" | rofi -dmenu -i -p "$msg" \
    -kb-row-up "k,Up" \
    -kb-row-down "j,Down" \
    -kb-accept-entry "l,Return" \
    -theme-str 'inputbar {enabled: false;} window {width: 30%;}')

if [[ -n "$chosen" ]]; then
    # Prompt for password if not a known connection
    nmcli dev wifi connect "$chosen" | grep -q "successfully activated"
    if [[ $? -eq 0 ]]; then
        notify-send "Network" "Connected to $chosen"
    else
        # If it fails, try to prompt for password in terminal or just notify
        notify-send "Network" "Connection to $chosen failed"
    fi
fi
