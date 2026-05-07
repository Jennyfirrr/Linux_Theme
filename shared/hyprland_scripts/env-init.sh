#!/bin/bash
eval $(dbus-launch)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Cursor — set early so Hyprland and XWayland pick it up.
# install_catppuccin_cursor() drops the theme into ~/.local/share/icons,
# which isn't in the default XCURSOR_PATH. XCURSOR_SIZE is set per-monitor
# by start_waybar.sh after Hyprland is up; pre-launch fallback is 24
# (1080p default — gets corrected on the first apply-scale pass).
export XCURSOR_SIZE=24
export XCURSOR_THEME=catppuccin-mocha-peach-cursors
export XCURSOR_PATH="$HOME/.local/share/icons:$HOME/.icons:/usr/share/icons:/usr/share/pixmaps"

