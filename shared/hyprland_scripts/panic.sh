#!/bin/bash
# FoxML Panic Button
# Instantly locks down the machine, wipes sensitive memory, and stops active engines.
#
# Process kills are scoped by exact binary name (-x) and per-pid cwd
# inspection so we don't nuke unrelated processes that happen to share
# a name (e.g. someone else's `engine` binary, or an nvim editing a
# poem). Generic substring pkill is intentionally avoided.

set -u

# 1. Clipboard wipe — best-effort across the common providers.
#
# Order matters here. cliphist uses bbolt for its on-disk store
# (~/.cache/cliphist/db); bbolt holds an exclusive file lock while
# the cliphist daemon is alive, so:
#   - rm on a locked file may fail silently
#   - even if rm succeeds, the running daemon's in-memory cache will
#     write back to a freshly-recreated db on the next clipboard event,
#     restoring the very entries we're trying to wipe.
#
# Correct sequence:
#   a) cliphist wipe        (clear daemon's in-memory state via API)
#   b) kill the wl-paste/cliphist daemons (release the bbolt lock + stop
#      future writes)
#   c) shred + rm the db file (now safely lockless; shred overwrites
#      blocks before unlink so the data isn't recoverable from the
#      filesystem)
#   d) wl-copy clear (covers the live Wayland clipboard buffer)
if command -v cliphist >/dev/null 2>&1; then
    cliphist wipe 2>/dev/null || true
fi
# Kill any cliphist-feeding wl-paste watchers AND the cliphist daemon
# itself. Without this, the db re-materialises seconds later.
pkill -9 -x cliphist 2>/dev/null || true
pkill -9 -f 'wl-paste --type (text|image) --watch cliphist' 2>/dev/null || true
# Wait for the bbolt lock to release; 1s is overkill but harmless.
for _ in 1 2 3 4 5; do
    fuser "$HOME/.cache/cliphist/db" >/dev/null 2>&1 || break
    sleep 0.1
done
db="$HOME/.cache/cliphist/db"
if [[ -f "$db" ]]; then
    if command -v shred >/dev/null 2>&1; then
        shred -uz "$db" 2>/dev/null || rm -f "$db" 2>/dev/null || true
    else
        rm -f "$db" 2>/dev/null || true
    fi
fi
if command -v wl-copy >/dev/null 2>&1; then
    wl-copy --clear 2>/dev/null || true
    wl-copy --primary --clear 2>/dev/null || true
fi

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
