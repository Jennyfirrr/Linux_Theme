#!/bin/bash
# Waybar System Health module
# Only appears when resources are heavily used

# Thresholds
CPU_THRESHOLD=80
RAM_THRESHOLD=85
TEMP_THRESHOLD=80

# Get CPU Usage
cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
cpu_int=${cpu_usage%.*}

# Get RAM Usage
ram_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
ram_int=${ram_usage%.*}

# Get Max Temp (requires lm_sensors)
temp_int=0
if command -v sensors >/dev/null 2>&1; then
    temp_int=$(sensors | grep 'Core 0' | awk '{print $3}' | tr -d '+°C' | cut -d. -f1)
fi

# Build warnings
warnings=()
[[ $cpu_int -gt $CPU_THRESHOLD ]] && warnings+=("CPU: ${cpu_int}%")
[[ $ram_int -gt $RAM_THRESHOLD ]] && warnings+=("RAM: ${ram_int}%")
[[ $temp_int -gt $TEMP_THRESHOLD ]] && warnings+=("Temp: ${temp_int}°C")

if [[ ${#warnings[@]} -gt 0 ]]; then
    text="  HEALTH"
    tooltip="System Stress Detected:\\n"
    for w in "${warnings[@]}"; do
        tooltip+="  • $w\\n"
    done
    echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"critical\"}"
else
    echo ""
fi
