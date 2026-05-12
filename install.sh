#!/bin/bash
# FoxML Theme Hub — Installer
# Renders templates with theme palette, copies to system
# Usage: ./install.sh [theme_name] [--deps] [--secure] [--perf] [--privacy]
#                     [--vault] [--ai] [--models] [--github] [--nvidia]
#                     [--xgboost] [--full|--all] [--render-only] [-y|--yes]
#
# --full / --all: enables every opt-in module except --xgboost.
# FOXML_NO_UPDATE=1: skip the auto-update + re-exec at startup.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
SHARED_DIR="$SCRIPT_DIR/shared"
ACTIVE_FILE="$SCRIPT_DIR/.active-theme"
BACKUP_DIR="$HOME/.theme_backups/foxml-backup-$(date +%Y%m%d-%H%M%S)"

# ─────────────────────────────────────────
# Self-update — pull latest installer from origin/main and re-exec
# before doing any destructive work. Runs ahead of mappings.sh / render.sh
# sourcing so the re-execed process picks up updated helpers too.
#
# Skip conditions (any one short-circuits to current version):
#   - FOXML_NO_UPDATE=1 in env (explicit pin / offline / dev)
#   - FOXML_UPDATED=1 in env (already re-execed, prevents loop)
#   - SCRIPT_DIR isn't inside a git work tree (curl-bash from tarball)
#   - HEAD isn't on main (don't auto-update arbitrary branches)
#   - working tree dirty (don't clobber in-progress edits)
#   - fetch fails within 15s (offline / GitHub down)
#   - pull would require non-FF (local commits ahead)
# ─────────────────────────────────────────
foxml_self_update() {
    [[ "${FOXML_NO_UPDATE:-0}" == "1" ]] && return
    [[ "${FOXML_UPDATED:-0}"   == "1" ]] && return
    git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    local branch
    branch="$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [[ "$branch" != "main" ]]; then
        echo "  • installer on branch '$branch' (not main), skipping auto-update"
        return
    fi
    if ! git -C "$SCRIPT_DIR" diff --quiet HEAD 2>/dev/null; then
        echo "  • installer has uncommitted changes, skipping auto-update"
        return
    fi

    echo "Checking for installer updates..."
    if ! timeout 15 git -C "$SCRIPT_DIR" fetch --quiet origin main 2>/dev/null; then
        echo "  • fetch failed (offline?), continuing with current version"
        return
    fi

    local local_sha remote_sha
    local_sha="$(git -C "$SCRIPT_DIR" rev-parse HEAD)"
    remote_sha="$(git -C "$SCRIPT_DIR" rev-parse origin/main 2>/dev/null)"
    if [[ -z "$remote_sha" || "$local_sha" == "$remote_sha" ]]; then
        echo "  installer up-to-date ($(git -C "$SCRIPT_DIR" rev-parse --short HEAD))"
        return
    fi

    echo "  Pulling updates: $(git -C "$SCRIPT_DIR" rev-parse --short HEAD) → $(git -C "$SCRIPT_DIR" rev-parse --short origin/main)"
    if ! git -C "$SCRIPT_DIR" pull --ff-only --quiet origin main 2>/dev/null; then
        echo "  ! non-fast-forward (local commits ahead?), continuing with current version"
        return
    fi

    echo "  Installer updated, re-executing with new version..."
    export FOXML_UPDATED=1
    exec "$SCRIPT_DIR/install.sh" "$@"
}
foxml_self_update "$@"

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
INSTALL_AMD_GPU=false
INSTALL_INTEL_GPU=false
INSTALL_FPRINT=false
IS_LAPTOP=false
INSTALL_XGBOOST=false
INSTALL_CPP_PRO=false
# Security hardening: ON by default. Opt out individually via --no-*
# flags. install.sh actually applies these only when --deps is set
# (so the required packages get installed in the same run); users doing
# a config-only re-run won't get half-installed hardening.
INSTALL_HARDEN_BROWSER=true
INSTALL_USBGUARD=true
INSTALL_ARCH_AUDIT=true
# MAC randomization stays opt-in — dorm / enterprise WiFi setups
# require a consistent MAC for the network ACL to recognise the device.
INSTALL_MAC_RANDOM=false
INSTALL_AI=false
INSTALL_MODELS=false
INSTALL_GITHUB=false
ASSUME_YES=false
RENDER_ONLY=false
DRY_RUN=false
QUICK=false
RESUME=false
PHASE=""
DEFAULT_THEME="FoxML_Classic"

