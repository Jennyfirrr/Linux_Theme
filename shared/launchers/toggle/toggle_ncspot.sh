#!/bin/bash
CLASS="ncspot"
CMD='kitty --class ncspot -e ncspot'
WORKSPACE="special:music"

echo "[INFO] Toggling $CLASS to $WORKSPACE"

# Check if ncspot window exists
NCSPOT_EXISTS=$(hyprctl clients -j | jq -e '.[] | select(.class=="'"$CLASS"'")' > /dev/null && echo "true" || echo "false")

if [[ "$NCSPOT_EXISTS" == "true" ]]; then
    echo "[*] $CLASS window found, toggling workspace"
    # Check if we're currently on the special workspace
    CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.name')
    if [[ "$CURRENT_WS" == "$WORKSPACE" ]]; then
        # We're on the special workspace, so go back to a regular workspace
        LAST_REGULAR_WS=$(hyprctl workspaces -j | jq -r '[.[] | select(.name | startswith("special") | not)] | sort_by(.lastwindow) | reverse | .[0].name')
        if [[ "$LAST_REGULAR_WS" == "null" || -z "$LAST_REGULAR_WS" ]]; then
            LAST_REGULAR_WS="1"
        fi
        echo "[*] Going to workspace: $LAST_REGULAR_WS"
        hyprctl dispatch workspace "$LAST_REGULAR_WS"
    else
        # We're on a regular workspace, so show the special workspace
        echo "[*] Showing special workspace"
        hyprctl dispatch togglespecialworkspace "music"
    fi
    exit 0
fi

echo "[*] Launching $CMD"
# Launch app
setsid bash -c "$CMD" >/dev/null 2>&1 &

# Wait for window to appear, then show it
for i in {1..60}; do
    sleep 0.1
    if hyprctl clients -j | jq -e '.[] | select(.class=="'"$CLASS"'")' > /dev/null; then
        echo "[*] $CLASS window appeared, showing workspace"
        hyprctl dispatch togglespecialworkspace "music"
        exit 0
    fi
done

echo "❌ [ERROR] Window for $CLASS never appeared"
exit 1
