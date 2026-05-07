#!/bin/bash
# Active Project Tracker for Waybar
# Detects current Git project based on active window title

# Get active window title (most shells put CWD or 'user@host: path' there)
title=$(hyprctl activewindow -j 2>/dev/null | jq -r '.title' 2>/dev/null)
[[ -z "$title" ]] && exit 0

# Try to extract a path from title (common formats like ~/code/project)
path=""
if [[ "$title" == *"/"* ]]; then
    # Pick the part that looks like a path
    path=$(echo "$title" | grep -oE '(/|~)[^ ]+')
fi

# If no path in title, fallback to active window class (e.g. "kitty")
# This is less accurate but better than nothing.
if [[ -z "$path" ]]; then
    class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class' 2>/dev/null)
    [[ "$class" == "kitty" ]] || exit 0
fi

# Try to find git root if we have a path
project=""
if [[ -d "$path" ]]; then
    project=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)
    [[ -n "$project" ]] && project=$(basename "$project")
fi

# If we couldn't find a git root, use the window title's last segment
if [[ -z "$project" ]]; then
    project=$(echo "$title" | awk -F' ' '{print $NF}' | awk -F'/' '{print $NF}')
fi

# Filter out non-project junk
[[ "$project" =~ ^(zsh|bash|nvim|~)$ ]] && project=""

if [[ -n "$project" ]]; then
    echo "{\"text\": \" $project\", \"tooltip\": \"Active Project: $project\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"No active project detected\"}"
fi
