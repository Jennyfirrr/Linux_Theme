#!/bin/bash
# D-Bus: prefer the user-session bus that systemd --user already
# provides. eval $(dbus-launch) was previously spawning a SECOND bus
# instance each session, leading to stale daemons and (in theory)
# bus-address interception. The systemd-managed bus lives at
#     $XDG_RUNTIME_DIR/bus
# and is the standard one every modern app uses. Only fall back to
# dbus-launch if that socket doesn't exist (e.g. very old setups
# without systemd --user).
if [[ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus" ]]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus"
elif command -v dbus-launch >/dev/null 2>&1; then
    eval "$(dbus-launch)"
    export DBUS_SESSION_BUS_ADDRESS
    export DBUS_SESSION_BUS_PID
fi

# Cursor — set early so Hyprland and XWayland pick it up.
# install_catppuccin_cursor() drops the theme into ~/.local/share/icons,
# which isn't in the default XCURSOR_PATH. XCURSOR_SIZE is set per-monitor
# by start_waybar.sh after Hyprland is up; pre-launch fallback is 24
# (1080p default — gets corrected on the first apply-scale pass).
export XCURSOR_SIZE=24
export XCURSOR_THEME=catppuccin-mocha-peach-cursors
export XCURSOR_PATH="$HOME/.local/share/icons:$HOME/.icons:/usr/share/icons:/usr/share/pixmaps"

