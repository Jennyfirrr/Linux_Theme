#!/usr/bin/env bash
# Pick a random wallpaper from ~/.wallpapers/ and apply via awww.
# Excludes the .current marker, dotfiles, and other-theme images.
set -euo pipefail

WALL_DIR="${HOME}/.wallpapers"

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

# Make sure awww-daemon is up; spawn detached if not. Wait for the socket
# to become responsive before issuing img — daemon startup is async.
if ! awww query &>/dev/null; then
    setsid awww-daemon >/dev/null 2>&1 < /dev/null &
    disown
    for _ in {1..30}; do
        awww query &>/dev/null && break
        sleep 0.1
    done
fi

awww img "$pick" \
    --transition-type fade \
    --transition-duration 1 \
    --transition-fps 60

echo "rotated to $(basename "$pick")"
command -v notify-send &>/dev/null && \
    notify-send -t 3000 -i "$pick" "Wallpaper" "$(basename "${pick%.*}")" || true
