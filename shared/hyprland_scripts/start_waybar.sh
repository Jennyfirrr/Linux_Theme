#!/usr/bin/env bash
# start_waybar.sh — apply monitor-scale-dependent settings, then launch waybar.
#
# Renders waybar style.css + config from .tmpl files (size-token substitution)
# AND sets cursor size to match — a 1080p panel and a 4K panel need very
# different waybar font sizes and cursor sizes.
#
# Profiles (effective width = pixels / monitor scale):
#   ≤ 1920  → 1080p   font 9.5pt,  bar 32, cursor 24
#   ≤ 2560  → 1440p   font 11pt,   bar 40, cursor 28
#   else    → 4K      font 12.5pt, bar 52, cursor 32
#
# Re-runnable: rerunning regenerates from the .tmpl files, so changing a
# theme via swap.sh + reloading Hyprland picks up new colors AND scales
# correctly to the current monitor.

set -euo pipefail

WAYBAR_DIR="${HOME}/.config/waybar"
STYLE_TMPL="${WAYBAR_DIR}/style.css.tmpl"
CONFIG_TMPL="${WAYBAR_DIR}/config.tmpl"
STYLE_OUT="${WAYBAR_DIR}/style.css"
CONFIG_OUT="${WAYBAR_DIR}/config"

# Effective width of the primary (first listed) monitor.
# `width / scale` is what waybar/Hyprland actually lay out against — a 4K
# panel at scale 2.0 should be treated as 1080p for sizing.
effective_width() {
    if ! command -v hyprctl >/dev/null 2>&1; then
        echo 1920; return
    fi
    local out
    out=$(hyprctl monitors -j 2>/dev/null) || { echo 1920; return; }
    if command -v jq >/dev/null 2>&1; then
        local w s
        w=$(printf '%s' "$out" | jq -r '.[0].width // 1920')
        s=$(printf '%s' "$out" | jq -r '.[0].scale // 1')
        # bash arithmetic doesn't do floats — multiply scale by 100, divide.
        local s100
        s100=$(awk -v s="$s" 'BEGIN{ printf "%d", s*100 }')
        (( s100 < 1 )) && s100=100
        echo $(( w * 100 / s100 ))
    else
        echo 1920
    fi
}

# Fetch gaps_out from Hyprland to align bar perfectly with windows.
# Default to 12 if not found or if hyprctl fails.
get_gaps() {
    if ! command -v hyprctl >/dev/null 2>&1; then
        echo 12; return
    fi
    local gaps
    gaps=$(hyprctl getoption general:gaps_out -j 2>/dev/null | jq -r '.custom' | awk '{print $1}')
    if [[ -z "$gaps" || "$gaps" == "null" ]]; then
        echo 12
    else
        echo "$gaps"
    fi
}

EW=$(effective_width)
GAPS=$(get_gaps)

# Pick a profile. Each profile defines the size tokens used by both the CSS
# and the JSON config — keep token names in sync with templates/waybar/style.css
# and shared/waybar_config.
if   (( EW <= 1920 )); then
    PROFILE="1080p"
    FONT_BASE="10"; FONT_LOGO="12";   FONT_STATS="9"
    PAD_WIN="3px 8px"; PAD_MOD="2px 10px"; MARGIN_MOD="1px 4px"
    HEIGHT="34"; TRAY_ICON="14"
    CURSOR_SIZE="24"
elif (( EW <= 2560 )); then
    PROFILE="1440p"
    FONT_BASE="11.5";  FONT_LOGO="14";   FONT_STATS="10.5"
    PAD_WIN="4px 9px"; PAD_MOD="3px 12px"; MARGIN_MOD="2px 5px"
    HEIGHT="42"; TRAY_ICON="15"
    CURSOR_SIZE="28"
else
    PROFILE="4K"
    FONT_BASE="13"; FONT_LOGO="16";  FONT_STATS="12"
    PAD_WIN="4px 10px"; PAD_MOD="4px 14px"; MARGIN_MOD="2px 6px"
    HEIGHT="56"; TRAY_ICON="16"
    CURSOR_SIZE="32"
