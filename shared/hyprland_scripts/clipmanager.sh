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
    # Image mode — uses a custom theme with large previews if possible
    # Note: cliphist stores images as encoded binary; this list shows the metadata
    selected=$(cliphist list | grep -iE "\[\[ binary data .* (png|jpg|jpeg|webp) .* \]\]" | \
        rofi -dmenu -p " Images" -i -theme-str "$ROFI_POS_THEME window {width: 40%;} listview {lines: 10;}")
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
