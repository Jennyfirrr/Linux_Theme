#!/bin/bash

# Simple wrapper to launch hyprlock
# The theme is handled via ~/.config/hypr/hyprlock.conf (templated)

if command -v hyprlock &>/dev/null; then
    hyprlock
else
    # Fallback to swaylock if hyprlock is missing
    swaylock -c 1a1214
fi
