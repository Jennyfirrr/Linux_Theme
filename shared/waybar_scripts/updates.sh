#!/bin/bash
# Waybar updates module — count of available pacman updates.
# Hides when 0 to stay quiet. Uses checkupdates (pacman-contrib).

if ! command -v checkupdates >/dev/null 2>&1; then
    echo '{"text":""}'
    exit 0
fi

count=$(checkupdates 2>/dev/null | wc -l)

if (( count > 0 )); then
    list=$(checkupdates 2>/dev/null | head -20)
    [[ $count -gt 20 ]] && list+=$'\n…'
    printf '{"text":"UPD %s","tooltip":"%s pacman updates available\\n\\n%s"}\n' \
        "$count" "$count" "${list//$'\n'/\\n}"
else
    echo '{"text":""}'
fi
