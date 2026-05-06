#!/bin/bash

# Simple Spotify module for Waybar using playerctl
# Returns JSON for custom module

PLAYER="spotify"

# Get status
STATUS=$(playerctl -p $PLAYER status 2>/dev/null)

if [[ -z "$STATUS" ]]; then
    # Spotify not running or no player found
    exit 0
fi

# Get metadata
ARTIST=$(playerctl -p $PLAYER metadata artist 2>/dev/null)
TITLE=$(playerctl -p $PLAYER metadata title 2>/dev/null)

# Truncate if too long
MAX_LENGTH=40
TEXT="$ARTIST - $TITLE"
if [[ ${#TEXT} -gt $MAX_LENGTH ]]; then
    TEXT="${TEXT:0:$MAX_LENGTH}..."
fi

# Icons based on status
ICON="󰓇"
CLASS="paused"
if [[ "$STATUS" == "Playing" ]]; then
    ICON="󰓇"
    CLASS="playing"
fi

echo "{\"text\": \"$ICON $TEXT\", \"class\": \"$CLASS\", \"alt\": \"$STATUS\", \"tooltip\": \"$ARTIST - $TITLE ($STATUS)\"}"
