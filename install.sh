#!/bin/bash
# FoxML Theme Hub — Installer
# Renders templates with theme palette, copies to system
# Usage: ./install.sh [theme_name] [--deps] [--secure] [--nvidia] [--xgboost] [-y|--yes]

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
INSTALL_SECURITY=false
INSTALL_PERF=false
INSTALL_PRIVACY=false
INSTALL_VAULT=false
INSTALL_NVIDIA=false
INSTALL_XGBOOST=false
INSTALL_AI=false
INSTALL_MODELS=false
INSTALL_GITHUB=false
ASSUME_YES=false
RENDER_ONLY=false
DEFAULT_THEME="FoxML_Classic"

for arg in "$@"; do
    case "$arg" in
        --deps) INSTALL_DEPS=true ;;
        --secure) INSTALL_SECURITY=true ;;
        --perf) INSTALL_PERF=true ;;
        --privacy) INSTALL_PRIVACY=true ;;
        --vault) INSTALL_VAULT=true ;;
        --nvidia) INSTALL_NVIDIA=true ;;
        --xgboost) INSTALL_XGBOOST=true ;;
        --ai) INSTALL_AI=true ;;
        --models) INSTALL_MODELS=true ;;
        --github) INSTALL_GITHUB=true ;;
        --render-only) RENDER_ONLY=true ;;
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
        # Bar + launcher + notifications + widgets
        waybar rofi-wayland mako dunst
        # Build tools (cmake for C++ projects bootstrapped from this machine)
        cmake
        # Core & CLI Tools
        base-devel zsh fzf eza bat yazi btop fd zoxide jq git-delta github-cli pacman-contrib rofi-calc rofi-emoji
        lazygit ncspot cliphist cloc tree rsync shellcheck ripgrep
        # Networking + audio + notifications + power telemetry
        # (wpctl/nmcli/notify-send/upower/sensors are called from scripts &
        # waybar modules — without these explicit deps, fresh Arch boxes
        # silently fail at runtime)
        networkmanager wireplumber libnotify upower lm_sensors
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
        # imagemagick — used by configure_monitors() to auto-crop landscape
        # wallpapers into portrait variants when a rotated monitor is detected
        imagemagick
        # Power profile switcher (waybar power-profiles-daemon module);
        # python-gobject is the optional dep that makes `powerprofilesctl` work
        # for click-to-switch handlers
        power-profiles-daemon python-gobject
    )

    # Security hardening — only added when --secure is passed.
    if $INSTALL_SECURITY; then
        PACMAN_PKGS+=(ufw fail2ban audit lynis)
    fi

    # Performance — only added when --perf is passed.
    if $INSTALL_PERF; then
        PACMAN_PKGS+=(chrony)
    fi

    # Vault — only added when --vault is passed.
    if $INSTALL_VAULT; then
        PACMAN_PKGS+=(pass)
    fi

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
        echo "  Steam requires the [multilib] repository, but it is disabled in /etc/pacman.conf"
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
            echo "  [multilib] enabled"
        else
            echo "  Skipping Steam (requires multilib)"
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
            && echo "  Default browser set to Firefox"
    fi

    # Enable power-profiles-daemon (waybar module needs it active to read profiles)
    if pacman -Qi power-profiles-daemon &>/dev/null \
        && ! systemctl is-active --quiet power-profiles-daemon; then
        sudo systemctl enable --now power-profiles-daemon \
            && echo "  power-profiles-daemon enabled"
    fi

    # Enable bluetooth service
    if pacman -Qi bluez &>/dev/null \
        && ! systemctl is-active --quiet bluetooth; then
        sudo systemctl enable --now bluetooth \
            && echo "  bluetooth service enabled"
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
            ) && AUR_HELPER="yay" || echo "  yay install failed"
            rm -rf "$YAY_DIR"
        fi
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
    #  - @google/gemini-cli       → `gemini` (Gemini CLI)
    #  - @anthropic-ai/claude-code → `claude` (Anthropic Claude Code)
    if command -v npm &>/dev/null; then
        NPM_GLOBALS=()
        command -v gemini &>/dev/null || NPM_GLOBALS+=("@google/gemini-cli")
        command -v claude &>/dev/null || NPM_GLOBALS+=("@anthropic-ai/claude-code")
        if [[ ${#NPM_GLOBALS[@]} -gt 0 ]]; then
            echo ""
            echo "Installing CLI tools (npm -g): ${NPM_GLOBALS[*]}"
            sudo npm install -g "${NPM_GLOBALS[@]}" \
                && echo "  Installed: ${NPM_GLOBALS[*]}" \
                || echo "  npm install failed — see output above"
        else
            echo "  Gemini CLI + Claude Code already installed"
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
            echo "  cmake not found. Run with --deps first, or: sudo pacman -S cmake"
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
        ) && echo "  XGBoost installed to /usr/local/" \
          || echo "  XGBoost build failed — see output above (continuing)"
    fi
fi

# zsh plugins — install whenever oh-my-zsh is present, regardless of --deps,
# so the caramel theme + plugin list in .zshrc don't error out on first shell.
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    for repo in zsh-syntax-highlighting zsh-autosuggestions zsh-completions; do
        if [[ ! -d "$ZSH_CUSTOM/plugins/$repo" ]]; then
            git clone --quiet --depth 1 "https://github.com/zsh-users/$repo.git" "$ZSH_CUSTOM/plugins/$repo" \
                && echo "  zsh plugin: $repo"
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
echo "  Templates rendered"

if $RENDER_ONLY; then
    # In render-only mode, we still need to deploy them to the system 
    # but we skip dependencies, backups, and special sudo-heavy handlers.
    echo "Installing rendered configs (render-only)..."
    for mapping in "${TEMPLATE_MAPPINGS[@]}"; do
        src="${mapping%%|*}"
        dest="${mapping##*|}"
        dest="${dest/#\~/$HOME}"
        [[ "$dest" == *"FIREFOX_PROFILE"* ]] && continue
        [[ "$dest" == *"GEMINI_DIR"* ]] && continue
        if [[ -f "$RENDERED_DIR/$src" ]]; then
            mkdir -p "$(dirname "$dest")"
            cp "$RENDERED_DIR/$src" "$dest"
        fi
    done
    
    echo "Installing shared configs (render-only)..."
    for mapping in "${SHARED_MAPPINGS[@]}"; do
        src="${mapping%%|*}"
        dest="${mapping##*|}"
        dest="${dest/#\~/$HOME}"
        if [[ -f "$SHARED_DIR/$src" ]]; then
            mkdir -p "$(dirname "$dest")"
            cp "$SHARED_DIR/$src" "$dest"
        elif [[ -d "$SHARED_DIR/$src" ]]; then
            mkdir -p "$(dirname "$dest")"
            cp -r "$SHARED_DIR/$src" "$dest"
        fi
    done

    # Re-run script and module deployment
    mkdir -p ~/.config/hypr/scripts ~/.config/waybar/scripts ~/.config/hypr/modules ~/.local/bin
    for script in "$SHARED_DIR/hyprland_scripts/"*.sh; do cp "$script" ~/.config/hypr/scripts/; chmod +x ~/.config/hypr/scripts/$(basename "$script"); done
    for script in "$SHARED_DIR/waybar_scripts/"*.sh; do cp "$script" ~/.config/waybar/scripts/; chmod +x ~/.config/waybar/scripts/$(basename "$script"); done
    for bin in "$SHARED_DIR/bin/"*; do cp "$bin" ~/.local/bin/; chmod +x ~/.local/bin/$(basename "$bin"); done
    for mod in "$SHARED_DIR/hyprland_modules/"*.conf; do 
        basename="$(basename "$mod")"
        [[ "$basename" == "theme.conf" ]] && continue
        [[ "$basename" == "nvidia.conf" ]] && continue
        cp "$mod" ~/.config/hypr/modules/
    done

    # Special handlers (AI settings, Firefox, etc.)
    install_specials "$RENDERED_DIR"
    
    # Still run waybar render to pick up monitor scale
    if [[ -x "$HOME/.config/hypr/scripts/start_waybar.sh" ]]; then
        "$HOME/.config/hypr/scripts/start_waybar.sh" --render-only || true
    fi
    
    rm -rf "$RENDERED_DIR"
    echo "Active theme: $THEME_NAME"
    echo "Render and deployment complete."
    exit 0
fi

# ─────────────────────────────────────────
# Compile FoxML Intelligence Layer (C++)
# ─────────────────────────────────────────
if [[ -d "$SCRIPT_DIR/src/fox-intel" ]]; then
    echo "Compiling FoxML Intelligence Layer (C++)..."
    (
        set -e
        cd "$SCRIPT_DIR/src/fox-intel"
        # Ensure json.hpp is present (fallback if not already there)
        if [[ ! -f "json.hpp" ]]; then
            curl -sLO https://github.com/nlohmann/json/releases/latest/download/json.hpp
        fi
        make clean &>/dev/null
        make -j"$(nproc)"
        cp findex fask "$SHARED_DIR/bin/"
        echo "  + Intelligence Layer compiled and deployed to shared/bin/"
    ) || echo "  ! Intelligence Layer build failed — ensure g++ and libcurl are installed."
fi

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
    echo "  $(basename "$dest")"
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

    # Skip Agent config (handled by specials — needs jq merge to preserve auth keys)
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
        echo "  $(basename "$dest")"
    fi
done

# ─────────────────────────────────────────
# Special handlers
# ─────────────────────────────────────────
echo ""
echo "Installing special configs..."
install_specials "$RENDERED_DIR"

# Waybar render is deferred until after configure_monitors writes the layout
# sidecar — otherwise start_waybar.sh sees no SECONDARY_OUTPUTS and emits a
# single-bar config, which wins over the multi-bar version a later run would
# generate.

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
# Security Hardening — opt-in
# ─────────────────────────────────────────
if $INSTALL_SECURITY; then
    echo ""
    echo "Configuring security hardening..."
    install_security
fi

# ─────────────────────────────────────────
# Performance — opt-in
# ─────────────────────────────────────────
if $INSTALL_PERF; then
    echo ""
    echo "Configuring performance tuning..."
    install_performance
fi

# ─────────────────────────────────────────
# Privacy — opt-in
# ─────────────────────────────────────────
if $INSTALL_PRIVACY; then
    echo ""
    echo "Configuring privacy (DoH)..."
    install_privacy
fi

# ─────────────────────────────────────────
# Vault — opt-in
# ─────────────────────────────────────────
if $INSTALL_VAULT; then
    echo ""
    echo "Configuring secure vault..."
    install_vault
fi

# ─────────────────────────────────────────
# AI Development Tools — opt-in
# ─────────────────────────────────────────
if $INSTALL_AI || $INSTALL_MODELS; then
echo ""
if ! command -v ollama &>/dev/null; then
    echo "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "Ollama already installed."
fi

# Ensure embedding model is present for RAG
echo "Pulling embedding model (nomic-embed-text)..."
ollama pull nomic-embed-text

if $INSTALL_AI; then

        echo "Installing OpenCode CLI..."
        curl -fsSL https://opencode.ai/install | bash
        echo "  AI Tools binary installed."
    fi

    if $INSTALL_MODELS; then
        echo "Detecting hardware for optimal AI model stack..."
        # fox-hw-info echoes KEY=value lines; eval to actually set the vars in this shell.
        eval "$(bash "$SHARED_DIR/bin/fox-hw-info")"
        echo "  RAM: ${RAM_GB}GB, VRAM: ${VRAM_GB}GB (Tier: $TIER)"

        case "$TIER" in
            "lite")
                echo "Pulling Lite Stack (1B, 3B, 7B)..."
                ollama pull qwen2.5-coder:1.5b
                ollama pull qwen2.5-coder:3b
                ollama pull qwen2.5-coder:7b
                ;;
            "standard")
                echo "Pulling Standard Stack (7B, 14B, 32B)..."
                ollama pull qwen2.5-coder:7b
                ollama pull qwen2.5-coder:14b
                ollama pull qwen2.5-coder:32b
                ;;
            "pro")
                echo "Pulling Pro Stack (14B, 32B, 70B)..."
                ollama pull qwen2.5-coder:14b
                ollama pull qwen2.5-coder:32b
                ollama pull qwen2.5-coder:70b
                ;;
        esac
        echo "  + AI Models ready."
    fi

    # OpenCode config gen is deferred — defined as a function here, called at
    # the end of install.sh after GitHub clones land so skill-path discovery
    # can see the freshly-cloned workspaces on a brand-new machine.
    configure_opencode() {
        echo "Configuring OpenCode (theme + multi-model picker + skill discovery)..."
        mkdir -p "$HOME/.config/opencode"

        # Discover installed Ollama models for the picker
        local INSTALLED_MODELS=()
        if command -v ollama &>/dev/null; then
            while IFS= read -r m; do
                [ -n "$m" ] && [ "$m" != "nomic-embed-text" ] && INSTALLED_MODELS+=("$m")
            done < <(ollama list 2>/dev/null | awk 'NR>1 && $1 != "" {print $1}')
        fi
        if [ ${#INSTALLED_MODELS[@]} -eq 0 ]; then
            INSTALLED_MODELS=(qwen2.5-coder:7b)
        fi

        local MODELS_JSON=""
        for m in "${INSTALLED_MODELS[@]}"; do
            [ -n "$MODELS_JSON" ] && MODELS_JSON+=","
            MODELS_JSON+=$(printf '"%s":{"name":"%s"}' "$m" "$m")
        done

        # Discover skill dirs by globbing local workspaces. Only paths that
        # actually exist (and contain at least one SKILL.md) get wired in —
        # keeps private skills local without naming any private repo here.
        local SKILL_PATHS=()
        for d in "$HOME"/code/*/claude-skills; do
            [ -d "$d" ] || continue
            if find "$d" -name SKILL.md -print -quit 2>/dev/null | grep -q .; then
                SKILL_PATHS+=("$d")
            fi
        done
        local SKILL_PATHS_JSON=""
        for p in "${SKILL_PATHS[@]}"; do
            [ -n "$SKILL_PATHS_JSON" ] && SKILL_PATHS_JSON+=","
            SKILL_PATHS_JSON+=$(printf '"%s"' "$p")
        done

        # Default model: prefer 7b if installed, else first available
        local DEFAULT_MODEL="ollama/${INSTALLED_MODELS[0]}"
        for m in "${INSTALLED_MODELS[@]}"; do
            if [ "$m" = "qwen2.5-coder:7b" ]; then
                DEFAULT_MODEL="ollama/qwen2.5-coder:7b"
                break
            fi
        done

        cat <<EOF > "$HOME/.config/opencode/opencode.json"
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (Local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {${MODELS_JSON}}
    }
  },
  "model": "${DEFAULT_MODEL}",
  "skills": {
    "paths": [${SKILL_PATHS_JSON}]
  }
}
EOF
        # Theme persistence lives in tui.json (separate schema). OpenCode
        # auto-migrates a top-level "theme" out of opencode.json into here on
        # first launch — we write it directly so a fresh install boots themed.
        cat <<EOF > "$HOME/.config/opencode/tui.json"
{
  "\$schema": "https://opencode.ai/tui.json",
  "theme": "foxml"
}
EOF
        echo "  + Theme: foxml (custom, palette-driven — re-run install.sh or render.sh after a palette swap to refresh)"
        echo "  + Models exposed to picker: ${#INSTALLED_MODELS[@]}  (default: $DEFAULT_MODEL)"
        echo "  + Skill workspaces wired: ${#SKILL_PATHS[@]}"

        # Project-local override so this repo always sees its own skills,
        # plus any other workspaces present on the same machine.
        mkdir -p "$SCRIPT_DIR/.opencode"
        cat <<EOF > "$SCRIPT_DIR/.opencode/opencode.json"
{
  "\$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": [${SKILL_PATHS_JSON}]
  }
}
EOF
        echo "  + Project-local OpenCode config: $SCRIPT_DIR/.opencode/opencode.json"
    }

    echo "Deploying AI Skills Vault..."
    mkdir -p "$HOME/.local/share/foxml/ai_skills"
    cp -r "$SHARED_DIR/ai_skills/"* "$HOME/.local/share/foxml/ai_skills/"
    echo "  Vault initialized at ~/.local/share/foxml/ai_skills"

    # Plug skills into the current project folder
    echo "Plugging AI skills into project..."
    mkdir -p "$SCRIPT_DIR/.agent/commands"
    for skill in "$SHARED_DIR/ai_skills/"*.md; do
        cp "$skill" "$SCRIPT_DIR/.agent/commands/"
    done
    echo "  + Project-level AI skills ready."
    fi

    # ─────────────────────────────────────────
    # GitHub Workspace — opt-in
    # ─────────────────────────────────────────
    install_github_workspace() {
    # If ASSUME_YES is on but --github wasn't passed, we skip.
    # If --github WAS passed, we run it regardless of ASSUME_YES because it's a specific user request.
    if $ASSUME_YES && ! $INSTALL_GITHUB; then
        return
    fi

    echo ""
    echo "╭──────────────────────────────────────────────────────────────────╮"
    echo "│   GitHub Workspace Setup                                        │"
    echo "├──────────────────────────────────────────────────────────────────┤"
    echo "│ This will create ~/code and clone all your public/private       │"
    echo "│ repositories. It uses 'gh' (GitHub CLI) for automation.         │"
    echo "╰──────────────────────────────────────────────────────────────────╯"
    if ! $ASSUME_YES; then
        read -p "Set up GitHub workspace? [y/N] " -n 1 -r; echo ""
        [[ ! $REPLY =~ ^[Yy]$ ]] && return
    fi

    # 1. Ensure gh is installed
    if ! command -v gh &>/dev/null; then
        echo "    Installing GitHub CLI..."
        sudo pacman -S --needed --noconfirm github-cli
    fi

    # 2. Check auth
    if ! gh auth status &>/dev/null; then
        echo "    You need to authenticate with GitHub."
        gh auth login
    fi

    # 3. Get username
    local gh_user
    gh_user=$(gh api user -q .login 2>/dev/null)
    if [[ -z "$gh_user" ]]; then
        read -p "    Enter your GitHub username: " gh_user
    fi

    if [[ -z "$gh_user" ]]; then
        echo "    ! No username provided, skipping."
        return
    fi

    # 4. Git Config Check
    if [[ -z "$(git config --global user.name)" ]]; then
        read -p "    Enter Git Name: " git_name
        [[ -n "$git_name" ]] && git config --global user.name "$git_name"
    fi
    if [[ -z "$(git config --global user.email)" ]]; then
        read -p "    Enter Git Email: " git_email
        [[ -n "$git_email" ]] && git config --global user.email "$git_email"
    fi

    # 4b. SSH key for git@github.com:... clones (idempotent)
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        echo "    Generating SSH key (ed25519)..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        local ssh_email
        ssh_email="$(git config --global user.email 2>/dev/null)"
        ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" \
            -C "${ssh_email:-$gh_user@$(hostname)}" -q
        echo "      Key: $HOME/.ssh/id_ed25519"
    fi

    # Upload pubkey to GitHub if not already registered there
    local pubkey_body
    pubkey_body="$(awk '{print $2}' "$HOME/.ssh/id_ed25519.pub")"
    if ! gh ssh-key list 2>/dev/null | grep -qF "$pubkey_body"; then
        if ! gh auth status 2>&1 | grep -q 'admin:public_key'; then
            echo "    Refreshing gh auth to include admin:public_key scope..."
            gh auth refresh -h github.com -s admin:public_key || true
        fi
        echo "    Uploading SSH key to GitHub..."
        gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$(hostname)" \
            || echo "    ! upload failed — run 'gh auth refresh -s admin:public_key' and retry"
    fi

    # 5. Workspace Directory
    mkdir -p "$HOME/code"
    cd "$HOME/code" || return

    # 6. Pull Repos
    echo "      Pulling all repositories for $gh_user..."
    # Get list of all repos (name and sshUrl)
    gh repo list "$gh_user" --limit 1000 --json name,sshUrl -q '.[] | [.name, .sshUrl] | @tsv' | while read -r name url; do
        if [[ -d "$name" ]]; then
            echo "      • $name already exists, skipping"
        else
            echo "      ↓ Cloning $name..."
            git clone "$url" "$name" --quiet
        fi
    done

    echo "    + Workspace setup complete in ~/code"
    }

    if $INSTALL_GITHUB; then
    install_github_workspace
    fi

    # ─────────────────────────────────────────
    # OpenCode JSON config — runs LAST so skill-path discovery sees any
    # workspaces that the GitHub clone step just brought down. Safe to call
    # whenever --ai is set; idempotent on re-runs.
    # ─────────────────────────────────────────
    if $INSTALL_AI; then
        configure_opencode
    fi

    # ─────────────────────────────────────────
    # Multi-monitor layout — runs after configs are deployed so the
    # generated monitors.conf overrides the freshly-installed default.
    # Skipped automatically when only one display is connected or when
    # hyprctl can't reach the IPC socket (installer run from a TTY).
    # ─────────────────────────────────────────
    echo ""
    echo "Configuring monitors..."
    configure_monitors

    # Backstop: regenerate portrait wallpapers any time the sidecar lists a
    # rotated output, regardless of whether the user re-ran the picker. Covers
    # the case where imagemagick was installed in this same run (after the
    # first configure_monitors pass) or a fresh wallpaper was added since.
    if [[ -f "$HOME/.config/foxml/monitor-layout.conf" ]]; then
        # shellcheck disable=SC1090
        source "$HOME/.config/foxml/monitor-layout.conf"
        if [[ -n "${PORTRAIT_OUTPUTS:-}" ]]; then
            _generate_portrait_wallpapers
        fi
    fi

    # Render waybar AFTER configure_monitors so start_waybar.sh sees the layout
    # sidecar and emits a multi-bar config when secondary monitors are present.
    # Then bounce the running waybar so the new config takes effect immediately
    # (otherwise the bar already on screen keeps the pre-configure single-bar
    # render until the next Hyprland session).
    if [[ -x "$HOME/.config/hypr/scripts/start_waybar.sh" ]]; then
        echo ""
        echo "Rendering waybar for current monitor layout..."
        "$HOME/.config/hypr/scripts/start_waybar.sh" --render-only || true
        if pgrep -x waybar >/dev/null 2>&1; then
            pkill -x waybar 2>/dev/null || true
            setsid "$HOME/.config/hypr/scripts/start_waybar.sh" >/dev/null 2>&1 < /dev/null &
            disown 2>/dev/null || true
            echo "  + waybar restarted"
        fi
    fi

    # ─────────────────────────────────────────
    # CPU throttling / power tuning — interactive wizard. Always offered at
# the end of an interactive install; auto-skipped under -y.
# ─────────────────────────────────────────
install_throttling

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

# ─────────────────────────────────────────
# Auto-apply post-install actions. Each step self-skips when its
# precondition isn't met (no Hyprland session, waybar/dunst not running,
# no nvim install, no jq, no Cursor/Code dir).
# ─────────────────────────────────────────
apply_post_install() {
    echo "Applying post-install actions..."

    # Hyprland reload — only inside an active Hyprland session
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl &>/dev/null; then
        hyprctl reload >/dev/null 2>&1 && echo "  + Hyprland reloaded"
    fi

    # Waybar — restart if currently running so it picks up new config
    if pgrep -x waybar >/dev/null && [[ -x "$HOME/.config/hypr/scripts/start_waybar.sh" ]]; then
        pkill -x waybar 2>/dev/null || true
        setsid -f "$HOME/.config/hypr/scripts/start_waybar.sh" >/dev/null 2>&1 || true
        echo "  + Waybar restarted"
    fi

    # Dunst — restart if currently running so the new palette loads
    if pgrep -x dunst >/dev/null; then
        pkill -x dunst 2>/dev/null || true
        setsid -f dunst >/dev/null 2>&1 || true
        echo "  + Dunst restarted"
    fi

    # Nvim Lazy sync — headless plugin update (60s cap so it can't hang)
    if command -v nvim &>/dev/null && [[ -d "$HOME/.local/share/nvim/lazy" ]]; then
        echo "  Running nvim Lazy sync (headless, 60s cap)..."
        if timeout 60 nvim --headless "+Lazy! sync" "+qa" >/dev/null 2>&1; then
            echo "  + Nvim plugins synced"
        else
            echo "  ! Lazy sync didn't complete cleanly — run ':Lazy sync' manually"
        fi
    fi

    # Cursor / VS Code — set workbench.colorTheme to "Fox ML" via jq merge
    if command -v jq &>/dev/null; then
        local ide_dir ide_root settings tmp
        for ide_dir in "$HOME/.config/Cursor/User" "$HOME/.config/Code/User"; do
            ide_root="${ide_dir%/User}"
            [[ -d "$ide_root" ]] || continue
            mkdir -p "$ide_dir"
            settings="$ide_dir/settings.json"
            [[ -f "$settings" ]] || echo '{}' > "$settings"
            tmp="$(mktemp)"
            if jq '. + {"workbench.colorTheme": "Fox ML"}' "$settings" > "$tmp" 2>/dev/null; then
                mv "$tmp" "$settings"
                echo "  + $(basename "$ide_root"): workbench.colorTheme = Fox ML"
            else
                rm -f "$tmp"
            fi
        done
    fi
}

apply_post_install

echo ""
echo "Manual step (intentional):"
echo "  - Restart Firefox to apply userChrome (auto-restart would kill open tabs)"
if $INSTALL_AI; then
    echo "  - OpenCode is ready: run 'opencode' to start local AI development"
    echo "  - AI Notifications: Gemini and Claude will now notify you via Dunst/Mako when prompts finish"
fi
if $INSTALL_GITHUB; then
    echo "  7. GitHub Workspace is ready: Your repos are in ~/code"
fi
if $INSTALL_NVIDIA; then
    echo "  8. Reboot to load the nvidia kernel module"
fi
echo ""

# Fingerprint reader detection (Moved to bottom)
if lsusb | grep -qi "fingerprint"; then
    echo "╭──────────────────────────────────────────────────────────────────╮"
    echo "│  Hardware Detected: Fingerprint Reader                        │"
    echo "├──────────────────────────────────────────────────────────────────┤"
    echo "│ To automate your biometric setup (Sudo, Login, Git):             │"
    echo "│   Run: fox-fingerprint                                           │"
    echo "╰──────────────────────────────────────────────────────────────────╯"
    echo ""
fi
