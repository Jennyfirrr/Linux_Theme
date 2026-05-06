#!/bin/bash
# FoxML Theme Hub — Installer
# Renders templates with theme palette, copies to system
# Usage: ./install.sh [theme_name] [--deps] [--nvidia] [--xgboost] [-y|--yes]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
SHARED_DIR="$SCRIPT_DIR/shared"
ACTIVE_FILE="$SCRIPT_DIR/.active-theme"
BACKUP_DIR="$HOME/.theme_backups/foxml-backup-$(date +%Y%m%d-%H%M%S)"

source "$SCRIPT_DIR/mappings.sh"
source "$SCRIPT_DIR/render.sh"

# ─────────────────────────────────────────
# Parse arguments
# ─────────────────────────────────────────
THEME_NAME=""
INSTALL_DEPS=false
INSTALL_NVIDIA=false
INSTALL_XGBOOST=false
ASSUME_YES=false
DEFAULT_THEME="FoxML_Classic"

for arg in "$@"; do
    case "$arg" in
        --deps) INSTALL_DEPS=true ;;
        --nvidia) INSTALL_NVIDIA=true ;;
        --xgboost) INSTALL_XGBOOST=true ;;
        -y|--yes) ASSUME_YES=true ;;
        *) THEME_NAME="$arg" ;;
    esac
done

# Non-interactive mode: default theme + prime sudo cache so pacman doesn't pause
if $ASSUME_YES; then
    [[ -z "$THEME_NAME" ]] && THEME_NAME="$DEFAULT_THEME"
    if $INSTALL_DEPS || $INSTALL_NVIDIA || $INSTALL_XGBOOST; then
        echo "Caching sudo credentials for unattended install..."
        sudo -v || { echo "sudo required for --deps / --nvidia / --xgboost"; exit 1; }
        # Keep sudo alive for the rest of the script
        ( while true; do sudo -n true; sleep 50; done 2>/dev/null ) &
        SUDO_KEEPALIVE_PID=$!
        trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
    fi
fi

