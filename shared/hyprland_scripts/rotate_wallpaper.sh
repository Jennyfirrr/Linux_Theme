#!/usr/bin/env bash
# Apply the wallpaper for the current time-of-day slot via awww.
#
# Slots:
#   05–10  dawn    → foxml_misty_dawn.jpg
#   10–18  midday  → foxml_earthy.jpg
#   18–22  sunset  → foxml_sunrise_sunbeams.jpg
#   22–05  night   → random pick from {foxml_night_dim_woods.jpg, foxml_night_ruins.jpg}
#
# A slot may list multiple comma-separated filenames; one is chosen at random
# on transition. Once a slot's pick is in .current, bucket-mode invocations
# stay idempotent (no re-roll on every timer fire), so randomness only fires
# when crossing a slot boundary.
#
# `--cycle` (used by the ALT+W keybind) rotates *within* the current calendar
# slot's filename list — pressing it during the night slot toggles between
# the night wallpapers; pressing it during a single-entry slot is a quiet
# no-op. It does not advance to a different time-of-day slot.
set -euo pipefail

WALL_DIR="${HOME}/.wallpapers"
MODE="${1:-bucket}"

# Slot definitions: start-hour, label, comma-separated filename(s). Keep
# ordered by start-hour. Multiple filenames = random pick on slot entry.
slots=(
    "05 dawn   foxml_misty_dawn.jpg"
    "10 midday foxml_earthy.jpg"
    "18 sunset foxml_sunrise_sunbeams.jpg"
    "22 night  foxml_night_dim_woods.jpg,foxml_night_ruins.jpg"
)

# Map current hour → slot index. Hours before the first start (00–04) fall
# through to the last slot (night, which spans midnight).
calendar_slot_index() {
    local hour idx=$(( ${#slots[@]} - 1 ))
    hour=$((10#$(date +%H)))
    for i in "${!slots[@]}"; do
        read -r start _ _ <<<"${slots[$i]}"
        (( hour >= 10#$start )) && idx=$i
    done
    echo "$idx"
}

# Return the comma-separated filename field of slot $1 as a bash array
# assigned to the caller-named variable $2. Uses a nameref so the write
# lands in the caller's scope; do NOT declare a local of the same name.
slot_filenames() {
    local __idx="$1"
    local -n __out="$2"
    local __raw
    read -r _ _ __raw <<<"${slots[$__idx]}"
    IFS=',' read -r -a __out <<<"$__raw"
}

case "$MODE" in
    --cycle|bucket|"") target_idx=$(calendar_slot_index) ;;
    *) echo "usage: $0 [--cycle]" >&2; exit 2 ;;
esac

slot_filenames "$target_idx" target_files
current_target=""
[[ -L "$WALL_DIR/.current" ]] && current_target="$(readlink "$WALL_DIR/.current")"

# Find current's index in the slot's list (-1 if not present).
cur_in_slot=-1
for i in "${!target_files[@]}"; do
    [[ "${target_files[$i]}" == "$current_target" ]] && { cur_in_slot=$i; break; }
done

if [[ "$MODE" == "--cycle" ]]; then
    # Rotate within the slot. Single-entry slot with .current already on it
    # → quiet no-op. Otherwise advance to the next entry (wraps around).
    if (( cur_in_slot >= 0 )); then
        (( ${#target_files[@]} == 1 )) && exit 0
        next_idx=$(( (cur_in_slot + 1) % ${#target_files[@]} ))
        filename="${target_files[$next_idx]}"
    else
        filename="${target_files[RANDOM % ${#target_files[@]}]}"
    fi
else
    # Bucket: idempotent if .current is anywhere in this slot's list,
    # so the timer doesn't re-roll on every fire. Otherwise random pick.
    (( cur_in_slot >= 0 )) && exit 0
    filename="${target_files[RANDOM % ${#target_files[@]}]}"
fi
pick="${WALL_DIR}/${filename}"
[[ ! -f "$pick" ]] && { echo "missing $pick" >&2; exit 1; }

ln -sfn "$filename" "$WALL_DIR/.current"

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

echo "rotated to $filename"
command -v notify-send &>/dev/null && \
    notify-send -t 3000 -i "$pick" "Wallpaper" "${filename%.*}" || true