for arg in "$@"; do
    case "$arg" in
        --deps) INSTALL_DEPS=true ;;
        --secure) INSTALL_SECURITY=true ;;
        --perf) INSTALL_PERF=true ;;
        --privacy) INSTALL_PRIVACY=true ;;
        --vault) INSTALL_VAULT=true ;;
        --nvidia)    INSTALL_NVIDIA=true ;;
        --gpu-amd)   INSTALL_AMD_GPU=true ;;
        --gpu-intel) INSTALL_INTEL_GPU=true ;;
        --fprint)    INSTALL_FPRINT=true ;;
        --xgboost) INSTALL_XGBOOST=true ;;
        --cpp-pro) INSTALL_CPP_PRO=true ;;
        --harden-browser|--no-harden-browser)
            [[ "$arg" == "--no-harden-browser" ]] && INSTALL_HARDEN_BROWSER=false || INSTALL_HARDEN_BROWSER=true
            ;;
        --usbguard|--no-usbguard)
            [[ "$arg" == "--no-usbguard" ]] && INSTALL_USBGUARD=false || INSTALL_USBGUARD=true
            ;;
        --arch-audit|--no-arch-audit)
            [[ "$arg" == "--no-arch-audit" ]] && INSTALL_ARCH_AUDIT=false || INSTALL_ARCH_AUDIT=true
            ;;
        --mac-random)     INSTALL_MAC_RANDOM=true ;;
        --ai) INSTALL_AI=true ;;
        --models) INSTALL_MODELS=true ;;
        --github) INSTALL_GITHUB=true ;;
        --full|--all)
            # Flip every opt-in module on. --xgboost stays out — it's a
            # heavy from-source build for a niche use case (training the
            # bundled trading models) and would dominate install time
            # for users who don't need it.
            INSTALL_DEPS=true
            INSTALL_SECURITY=true
            INSTALL_PERF=true
            INSTALL_PRIVACY=true
            INSTALL_VAULT=true
            INSTALL_NVIDIA=true
            INSTALL_AI=true
            INSTALL_MODELS=true
            INSTALL_GITHUB=true
            ;;
        --render-only) RENDER_ONLY=true ;;
        --dry-run)     DRY_RUN=true ;;
        --quick)       QUICK=true ;;
        --resume)      RESUME=true ;;
        --phase)       PHASE="${arg##*=}"; [[ "$PHASE" == "--phase" ]] && PHASE="next" ;;
        --phase=*)     PHASE="${arg#--phase=}" ;;
        -y|--yes) ASSUME_YES=true ;;
        *) THEME_NAME="$arg" ;;
    esac
done

# ─────────────────────────────────────────
# Hardware auto-detect block.
#
# Three independent detections, each behind a Y/n prompt in interactive
# mode and a warning-only line in --yes mode (don't auto-modify system
# without consent):
#   1. NVIDIA GPU  → nvidia-open-dkms + DKMS headers + boot tweaks
#   2. AMD GPU     → vulkan-radeon + libva-mesa-driver (userspace only)
#   3. Intel GPU   → intel-media-driver + libva-intel-driver (userspace)
#   4. Chassis type (/sys/class/dmi/id/chassis_type) → IS_LAPTOP flag
#   5. Fingerprint reader (USB vendor IDs) → fprintd + PAM integration
#
# All idempotent — re-runs see flags already set and skip prompts.
# ─────────────────────────────────────────

# Chassis: 8/9/10/11/14 = laptop family; 30/31 = tablet/convertible.
# Used to gate the fingerprint prompt (readers are laptop-only) and
# could later inform battery widget defaults.
if [[ -r /sys/class/dmi/id/chassis_type ]]; then
    case "$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)" in
        8|9|10|11|14|30|31) IS_LAPTOP=true ;;
    esac
fi

# Helper: prompt to enable a GPU userspace stack. Same pattern as
# NVIDIA but factored so the three branches stay readable.
# Note the explicit `return 0` on the early-exits — `set -e` is in effect
# at this point of the script, and a bare `return` would inherit the
# previous command's exit status (e.g. 1 from a non-matching grep) and
# kill the whole installer. "No matching GPU" is not an error.
_gpu_prompt() {
    local pattern="$1" vendor_label="$2" pkgs_label="$3" var_to_set="$4"
    local current_val="${!var_to_set}"
    [[ "$current_val" == "true" ]] && return 0
    command -v lspci >/dev/null 2>&1 || return 0
    lspci 2>/dev/null | grep -qE "$pattern" || return 0
    local gpu
    gpu=$(lspci 2>/dev/null | grep -E "$pattern" | head -1 | sed -E 's/^.*: //; s/ \(rev [^)]*\)$//')
    if $ASSUME_YES; then
        foxml_warn "${vendor_label} GPU detected (${gpu}) — pass the matching flag explicitly in --yes mode"
        return
    fi
    echo ""
    foxml_section "${vendor_label} GPU detected"
    foxml_substep "${gpu}"
    read -p "Install ${pkgs_label}? [Y/n] " -n 1 -r
    echo ""
    if [[ ! "$REPLY" =~ ^[Nn]$ ]]; then
        printf -v "$var_to_set" '%s' "true"
        foxml_ok "${vendor_label} GPU userspace enabled for this install"
    else
        foxml_substep "skipping ${vendor_label} GPU install"
    fi
}

if ! $INSTALL_NVIDIA; then
    _gpu_prompt '(VGA|3D).*NVIDIA' 'NVIDIA' \
        'nvidia-open-dkms + DKMS headers + Hyprland NVIDIA tweaks' INSTALL_NVIDIA
fi
_gpu_prompt '(VGA|3D).*(AMD|ATI)' 'AMD' \
    'vulkan-radeon + libva-mesa-driver (userspace only, no boot tweaks)' INSTALL_AMD_GPU
_gpu_prompt '(VGA|3D).*Intel' 'Intel' \
    'intel-media-driver + libva-intel-driver + vulkan-intel' INSTALL_INTEL_GPU

