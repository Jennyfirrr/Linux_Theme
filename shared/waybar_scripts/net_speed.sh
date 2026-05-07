#!/bin/bash
# Network speed HUD for Waybar
# Monitors throughput for HFT DataStream awareness

INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
[[ -z "$INTERFACE" ]] && exit 0

# Get initial bytes
read -r RX1 TX1 < <(grep "$INTERFACE" /proc/net/dev | awk '{print $2, $10}')
sleep 1
# Get bytes after 1s
read -r RX2 TX2 < <(grep "$INTERFACE" /proc/net/dev | awk '{print $2, $10}')

# Calculate speed in KB/s
RX_SPEED=$(( (RX2 - RX1) / 1024 ))
TX_SPEED=$(( (TX2 - TX1) / 1024 ))

# Formatter helper — pure bash, avoids a `bc` runtime dep
format_speed() {
    local speed=$1
    if (( speed > 1024 )); then
        # one decimal place via integer math: 12345 KB → 12.0 MB
        printf "%d.%d MB/s" $(( speed / 1024 )) $(( (speed * 10 / 1024) % 10 ))
    else
        echo "${speed} KB/s"
    fi
}

RX_F=$(format_speed $RX_SPEED)
TX_F=$(format_speed $TX_SPEED)

echo "{\"text\": \"󰇚 $RX_F  󰕒 $TX_F\", \"tooltip\": \"Interface: $INTERFACE\"}"
