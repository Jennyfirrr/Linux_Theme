#!/bin/bash
# FoxML Rofi Toggle & Positioning Wrapper
# 1. Kills Rofi if already running (Toggle behavior).
# 2. Injects dynamic positioning (ROFI_X, ROFI_Y) into the command.
# 3. Executes the menu.

if pkill -x rofi; then
    exit 0
fi

# Fetch current offsets with fallbacks
X=${ROFI_X:-12}
Y=${ROFI_Y:-50}

# Common theme overrides for the "dropdown" look
# We append these to the command.
THEME_STR="window {location: north west; anchor: north west; x-offset: ${X}px; y-offset: ${Y}px;}"

# If the command is a direct Rofi call, we can append -theme-str.
# If it's a script (like network.sh), that script needs to handle its own positioning 
# or we just let it be. 
# However, to keep it simple and robust, we check if the first arg is "rofi".
if [[ "$1" == "rofi" ]]; then
    # Insert -theme-str before other args to ensure it's picked up
    cmd="$1"
    shift
    exec "$cmd" -theme-str "$THEME_STR" "$@"
else
    # For scripts, we just exec them. Scripts like hub.sh already 
    # use ROFI_X/ROFI_Y internally.
    exec "$@"
fi