# Fingerprint reader: USB vendor IDs covering most consumer readers.
# Laptop-only (chassis_type check) so desktop users with random USB
# devices don't get false positives. PAM integration touches
# /etc/pam.d/system-local-login — strictly behind a prompt.
if $IS_LAPTOP && ! $ASSUME_YES && command -v lsusb >/dev/null 2>&1; then
    fp_vendors='138a|06cb|27c6|1c7a|147e|04f3|0483|08ff'
    if lsusb 2>/dev/null | grep -qiE "ID (${fp_vendors})"; then
        fp_dev=$(lsusb 2>/dev/null | grep -iE "ID (${fp_vendors})" | head -1 | sed -E 's/^Bus [0-9]+ Device [0-9]+: //')
        echo ""
        foxml_section "Fingerprint reader detected"
        foxml_substep "${fp_dev}"
        read -p "Enable fprintd + PAM integration (touches /etc/pam.d/system-local-login)? [y/N] " -n 1 -r
        echo ""
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            INSTALL_FPRINT=true
            foxml_ok "fingerprint stack enabled — you'll be prompted to enroll a finger after install"
        else
            foxml_substep "skipping fingerprint integration"
        fi
    fi
fi

# ─────────────────────────────────────────
# Pre-flight checks. Disk space, connectivity, existing-install marker,
# conflicting WM/DE. Fail fast on hard problems (no disk, no network);
# warn on soft conflicts (other DE installed).
# ─────────────────────────────────────────

# Disk: require ≥5GB free in $HOME for templates + backups + AI binaries.
# --models adds 5-20GB depending on tier; warn separately so user can
# bail before kicking off a multi-GB pull.
_free_home=$(df -BG --output=avail "$HOME" 2>/dev/null | tail -1 | tr -dc '0-9')
if [[ -n "$_free_home" && "$_free_home" -lt 5 ]]; then
    foxml_err "less than 5GB free in $HOME (${_free_home}GB) — installer needs headroom for backups + tools"
    exit 1
fi
if $INSTALL_MODELS && [[ -n "$_free_home" && "$_free_home" -lt 25 ]]; then
    foxml_warn "${_free_home}GB free in $HOME — --models pulls 5-20GB depending on tier; consider pruning"
fi

# Connectivity: only matters when the install actually fetches things.
# 3s timeout — fails fast on offline / DNS-broken machines instead of
# letting pacman / git stall mid-run.
if ! $DRY_RUN && ! $RENDER_ONLY \
    && ( $INSTALL_DEPS || $INSTALL_AI || $INSTALL_MODELS || $INSTALL_GITHUB ); then
    if ! timeout 3 curl -sSf https://archlinux.org/ >/dev/null 2>&1; then
        foxml_err "can't reach archlinux.org — installer needs network for pacman / git / ollama"
        foxml_substep "diagnose: ping archlinux.org   /   systemctl status NetworkManager"
        exit 1
    fi
fi

# Existing install: marker file at the end of a successful install
# records the theme + timestamp. --quick on a re-run skips deps/clones
# (the slow parts) and just re-renders + redeploys configs. Without
# --quick, we just nudge.
INSTALL_MARKER="$HOME/.local/share/foxml/.installed-version"
if [[ -f "$INSTALL_MARKER" ]]; then
    _prior=$(cat "$INSTALL_MARKER" 2>/dev/null)
    if $QUICK; then
        foxml_substep "Quick mode: skipping deps/clones (prior install: ${_prior})"
        INSTALL_DEPS=false
        INSTALL_GITHUB=false
        INSTALL_MODELS=false
    else
        foxml_substep "Existing FoxML install detected (${_prior}) — pass --quick to skip deps + clones next time"
    fi
fi

# Phase markers. The installer records its last-completed phase in a
# state file; --resume reads it back and prints guidance. --phase X
# exits cleanly after phase X. The marker pattern is intentionally
# minimal — the existing flags (--deps off, --quick) handle most of
# the "skip-what's-done" needs.
#
# Phase names (in execution order):
#   deps   — pacman + AUR helper + Oh My Zsh + npm globals
#   render — render templates, deploy configs, scripts, modules
#   ai     — Ollama + OpenCode + model pulls + AI skills
#   github — gh auth + ~/code clone-all
#   post   — apply_post_install, install marker, summary
PHASE_STATE_FILE="$HOME/.local/state/foxml/install-state"
if $RESUME && [[ -f "$PHASE_STATE_FILE" ]]; then
    _resume_phase=$(cat "$PHASE_STATE_FILE" 2>/dev/null)
    foxml_substep "last completed phase: '${_resume_phase:-none}'"
    foxml_substep "this run continues from there; pass --quick to skip deps if already installed"
fi
_phase_mark() {
    mkdir -p "$(dirname "$PHASE_STATE_FILE")"
    echo "$1" > "$PHASE_STATE_FILE"
}
_phase_exit_if_done() {
    if [[ -n "$PHASE" && "$PHASE" == "$1" ]]; then
        foxml_substep "phase '$1' complete — exiting (--phase requested)"
        exit 0
    fi
}

