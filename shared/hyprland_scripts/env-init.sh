#!/bin/bash
eval $(dbus-launch)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Cursor — set early so Hyprland and XWayland pick it up
export XCURSOR_SIZE=30
export XCURSOR_THEME=catppuccin-mocha-peach-cursors

