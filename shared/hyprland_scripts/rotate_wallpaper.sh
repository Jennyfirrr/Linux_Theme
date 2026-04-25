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

# Drop the currently-active wallpaper from the pool so consecutive rotations
# always change. .current is a relative symlink; resolve it before comparing.
current=""
[[ -L "$WALL_DIR/.current" ]] && current="$WALL_DIR/$(readlink "$WALL_DIR/.current")"
if (( ${#pool[@]} > 1 )) && [[ -n "$current" ]]; then
    filtered=()
    for p in "${pool[@]}"; do [[ "$p" != "$current" ]] && filtered+=("$p"); done
    pool=("${filtered[@]}")
fi

pick="${pool[RANDOM % ${#pool[@]}]}"

# Update the stable symlink so anything else (hyprlock, etc.) follows.
ln -sfn "$(basename "$pick")" "$WALL_DIR/.current"

# Rewrite hyprlock's wallpaper path. hyprlock's image loader dispatches on
# file extension, so it can't load the .current symlink directly — point it
# at the real file and it'll pick this up next time it launches.
hyprlock_conf="${HOME}/.config/hypr/hyprlock.conf"
[[ -f "$hyprlock_conf" ]] && \
    sed -i -E "s|^(\s*path\s*=\s*).*|\1${pick}|" "$hyprlock_conf"

# Try IPC first; fall back to restarting hyprpaper if the IPC route fails.
if hyprctl hyprpaper preload "$pick" 2>/dev/null \
   && hyprctl hyprpaper wallpaper "${MONITOR},${pick}" 2>/dev/null; then
    method=IPC
else
    sed -i -E "s|^(\s*path\s*=\s*).*|\1${pick}|" "${HOME}/.config/hypr/hyprpaper.conf"
    pkill -x hyprpaper 2>/dev/null || true
    sleep 0.3
    setsid hyprpaper >/dev/null 2>&1 < /dev/null &
    disown
    method=restart
fi

echo "rotated to $(basename "$pick") via $method"
command -v notify-send &>/dev/null && \
    notify-send -t 3000 -i "$pick" "Wallpaper" "$(basename "${pick%.*}")" || true
