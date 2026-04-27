#!/usr/bin/env bash
# FoxML Theme Hub — One-command bootstrap.
#
# Usage (run on a fresh Arch + Hyprland laptop):
#   curl -fsSL https://raw.githubusercontent.com/Jennyfirrr/Linux_Theme/main/bootstrap.sh | bash
#
# Optional theme arg:
#   curl -fsSL .../bootstrap.sh | bash -s Cave_Data_Center
#
# Honors env vars:
#   FOXML_DIR  — where to clone the repo (default: ~/Linux_Theme)
#   FOXML_REPO — git URL to clone        (default: GitHub mirror)

set -euo pipefail

THEME_NAME="${1:-FoxML_Classic}"
FOXML_REPO="${FOXML_REPO:-https://github.com/Jennyfirrr/Linux_Theme.git}"
FOXML_DIR="${FOXML_DIR:-$HOME/Linux_Theme}"

echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                FoxML Theme Hub — Bootstrap                       │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo "  Theme:     $THEME_NAME"
echo "  Repo:      $FOXML_REPO"
echo "  Clone to:  $FOXML_DIR"
echo ""

# ─── Sanity checks ──────────────────────────────────────────────────
if ! command -v pacman >/dev/null 2>&1; then
    echo "ERROR: pacman not found — this installer requires Arch Linux." >&2
    exit 1
fi

# Clear sudo prompt up front so the rest can run unattended
echo "Caching sudo (needed for pacman, greetd config, etc.)..."
sudo -v || { echo "ERROR: sudo required."; exit 1; }
( while true; do sudo -n true; sleep 50; done 2>/dev/null ) &
SUDO_PID=$!
trap 'kill "$SUDO_PID" 2>/dev/null || true' EXIT

# ─── Bootstrap deps ─────────────────────────────────────────────────
need_install=()
command -v git  >/dev/null 2>&1 || need_install+=(git)
command -v curl >/dev/null 2>&1 || need_install+=(curl)
if [[ ${#need_install[@]} -gt 0 ]]; then
    echo "Installing bootstrap deps: ${need_install[*]}"
    sudo pacman -S --needed --noconfirm "${need_install[@]}"
fi

# ─── Clone or update ────────────────────────────────────────────────
if [[ -d "$FOXML_DIR/.git" ]]; then
    echo "Repo already cloned — pulling latest..."
    git -C "$FOXML_DIR" pull --ff-only
else
    echo "Cloning $FOXML_REPO → $FOXML_DIR..."
    git clone --depth 1 "$FOXML_REPO" "$FOXML_DIR"
fi

# ─── Run installer non-interactively ────────────────────────────────
# Auto-detect an NVIDIA discrete GPU and pass --nvidia so the dGPU
# driver + Hyprland nvidia.conf get set up. No-ops on non-nvidia boxes,
# so the same bootstrap line works everywhere.
INSTALL_FLAGS=(--deps --yes)
for dev in /sys/bus/pci/devices/*/; do
    [[ "$(cat "$dev/vendor" 2>/dev/null)" == "0x10de" ]] || continue
    [[ "$(cat "$dev/class" 2>/dev/null)" == 0x03* ]] || continue
    INSTALL_FLAGS+=(--nvidia)
    echo "NVIDIA GPU detected at $(basename "$dev") — adding --nvidia to install."
    break
done

cd "$FOXML_DIR"
echo ""
echo "Running install.sh $THEME_NAME ${INSTALL_FLAGS[*]} ..."
echo ""
./install.sh "$THEME_NAME" "${INSTALL_FLAGS[@]}"

echo ""
echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                       Bootstrap Complete                         │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo "  Reload Hyprland:   hyprctl reload"
echo "  Restart bar:       pkill waybar && waybar &"
echo "  Open new shell to load the caramel zsh prompt."
