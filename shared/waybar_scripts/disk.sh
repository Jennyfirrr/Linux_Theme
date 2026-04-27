#!/bin/bash
# Waybar DISK module — used/total of /, in whole GB.

read -r used_kb total_kb <<<"$(df -P / | awk 'NR==2 {print $3, $2}')"
used_gb=$(( used_kb / 1024 / 1024 ))
total_gb=$(( total_kb / 1024 / 1024 ))

if (( total_kb > 0 )); then
    pct=$(( 100 * used_kb / total_kb ))
else
    pct=0
fi

cls=""
if (( pct >= 95 )); then cls=',"class":"critical"'
elif (( pct >= 80 )); then cls=',"class":"warning"'
fi

printf '{"text":"DISK %sg/%sg","tooltip":"%s%% of /"%s}\n' "$used_gb" "$total_gb" "$pct" "$cls"
