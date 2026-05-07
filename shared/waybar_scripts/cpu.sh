#!/bin/bash
# Waybar CPU module — usage % (1s sample) + package temp via coretemp.
# Resolved by hwmon "name", so it survives hwmonN renumbering across boots.

read_cpu() {
    local _cpu user nice system idle iowait irq softirq steal _rest
    read -r _cpu user nice system idle iowait irq softirq steal _rest < /proc/stat
    local total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    local used=$((total - idle - iowait))
    echo "$used $total"
}

read -r u1 t1 < <(read_cpu)
sleep 1
read -r u2 t2 < <(read_cpu)

dt=$((t2 - t1))
if (( dt > 0 )); then
    usage=$(( 100 * (u2 - u1) / dt ))
else
    usage=0
fi

temp=""
for d in /sys/class/hwmon/hwmon*/; do
    [[ "$(cat "$d/name" 2>/dev/null)" == "coretemp" ]] || continue
    raw=$(cat "$d/temp1_input" 2>/dev/null)
    [[ -n "$raw" ]] && temp=$(( raw / 1000 ))
    break
done

# Gather GPU stats for tooltip
gpu_util=""
gpu_temp=""
if command -v nvidia-smi >/dev/null 2>&1; then
    output=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
    if (( $? == 0 )); then
        read -r gpu_util gpu_temp < <(printf '%s\n' "$output" | head -1 | tr -d ' ' | tr ',' ' ')
    fi
fi

cls=""
if (( usage >= 90 )); then cls=',"class":"critical"'
elif (( usage >= 70 )); then cls=',"class":"warning"'
fi

# Build tooltip string
tooltip="CPU: ${usage}% ${temp}°C"
if [[ -n "$gpu_util" ]]; then
    tooltip+="\nGPU: ${gpu_util}% ${gpu_temp}°C"
fi

if [[ -n "$temp" ]]; then
    printf '{"text":"CPU %s%% %s°","tooltip":"%s"%s}\n' "$usage" "$temp" "$tooltip" "$cls"
else
    printf '{"text":"CPU %s%%","tooltip":"%s"%s}\n' "$usage" "$tooltip" "$cls"
fi
