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
        # Fallback: parse text output. `Monitor … 3840x2160@…, scale: 2.0`
        local w s
        w=$(printf '%s' "$out" | awk '/^\s*[0-9]+x[0-9]+@/ { split($1,a,"x"); print a[1]; exit }')
        s=$(printf '%s' "$out" | awk -F': ' '/scale:/ { print $2; exit }')
        [[ -z "$w" ]] && { echo 1920; return; }
        [[ -z "$s" ]] && s=1
        local s100
        s100=$(awk -v s="$s" 'BEGIN{ printf "%d", s*100 }')
        (( s100 < 1 )) && s100=100
        echo $(( w * 100 / s100 ))
    fi
}

EW=$(effective_width)

# Pick a profile. Each profile defines the size tokens used by both the CSS
# and the JSON config — keep token names in sync with templates/waybar/style.css
# and shared/waybar_config.
if   (( EW <= 1920 )); then
    PROFILE="1080p"
    FONT_BASE="9.5"; FONT_LOGO="11";   FONT_STATS="8.5"
    PAD_WIN="3px 8px"; PAD_MOD="2px 10px"; MARGIN_MOD="1px 4px"
    HEIGHT="32"; MARGIN_BAR="6 6 0 6"; TRAY_ICON="14"
    CURSOR_SIZE="24"
elif (( EW <= 2560 )); then
    PROFILE="1440p"
    FONT_BASE="11";  FONT_LOGO="13";   FONT_STATS="10"
    PAD_WIN="4px 9px"; PAD_MOD="3px 12px"; MARGIN_MOD="2px 5px"
    HEIGHT="40"; MARGIN_BAR="8 8 0 8"; TRAY_ICON="15"
    CURSOR_SIZE="28"
else
    PROFILE="4K"
    FONT_BASE="12.5"; FONT_LOGO="14";  FONT_STATS="11"
    PAD_WIN="4px 10px"; PAD_MOD="4px 14px"; MARGIN_MOD="2px 6px"
    HEIGHT="52"; MARGIN_BAR="12 12 0 12"; TRAY_ICON="16"
    CURSOR_SIZE="32"
fi

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

# Apply cursor size to the running session AND set XCURSOR_SIZE for new
# children Hyprland spawns. Skip silently if hyprctl can't reach the IPC
# socket (we're being called pre-Hyprland from install.sh).
if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" || -d "${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr" ]]; then
    hyprctl setcursor "${XCURSOR_THEME:-catppuccin-mocha-peach-cursors}" "$CURSOR_SIZE" >/dev/null 2>&1 || true
    hyprctl setenv XCURSOR_SIZE "$CURSOR_SIZE" >/dev/null 2>&1 || true
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