fi

# Construct margin string: {gaps} {gaps} 0 {gaps}
# Subtract the 4px border width from the gap value so the outer edges 
# of the bar and the windows line up perfectly.
ALIGNED_MARGIN=$(( GAPS - 4 ))
(( ALIGNED_MARGIN < 0 )) && ALIGNED_MARGIN=0

MARGIN_BAR="${ALIGNED_MARGIN} ${GAPS} 0 ${GAPS}"

# If the .tmpl files don't exist yet (e.g. someone ran an older install.sh),
# fall back to whatever's currently in style.css/config — better to start an
# untouched bar than to fail silently.
[[ -f "$STYLE_TMPL"  ]] || cp -f "$STYLE_OUT"  "$STYLE_TMPL"  2>/dev/null || true
[[ -f "$CONFIG_TMPL" ]] || cp -f "$CONFIG_OUT" "$CONFIG_TMPL" 2>/dev/null || true

# Substitute. Use a sed delimiter that won't appear in any value — pipe is
# safe for these size strings (px, pt, plain ints, space-separated quads).
substitute() {
    local in="$1" out="$2"
    sed \
        -e "s|__FONT_BASE__|${FONT_BASE}|g" \
        -e "s|__FONT_LOGO__|${FONT_LOGO}|g" \
        -e "s|__FONT_STATS__|${FONT_STATS}|g" \
        -e "s|__PAD_WIN__|${PAD_WIN}|g" \
        -e "s|__PAD_MOD__|${PAD_MOD}|g" \
        -e "s|__MARGIN_MOD__|${MARGIN_MOD}|g" \
        -e "s|__HEIGHT__|${HEIGHT}|g" \
        -e "s|__MARGIN_BAR__|${MARGIN_BAR}|g" \
        -e "s|__TRAY_ICON__|${TRAY_ICON}|g" \
        "$in" > "$out"
}

[[ -f "$STYLE_TMPL"  ]] && substitute "$STYLE_TMPL"  "$STYLE_OUT"
[[ -f "$CONFIG_TMPL" ]] && substitute "$CONFIG_TMPL" "$CONFIG_OUT"

# Calculate Rofi offsets for the launcher-integrated look.
# Y: bottom of the bar (top margin + height).
# X: left edge of the launcher box (gaps + module margin).
# We set these as env vars so scripts and keybinds can use them.
# We subtract 1 from Y to overlap the borders and make it look like one unit.
ROFI_Y=$(( ALIGNED_MARGIN + HEIGHT - 1 ))
# Extract the horizontal margin from MARGIN_MOD (e.g., "1px 4px" -> 4)
MOD_X_MARGIN=$(echo "$MARGIN_MOD" | awk '{print $NF}' | tr -dc '0-9')
ROFI_X=$(( GAPS + MOD_X_MARGIN ))

# Apply cursor size to the running session AND set XCURSOR_SIZE for new
# children Hyprland spawns. Skip silently if hyprctl can't reach the IPC
# socket (we're being called pre-Hyprland from install.sh).
if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" || -d "${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr" ]]; then
    hyprctl setcursor "${XCURSOR_THEME:-catppuccin-mocha-peach-cursors}" "$CURSOR_SIZE" >/dev/null 2>&1 || true
    hyprctl setenv XCURSOR_SIZE "$CURSOR_SIZE" >/dev/null 2>&1 || true
    hyprctl setenv ROFI_X "$ROFI_X" >/dev/null 2>&1 || true
    hyprctl setenv ROFI_Y "$ROFI_Y" >/dev/null 2>&1 || true
fi

# `--render-only`: install.sh calls us this way after rendering templates,
# so the live style.css/config exist before Hyprland is even running.
if [[ "${1:-}" == "--render-only" ]]; then
    echo "  ✓ waybar rendered for ${PROFILE} (width ${EW}px, cursor ${CURSOR_SIZE}px)"
    exit 0
fi

# Replace any existing waybar so a Hyprland reload picks up new sizes.
pkill -x waybar 2>/dev/null || true
exec waybar
