#!/bin/bash
# Waybar media player module
# Shows current track, scroll to seek, click to play/pause

status=$(playerctl status 2>/dev/null)
if [[ -z "$status" ]]; then
    echo ""
    exit 0
fi

icon="󰎆"
[[ "$status" == "Playing" ]] && icon="󰏤" || icon="󰐊"

artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

# Truncate long titles
full_text="$icon $artist - $title"
if (( ${#full_text} > 40 )); then
    display_text="${full_text:0:37}..."
else
    display_text="$full_text"
fi

echo "{\"text\": \"$display_text\", \"tooltip\": \"$full_text\", \"class\": \"${status,,}\"}"
