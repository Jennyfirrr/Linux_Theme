#!/bin/bash
# FoxML Panic Button
# Instantly locks down the machine, wipes sensitive memory, and stops active engines.

# 1. Clear Clipboard (wipe history and current selection)
if command -v cliphist &>/dev/null; then
    cliphist wipe
fi
if command -v wl-copy &>/dev/null; then
    wl-copy --clear
fi

# 2. Kill Sensitive UI Processes
pkill -9 rofi
pkill -9 rofi-pass
pkill -9 nvim

# 3. Stop Trading Engines (Custom project names)
pkill -SIGINT FoxML_Trader
pkill -SIGINT tick_trader
pkill -SIGINT engine

# 4. Notify (Briefly before locking)
notify-send -u critical "LOCKDOWN" "System secured. Clipboard wiped."

# 5. Lock Screen
# Use the project's lock script if it exists
if [[ -x "$HOME/.config/hypr/scripts/lock.sh" ]]; then
    "$HOME/.config/hypr/scripts/lock.sh"
else
    hyprlock
fi
