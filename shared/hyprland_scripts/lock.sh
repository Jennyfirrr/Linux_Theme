#!/bin/bash

# Lock launcher — prefers fox-lock (pre-check wrapper) over bare hyprlock.
# fox-lock catches wedge precursors (dbus unreachable, awww dead, hyprlock
# already running) before locking, so the lock screen doesn't hang.
# Falls through to direct hyprlock, then swaylock, if either is missing.
# The theme is handled via ~/.config/hypr/hyprlock.conf (templated).

if command -v fox-lock &>/dev/null; then
    fox-lock
elif command -v hyprlock &>/dev/null; then
    hyprlock
else
    swaylock -c 1a1214
fi