# Conflicting WM/DE: warn that configs coexist but Hyprland-specific
# keybinds won't apply if the user logs into the other session.
if command -v pacman >/dev/null 2>&1; then
    _wm_conflicts=()
    pacman -Qi plasma-desktop &>/dev/null && _wm_conflicts+=("KDE Plasma")
    pacman -Qi gnome-shell    &>/dev/null && _wm_conflicts+=("GNOME")
    pacman -Qi sway           &>/dev/null && _wm_conflicts+=("sway")
    pacman -Qi i3-wm          &>/dev/null && _wm_conflicts+=("i3")
    pacman -Qi xfce4-session  &>/dev/null && _wm_conflicts+=("XFCE")
    if (( ${#_wm_conflicts[@]} > 0 )); then
        foxml_warn "another desktop / WM installed: ${_wm_conflicts[*]}"
        foxml_substep "configs will coexist; Hyprland binds only apply inside Hyprland session"
    fi
fi

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

# ─────────────────────────────────────────
# Dry-run: print plan summary and exit. No file writes, no pacman calls,
# no sudo. Lets the user preview which modules would activate, how many
# templates would render, and what the monitor layout looks like — useful
# when running with --full on a new machine, or sanity-checking a config
# change before committing to the install.
# ─────────────────────────────────────────
if $DRY_RUN; then
    foxml_section "Dry run — no changes will be applied"
    foxml_summary_row "Theme"             "$THEME_NAME"
    foxml_summary_row "Templates"         "${#TEMPLATE_MAPPINGS[@]} files would render"
    foxml_summary_row "Backup target"     "$BACKUP_DIR"
    mods=()
    $INSTALL_DEPS     && mods+=("deps")
    $INSTALL_SECURITY && mods+=("security")
    $INSTALL_PERF     && mods+=("perf")
    $INSTALL_PRIVACY  && mods+=("privacy")
    $INSTALL_VAULT    && mods+=("vault")
    $INSTALL_NVIDIA   && mods+=("nvidia")
    $INSTALL_AMD_GPU  && mods+=("gpu-amd")
    $INSTALL_INTEL_GPU && mods+=("gpu-intel")
    $INSTALL_FPRINT   && mods+=("fprint")
    $IS_LAPTOP        && mods+=("chassis:laptop")
    $INSTALL_XGBOOST  && mods+=("xgboost")
    $INSTALL_CPP_PRO  && mods+=("cpp-pro")
    $INSTALL_HARDEN_BROWSER && mods+=("harden-browser")
    $INSTALL_USBGUARD       && mods+=("usbguard")
    $INSTALL_ARCH_AUDIT     && mods+=("arch-audit")
    $INSTALL_MAC_RANDOM     && mods+=("mac-random")
    $INSTALL_AI       && mods+=("ai")
    $INSTALL_MODELS   && mods+=("models")
    $INSTALL_GITHUB   && mods+=("github")
    foxml_summary_row "Modules"           "${mods[*]:-none}"
    if [[ -f "$HOME/.config/foxml/monitor-layout.conf" ]]; then
        # shellcheck disable=SC1090
        ( source "$HOME/.config/foxml/monitor-layout.conf"
          foxml_summary_row "Monitors (sidecar)" "${MONITOR_RESOLUTIONS:-unknown}"
          foxml_summary_row "Primary"            "${PRIMARY:-unknown}" )
    else
        foxml_summary_row "Monitors" "configure_monitors would run interactively"
    fi
    echo ""
    foxml_substep "no files written, no packages installed — rerun without --dry-run to apply"
    exit 0
fi

# ─────────────────────────────────────────
# Distro / session guard. install.sh issues pacman / yay / makepkg calls
# unconditionally and writes Hyprland-format configs. Fail fast with a
# clear message rather than the deep "command not found" the user would
# otherwise see hundreds of lines into the install. --dry-run skips this
# so a non-Arch user can still preview the plan.
# ─────────────────────────────────────────
if ! command -v pacman >/dev/null 2>&1; then
    foxml_err "pacman not found — install.sh requires Arch Linux or an Arch-derived distro"
    distro_id=$(grep ^ID= /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    foxml_substep "detected: ${distro_id:-unknown}"
    foxml_substep "if you're on Arch under a non-standard PATH, ensure /usr/bin is in \$PATH"
    foxml_substep "preview the install on this system without running it: ./install.sh --dry-run"
    exit 1
fi

# Hyprland session is not required for --render-only / --deps / theme
# rendering, but configure_monitors and post-install reload steps will
# self-skip without it. Surface a single line up front so the user knows
# those will defer rather than wondering why monitors aren't picked up.
if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    foxml_warn "no active Hyprland session — configure_monitors will defer to next install"
    foxml_substep "run ./install.sh from inside a Hyprland session to capture monitor layout"
fi

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
    foxml_section "Installing dependencies"

    PACMAN_PKGS=(
        # Fonts (nerd fonts for prompt glyphs, noto for CJK/emoji fallback in welcome banner)
        ttf-hack-nerd ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji
        # Compositor + lock + wallpaper + idle
        hyprland hyprlock awww hypridle
        # Themed login screen — auto-configured by install_greetd() below
        greetd greetd-regreet
        # Secrets / keyring (gnome-keyring-daemon is started from autostart.conf;
        # libsecret is the API most apps query, seahorse is the GUI manager).
        # gnupg powers gpg-agent for git commit signing — install_gpg_agent_cache()
        # extends its passphrase TTL so agent commits don't re-prompt every 10 min.
        gnome-keyring libsecret seahorse gnupg
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
        # socat — used by fox-monitor-watch.sh to stream Hyprland's socket2
        # event feed (monitoradded/monitorremoved) for hot-swap detection
        socat
        # Power profile switcher (waybar power-profiles-daemon module);
        # python-gobject is the optional dep that makes `powerprofilesctl` work
        # for click-to-switch handlers
        power-profiles-daemon python-gobject
        # ufw is always installed — install_ufw_baseline() applies a
        # default-deny incoming firewall on every install, not just --secure.
        # fail2ban / audit / lynis stay behind --secure (server-grade tools
        # that are dead weight on a personal laptop with no public services).
        ufw
    )

    # Security hardening — only added when --secure is passed.
    if $INSTALL_SECURITY; then
        PACMAN_PKGS+=(fail2ban audit lynis)
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

    # AMD / Intel GPU userspace — auto-detected upstream; only Vulkan /
    # VA-API packages, no kernel modules or boot tweaks. Safe to install
    # alongside mesa (already in deps).
    if $INSTALL_AMD_GPU; then
        PACMAN_PKGS+=(vulkan-radeon libva-mesa-driver mesa-vdpau)
    fi
    if $INSTALL_INTEL_GPU; then
        PACMAN_PKGS+=(intel-media-driver libva-intel-driver vulkan-intel)
    fi

    # C++ trading toolchain extras — opt-in via --cpp-pro. base-devel
    # already covers gcc/make; this layer adds:
    #   clang, lldb        — alternative compiler + debugger
    #   mold               — 5-10x faster linker than ld.bfd
    #   ccache             — rebuild cache, big win on repeated builds
    #   gdb                — Linux's default debugger (not in base-devel)
    #   valgrind           — memory error / leak checks
    #   perf               — Linux kernel profiling
    #   hyperfine          — microbenchmark CLI
    #   linux-tools-common — perf needs this companion meta on some kernels
    if $INSTALL_CPP_PRO; then
        PACMAN_PKGS+=(clang lldb mold ccache gdb valgrind perf hyperfine)
    fi

    # Security hardening add-ons — on by default, --no-X opts out.
    # firejail comes in with --harden-browser since Firefox-in-firejail
    # is the canonical sandbox pairing for risky browsing.
    $INSTALL_HARDEN_BROWSER && PACMAN_PKGS+=(firejail)
    $INSTALL_USBGUARD       && PACMAN_PKGS+=(usbguard)
    $INSTALL_ARCH_AUDIT     && PACMAN_PKGS+=(arch-audit)

    TO_INSTALL=()
    ALREADY_INSTALLED=0
    for pkg in "${PACMAN_PKGS[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
        else
            TO_INSTALL+=("$pkg")
        fi
    done
    foxml_substep "${ALREADY_INSTALLED}/${#PACMAN_PKGS[@]} packages already installed"

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
        foxml_substep "${#TO_INSTALL[@]} new package(s) to install: ${TO_INSTALL[*]}"
        if $ASSUME_YES; then
            sudo pacman -S --needed --noconfirm "${TO_INSTALL[@]}"
        else
            read -p "  Install with pacman? [y/N] " -n 1 -r
            echo ""
            [[ $REPLY =~ ^[Yy]$ ]] && sudo pacman -S --needed "${TO_INSTALL[@]}"
        fi
    else
        foxml_ok "all packages already installed — nothing to do"
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

    # Fingerprint reader: enable fprintd + wire PAM. Gated by the
    # hardware-detect prompt above ($INSTALL_FPRINT). PAM edit is the
    # delicate bit — we insert pam_fprintd as `sufficient` *before* the
    # password lines so finger-presence skips the password ask, with
    # password still available as fallback. Idempotent on re-runs.
    if $INSTALL_FPRINT && pacman -Qi fprintd &>/dev/null; then
        if ! systemctl is-active --quiet fprintd; then
            sudo systemctl enable --now fprintd 2>/dev/null \
                && echo "  fprintd service enabled"
        fi
        pam_file=/etc/pam.d/system-local-login
        if [[ -f "$pam_file" ]] && ! grep -q pam_fprintd "$pam_file"; then
            # Insert sufficient pam_fprintd as the first auth rule. If
            # finger presence succeeds, login proceeds; otherwise PAM
            # falls through to the existing system-login include chain.
            sudo sed -i '0,/^auth/{s|^auth|auth      sufficient   pam_fprintd.so\nauth|}' \
                "$pam_file" 2>/dev/null && echo "  fprintd PAM line added"
        fi
        echo "  + run 'fprintd-enroll' to register a finger when ready"
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
    _phase_mark deps
fi
_phase_exit_if_done deps

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
foxml_section "Rendering templates with $THEME_NAME palette"
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
        [[ "$dest" == *"AGENT_DIR"* ]] && continue
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
    foxml_section "Compiling FoxML Intelligence Layer (C++)"
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
}

# ─────────────────────────────────────────
# Install rendered template files
# ─────────────────────────────────────────
echo ""
total_tmpl=${#TEMPLATE_MAPPINGS[@]}
cur_tmpl=0
for mapping in "${TEMPLATE_MAPPINGS[@]}"; do
    cur_tmpl=$((cur_tmpl + 1))
    if command -v foxml_progress >/dev/null; then foxml_progress "$cur_tmpl" "$total_tmpl" "Installing themed configs"; else echo -ne "\rInstalling themed configs $cur_tmpl/$total_tmpl"; fi

    src="${mapping%%|*}"
    dest="${mapping##*|}"
    dest="${dest/#\~/$HOME}"

    # Skip Firefox (handled by specials) and entries with FIREFOX_PROFILE
    [[ "$dest" == *"FIREFOX_PROFILE"* ]] && continue

    # Skip Agent config (handled by specials — needs jq merge to preserve auth keys)
    [[ "$dest" == *"AGENT_DIR"* ]] && continue

    # Skip if oh-my-zsh not installed (for caramel theme)
    [[ "$dest" == *".oh-my-zsh"* && ! -d "$HOME/.oh-my-zsh" ]] && continue

    if [[ -f "$RENDERED_DIR/$src" ]]; then
        backup_and_copy "$RENDERED_DIR/$src" "$dest"
    fi
done
echo ""

# ─────────────────────────────────────────
# Install shared (non-color) files
# ─────────────────────────────────────────
echo ""
total_shared=${#SHARED_MAPPINGS[@]}
cur_shared=0
for mapping in "${SHARED_MAPPINGS[@]}"; do
    cur_shared=$((cur_shared + 1))
    if command -v foxml_progress >/dev/null; then foxml_progress "$cur_shared" "$total_shared" "Installing shared configs"; else echo -ne "\rInstalling shared configs $cur_shared/$total_shared"; fi

    src="${mapping%%|*}"
    dest="${mapping##*|}"
    dest="${dest/#\~/$HOME}"

    if [[ -f "$SHARED_DIR/$src" ]]; then
        backup_and_copy "$SHARED_DIR/$src" "$dest"
    elif [[ -d "$SHARED_DIR/$src" ]]; then
        # Handle directory entries (like nvim_ftplugin/cpp.lua)
        mkdir -p "$(dirname "$dest")"
        cp -a "$SHARED_DIR/$src/." "$dest/"
    fi
done
echo ""

_phase_mark render
_phase_exit_if_done render

# ─────────────────────────────────────────
# Special handlers
# ─────────────────────────────────────────
echo ""
foxml_section "Installing special configs"
install_specials "$RENDERED_DIR"

# Waybar render is deferred until after configure_monitors writes the layout
# sidecar — otherwise start_waybar.sh sees no SECONDARY_OUTPUTS and emits a
# single-bar config, which wins over the multi-bar version a later run would
# generate.

# ─────────────────────────────────────────
# systemd-resolved DNSSEC — drop strict validation so zones with unsigned
# upstream responses (NTP pool subdomains, smaller zones) don't break name
# resolution. Without this, chronyd silently fails to sync the clock.
# ─────────────────────────────────────────
echo ""
echo "Configuring systemd-resolved DNSSEC..."
install_resolved_dnssec

# ─────────────────────────────────────────
# One-shot clock correction — direct UDP/123 to Cloudflare NTP IP, no
# DNS dependency. Fixes wedged clocks (multi-hour offsets) that chrony's
# slew mode refuses to step. Skipped when chrony isn't installed.
# ─────────────────────────────────────────
echo ""
echo "Synchronizing system clock..."
install_clock_sync

# ─────────────────────────────────────────
# gpg-agent passphrase cache TTL — extends the default 10-min idle cache
# so agent-driven commits don't re-prompt mid-session. No-op for users
# who don't sign with GPG. Override duration via FOXML_GPG_CACHE_TTL.
# ─────────────────────────────────────────
echo ""
echo "Configuring gpg-agent passphrase cache..."
install_gpg_agent_cache

# ─────────────────────────────────────────
# Kernel hardening sysctls — auto-applied. Drop-in at
# /etc/sysctl.d/99-foxml-hardening.conf, reversible by deleting the file.
# Pure-win settings (kptr/dmesg restrict, syncookies, rp_filter, etc.) —
# nothing that breaks normal desktop / dev workflows.
# ─────────────────────────────────────────
echo ""
echo "Applying kernel hardening sysctls..."
install_kernel_hardening

# ─────────────────────────────────────────
# Auto-on security hardening features. Flags default true; --no-X opts
# out individually. Gated on $INSTALL_DEPS so packages exist in the
# same run; config-only re-runs skip these (avoids half-installed
# state).
# ─────────────────────────────────────────
if $INSTALL_DEPS; then
    if $INSTALL_HARDEN_BROWSER; then
        echo ""
        foxml_section "Browser hardening (arkenfox + firejail)"
        install_browser_hardening
    fi
    if $INSTALL_USBGUARD; then
        echo ""
        foxml_section "USBGuard policy"
        install_usbguard
    fi
    if $INSTALL_ARCH_AUDIT; then
        echo ""
        foxml_section "arch-audit daily timer"
        install_arch_audit
    fi
fi
# MAC randomization is opt-in and doesn't require new packages
# (NetworkManager handles it), so it runs whenever the flag is set.
if $INSTALL_MAC_RANDOM; then
    echo ""
    foxml_section "NetworkManager MAC randomization"
    install_mac_random
fi

# ─────────────────────────────────────────
# UFW firewall baseline — auto-applied. Default deny incoming, allow
# outgoing, conditional limit ssh only when sshd is actually enabled.
# Skipped cleanly if ufw isn't installed; the --secure module's SSH
# hardening wizard handles port-22 vs custom-port logic separately.
# ─────────────────────────────────────────
echo ""
echo "Applying UFW firewall baseline..."
install_ufw_baseline

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
    install_greetd_fingerprint
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

        # Hybrid stack: a qwen2.5 chat sibling alongside the coder series.
        # The coder models are FIM-tuned and emit code when asked anything
        # general ("count to 10" → `echo -e "1\n2\n3"` with literal \n).
        # configure_opencode picks the chat sibling as the OpenCode default
        # model so general prompts produce prose; coder is still in the
        # picker for code tasks.
        case "$TIER" in
            "lite")
                echo "Pulling Lite Stack (chat 3B + coder 1.5B/3B/7B)..."
                ollama pull qwen2.5:3b
                ollama pull qwen2.5-coder:1.5b
                ollama pull qwen2.5-coder:3b
                ollama pull qwen2.5-coder:7b
                ;;
            "standard")
                echo "Pulling Standard Stack (chat 7B + coder 7B/14B/32B)..."
                ollama pull qwen2.5:7b
                ollama pull qwen2.5-coder:7b
                ollama pull qwen2.5-coder:14b
                ollama pull qwen2.5-coder:32b
                ;;
            "pro")
                # qwen2.5-coder tops out at 32B on the Ollama registry. Larger
                # hosts get the same coder ceiling — no broken 70B pull.
                echo "Pulling Pro Stack (chat 14B + coder 14B/32B)..."
                ollama pull qwen2.5:14b
                ollama pull qwen2.5-coder:14b
                ollama pull qwen2.5-coder:32b
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

        # Discover installed Ollama models for the picker. Embedding-only
        # models (nomic-embed-text*, mxbai-embed-*, bge-*) are filtered out
        # — they exit non-zero from the chat endpoint and clutter the model
        # picker. The previous filter matched only the bare name, so
        # nomic-embed-text:latest (the actual installed tag) slipped through.
        local INSTALLED_MODELS=()
        if command -v ollama &>/dev/null; then
            while IFS= read -r m; do
                [[ -z "$m" ]] && continue
                case "$m" in
                    nomic-embed-text*|mxbai-embed-*|bge-*) continue ;;
                esac
                INSTALLED_MODELS+=("$m")
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

        # Default model: prefer a chat-tuned variant over a coder variant.
        # Coder models are FIM-tuned and produce code-formatted responses
        # for general prompts (the user reported "count to 10" yielding
        # `echo -e "1\n2..."` with literal escapes). Preference cascade:
        #   1. qwen2.5:7b   — Standard tier chat sibling
        #   2. qwen2.5:14b  — Pro tier chat sibling
        #   3. qwen2.5:3b   — Lite tier chat sibling
        #   4. any other non-coder model present
        #   5. first installed (falls back to coder if that's all there is)
        local DEFAULT_MODEL="ollama/${INSTALLED_MODELS[0]}"
        local chat_preference=("qwen2.5:7b" "qwen2.5:14b" "qwen2.5:3b")
        local picked=""
        for pref in "${chat_preference[@]}"; do
            for m in "${INSTALLED_MODELS[@]}"; do
                [ "$m" = "$pref" ] && { picked="$m"; break 2; }
            done
        done
        if [ -z "$picked" ]; then
            # No tier-specific chat model — scan for any non-coder model
            # that's not an embed variant (those are already filtered out).
            for m in "${INSTALLED_MODELS[@]}"; do
                case "$m" in
                    *-coder*) continue ;;
                    *)        picked="$m"; break ;;
                esac
            done
        fi
        [ -n "$picked" ] && DEFAULT_MODEL="ollama/$picked"

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

        # Project-local override — wires opencode into THIS project's own
        # claude-skills directory via a relative path. Intentionally does
        # not reference other workspaces; cross-workspace skill discovery
        # belongs in the user-level config above. Keeping this file
        # machine-agnostic means it's safe to commit (no /home/<user>
        # leaks, no private-workspace names) and identical across every
        # user who runs install.sh.
        mkdir -p "$SCRIPT_DIR/.opencode"
        cat <<EOF > "$SCRIPT_DIR/.opencode/opencode.json"
{
  "\$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["./claude-skills"]
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

    # 4c. GPG signing key — generates a passphrase-protected ed25519
    # signing key, uploads it to GitHub, and turns on commit/tag auto-
    # sign. Idempotent on re-runs.
    install_github_gpg_signing

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
    _phase_mark github
    fi
    _phase_exit_if_done github

    # ─────────────────────────────────────────
    # OpenCode JSON config — runs LAST so skill-path discovery sees any
    # workspaces that the GitHub clone step just brought down. Safe to call
    # whenever --ai is set; idempotent on re-runs.
    # ─────────────────────────────────────────
    if $INSTALL_AI; then
        configure_opencode
        _phase_mark ai
    fi
    _phase_exit_if_done ai

    # ─────────────────────────────────────────
    # Multi-monitor layout — runs after configs are deployed so the
    # generated monitors.conf overrides the freshly-installed default.
    # Skipped automatically when only one display is connected or when
    # hyprctl can't reach the IPC socket (installer run from a TTY).
    # ─────────────────────────────────────────
    echo ""
    foxml_section "Configuring monitors"
    configure_monitors

    # Backstop: regenerate per-monitor wallpaper variants, re-personalise
    # hyprlock, and re-pin workspace 1 any time the sidecar exists,
    # regardless of whether the user re-ran the picker. Covers imagemagick
    # installed mid-run, fresh wallpaper added since, or a previous
    # configure_monitors that short-circuited (no-TTY skip path).
    if [[ -f "$HOME/.config/foxml/monitor-layout.conf" ]]; then
        _generate_per_monitor_wallpapers
        _personalize_hyprlock
        _personalize_workspace_rules
    fi

    # Render waybar AFTER configure_monitors so start_waybar.sh sees the layout
    # sidecar and emits a multi-bar config when secondary monitors are present.
    # Then bounce the running waybar so the new config takes effect immediately
    # (otherwise the bar already on screen keeps the pre-configure single-bar
    # render until the next Hyprland session).
    if [[ -x "$HOME/.config/hypr/scripts/start_waybar.sh" ]]; then
        echo ""
        foxml_section "Rendering waybar for current monitor layout"
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

# Persistent install marker. Read by --quick on subsequent runs to skip
# the expensive parts (deps install, github clones, model pulls) when
# the theme/scripts just need a re-render.
mkdir -p "$HOME/.local/share/foxml"
{
    echo "theme=${THEME_NAME}"
    echo "installed_at=$(date -Iseconds)"
    echo "script_dir=${SCRIPT_DIR}"
} > "$HOME/.local/share/foxml/.installed-version"

# ─────────────────────────────────────────
# Pacman-style install summary
# ─────────────────────────────────────────
_summary_monitor_line() {
    # Read sidecar to produce a one-line monitor summary
    # ("eDP-1 1920x1080 + HDMI-A-1 1080x1920 (portrait)") for the report.
    local layout="$HOME/.config/foxml/monitor-layout.conf"
    [[ -f "$layout" ]] || { echo "none"; return; }
    # shellcheck disable=SC1090
    local PRIMARY="" PORTRAIT_OUTPUTS="" MONITOR_RESOLUTIONS=""
    source "$layout"
    [[ -z "$MONITOR_RESOLUTIONS" ]] && { echo "${PRIMARY:-unknown}"; return; }
    local out="" entry name res portrait
    for entry in $MONITOR_RESOLUTIONS; do
        name="${entry%%:*}"; res="${entry##*:}"
        portrait=""
        [[ " ${PORTRAIT_OUTPUTS:-} " == *" ${name} "* ]] && portrait=" (portrait)"
        [[ -n "$out" ]] && out+=" + "
        out+="${name} ${res}${portrait}"
    done
    echo "$out"
}
_summary_wallpaper_count() {
    # Count pre-rendered ${base}_${WxH}.${ext} files. nullglob keeps this
    # quiet on a setup with no variants yet.
    local count
    shopt -s nullglob
    count=$(printf '%s\n' "$HOME"/.wallpapers/*_[0-9]*x[0-9]*.{jpg,jpeg,png} | grep -c '.')
    shopt -u nullglob
    echo "${count:-0}"
}

echo ""
foxml_section "Installation Complete"
foxml_summary_row "Active theme"      "$THEME_NAME"
foxml_summary_row "Templates rendered" "${#TEMPLATE_MAPPINGS[@]}"
foxml_summary_row "Monitors detected"  "$(_summary_monitor_line)"
foxml_summary_row "Wallpapers cached"  "$(_summary_wallpaper_count)"
foxml_summary_row "Backups saved to"   "$BACKUP_DIR"

# Health check: run fox-doctor and surface the headline count. Full
# output goes through fox-doctor directly if the user wants details
# (just run `fox doctor`). Skips if fox-doctor isn't on PATH yet, e.g.
# the very first install hasn't propagated ~/.local/bin yet.
if command -v fox-doctor >/dev/null 2>&1; then
    _doctor_out=$(fox-doctor 2>&1 || true)
    _doctor_result=$(printf '%s\n' "$_doctor_out" | grep -E '^Result:' | tail -1)
    if [[ -n "$_doctor_result" ]]; then
        # Strip ANSI colour codes from the captured line so the row aligns.
        _doctor_result=$(printf '%s' "$_doctor_result" | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g; s/^Result: //')
        foxml_summary_row "Health check"     "${_doctor_result}"
        foxml_substep "run \`fox doctor\` for the full report"
    fi
fi
echo ""

# ─────────────────────────────────────────
# Auto-apply post-install actions. Each step self-skips when its
# precondition isn't met (no Hyprland session, waybar/dunst not running,
# no nvim install, no jq, no Cursor/Code dir).
# ─────────────────────────────────────────
apply_post_install() {
    foxml_section "Applying post-install actions"

    # Hyprland reload — only inside an active Hyprland session
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl &>/dev/null; then
        # Commented out by user request to prevent breaking portrait monitor configurations during install testing
        # hyprctl reload >/dev/null 2>&1 && echo "  + Hyprland reloaded"
        echo "  + Hyprland reload skipped (user requested)"
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

        # Rebuild treesitter parsers against current nvim ABI. Stale .so files
        # from an older Neovim cause "attempt to call method 'range' (a nil
        # value)" and similar errors after a Neovim version bump.
        if [[ -d "$HOME/.local/share/nvim/lazy/nvim-treesitter" ]]; then
            echo "  Rebuilding treesitter parsers (headless, 120s cap)..."
            if timeout 120 nvim --headless "+TSUpdateSync" "+qa" >/dev/null 2>&1; then
                echo "  + Treesitter parsers rebuilt"
            else
                echo "  ! TSUpdateSync didn't complete cleanly — run ':TSUpdateSync' manually"
            fi
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
_phase_mark post

echo ""
if $INSTALL_AI; then
    echo "Next steps:"
    echo "  - OpenCode is ready: run 'opencode' to start local AI development"
    echo "  - AI Notifications: Claude/Gemini will notify via mako/dunst on turn complete, subagent done, and input needed (ALT+SHIFT+E for triage). Restart any in-flight agent sessions to load the new hooks."
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
