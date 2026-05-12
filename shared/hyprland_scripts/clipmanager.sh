#!/bin/bash
# Refined Earthy Clipboard Manager
# Handles both text and images with a clean Rofi UI

ROFI_ZONE="${ROFI_ZONE:-nw}"
source ~/.config/hypr/scripts/_rofi_zone.sh

# Source palette colors (using the one we just made for borders)
PALETTE="${HOME}/.config/hypr/modules/border_colors.sh"
[[ -f "$PALETTE" ]] && source "$PALETTE"

# Fallbacks if palette missing
C_PRIMARY="${C_PRIMARY:-d4985a}"
C_BG_ALT="${C_BG_ALT:-2d1a2d}"

# Mode: "text" (default) or "image"
MODE=${1:-text}

if [[ "$MODE" == "image" ]]; then
    # Image mode. cliphist stores images as encoded binary, and rofi has
    # no native preview for cliphist's "[[ binary data ... ]]" rows — the
    # user just saw a wall of identical-looking metadata and had to paste
    # blind to find out which thumbnail they were picking.
    #
    # Decode each image entry to a temp file, build an indexed line that
    # carries both the cliphist row id (for decode) and human-meaningful
    # context (size + age), and feed Rofi with -show-icons pointed at the
    # decoded path. Result: real thumbnails next to descriptive labels.
    tmpdir=$(mktemp -d -t foxml-clip-XXXXXX)
    trap 'rm -rf "$tmpdir"' EXIT

    rows=$(cliphist list | grep -iE '\[\[ binary data .* (png|jpg|jpeg|webp) .* \]\]')
    if [[ -z "$rows" ]]; then
        notify-send -t 2000 "Clipboard" "No image entries found"
        exit 0
    fi

    menu=""
    declare -A id_for_label=()
    while IFS= read -r row; do
        id="${row%%$'\t'*}"
        # Decode into the tmpdir for both preview AND label sizing.
        ext="png"
        [[ "$row" =~ jpe?g ]]      && ext="jpg"
        [[ "$row" =~ webp ]]       && ext="webp"
        thumb="$tmpdir/${id}.${ext}"
        cliphist decode "$id" >"$thumb" 2>/dev/null || continue
        size_h=$(du -h "$thumb" 2>/dev/null | awk '{print $1}')
        label="Image #${id} (${size_h:-?})"
        id_for_label["$label"]="$id"
        # rofi -show-icons takes the icon path from a literal "\0icon\x1f<path>"
        # field on each line. Wrapped in printf so the special chars survive.
        menu+="$(printf '%s\0icon\x1f%s\n' "$label" "$thumb")"$'\n'
    done <<<"$rows"

    selected_label=$(printf '%s' "$menu" | rofi -dmenu -p " Images" -i \
        -show-icons \
        -theme-str "$ROFI_POS_THEME window {width: 40%;} listview {lines: 10;}")

    if [[ -n "$selected_label" ]]; then
        sel_id="${id_for_label[$selected_label]}"
        if [[ -n "$sel_id" ]]; then
            cliphist decode "$sel_id" | wl-copy
            notify-send -t 2000 "Copied" "Image #${sel_id} copied to clipboard."
        fi
    fi
    exit 0
else
    # Text mode — clean earthy list
    selected=$(cliphist list | rofi -dmenu -p " Clipboard" -i \
        -kb-row-up "k,Up" \
        -kb-row-down "j,Down" \
        -kb-accept-entry "l,Return" \
        -theme-str "$ROFI_POS_THEME window {width: 50%;} listview {lines: 15;} element {padding: 10px;}")
fi

if [[ -n "$selected" ]]; then
    echo "$selected" | cliphist decode | wl-copy
    notify-send -t 2000 "Copied" "Clipboard content restored to primary buffer."
fi
