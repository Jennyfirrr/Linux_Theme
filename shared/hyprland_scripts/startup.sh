#!/bin/bash

# Start UI services (hypridle started via exec-once in autostart.conf).
# start_waybar.sh detects monitor scale + sed-substitutes size tokens into
# the live waybar style.css/config, then execs waybar.
~/.config/hypr/scripts/start_waybar.sh &

# Eww daemon — disabled. The Eww control center turned out to need significant
# work (no native hjkl, GTK keyboard nav only, manual close button quirks) to
# match the existing rofi syshub. Templates and scripts are still in the repo
# under templates/eww/ and shared/hyprland_scripts/eww_action.sh so this can be
# revisited; just remove the leading `#` to re-enable the daemon at startup.
# eww daemon &

# Border telemetry (dynamic earthy borders based on system state)
~/.config/hypr/scripts/border_telemetry.sh &

# Update checker
~/.config/hypr/scripts/update_check.sh &

# Set wallpaper with a small delay
sleep 1
#swww img ~/.wallpapers/fox.png --transition-type simple &

# Wait a bit then switch to workspace 1
sleep 2
hyprctl dispatch workspace 1 &
