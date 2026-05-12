#!/bin/bash
# FoxML Panic Button
# Instantly locks down the machine, wipes sensitive memory, and stops active engines.
#
# Process kills are scoped by exact binary name (-x) and per-pid cwd
# inspection so we don't nuke unrelated processes that happen to share
# a name (e.g. someone else's `engine` binary, or an nvim editing a
# poem). Generic substring pkill is intentionally avoided.

set -u

# 1. Clipboard wipe — best-effort across the common providers. We wipe
#    BEFORE killing cliphist so the wipes actually persist; otherwise
#    a killed cliphist daemon leaves the db file intact on disk.
if command -v cliphist >/dev/null 2>&1; then
    cliphist wipe 2>/dev/null || true
fi
if command -v wl-copy >/dev/null 2>&1; then
    wl-copy --clear 2>/dev/null || true
    wl-copy --primary --clear 2>/dev/null || true
fi
# Drop the on-disk cliphist DB too. The daemon caches both in memory
# and on disk; `cliphist wipe` clears its memory state but the bbolt
# db file at ~/.cache/cliphist/db can contain previously-stored entries.
rm -f "$HOME/.cache/cliphist/db" 2>/dev/null || true

# 2. Kill sensitive UI processes by EXACT match (-x) so a substring
#    collision (e.g. some-rofi-thing) doesn't get nuked.
pkill -9 -x rofi      2>/dev/null || true
pkill -9 -x rofi-pass 2>/dev/null || true

# 3. nvim: only kill instances whose cwd is under $HOME/code (where
#    FoxML projects live). A bare `pkill nvim` would kill an unrelated
#    nvim session the user has open elsewhere (notes, journal, etc.)
#    which is way too aggressive for a panic button.
for pid in $(pgrep -x nvim 2>/dev/null); do
    cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null)
    [[ "$cwd" == "$HOME/code/"* ]] && kill -9 "$pid" 2>/dev/null || true
done

# 4. Stop trading engines by exact binary name. SIGINT first for a
#    clean P&L flush, then SIGKILL after a beat if anything's hung.
for bin in FoxML_Trader FoxML_Trader_v2 tick_trader; do
    pkill -SIGINT -x "$bin" 2>/dev/null || true
done
sleep 1
for bin in FoxML_Trader FoxML_Trader_v2 tick_trader; do
    pkill -9 -x "$bin" 2>/dev/null || true
done

# 5. Notify briefly before locking. The lock screen overlays this
#    quickly anyway, but notify-send fires the bell sound so the user
#    knows the panic button actually worked.
notify-send -u critical "LOCKDOWN" "Clipboard wiped. Engines stopped. Screen locking..." 2>/dev/null || true

# 6. Lock. Prefer fox-lock (dbus + awww sanity check) when present.
if command -v fox-lock >/dev/null 2>&1; then
    exec fox-lock
elif [[ -x "$HOME/.config/hypr/scripts/lock.sh" ]]; then
    exec "$HOME/.config/hypr/scripts/lock.sh"
else
    exec hyprlock
fi
