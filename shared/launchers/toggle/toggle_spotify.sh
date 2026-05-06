#!/bin/bash
CLASS="Spotify"
CMD="spotify"
WORKSPACE="special:music"

echo "[INFO] Toggling $CLASS to $WORKSPACE"

# Check if Spotify window exists
SPOTIFY_EXISTS=$(hyprctl clients -j | jq -e '.[] | select(.class=="'"$CLASS"'")' > /dev/null && echo "true" || echo "false")

if [[ "$SPOTIFY_EXISTS" == "true" ]]; then
    echo "[*] $CLASS window found, toggling workspace"
    # Check if we're currently on the music workspace
    CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.name')
    if [[ "$CURRENT_WS" == "$WORKSPACE" ]]; then
        # Go back to last regular workspace
        LAST_REGULAR_WS=$(hyprctl workspaces -j | jq -r '[.[] | select(.name | startswith("special") | not)] | sort_by(.lastwindow) | reverse | .[0].name')
        [[ "$LAST_REGULAR_WS" == "null" || -z "$LAST_REGULAR_WS" ]] && LAST_REGULAR_WS="1"
        hyprctl dispatch workspace "$LAST_REGULAR_WS"
    else
        hyprctl dispatch togglespecialworkspace "music"
    fi
    exit 0
fi

echo "[*] Launching $CMD"
setsid bash -c "$CMD" >/dev/null 2>&1 &

# Wait for window
for i in {1..60}; do
    sleep 0.1
    if hyprctl clients -j | jq -e '.[] | select(.class=="'"$CLASS"'")' > /dev/null; then
        hyprctl dispatch togglespecialworkspace "music"
        exit 0
    fi
done

echo "❌ [ERROR] Window for $CLASS never appeared"
exit 1
