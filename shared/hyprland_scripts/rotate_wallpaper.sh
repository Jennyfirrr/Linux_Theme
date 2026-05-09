#!/usr/bin/env bash
# Apply the wallpaper for the current time-of-day slot via awww.
#
# Slots:
#   05–10  dawn    → foxml_misty_dawn.jpg
#   10–18  midday  → foxml_earthy.jpg
#   18–22  sunset  → foxml_sunrise_sunbeams.jpg
#   22–05  night   → foxml_night_woods.jpg
#
# Default invocation is idempotent — exits without fading or notifying if the
# slot's wallpaper is already active. Safe to fire from a frequent timer.
#
# `--cycle` (used by the ALT+W keybind) advances one slot from whatever is
# currently shown, regardless of the clock — gives "next mood now" semantics
# for the manual keybind. The next timer fire snaps back to the calendar slot.
set -euo pipefail

WALL_DIR="${HOME}/.wallpapers"
MODE="${1:-bucket}"

# Slot definitions: start-hour, label, filename. Keep ordered by start-hour.
slots=(
    "05 dawn   foxml_misty_dawn.jpg"
    "10 midday foxml_earthy.jpg"
    "18 sunset foxml_sunrise_sunbeams.jpg"
    "22 night  foxml_night_woods.jpg"
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

# Find the slot whose filename matches the .current symlink target.
# Returns -1 if .current is missing or points at something not in the table.
slot_index_of_current() {
    local cur_link="" i fname
    [[ -L "$WALL_DIR/.current" ]] && cur_link="$(readlink "$WALL_DIR/.current")"
    [[ -z "$cur_link" ]] && { echo -1; return; }
    for i in "${!slots[@]}"; do
        read -r _ _ fname <<<"${slots[$i]}"
        [[ "$fname" == "$cur_link" ]] && { echo "$i"; return; }
    done
    echo -1
}

case "$MODE" in
    --cycle)
        idx=$(slot_index_of_current)
        # If .current isn't in the slot table, anchor cycle on the calendar
        # slot so the first ALT+W press always moves somewhere predictable.
        (( idx == -1 )) && idx=$(calendar_slot_index)
        target_idx=$(( (idx + 1) % ${#slots[@]} ))
        ;;
    bucket|"")
        target_idx=$(calendar_slot_index)
        ;;
    *)
        echo "usage: $0 [--cycle]" >&2
        exit 2
        ;;
esac

read -r _ _ filename <<<"${slots[$target_idx]}"
pick="${WALL_DIR}/${filename}"
[[ ! -f "$pick" ]] && { echo "missing $pick" >&2; exit 1; }

# Idempotency: skip the fade + notify if we'd be applying what's already up,
# unless --cycle was passed (cycle should always change the image).
if [[ "$MODE" != "--cycle" ]]; then
    current_target=""
    [[ -L "$WALL_DIR/.current" ]] && current_target="$(readlink "$WALL_DIR/.current")"
    [[ "$current_target" == "$filename" ]] && exit 0
fi

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

# Per-monitor wallpaper. If hyprctl is available, iterate each connected
# monitor and apply with -o. For rotated outputs (transform 1/3) prefer a
# pre-rendered portrait variant ({name}_portrait.{ext}) — install.sh's
# configure_monitors() generates these via imagemagick. Falls back to
# --resize crop on the landscape source if no portrait variant exists.
applied_per_monitor=false
if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    monitors_json=$(hyprctl monitors -j 2>/dev/null || true)
    if [[ -n "$monitors_json" && "$monitors_json" != "[]" ]]; then
        applied_per_monitor=true
        pick_ext="${pick##*.}"
        pick_base="${pick%.*}"
        portrait_pick="${pick_base}_portrait.${pick_ext}"
        while IFS=$'\t' read -r name transform; do
            [[ -z "$name" ]] && continue
            mon_pick="$pick"
            # Landscape default: crop (scale-to-fill, trim overflow). Avoids
            # black bars on monitors whose aspect doesn't match the source —
            # wallpaper subjects are centered, so trimming is invisible.
            resize="crop"
            if [[ "$transform" == "1" || "$transform" == "3" ]]; then
                if [[ -f "$portrait_pick" ]]; then
                    # Portrait variant is pre-cropped to the rotated logical
                    # size — fit gives a 1:1 match with no scaling.
                    mon_pick="$portrait_pick"
                    resize="fit"
                fi
            fi
            awww img -o "$name" "$mon_pick" \
                --resize "$resize" \
                --transition-type fade \
                --transition-duration 1 \
                --transition-fps 60 || true
        done < <(echo "$monitors_json" | jq -r '.[] | "\(.name)\t\(.transform)"')
    fi
fi

if ! $applied_per_monitor; then
    awww img "$pick" \
        --transition-type fade \
        --transition-duration 1 \
        --transition-fps 60
fi

echo "rotated to $filename"
command -v notify-send &>/dev/null && \
    notify-send -t 3000 -i "$pick" "Wallpaper" "${filename%.*}" || true
