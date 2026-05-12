#!/usr/bin/env bash
# fox-unlock-hook.sh — invoked when the screen unlocks. Restores
# USBGuard's implicit-policy back to "apply-policy" so devices plugged
# in WHILE you're at the desk are evaluated normally instead of
# blanket-blocked. Pair to fox-lock's lock-on-screen-lock hardening.
#
# Wire-up: hypridle's unlock_cmd, OR called from a hyprlock post-auth
# hook. For now the wire-up is via hypridle (configured by mappings.sh
# alongside lock_cmd).

set -u

if command -v usbguard >/dev/null 2>&1 && systemctl is-active --quiet usbguard 2>/dev/null; then
    usbguard set-parameter ImplicitPolicyTarget apply-policy 2>/dev/null || true
fi
