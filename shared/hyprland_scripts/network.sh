#!/bin/bash

# Simple Rofi Network Manager wrapper using nmcli
# Matches FoxML sharp corners and earthy colors

ROFI_ZONE="${ROFI_ZONE:-ne}"
source ~/.config/hypr/scripts/_rofi_zone.sh

msg="Select Network"
# Get list of SSIDs
options=$(nmcli -t -f SSID dev wifi list | grep -v '^--' | sort -u)

chosen=$(echo -e "$options" | rofi -dmenu -i -p "$msg" \
    -kb-row-up "k,Up" \
    -kb-row-down "j,Down" \
    -kb-accept-entry "l,Return" \
    -kb-cancel "Escape,h" \
    -theme-str "$ROFI_POS_THEME inputbar {enabled: false;} window {width: 30%;}")

if [[ -n "$chosen" ]]; then
    # `--` terminates option parsing so a maliciously named SSID
    # starting with `-` (or containing $() shell-substitution chars)
    # is treated as a literal argument to nmcli, not a flag and not
    # something nmcli might re-interpret. Belt-and-suspenders: validate
    # SSIDs match the IEEE 802.11 spec (1-32 bytes, no NUL); reject
    # anything else as malformed before passing to nmcli.
    if (( ${#chosen} < 1 || ${#chosen} > 32 )) || [[ "$chosen" == *$'\0'* ]]; then
        notify-send "Network" "SSID '$chosen' rejected (invalid length or null byte)"
        exit 1
    fi
    nmcli dev wifi connect -- "$chosen" | grep -q "successfully activated"
    if [[ $? -eq 0 ]]; then
        notify-send "Network" "Connected to $chosen"
    else
        # If it fails, try to prompt for password in terminal or just notify
        notify-send "Network" "Connection to $chosen failed"
    fi
fi
