#!/bin/bash
# Waybar GPU module — NVIDIA, Optimus-aware.
# Skips nvidia-smi when the dGPU is runtime-suspended so polling
# doesn't keep it awake and burn battery.

LABEL='GPU'

gpu_path=""
for dev in /sys/bus/pci/devices/*/; do
    [[ "$(cat "$dev/vendor" 2>/dev/null)" == "0x10de" ]] || continue
    [[ "$(cat "$dev/class" 2>/dev/null)" == 0x03* ]] || continue
    gpu_path="$dev"
    break
done

if [[ -z "$gpu_path" ]] || ! command -v nvidia-smi >/dev/null 2>&1; then
    echo '{"text":""}'
    exit 0
fi

state=$(cat "${gpu_path}power/runtime_status" 2>/dev/null || echo unknown)
if [[ "$state" != "active" ]]; then
    printf '{"text":"%s idle","class":"idle"}\n' "$LABEL"
    exit 0
fi

read -r util temp < <(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ' | tr ',' ' ')
if [[ -n "$util" && -n "$temp" ]]; then
    printf '{"text":"%s %s%% %s°"}\n' "$LABEL" "$util" "$temp"
else
    printf '{"text":"%s %s%%"}\n' "$LABEL" "${util:-—}"
fi
