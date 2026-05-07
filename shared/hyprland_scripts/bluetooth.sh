#!/bin/bash

# Simple Rofi Bluetooth Manager wrapper using bluetoothctl
# Matches FoxML sharp corners and earthy colors

msg="Bluetooth"

# Get status
POWER=$(bluetoothctl show | grep "Powered: yes" >/dev/null && echo "on" || echo "off")

if [[ "$POWER" == "off" ]]; then
    chosen=$(printf "󰂯  Power On\n󰗼  Exit" | rofi -dmenu -i -p "$msg" -theme-str 'inputbar {enabled: false;} window {width: 300px;}')
    [[ "$chosen" == "󰂯  Power On" ]] && bluetoothctl power on
    exit 0
fi

# Get paired devices
devices=$(bluetoothctl devices Paired | cut -d ' ' -f 3-)
options=$(printf "󰂲  Power Off\n󰚰  Scan\n---\n$devices")

chosen=$(echo -e "$options" | rofi -dmenu -i -p "$msg" -theme-str 'inputbar {enabled: false;} window {width: 400px;}')

case "$chosen" in
    "󰂲  Power Off") bluetoothctl power off ;;
    "󰚰  Scan") 
        notify-send "Bluetooth" "Scanning for 10s..."
        bluetoothctl scan on & sleep 10; bluetoothctl scan off ;;
    "---"| "") exit 0 ;;
    *)
        # Extract name and find MAC
        mac=$(bluetoothctl devices Paired | grep "$chosen" | cut -d ' ' -f 2)
        if [[ -n "$mac" ]]; then
            # Toggle connection
            connected=$(bluetoothctl info "$mac" | grep "Connected: yes" >/dev/null && echo "yes" || echo "no")
            if [[ "$connected" == "yes" ]]; then
                bluetoothctl disconnect "$mac" && notify-send "Bluetooth" "Disconnected $chosen"
            else
                bluetoothctl connect "$mac" && notify-send "Bluetooth" "Connected to $chosen"
            fi
        fi
        ;;
esac
