#!/bin/bash

# Simple Rofi Network Manager wrapper using nmcli
# Matches FoxML sharp corners and earthy colors

# Check if rofi-network-manager is installed, otherwise use a fallback or instructions
# For now, we'll use a direct nmcli-based rofi menu for maximum portability

msg="Select Network"
# Get list of SSIDs
options=$(nmcli -t -f SSID dev wifi list | grep -v '^--' | sort -u)

chosen=$(echo -e "$options" | rofi -dmenu -i -p "$msg" -theme-str 'window {width: 400px;}')

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
