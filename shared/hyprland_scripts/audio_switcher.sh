#!/bin/bash

# FoxML Audio Switcher
# A themed Rofi menu to toggle between audio output devices

ROFI_ZONE="${ROFI_ZONE:-ne}"
source ~/.config/hypr/scripts/_rofi_zone.sh

# Get list of sinks (id and name).
# Format: "  * 54. Family 17h (Models 10h-1fh) HD Audio Controller Speaker [vol: 0.40]"
#
# `grep -A 10 "Sinks:"` was bleeding into adjacent sections (Sources,
# Filters) — wpctl's tree output puts Sources right after Sinks, so a
# microphone sharing a name fragment with a speaker would also match.
# Switch to an awk state machine that flips on at "Sinks:" and flips
# off at the next top-level section header (any non-indented line).
sinks=$(wpctl status | awk '
    /^[^[:space:]]/ { in_sinks=0 }
    /^[[:space:]]*Sinks:/ { in_sinks=1; next }
    in_sinks && /\[vol:/ { sub(/^[[:space:]]+/, ""); print }
')

# Build Rofi list
options=""
while IFS= read -r line; do
    # Extract ID (e.g., 54)
    id=$(echo "$line" | grep -oP '^\d+' || echo "$line" | grep -oP '^\* \d+' | cut -d' ' -f2)
    # Extract Name (e.g., Family 17h...)
    name=$(echo "$line" | sed -E 's/^(\* )?[0-9]+\. //; s/ \[vol:.*$//')
    
    # Mark active sink
    if echo "$line" | grep -q "\*"; then
        options+="󰓃  $name (Active)\n"
    else
        options+="󰓃  $name\n"
    fi
done <<< "$sinks"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Audio Output" \
    -kb-row-up "k,Up" \
    -kb-row-down "j,Down" \
    -kb-accept-entry "l,Return" \
    -kb-cancel "Escape,h" \
    -theme-str "$ROFI_POS_THEME inputbar {enabled: false;} window {width: 35%;}")

if [[ -n "$chosen" ]]; then
    # Extract name from selection
    clean_name=$(echo "$chosen" | sed 's/󰓃  //; s/ (Active)//')
    # Find ID for this name — restrict to the Sinks block so we don't
    # accidentally pick a Source/Filter ID with a matching substring.
    id=$(wpctl status | awk -v target="$clean_name" '
        /^[^[:space:]]/ { in_sinks=0 }
        /^[[:space:]]*Sinks:/ { in_sinks=1; next }
        in_sinks && index($0, target) > 0 {
            match($0, /[0-9]+/)
            print substr($0, RSTART, RLENGTH)
            exit
        }
    ')

    if [[ -n "$id" ]]; then
        wpctl set-default "$id"
        notify-send "Audio" "Switched to $clean_name"
    fi
fi
