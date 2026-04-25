#!/usr/bin/env bash
# Pick a random wallpaper from ~/.wallpapers/ and apply via hyprpaper.
# Excludes the active-theme wallpaper-set marker, dotfiles, and other-theme images.
set -euo pipefail

WALL_DIR="${HOME}/.wallpapers"
ACTIVE_THEME_FILE="${HOME}/Linux_Theme/.active-theme"
MONITOR="${1:-eDP-1}"

shopt -s nullglob nocaseglob
mapfile -t pool < <(
    find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        ! -name ".*" ! -name "cave_data_center*"
)
shopt -u nullglob nocaseglob

(( ${#pool[@]} == 0 )) && { echo "no wallpapers found in $WALL_DIR" >&2; exit 1; }

pick="${pool[RANDOM % ${#pool[@]}]}"

# Try IPC first; fall back to restarting hyprpaper if the IPC route fails.
if hyprctl hyprpaper preload "$pick" 2>/dev/null \
   && hyprctl hyprpaper wallpaper "${MONITOR},${pick}" 2>/dev/null; then
    echo "rotated to $(basename "$pick") via IPC"
else
    sed -i -E "s|^(\s*path\s*=\s*).*|\1${pick}|" "${HOME}/.config/hypr/hyprpaper.conf"
    pkill -x hyprpaper 2>/dev/null || true
    sleep 0.3
    setsid hyprpaper >/dev/null 2>&1 < /dev/null &
    disown
    echo "rotated to $(basename "$pick") via restart"
fi
