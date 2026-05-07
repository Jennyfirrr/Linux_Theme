#!/usr/bin/env bash
# Hyprland Border Telemetry — Earthy edition
# Changes border colors based on system state while maintaining the FoxML vibe.

# Source the rendered palette
PALETTE="${HOME}/.config/hypr/modules/border_colors.sh"
[[ -f "$PALETTE" ]] || exit 1
source "$PALETTE"

# Thresholds
CPU_HIGH=80
BAT_LOW=20

last_state=""

get_cpu() {
    # Returns CPU usage as integer
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' | cut -d. -f1
}

get_bat_info() {
    # Returns "status percentage" e.g. "Charging 85"
    if command -v upower &>/dev/null; then
        local bat
        bat=$(upower -e | grep battery | head -1)
        if [[ -n "$bat" ]]; then
            upower -i "$bat" | awk '/state|percentage/ {print $2}' | tr -d '%' | xargs
            return
        fi
    fi
    # Fallback to sysfs
    if [[ -d /sys/class/power_supply/BAT0 ]]; then
        local status cap
        status=$(cat /sys/class/power_supply/BAT0/status)
        cap=$(cat /sys/class/power_supply/BAT0/capacity)
        echo "$status $cap"
    else
        echo "Full 100"
    fi
}

update_border() {
    local color1="$1"
    local color2="$2"
    local state_key="${color1}-${color2}"

    if [[ "$last_state" != "$state_key" ]]; then
        hyprctl keyword general:col.active_border "rgba(${color1}ff) rgba(${color2}ff) 45deg" > /dev/null
        last_state="$state_key"
    fi
}

while true; do
    cpu=$(get_cpu)
    read -r bat_status bat_cap <<< "$(get_bat_info)"

    # Priority 1: High CPU (Warning/Stress)
    if (( cpu > CPU_HIGH )); then
        update_border "$C_WARN" "$C_RED"
    
    # Priority 2: Charging (Growth/Success)
    elif [[ "$bat_status" == "Charging" || "$bat_status" == "Full" ]]; then
        update_border "$C_OK" "$C_PRIMARY"

    # Priority 3: Low Battery (Urgent/Dimming)
    elif (( bat_cap < BAT_LOW )); then
        update_border "$C_RED" "$C_BG_ALT"

    # Default: Normal (Earthy/Productive)
    else
        update_border "$C_PRIMARY" "$C_YELLOW_BRIGHT"
    fi

    sleep 5
done
