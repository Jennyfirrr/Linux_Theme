#!/bin/bash
# Minimalist earthy weather for Waybar
# Uses wttr.in (no API key required)

# Get weather for current location (IP-based)
# Format: "Condition Temperature"
weather=$(curl -s "wttr.in/?format=%c+%t" | tr -d '+')

if [[ -n "$weather" ]]; then
    # Format for Waybar JSON
    # Icon is usually the first char
    echo "{\"text\": \"$weather\", \"tooltip\": \"Weather info from wttr.in\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"Weather unavailable\"}"
fi
