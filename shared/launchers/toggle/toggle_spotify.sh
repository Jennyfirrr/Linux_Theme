#!/bin/bash
CLASS="spotify"
CMD="spotify"
WORKSPACE="special:music"

# Spotify class can be 'Spotify' or 'spotify'. Hyprland search is case-sensitive by default in jq.
# We'll search for both.

echo "[INFO] Toggling Spotify to $WORKSPACE"

get_spotify_window() {
    hyprctl clients -j | jq -e '.[] | select((.class == "Spotify" or .class == "spotify"))' > /dev/null
}

if get_spotify_window; then
    echo "[*] Spotify window found, toggling workspace"
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

# If we get here, no window is found.
# Check if the process is running but hidden in tray
if pgrep -x "spotify" > /dev/null; then
    echo "[*] Spotify process found but no window. Restarting to bring it back..."
    pkill -9 -x "spotify"
    sleep 0.5
fi

echo "[*] Launching $CMD"
setsid bash -c "$CMD" >/dev/null 2>&1 &

# Wait for window
for i in {1..80}; do
    sleep 0.1
    if get_spotify_window; then
        echo "[*] Spotify window appeared"
        hyprctl dispatch togglespecialworkspace "music"
        exit 0
    fi
done

echo "❌ [ERROR] Window for Spotify never appeared"
exit 1
