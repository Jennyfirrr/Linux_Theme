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

# dGPU is powered, but on hybrid setups (Steam waking the card via PCI runtime PM)
# nvidia-smi can fail with "couldn't communicate with NVIDIA driver" — and prints
# that error to stdout, not just stderr. Validate exit code AND that the values
# are numeric before trusting them.
output=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
util=""
temp=""
if (( $? == 0 )); then
    read -r util temp < <(printf '%s\n' "$output" | head -1 | tr -d ' ' | tr ',' ' ')
fi

if [[ "$util" =~ ^[0-9]+$ && "$temp" =~ ^[0-9]+$ ]]; then
    printf '{"text":"%s %s%% %s°"}\n' "$LABEL" "$util" "$temp"
else
    printf '{"text":"%s on","class":"idle"}\n' "$LABEL"
fi