# ─────────────────────────────────────────
# Theme selection (interactive if not specified)
# ─────────────────────────────────────────
if [[ -z "$THEME_NAME" ]]; then
    echo "╭──────────────────────────────────────────────────────────────────╮"
    echo "│                    FoxML Theme Installer                        │"
    echo "╰──────────────────────────────────────────────────────────────────╯"
    echo ""

    available=()
    for d in "$THEMES_DIR"/*/; do
        [[ -f "$d/theme.conf" ]] || continue
        available+=("$(basename "$d")")
    done

    if [[ ${#available[@]} -eq 0 ]]; then
        echo "No themes found in $THEMES_DIR"
        exit 1
    fi

    echo "Available themes:"
    for i in "${!available[@]}"; do
        local_type=$(grep '^type=' "$THEMES_DIR/${available[$i]}/theme.conf" | cut -d= -f2)
        local_desc=$(grep '^description=' "$THEMES_DIR/${available[$i]}/theme.conf" | cut -d= -f2)
        printf "  [%d] %s (%s) — %s\n" "$((i+1))" "${available[$i]}" "$local_type" "$local_desc"
    done
    echo ""
    read -p "Select theme [1-${#available[@]}]: " choice
    if [[ "$choice" -ge 1 && "$choice" -le ${#available[@]} ]] 2>/dev/null; then
        THEME_NAME="${available[$((choice-1))]}"
    else
        echo "Invalid selection."
        exit 1
    fi
fi

PALETTE_FILE="$THEMES_DIR/$THEME_NAME/palette.sh"
if [[ ! -f "$PALETTE_FILE" ]]; then
    echo "Theme '$THEME_NAME' not found (missing palette.sh)"
    exit 1
fi

echo ""
echo "Installing theme: $THEME_NAME"
echo "Backups will be saved to: $BACKUP_DIR"
echo ""
if ! $ASSUME_YES; then
    read -p "Continue? [y/N] " -n 1 -r
    echo ""
    [[ ! $REPLY =~ ^[Yy]$ ]] && echo "Aborted." && exit 1
fi

mkdir -p "$BACKUP_DIR"

# ─────────────────────────────────────────
# Dependencies (only with --deps)
# ─────────────────────────────────────────
if $INSTALL_DEPS; then
    echo ""
    echo "Installing dependencies..."

    PACMAN_PKGS=(
        # Fonts (nerd fonts for prompt glyphs, noto for CJK/emoji fallback in welcome banner)
        ttf-hack-nerd ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji
        # Compositor + lock + wallpaper + idle
        hyprland hyprlock awww hypridle
        # Themed login screen — auto-configured by install_greetd() below
        greetd greetd-regreet
        # Secrets / keyring (gnome-keyring-daemon is started from autostart.conf;
        # libsecret is the API most apps query, seahorse is the GUI manager)
        gnome-keyring libsecret seahorse
        # Editor + terminal + multiplexer
        neovim kitty tmux
        # Neovim runtime deps:
        #  - nodejs/npm: copilot.lua needs node to launch the Copilot LSP, and
        #    mason installs pyright/bashls/jsonls/yamlls as npm packages
        #  - tree-sitter-cli: nvim-treesitter regenerates the latex grammar from
        #    source on this driver line; without the CLI it errors at startup
        nodejs npm tree-sitter-cli
        # Bar + launcher + notifications
        waybar rofi-wayland mako dunst
        # Build tools (cmake for C++ projects bootstrapped from this machine)
        cmake
        # Shell + tooling
        base-devel zsh fzf eza bat yazi btop fd zoxide jq git-delta github-cli pacman-contrib
        lazygit ncspot cliphist
        # unzip is needed by install_catppuccin_cursor (extracts the release zip)
        unzip
        # Screenshots + clipboard + media keys
        grim slurp wl-clipboard playerctl brightnessctl pavucontrol wlsunset swappy
        # Bluetooth
        bluez bluez-utils blueman
        # Fingerprint support
        fprintd
        # Apps + viewers (xdg-utils provides xdg-open / xdg-settings so CLI tools
        # — gcloud, gh, etc. — can spawn the default browser without ENOENT)
        firefox zathura zathura-pdf-mupdf xdg-utils thunar steam
        # Runtime libs often needed by proprietary/AUR packages
        libutf8proc xsimd
        # Tools
        hyprpicker
        # Power profile switcher (waybar power-profiles-daemon module);
        # python-gobject is the optional dep that makes `powerprofilesctl` work
        # for click-to-switch handlers
        power-profiles-daemon python-gobject
    )

    # NVIDIA driver stack — only added when --nvidia is passed.
    # nvidia-open-dkms is the kernel module (rebuilds on kernel updates
    # via DKMS), linux-headers is the DKMS prereq, libva-nvidia-driver
    # gives Firefox/VLC hardware video decode on the dGPU.
    if $INSTALL_NVIDIA; then
        PACMAN_PKGS+=(nvidia-open-dkms linux-headers libva-nvidia-driver)
    fi

    TO_INSTALL=()
    for pkg in "${PACMAN_PKGS[@]}"; do
        pacman -Qi "$pkg" &>/dev/null || TO_INSTALL+=("$pkg")
    done

    # Check for multilib if steam is needed
    if [[ " ${TO_INSTALL[*]} " =~ " steam " ]] && ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo ""
        echo "  ⚠ Steam requires the [multilib] repository, but it is disabled in /etc/pacman.conf"
        ENABLE_MULTILIB=false
        if $ASSUME_YES; then
            ENABLE_MULTILIB=true
        else
            read -p "  Enable [multilib]? (Requires sudo) [y/N] " -n 1 -r
            echo ""
            [[ $REPLY =~ ^[Yy]$ ]] && ENABLE_MULTILIB=true
        fi

        if $ENABLE_MULTILIB; then
            echo "  Enabling [multilib]..."
            sudo sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
            sudo pacman -Sy
            echo "  ✓ [multilib] enabled"
        else
            echo "  ⚠ Skipping Steam (requires multilib)"
            # Remove steam from TO_INSTALL
            TO_INSTALL=(${TO_INSTALL[@]/steam/})
        fi
    fi

    if [[ ${#TO_INSTALL[@]} -gt 0 ]]; then
        echo "  Packages to install: ${TO_INSTALL[*]}"
        if $ASSUME_YES; then
            sudo pacman -S --needed --noconfirm "${TO_INSTALL[@]}"
        else
            read -p "  Install with pacman? [y/N] " -n 1 -r
            echo ""
            [[ $REPLY =~ ^[Yy]$ ]] && sudo pacman -S --needed "${TO_INSTALL[@]}"
        fi
    else
        echo "  All packages already installed"
    fi

    # Default web browser — wire xdg-open to Firefox so CLI auth flows
    # (gcloud, gh, oauth helpers) launch a browser instead of ENOENT-ing.
    # Idempotent: writes the user's ~/.config/mimeapps.list.
    if command -v xdg-settings &>/dev/null && [[ -f /usr/share/applications/firefox.desktop ]]; then
        xdg-settings set default-web-browser firefox.desktop \
            && echo "  ✓ Default browser set to Firefox"
    fi

    # Enable power-profiles-daemon (waybar module needs it active to read profiles)
    if pacman -Qi power-profiles-daemon &>/dev/null \
        && ! systemctl is-active --quiet power-profiles-daemon; then
        sudo systemctl enable --now power-profiles-daemon \
            && echo "  ✓ power-profiles-daemon enabled"
    fi

    # Enable bluetooth service
    if pacman -Qi bluez &>/dev/null \
        && ! systemctl is-active --quiet bluetooth; then
        sudo systemctl enable --now bluetooth \
            && echo "  ✓ bluetooth service enabled"
    fi

    # AUR Helper (yay) and Spotify/Spicetify
    AUR_HELPER=""
    command -v yay &>/dev/null && AUR_HELPER="yay"
    command -v paru &>/dev/null && [[ -z "$AUR_HELPER" ]] && AUR_HELPER="paru"

    if [[ -z "$AUR_HELPER" ]]; then
        echo ""
        echo "No AUR helper (yay/paru) found."
        INSTALL_YAY=false
        if $ASSUME_YES; then
            INSTALL_YAY=true
        else
            read -p "  Install yay? [y/N] " -n 1 -r
            echo ""
            [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_YAY=true
        fi

        if $INSTALL_YAY; then
            echo "  Installing yay..."
            YAY_DIR=$(mktemp -d)
            (
                set -e
                git clone https://aur.archlinux.org/yay-bin.git "$YAY_DIR"
                cd "$YAY_DIR"
                makepkg -si --noconfirm
            ) && AUR_HELPER="yay" || echo "  ⚠ yay install failed"
            rm -rf "$YAY_DIR"
        fi
    fi

    if [[ -n "$AUR_HELPER" ]]; then
        echo "  ✓ AUR helper $AUR_HELPER found"
    fi

    # Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        if $ASSUME_YES; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        else
            read -p "  Install Oh My Zsh? [y/N] " -n 1 -r
            echo ""
            [[ $REPLY =~ ^[Yy]$ ]] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
    fi

    # Global CLI tools (npm). Idempotent: only installs ones missing from PATH.
    #  - @google/gemini-cli      → `gemini`  (Google Gemini)
    #  - @anthropic-ai/claude-code → `claude` (Anthropic Claude Code)
    if command -v npm &>/dev/null; then
        NPM_GLOBALS=()
        command -v gemini &>/dev/null || NPM_GLOBALS+=("@google/gemini-cli")
        command -v claude &>/dev/null || NPM_GLOBALS+=("@anthropic-ai/claude-code")
        if [[ ${#NPM_GLOBALS[@]} -gt 0 ]]; then
            echo ""
            echo "Installing CLI tools (npm -g): ${NPM_GLOBALS[*]}"
            sudo npm install -g "${NPM_GLOBALS[@]}" \
                && echo "  ✓ Installed: ${NPM_GLOBALS[*]}" \
                || echo "  ⚠ npm install failed — see output above"
        else
            echo "  ✓ Gemini CLI + Claude Code already installed"
        fi
    fi
fi

# ─────────────────────────────────────────
# XGBoost — built from source (not in any Arch repo). Heavy: ~5–10 min compile.
# Used by the FoxML_Trader training pipeline and other ML projects.
# Gated behind its own --xgboost flag since most users won't need it.
# Idempotent: skipped entirely if libxgboost.so is already installed system-wide.
# ─────────────────────────────────────────
if $INSTALL_XGBOOST; then
    if [[ -f /usr/local/lib/libxgboost.so ]]; then
        echo ""
        echo "XGBoost already installed (skipping build)"
    else
        echo ""
        echo "Building XGBoost from source (~5-10 min)..."
        # Hard-fail early if cmake is missing — saves a clone before the build dies.
        if ! command -v cmake &>/dev/null; then
            echo "  ✗ cmake not found. Run with --deps first, or: sudo pacman -S cmake"
            exit 1
        fi
        XGB_DIR="$HOME/code/xgboost"
        [[ -d "$XGB_DIR" ]] || git clone --recursive https://github.com/dmlc/xgboost.git "$XGB_DIR"
        # Subshell isolates the build's set -e so a failure here doesn't abort the
        # rest of the installer — XGBoost is opt-in via --xgboost.
        (
            set -e
            cd "$XGB_DIR"
            mkdir -p build && cd build
            cmake .. -DBUILD_STATIC_LIB=OFF
            make -j"$(nproc)"
            sudo make install
            sudo ldconfig
        ) && echo "  ✓ XGBoost installed to /usr/local/" \
          || echo "  ⚠ XGBoost build failed — see output above (continuing)"
    fi
fi

# zsh plugins — install whenever oh-my-zsh is present, regardless of --deps,
# so the caramel theme + plugin list in .zshrc don't error out on first shell.
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    for repo in zsh-syntax-highlighting zsh-autosuggestions zsh-completions; do
        if [[ ! -d "$ZSH_CUSTOM/plugins/$repo" ]]; then
            git clone --quiet --depth 1 "https://github.com/zsh-users/$repo.git" "$ZSH_CUSTOM/plugins/$repo" \
                && echo "  ✓ zsh plugin: $repo"
        fi
    done
fi

# ─────────────────────────────────────────
# Render templates
# ─────────────────────────────────────────
echo ""
echo "Rendering templates with $THEME_NAME palette..."
RENDERED_DIR=$(mktemp -d)
render_all "$PALETTE_FILE" "$TEMPLATES_DIR" "$RENDERED_DIR"
echo "  ✓ Templates rendered"

# ─────────────────────────────────────────
# Backup and copy helper
# ─────────────────────────────────────────
backup_and_copy() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [[ -f "$dest" ]]; then
        local backup_path="$BACKUP_DIR/${dest#$HOME/}"
        mkdir -p "$(dirname "$backup_path")"
        cp "$dest" "$backup_path" 2>/dev/null || true
    fi
    cp "$src" "$dest"
    echo "  ✓ $(basename "$dest")"
}

# ─────────────────────────────────────────
# Install rendered template files
# ─────────────────────────────────────────
echo ""
echo "Installing themed configs..."
for mapping in "${TEMPLATE_MAPPINGS[@]}"; do
    src="${mapping%%|*}"
    dest="${mapping##*|}"
    dest="${dest/#\~/$HOME}"

    # Skip Firefox (handled by specials) and entries with FIREFOX_PROFILE
    [[ "$dest" == *"FIREFOX_PROFILE"* ]] && continue

    # Skip Gemini (handled by specials — needs jq merge to preserve auth keys)
    [[ "$dest" == *"GEMINI_DIR"* ]] && continue

    # Skip if oh-my-zsh not installed (for caramel theme)
    [[ "$dest" == *".oh-my-zsh"* && ! -d "$HOME/.oh-my-zsh" ]] && continue

    if [[ -f "$RENDERED_DIR/$src" ]]; then
        backup_and_copy "$RENDERED_DIR/$src" "$dest"
    fi
done

# ─────────────────────────────────────────
# Install shared (non-color) files
# ─────────────────────────────────────────
echo ""
echo "Installing shared configs..."
for mapping in "${SHARED_MAPPINGS[@]}"; do
    src="${mapping%%|*}"
    dest="${mapping##*|}"
    dest="${dest/#\~/$HOME}"

    if [[ -f "$SHARED_DIR/$src" ]]; then
        backup_and_copy "$SHARED_DIR/$src" "$dest"
    elif [[ -d "$SHARED_DIR/$src" ]]; then
        # Handle directory entries (like nvim_ftplugin/cpp.lua)
        mkdir -p "$(dirname "$dest")"
        cp "$SHARED_DIR/$src" "$dest"
        echo "  ✓ $(basename "$dest")"
    fi
done

# ─────────────────────────────────────────
# Special handlers
# ─────────────────────────────────────────
echo ""
echo "Installing special configs..."
install_specials "$RENDERED_DIR"

# ─────────────────────────────────────────
# Render waybar at install time so the live style.css/config exist
# immediately (without waiting for the next Hyprland session). The wrapper
# detects the current monitor and substitutes size tokens into the .tmpl
# files just deployed by the mappings loop.
# ─────────────────────────────────────────
if [[ -x "$HOME/.config/hypr/scripts/start_waybar.sh" ]]; then
    echo ""
    echo "Rendering waybar for current monitor..."
    "$HOME/.config/hypr/scripts/start_waybar.sh" --render-only || true
fi

# ─────────────────────────────────────────
# Catppuccin cursor (per-user fetch from GitHub releases).
# Always runs — it's idempotent and our configs reference the theme.
# ─────────────────────────────────────────
echo ""
echo "Installing Catppuccin cursor..."
install_catppuccin_cursor

# ─────────────────────────────────────────
# greetd login screen — auto-runs when greetd-regreet is installed
# ─────────────────────────────────────────
if pacman -Qi greetd-regreet &>/dev/null; then
    echo ""
    echo "Configuring greetd login screen..."
    install_greetd
fi

# ─────────────────────────────────────────
# Nvidia (full Wayland session on dGPU) — opt-in
# ─────────────────────────────────────────
if $INSTALL_NVIDIA; then
    echo ""
    echo "Configuring NVIDIA full-session setup..."
    install_nvidia
fi

# ─────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────
rm -rf "$RENDERED_DIR"

# ─────────────────────────────────────────
# Write active theme
# ─────────────────────────────────────────
echo "$THEME_NAME" > "$ACTIVE_FILE"

echo ""
echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                    Installation Complete!                       │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo ""
echo "Active theme: $THEME_NAME"
echo "Backups saved to: $BACKUP_DIR"
echo ""
echo "Post-install steps:"
echo "  1. Reload Hyprland: hyprctl reload"
echo "  2. Restart Waybar/Dunst: ~/.config/hypr/scripts/start_waybar.sh & pkill dunst && dunst &"
echo "  3. Open nvim and run :Lazy sync"
echo "  4. Restart Firefox (enable userChrome in about:config)"
echo "  5. Select 'Fox ML' theme in Cursor/VS Code"
if $INSTALL_NVIDIA; then
    echo "  6. Reboot to load the nvidia kernel module"
fi
echo ""

# Fingerprint reader detection (Moved to bottom)
if lsusb | grep -qi "fingerprint"; then
    echo "╭──────────────────────────────────────────────────────────────────╮"
    echo "│ 󰆐  Hardware Detected: Fingerprint Reader                        │"
    echo "├──────────────────────────────────────────────────────────────────┤"
    echo "│ To automate your biometric setup (Sudo, Login, Git):             │"
    echo "│   Run: fox-fingerprint                                           │"
    echo "╰──────────────────────────────────────────────────────────────────╯"
    echo ""
fi
