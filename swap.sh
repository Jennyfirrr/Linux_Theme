#!/bin/bash
# FoxML Theme Hub — Theme Swapper with color previews
# Usage: ./swap.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
ACTIVE_FILE="$SCRIPT_DIR/.active-theme"

ACTIVE_THEME=""
[[ -f "$ACTIVE_FILE" ]] && ACTIVE_THEME="$(cat "$ACTIVE_FILE")"

# ─────────────────────────────────────────
# Discover themes
# ─────────────────────────────────────────
themes=()
for d in "$THEMES_DIR"/*/; do
    [[ -f "$d/palette.sh" && -f "$d/theme.conf" ]] || continue
    themes+=("$(basename "$d")")
done

if [[ ${#themes[@]} -eq 0 ]]; then
    echo "No themes found in $THEMES_DIR"
    exit 1
fi

# ─────────────────────────────────────────
# Render color swatch (truecolor)
# ─────────────────────────────────────────
hex_to_rgb() {
    local hex="$1"
    printf "%d %d %d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

render_swatch() {
    local hex="$1"
    local r g b
    read r g b <<< "$(hex_to_rgb "$hex")"
    printf "\033[48;2;%d;%d;%dm      \033[0m" "$r" "$g" "$b"
}

# ─────────────────────────────────────────
# Display
# ─────────────────────────────────────────
echo ""
echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                    FoxML Theme Swapper                          │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo ""

if [[ -n "$ACTIVE_THEME" ]]; then
    echo "Current theme: $ACTIVE_THEME"
else
    echo "Current theme: (none)"
fi
echo ""

for i in "${!themes[@]}"; do
    name="${themes[$i]}"

    # Load palette
    unset BG FG PRIMARY SECONDARY ACCENT SURFACE PALETTE_LABELS
    source "$THEMES_DIR/$name/palette.sh"

    # Load theme.conf
    local_type=$(grep '^type=' "$THEMES_DIR/$name/theme.conf" | cut -d= -f2)

    # Active indicator
    active_mark=""
    if [[ "$name" == "$ACTIVE_THEME" ]]; then
        active_mark="  ● ACTIVE"
    fi

    printf "[%d] %s (%s)%s\n" "$((i+1))" "$name" "$local_type" "$active_mark"

    # Render swatches
    printf "    "
    render_swatch "$BG"
    printf " "
    render_swatch "$FG"
    printf " "
    render_swatch "$PRIMARY"
    printf " "
    render_swatch "$SECONDARY"
    printf " "
    render_swatch "$ACCENT"
    printf " "
    render_swatch "$SURFACE"
    echo ""

    # Labels
    printf "    "
    for label in "${PALETTE_LABELS[@]}"; do
        printf "%-7s" "$label"
    done
    echo ""
    echo ""
done

# ─────────────────────────────────────────
# Selection
# ─────────────────────────────────────────
read -p "Select theme to install [1-${#themes[@]}] (q to quit): " choice

if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
    echo "Cancelled."
    exit 0
fi

if [[ "$choice" -ge 1 && "$choice" -le ${#themes[@]} ]] 2>/dev/null; then
    selected="${themes[$((choice-1))]}"
    echo ""
    exec "$SCRIPT_DIR/install.sh" "$selected"
else
    echo "Invalid selection."
    exit 1
fi
