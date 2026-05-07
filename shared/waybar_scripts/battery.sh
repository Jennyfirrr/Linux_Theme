#!/bin/bash
# Waybar composite battery — capacity + status as text, current volume
# and screen brightness as tooltip. Replaces the standalone battery,
# pulseaudio, and backlight modules in one bubble.

# ── Battery ───────────────────────────────────────────────────────
bat=""
for p in /sys/class/power_supply/BAT0 /sys/class/power_supply/BAT1; do
    [[ -d "$p" ]] && { bat="$p"; break; }
done
if [[ -z "$bat" ]]; then
    echo '{"text":""}'
    exit 0
fi

cap=$(cat "$bat/capacity" 2>/dev/null || echo 0)
status=$(cat "$bat/status" 2>/dev/null || echo Unknown)

# Discharge icons step every 20% so all six icons get used
icon="󰁹"
case "$status" in
    Charging|Full) icon="󰂅" ;;
    Discharging|Not\ charging)
        if   (( cap >= 90 )); then icon="󰁹"
        elif (( cap >= 70 )); then icon="󰂀"
        elif (( cap >= 50 )); then icon="󰁾"
        elif (( cap >= 30 )); then icon="󰁼"
        elif (( cap >= 10 )); then icon="󰁺"
        else                       icon="󰂃"
        fi
        ;;
esac

text="$icon $cap%"

# ── Volume ────────────────────────────────────────────────────────
vol="?"
if command -v pactl >/dev/null 2>&1; then
    vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null \
            | grep -oE '[0-9]+%' | head -1)
    [[ -z "$vol" ]] && vol="?"
fi

# ── Brightness ────────────────────────────────────────────────────
bright="?"
if command -v brightnessctl >/dev/null 2>&1; then
    cur=$(brightnessctl g 2>/dev/null)
    max=$(brightnessctl m 2>/dev/null)
    if [[ "$cur" =~ ^[0-9]+$ && "$max" =~ ^[0-9]+$ ]] && (( max > 0 )); then
        bright="$(( cur * 100 / max ))%"
    fi
fi

tooltip="Battery: ${cap}% (${status})\\n  Volume: ${vol}\\n  Brightness: ${bright}"

# Emit a class so the CSS can re-apply the old battery state colors
# (charging=peach, warning=yellow, critical=red). Waybar reserves the
# 'class' field on JSON-mode custom modules for exactly this. Field is
# only included when there's a state — empty class strings tickle a
# selector edge case in GTK's CSS parser.
class=""
case "$status" in
    Charging|Full) class="charging" ;;
    *)
        if   (( cap < 10 )); then class="critical"
        elif (( cap < 25 )); then class="warning"
        fi
        ;;
esac

if [[ -n "$class" ]]; then
    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
else
    printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
fi
