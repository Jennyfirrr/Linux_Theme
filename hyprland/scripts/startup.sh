#!/bin/bash

# Start UI services (hypridle started via exec-once in autostart.conf)
waybar &

# Set wallpaper with a small delay
sleep 1
#swww img ~/.wallpapers/fox.png --transition-type simple &

# Wait a bit then switch to workspace 1
sleep 2
hyprctl dispatch workspace 1 &
