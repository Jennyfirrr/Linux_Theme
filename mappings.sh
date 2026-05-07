#!/bin/bash
# FoxML Theme Hub — source → destination mappings
# Format: "relative-path|system-destination"
# ~ is expanded at runtime

# ─────────────────────────────────────────
# Template files (rendered with palette colors)
# Source: templates/ directory
# ─────────────────────────────────────────
TEMPLATE_MAPPINGS=(
    # Hyprland
    "hyprland/theme.conf|~/.config/hypr/modules/theme.conf"
    "hyprlock/hyprlock.conf|~/.config/hypr/hyprlock.conf"

    # Neovim
    "nvim/init.lua|~/.config/nvim/init.lua"

    # Kitty
    "kitty/kitty.conf|~/.config/kitty/kitty.conf"

    # Waybar — style.css carries __SIZE__ tokens that start_waybar.sh
    # substitutes at runtime based on detected monitor scale, so we deploy
    # it as .tmpl. The wrapper writes the live style.css on first launch.
    "waybar/style.css|~/.config/waybar/style.css.tmpl"

    # Tmux
    "tmux/.tmux.conf|~/.tmux.conf"

    # Zsh
    "zsh/.zshrc|~/.zshrc"
    "zsh/colors.zsh|~/.config/zsh/colors.zsh"
    "zsh/welcome.zsh|~/.config/zsh/welcome.zsh"
    "zsh/caramel.zsh-theme|~/.oh-my-zsh/themes/caramel.zsh-theme"

    # ReGreet (login screen — needs sudo to install to /etc/greetd/)
    # "regreet/regreet.css|/etc/greetd/regreet.css"

    # Mako
    "mako/config|~/.config/mako/config"

    # Dunst
    "dunst/dunstrc|~/.config/dunst/dunstrc"

    # Fastfetch
    "fastfetch/config.jsonc|~/.config/fastfetch/config.jsonc"

    # Rofi
    "rofi/glass.rasi|~/.config/rofi/glass.rasi"

    # GTK
    "gtk-3.0/gtk.css|~/.config/gtk-3.0/gtk.css"
    "gtk-4.0/gtk.css|~/.config/gtk-4.0/gtk.css"

    # btop
    "btop/foxml.theme|~/.config/btop/themes/foxml.theme"

    # Yazi
    "yazi/theme.toml|~/.config/yazi/theme.toml"

    # Lazygit
    "lazygit/config.yml|~/.config/lazygit/config.yml"

    # Zathura
    "zathura/zathurarc|~/.config/zathura/zathurarc"

    # Bat
    "bat/foxml.tmTheme|~/.config/bat/themes/Fox ML.tmTheme"

    # Border colors for scripts
    "hyprland/border_colors.sh|~/.config/hypr/modules/border_colors.sh"

    # Gemini CLI — GEMINI_DIR placeholder is resolved by the special handler,
    # which jq-merges into the user's settings.json to preserve security.auth.
    "gemini/settings.json|GEMINI_DIR/settings.json"

    # Git (delta pager — included from ~/.gitconfig, doesn't touch user identity)
    "git/delta.gitconfig|~/.config/git/delta-foxml.gitconfig"

    # Cursor/VS Code
    "cursor/foxml-color-theme.json|~/.cursor/extensions/foxml-theme/themes/foxml-color-theme.json"

    # Firefox
    "firefox/userChrome.css|FIREFOX_PROFILE/chrome/userChrome.css"
    "firefox/userContent.css|FIREFOX_PROFILE/chrome/userContent.css"
)

# ─────────────────────────────────────────
# Shared files (copied as-is, no rendering)
# Source: shared/ directory, with _ replacing /
# ─────────────────────────────────────────
SHARED_MAPPINGS=(
    # Hyprland
    "hyprland.conf|~/.config/hypr/hyprland.conf"
    "hyprland_hypridle_ac.conf|~/.config/hypr/hypridle-ac.conf"
    "hyprland_hypridle_battery.conf|~/.config/hypr/hypridle-battery.conf"

    # Launcher toggle scripts (referenced by keybinds.conf)
    "launchers/toggle/toggle_btop.sh|~/.config/launchers/toggle/toggle_btop.sh"
    "launchers/toggle/toggle_yazi.sh|~/.config/launchers/toggle/toggle_yazi.sh"

    # Neovim
    "nvim_lazy-lock.json|~/.config/nvim/lazy-lock.json"
    "nvim_ftplugin/cpp.lua|~/.config/nvim/ftplugin/cpp.lua"

    # Rofi config
    "rofi_config.rasi|~/.config/rofi/config.rasi"

    # GTK settings
    "gtk-3.0_settings.ini|~/.config/gtk-3.0/settings.ini"
    "gtk-4.0_settings.ini|~/.config/gtk-4.0/settings.ini"

    # Zsh non-color
    "zsh_aliases.zsh|~/.config/zsh/aliases.zsh"
    "zsh_git.zsh|~/.config/zsh/git.zsh"
    "zsh_paths.zsh|~/.config/zsh/paths.zsh"
    "zsh_conda.zsh|~/.config/zsh/conda.zsh"

    # Waybar config
    "waybar_config|~/.config/waybar/config.tmpl"

    # ReGreet (login screen — needs sudo to install to /etc/greetd/)
    # "regreet.toml|/etc/greetd/regreet.toml"
)

# ─────────────────────────────────────────
# Special install handlers
# ─────────────────────────────────────────

get_firefox_profile() {
    # Firefox 150+ on Arch defaults to XDG paths (~/.config/mozilla/firefox);
    # older versions and other distros still use the legacy ~/.mozilla path.
    # Check both, preferring whichever has a *.default-release profile.
    for base in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox"; do
        local hit
        hit=$(find "$base" -maxdepth 1 -name "*.default-release*" -type d 2>/dev/null | head -1)
        [[ -n "$hit" ]] && { echo "$hit"; return; }
    done
}

install_specials() {
    local rendered_dir="$1"

    # Firefox — resolve FIREFOX_PROFILE placeholder
    local ff_profile
    ff_profile="$(get_firefox_profile)"
    if [[ -n "$ff_profile" ]]; then
        for css in userChrome.css userContent.css; do
            if [[ -f "$rendered_dir/firefox/$css" ]]; then
                mkdir -p "$ff_profile/chrome"
                cp "$rendered_dir/firefox/$css" "$ff_profile/chrome/$css"
                echo "  ✓ Firefox $css"
            fi
        done
        # Set the legacy stylesheet pref via user.js so userChrome/userContent
        # actually load — user.js is read on every launch and overrides
        # prefs.js, so this stays correct even if Firefox rewrites prefs.
        local ff_userjs="$ff_profile/user.js"
        local ff_pref='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
        if ! grep -qF 'toolkit.legacyUserProfileCustomizations.stylesheets' "$ff_userjs" 2>/dev/null; then
            printf '// FoxML theming\n%s\n' "$ff_pref" >> "$ff_userjs"
            echo "  ✓ Firefox user.js (legacy stylesheet pref)"
        fi
    else
        echo "  ⚠ No Firefox profile found, skipping"
    fi

    # Cursor/VS Code — package.json setup
    for ext_dir in ~/.cursor/extensions ~/.vscode/extensions; do
        if [[ -d "$ext_dir" && -f "$rendered_dir/cursor/foxml-color-theme.json" ]]; then
            mkdir -p "$ext_dir/foxml-theme/themes"
            cp "$rendered_dir/cursor/foxml-color-theme.json" "$ext_dir/foxml-theme/themes/"
            cat > "$ext_dir/foxml-theme/package.json" << 'PKGJSON'
{
  "name": "foxml-theme",
  "displayName": "Fox ML Theme",
  "version": "1.0.0",
  "publisher": "foxml",
  "engines": { "vscode": "^1.60.0" },
  "categories": ["Themes"],
  "contributes": {
    "themes": [{ "label": "Fox ML", "uiTheme": "vs-dark", "path": "./themes/foxml-color-theme.json" }]
  }
}
PKGJSON
            echo "  ✓ $(basename "$ext_dir" | sed 's/^\.//') theme"
        fi
    done

    # Bat cache rebuild
    if command -v bat &>/dev/null; then
        bat cache --build &>/dev/null
        echo "  ✓ Bat cache rebuilt"
    fi

    # Gemini CLI — merge the rendered ui block into the user's settings.json so
    # security/auth keys are preserved. Falls back to a plain copy if the file
    # doesn't exist yet, or if jq isn't available.
    local gemini_dir="${GEMINI_CONFIG_HOME:-$HOME/.gemini}"
    local gemini_settings="$gemini_dir/settings.json"
    if [[ -f "$rendered_dir/gemini/settings.json" ]]; then
        if [[ -f "$gemini_settings" ]]; then
            local tmp_settings; tmp_settings="$(mktemp)"
            if jq -s '.[0] * .[1]' "$gemini_settings" "$rendered_dir/gemini/settings.json" > "$tmp_settings" 2>/dev/null; then
                mv "$tmp_settings" "$gemini_settings"
                echo "  ✓ Gemini theme merged"
            else
                rm -f "$tmp_settings"
                echo "  ⚠ Gemini merge failed, skipping"
            fi
        else
            mkdir -p "$(dirname "$gemini_settings")"
            cp "$rendered_dir/gemini/settings.json" "$gemini_settings"
            echo "  ✓ Gemini theme installed"
        fi
    fi

    # ~/.local/bin helpers (tmux pane-label, etc.) — referenced by configs but
    # too small for their own subdir; kept executable on copy.
    if [[ -d "$SCRIPT_DIR/shared/bin" ]]; then
        mkdir -p "$HOME/.local/bin"
        for bin in "$SCRIPT_DIR/shared/bin/"*; do
            [[ -f "$bin" ]] || continue
            cp "$bin" "$HOME/.local/bin/$(basename "$bin")"
            chmod +x "$HOME/.local/bin/$(basename "$bin")"
            echo "  ✓ bin/$(basename "$bin")"
        done
    fi

    # Hyprland scripts
    if [[ -d "$SCRIPT_DIR/shared/hyprland_scripts" ]]; then
        mkdir -p ~/.config/hypr/scripts
        for script in "$SCRIPT_DIR/shared/hyprland_scripts/"*.sh; do
            [[ -f "$script" ]] || continue
            cp "$script" "$HOME/.config/hypr/scripts/$(basename "$script")"
            chmod +x "$HOME/.config/hypr/scripts/$(basename "$script")"
            echo "  ✓ scripts/$(basename "$script")"
        done
    fi

    # Waybar scripts
    if [[ -d "$SCRIPT_DIR/shared/waybar_scripts" ]]; then
        mkdir -p ~/.config/waybar/scripts
        for script in "$SCRIPT_DIR/shared/waybar_scripts/"*.sh; do
            [[ -f "$script" ]] || continue
            cp "$script" "$HOME/.config/waybar/scripts/$(basename "$script")"
            chmod +x "$HOME/.config/waybar/scripts/$(basename "$script")"
            echo "  ✓ waybar/$(basename "$script")"
        done
    fi

    # Hyprland modules
    if [[ -d "$SCRIPT_DIR/shared/hyprland_modules" ]]; then
        mkdir -p ~/.config/hypr/modules
        for mod in "$SCRIPT_DIR/shared/hyprland_modules/"*.conf; do
            [[ -f "$mod" ]] || continue
            local basename="$(basename "$mod")"
            [[ "$basename" == "theme.conf" ]] && continue   # theme.conf comes from templates
            [[ "$basename" == "nvidia.conf" ]] && continue  # opt-in, handled by install_nvidia()
            cp "$mod" "$HOME/.config/hypr/modules/$basename"
            echo "  ✓ modules/$basename"
        done
    fi

    # ReGreet (login screen — requires sudo)
    if [[ -f "$rendered_dir/regreet/regreet.css" ]]; then
        # Stage files where user can review them
        mkdir -p ~/.config/regreet
        cp "$rendered_dir/regreet/regreet.css" ~/.config/regreet/regreet.css
        cp "$SCRIPT_DIR/shared/regreet.toml" ~/.config/regreet/regreet.toml
        cp "$SCRIPT_DIR/shared/greetd_hyprland.conf" ~/.config/regreet/hyprland.conf
        echo "  ✓ ReGreet staged to ~/.config/regreet/"
        echo "  To activate:"
        echo "    sudo cp ~/.config/regreet/regreet.{css,toml} /etc/greetd/"
        echo "    sudo cp ~/.config/regreet/hyprland.conf /etc/greetd/hyprland.conf"
        echo "    sudo cp ~/.wallpapers/foxml_earthy.jpg /usr/share/wallpapers/"
        echo "  Then set greetd config.toml to:"
        echo "    command = \"Hyprland -c /etc/greetd/hyprland.conf\""
    fi

    # Wallpapers (image files only — skip README etc.)
    if [[ -d "$SCRIPT_DIR/shared/wallpapers" ]]; then
        mkdir -p ~/.wallpapers
        shopt -s nullglob nocaseglob
        for wp in "$SCRIPT_DIR/shared/wallpapers/"*.{jpg,jpeg,png,webp}; do
            cp "$wp" ~/.wallpapers/
            echo "  ✓ $(basename "$wp")"
        done
        shopt -u nullglob nocaseglob
    fi

    # Cursor theme — Catppuccin Mocha Peach matches the FoxML earthy palette.
    # The Hyprland env + GTK ini both reference it; this fetches the theme
    # files from the upstream GitHub release if they're not already present.
    local cursor_name="catppuccin-mocha-peach-cursors"
    local cursor_dir="$HOME/.local/share/icons/$cursor_name"
    if [[ ! -d "$cursor_dir" ]]; then
        local cursor_url="https://github.com/catppuccin/cursors/releases/download/v2.0.0/${cursor_name}.zip"
        local tmp_zip; tmp_zip="$(mktemp --suffix=.zip)"
        if curl -fsSL -o "$tmp_zip" "$cursor_url"; then
            mkdir -p "$HOME/.local/share/icons"
            unzip -o -q "$tmp_zip" -d "$HOME/.local/share/icons/"
            rm -f "$tmp_zip"
            echo "  ✓ cursor theme: $cursor_name"
        else
            echo "  ⚠ cursor download failed; install from AUR or skip"
        fi
    else
        echo "  ✓ cursor theme already present"
    fi
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface cursor-theme "$cursor_name" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-size 30 2>/dev/null || true
    fi

    # Icon theme — Papirus-Dark with Catppuccin Mocha Peach folders. The
    # GTK ini already references Papirus-Dark; this fetches the theme
    # user-locally (no sudo) and recolors folders to match the cursor.
    local icons_dir="$HOME/.local/share/icons"
    if [[ ! -d "$icons_dir/Papirus" ]]; then
        if curl -fsSL "https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh" \
                | DESTDIR="$icons_dir" sh &>/dev/null; then
            echo "  ✓ Papirus icon theme"
        else
            echo "  ⚠ Papirus install failed; skipping folder recolor"
        fi
    else
        echo "  ✓ Papirus already present"
    fi

    if [[ -d "$icons_dir/Papirus" ]]; then
        # Inject Catppuccin folder SVGs (Papirus-Dark/Light symlink to Papirus)
        local cat_tmp; cat_tmp="$(mktemp -d)"
        if git clone --depth 1 --quiet \
                https://github.com/catppuccin/papirus-folders.git "$cat_tmp/repo" 2>/dev/null; then
            cp -r "$cat_tmp/repo/src/"* "$icons_dir/Papirus/" 2>/dev/null || true
            echo "  ✓ Catppuccin folder palette injected"
        fi
        rm -rf "$cat_tmp"

        # Fetch the papirus-folders helper if not on PATH and apply peach color
        local pf_script
        if command -v papirus-folders &>/dev/null; then
            pf_script="papirus-folders"
        else
            pf_script="$(mktemp)"
            curl -fsSL -o "$pf_script" \
                "https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders" \
                && chmod +x "$pf_script"
        fi
        if [[ -x "$pf_script" ]]; then
            "$pf_script" -C cat-mocha-peach -t Papirus-Dark &>/dev/null || true
            echo "  ✓ folders → cat-mocha-peach"
            [[ "$pf_script" != "papirus-folders" ]] && rm -f "$pf_script"
        fi

        if command -v gsettings &>/dev/null; then
            gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
        fi
    fi

    # bat — write a tiny config that selects the FoxML tmTheme by name
    local bat_dir="$HOME/.config/bat"
    if [[ -d "$bat_dir/themes" ]]; then
        if [[ -f "$bat_dir/config" ]] && grep -q '^--theme=' "$bat_dir/config"; then
            sed -i -E 's|^--theme=.*|--theme="Fox ML"|' "$bat_dir/config"
        else
            mkdir -p "$bat_dir"
            printf -- '--theme="Fox ML"\n' >> "$bat_dir/config"
        fi
        echo "  ✓ bat --theme=\"Fox ML\""
    fi

    # delta — wire the rendered FoxML gitconfig in via [include] so the user's
    # ~/.gitconfig (identity, etc.) stays untouched. git-config -e replaces the
    # same key on re-runs, and we only add the include if delta is installed.
    if command -v delta &>/dev/null && [[ -f "$rendered_dir/git/delta.gitconfig" ]]; then
        local delta_inc="$HOME/.config/git/delta-foxml.gitconfig"
        if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$delta_inc"; then
            git config --global --add include.path "$delta_inc"
        fi
        echo "  ✓ git delta include → $delta_inc"
    fi

    # btop — point btop.conf at the FoxML theme. If btop hasn't run yet there's
    # no btop.conf; create a one-line config (btop auto-fills the rest of the
    # defaults on first launch). Without this branch the theme silently no-ops
    # on first install.
    local btop_conf="$HOME/.config/btop/btop.conf"
    if [[ ! -f "$btop_conf" ]]; then
        mkdir -p "$(dirname "$btop_conf")"
        echo 'color_theme = "foxml"' > "$btop_conf"
        echo "  ✓ btop.conf created with FoxML theme"
    elif grep -qE '^color_theme\s*=\s*"foxml"' "$btop_conf"; then
        echo "  ✓ btop already on FoxML theme"
    elif grep -qE '^color_theme\s*=' "$btop_conf"; then
        sed -i -E 's|^(color_theme\s*=\s*).*|\1"foxml"|' "$btop_conf"
        echo "  ✓ btop color_theme → foxml"
    else
        echo 'color_theme = "foxml"' >> "$btop_conf"
        echo "  ✓ btop color_theme → foxml"
    fi

    # Systemd user units (wallpaper rotation timer, etc.)
    if [[ -d "$SCRIPT_DIR/shared/systemd_user" ]]; then
        mkdir -p ~/.config/systemd/user
        local installed_any=0
        for unit in "$SCRIPT_DIR/shared/systemd_user/"*.{service,timer}; do
            [[ -f "$unit" ]] || continue
            cp "$unit" "$HOME/.config/systemd/user/$(basename "$unit")"
            echo "  ✓ systemd/$(basename "$unit")"
            installed_any=1
        done
        if (( installed_any )); then
            systemctl --user daemon-reload &>/dev/null || true
            for timer in "$SCRIPT_DIR/shared/systemd_user/"*.timer; do
                [[ -f "$timer" ]] || continue
                systemctl --user enable --now "$(basename "$timer")" &>/dev/null || true
            done
            echo "  ✓ systemd user timers enabled"
        fi
    fi
}

# ─────────────────────────────────────────
# Nvidia (full Wayland session on dGPU) — opt-in via install.sh --nvidia
# Wires Hyprland env vars + mkinitcpio MODULES + kernel cmdline so the
# nvidia driver loads at boot and Aquamarine targets the discrete card.
# Idempotent: rerunning detects existing config and skips edits.
# ─────────────────────────────────────────

install_nvidia() {
    # Detect dGPU and iGPU PCI addresses. Aquamarine needs BOTH because the
    # eDP display is hardwired to the iGPU on Optimus laptops — nvidia
    # renders, intel scans out via DMA-BUF.
    local nvidia_addr="" intel_addr=""
    for dev in /sys/bus/pci/devices/*/; do
        local vendor class
        vendor="$(cat "$dev/vendor" 2>/dev/null)"
        class="$(cat "$dev/class" 2>/dev/null)"
        [[ "$class" == 0x03* ]] || continue   # display controllers only
        case "$vendor" in
            0x10de) [[ -z "$nvidia_addr" ]] && nvidia_addr="$(basename "$dev")" ;;
            0x8086) [[ -z "$intel_addr" ]]  && intel_addr="$(basename "$dev")" ;;
            0x1002) [[ -z "$intel_addr" ]]  && intel_addr="$(basename "$dev")" ;;  # AMD iGPU also fits the scanout role
        esac
    done

    if [[ -z "$nvidia_addr" ]]; then
        echo "  ⚠ No NVIDIA GPU found, skipping nvidia setup"
        return
    fi

    # Resolve by-path symlinks to /dev/dri/cardN — aquamarine splits
    # AQ_DRM_DEVICES on ':', and the by-path names contain ':' themselves
    # (pci-0000:01:00.0-card), which shreds the list. cardN is colon-free.
    local nvidia_drm intel_drm
    nvidia_drm="$(readlink -f "/dev/dri/by-path/pci-${nvidia_addr}-card" 2>/dev/null)"
    if [[ -z "$nvidia_drm" || ! -e "$nvidia_drm" ]]; then
        echo "  ⚠ Could not resolve /dev/dri/by-path/pci-${nvidia_addr}-card — is the nvidia driver loaded?"
        return
    fi
    local aq_drm_devices="$nvidia_drm"
    if [[ -n "$intel_addr" ]]; then
        intel_drm="$(readlink -f "/dev/dri/by-path/pci-${intel_addr}-card" 2>/dev/null)"
        if [[ -n "$intel_drm" && -e "$intel_drm" ]]; then
            aq_drm_devices+=":${intel_drm}"
            echo "  Detected NVIDIA at ${nvidia_addr} (${nvidia_drm}), iGPU at ${intel_addr} (${intel_drm})"
        else
            echo "  Detected NVIDIA at ${nvidia_addr} (${nvidia_drm}); iGPU at ${intel_addr} but no DRM node yet — listing nvidia only"
        fi
    else
        echo "  Detected NVIDIA at ${nvidia_addr} (${nvidia_drm}) (no iGPU — single-GPU box)"
    fi

    # Hyprland env-var module
    if [[ -f "$SCRIPT_DIR/shared/hyprland_modules/nvidia.conf" ]]; then
        mkdir -p ~/.config/hypr/modules
        sed "s|AQ_DRM_DEVICES,.*|AQ_DRM_DEVICES, ${aq_drm_devices}|" \
            "$SCRIPT_DIR/shared/hyprland_modules/nvidia.conf" \
            > ~/.config/hypr/modules/nvidia.conf
        echo "  ✓ modules/nvidia.conf (AQ_DRM_DEVICES → ${aq_drm_devices})"

        local hypr_main="$HOME/.config/hypr/hyprland.conf"
        if [[ -f "$hypr_main" ]] && ! grep -qF 'modules/nvidia.conf' "$hypr_main"; then
            printf '\n# Nvidia (added by install.sh --nvidia)\nsource = ~/.config/hypr/modules/nvidia.conf\n' \
                >> "$hypr_main"
            echo "  ✓ hyprland.conf sources nvidia.conf"
        fi
    fi

    # /etc/mkinitcpio.conf — early-load nvidia modules so they claim the device
    # before kms / nouveau can. Idempotent: skip if nvidia_drm already listed.
    #
    # Guard against tiny EFI System Partitions: nvidia-bearing initramfs grows
    # to ~135 MB on this driver line, and a half-written .img on a full /boot
    # leaves the system unbootable. Refuse to edit if /boot has under 80 MB free.
    local mkinit="/etc/mkinitcpio.conf"
    if [[ -f "$mkinit" ]] && ! grep -qE '^MODULES=.*nvidia_drm' "$mkinit"; then
        local boot_free_mb
        boot_free_mb=$(df --output=avail -BM /boot 2>/dev/null | tail -1 | tr -dc '0-9')
        if [[ -n "$boot_free_mb" && "$boot_free_mb" -lt 80 ]]; then
            echo "  ⚠ /boot has only ${boot_free_mb} MB free — skipping mkinitcpio edit"
            echo "    nvidia-bearing initramfs needs ~135 MB. Free space in /boot"
            echo "    (older kernels, fallback initramfs) and re-run, or skip this"
            echo "    step — the dGPU will still render via udev module loading."
        else
            sudo sed -i.foxml-bak \
                's/^MODULES=([^)]*)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
                "$mkinit"
            echo "  ✓ mkinitcpio MODULES updated (backup: ${mkinit}.foxml-bak)"
            sudo mkinitcpio -P 2>&1 | tail -3
        fi
    else
        echo "  • mkinitcpio already has nvidia modules"
    fi

    # systemd-boot loader entry — add kernel cmdline for DRM modeset.
    # Other bootloaders (GRUB, refind) need manual editing; we warn here.
    local boot_entry="/boot/loader/entries/arch.conf"
    if [[ -f "$boot_entry" ]]; then
        if ! grep -qF 'nvidia_drm.modeset=1' "$boot_entry"; then
            sudo sed -i.foxml-bak \
                -E 's/^(options .*)$/\1 nvidia_drm.modeset=1 nvidia_drm.fbdev=1/' \
                "$boot_entry"
            echo "  ✓ kernel cmdline updated (backup: ${boot_entry}.foxml-bak)"
        else
            echo "  • kernel cmdline already has nvidia_drm.modeset=1"
        fi
    elif [[ -f /etc/default/grub ]]; then
        echo "  ⚠ GRUB detected — add 'nvidia_drm.modeset=1 nvidia_drm.fbdev=1'"
        echo "    to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub, then"
        echo "    run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    else
        echo "  ⚠ Unknown bootloader — add 'nvidia_drm.modeset=1 nvidia_drm.fbdev=1'"
        echo "    to your kernel cmdline manually."
    fi

    echo ""
    echo "  Reboot to load the nvidia driver."
    echo "  Recovery: if Hyprland fails to start, switch to a TTY"
    echo "  (Ctrl+Alt+F2), restore ${mkinit}.foxml-bak and"
    echo "  ${boot_entry}.foxml-bak, run 'sudo mkinitcpio -P', reboot."
}

# ─────────────────────────────────────────
# Catppuccin cursor (referenced by GTK / Hyprland env / regreet.toml).
# Not in official Arch repos; pull from upstream GitHub releases and drop
# into ~/.local/share/icons (per-user, no sudo). Idempotent.
# ─────────────────────────────────────────

install_catppuccin_cursor() {
    local theme="catppuccin-mocha-peach-cursors"
    local user_dir="$HOME/.local/share/icons"
    local sys_dir="/usr/share/icons"

    if [[ -d "$sys_dir/$theme" || -d "$user_dir/$theme" ]]; then
        echo "  • $theme already installed"
        return
    fi

    if ! command -v curl >/dev/null 2>&1; then
        echo "  ⚠ curl not found — install curl or fetch $theme manually"
        return
    fi

    # GitHub release asset name (catppuccin/cursors ships one zip per flavor).
    local asset="${theme}.zip"
    local api="https://api.github.com/repos/catppuccin/cursors/releases/latest"
    local url
    url=$(curl -fsSL "$api" 2>/dev/null \
            | grep -oE "https://[^\"]+/${asset}" \
            | head -1)

    if [[ -z "$url" ]]; then
        echo "  ⚠ Couldn't resolve $asset from $api — skipping cursor install"
        return
    fi

    local tmp
    tmp=$(mktemp -d)
    if ! curl -fsSL -o "$tmp/$asset" "$url"; then
        echo "  ⚠ Download failed: $url"
        rm -rf "$tmp"
        return
    fi

    if ! command -v unzip >/dev/null 2>&1; then
        echo "  ⚠ unzip not found — pacman -S unzip then re-run"
        rm -rf "$tmp"
        return
    fi

    mkdir -p "$user_dir"
    unzip -q -o "$tmp/$asset" -d "$user_dir"
    rm -rf "$tmp"

    if [[ -d "$user_dir/$theme" ]]; then
        echo "  ✓ $theme → $user_dir"
    else
        echo "  ⚠ Extraction did not produce $user_dir/$theme — check asset layout"
    fi
}

# ─────────────────────────────────────────
# greetd + regreet (themed login screen)
# Auto-runs when greetd-regreet is installed. Idempotent.
# Replaces the README's manual "sudo cp + tee" post-install dance.
# ─────────────────────────────────────────

install_greetd() {
    if ! pacman -Qi greetd-regreet &>/dev/null; then
        echo "  • greetd-regreet not installed, skipping login-screen setup"
        return
    fi

    local staged="$HOME/.config/regreet"
    if [[ ! -f "$staged/regreet.css" || ! -f "$staged/regreet.toml" || ! -f "$staged/hyprland.conf" ]]; then
        echo "  ⚠ Staged regreet files missing in $staged — skipping"
        return
    fi

    # Wallpaper referenced from regreet.toml. Read it out and copy that exact
    # file, so theme swaps that change the wallpaper Just Work.
    local wall_path
    wall_path=$(awk -F'"' '/^path *= *"/ { print $2; exit }' "$staged/regreet.toml")
    [[ -z "$wall_path" ]] && wall_path="/usr/share/wallpapers/foxml_earthy.jpg"
    local wall_name="$(basename "$wall_path")"
    local wall_src="$HOME/.wallpapers/$wall_name"

    if [[ ! -f "$wall_src" ]]; then
        echo "  ⚠ Login wallpaper $wall_src missing — copy your wallpaper to ~/.wallpapers/ first"
        return
    fi

    sudo install -d /etc/greetd /usr/share/wallpapers
    sudo install -m 644 "$staged/regreet.css"     /etc/greetd/regreet.css
    sudo install -m 644 "$staged/regreet.toml"    /etc/greetd/regreet.toml
    sudo install -m 644 "$staged/hyprland.conf"   /etc/greetd/hyprland.conf
    sudo install -m 644 "$wall_src"               "$wall_path"
    echo "  ✓ regreet css/toml/hyprland.conf → /etc/greetd/"
    echo "  ✓ login wallpaper → $wall_path"

    # /etc/greetd/config.toml — only rewrite if it's still the stock default
    # (command = "agreety …"). Preserve any user customization beyond that.
    local cfg=/etc/greetd/config.toml
    if [[ ! -f "$cfg" ]] || sudo grep -qE '^command = "agreety' "$cfg" 2>/dev/null; then
        sudo tee "$cfg" >/dev/null <<'EOF'
[terminal]
vt = 1
[default_session]
command = "Hyprland -c /etc/greetd/hyprland.conf"
user = "greeter"
EOF
        echo "  ✓ /etc/greetd/config.toml (Hyprland greeter session)"
    else
        echo "  • /etc/greetd/config.toml already customized — leaving as-is"
    fi

    if ! systemctl is-enabled --quiet greetd 2>/dev/null; then
        sudo systemctl enable greetd && echo "  ✓ greetd enabled (login screen on next boot)"
    else
        echo "  • greetd already enabled"
    fi
}

# ─────────────────────────────────────────
# CPU throttling / power tuning — interactive wizard prompted at end of
# install. Each step is its own y/N so users can pick & choose:
#   * Intel turbo disable → /etc/tmpfiles.d/disable-turbo.conf
#     (systemd-tmpfiles re-applies on every boot, so the kernel reset
#     after suspend/wake doesn't bring turbo back)
#   * cpupower max-frequency cap → persisted via /etc/default/cpupower
#     and cpupower.service so it survives reboots
#   * Optional CPU governor (powersave / performance / schedutil / etc.)
#   * throttled — Lenovo ThinkPad MSR-based undervolt + temperature fix
#     from AUR (only offered when DMI says ThinkPad)
# Skipped under -y because every step needs a user-chosen value.
# ─────────────────────────────────────────

# Idempotent KEY=VALUE writer for /etc/default/cpupower (sourced as shell
# by the cpupower service). Replaces an existing key if present, else
# appends. Numeric values pass unquoted; quote string values at the call
# site (`'performance'`).
_persist_cpupower() {
    local key="$1" val="$2"
    sudo install -d /etc/default
    [[ -f /etc/default/cpupower ]] || echo "" | sudo tee /etc/default/cpupower >/dev/null
    if sudo grep -qE "^${key}=" /etc/default/cpupower; then
        sudo sed -i -E "s|^${key}=.*|${key}=${val}|" /etc/default/cpupower
    else
        echo "${key}=${val}" | sudo tee -a /etc/default/cpupower >/dev/null
    fi
}

install_throttling() {
    if $ASSUME_YES; then
        echo ""
        echo "  • Throttling setup skipped (run without -y to configure)"
        return
    fi

    echo ""
    echo "╭──────────────────────────────────────────────────────────────────╮"
    echo "│   CPU Throttling / Power Setup (optional)                       │"
    echo "├──────────────────────────────────────────────────────────────────┤"
    echo "│ Configure max-frequency cap, Intel turbo, governor, and (on     │"
    echo "│ ThinkPads) the 'throttled' MSR fix. Each step is opt-in.        │"
    echo "╰──────────────────────────────────────────────────────────────────╯"
    read -p "Configure CPU throttling now? [y/N] " -n 1 -r; echo ""
    [[ ! $REPLY =~ ^[Yy]$ ]] && return

    # Hardware detection
    local is_intel=false is_thinkpad=false
    grep -qi 'GenuineIntel' /proc/cpuinfo && is_intel=true
    if [[ -r /sys/class/dmi/id/product_family ]] \
        && grep -qi thinkpad /sys/class/dmi/id/product_family 2>/dev/null; then
        is_thinkpad=true
    elif [[ -r /sys/class/dmi/id/product_version ]] \
        && grep -qi thinkpad /sys/class/dmi/id/product_version 2>/dev/null; then
        is_thinkpad=true
    fi

    # Resolve AUR helper — may not be set if --deps wasn't passed earlier
    local aur=""
    command -v yay  &>/dev/null && aur="yay"
    [[ -z "$aur" ]] && command -v paru &>/dev/null && aur="paru"

    # ── 1. Intel turbo ────────────────────────────────────────────
    if $is_intel && [[ -e /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
        local turbo_now turbo_state="enabled"
        turbo_now=$(cat /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null)
        [[ "$turbo_now" == "1" ]] && turbo_state="disabled"
        echo ""
        echo "  Intel Turbo Boost is currently: ${turbo_state}"
        read -p "  Disable Intel turbo on every boot? [y/N] " -n 1 -r; echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo install -d /etc/tmpfiles.d
            sudo tee /etc/tmpfiles.d/disable-turbo.conf >/dev/null <<'EOF'
# Re-applied on every boot by systemd-tmpfiles
w /sys/devices/system/cpu/intel_pstate/no_turbo - - - - 1
EOF
            sudo systemd-tmpfiles --create /etc/tmpfiles.d/disable-turbo.conf >/dev/null 2>&1
            echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo >/dev/null
            echo "    ✓ Intel Turbo disabled (now and on every boot)"
        fi
    fi

    # ── 2. cpupower max frequency ─────────────────────────────────
    echo ""
    read -p "  Cap CPU max frequency via cpupower? [y/N] " -n 1 -r; echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! pacman -Qi cpupower &>/dev/null; then
            echo "    Installing cpupower..."
            sudo pacman -S --needed --noconfirm cpupower
        fi
        local hw_max_khz hw_max_mhz
        hw_max_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo 0)
        hw_max_mhz=$((hw_max_khz / 1000))
        (( hw_max_mhz > 0 )) && echo "    Hardware max: ${hw_max_mhz} MHz"
        read -p "    Cap max frequency in MHz (e.g. 2400, blank to skip): " max_mhz
        if [[ "$max_mhz" =~ ^[0-9]+$ ]] && (( max_mhz > 0 )); then
            local max_khz=$((max_mhz * 1000))
            if sudo cpupower frequency-set -u "${max_mhz}MHz" >/dev/null 2>&1; then
                echo "    ✓ Max set to ${max_mhz} MHz (live)"
            else
                echo "    ⚠ Live cap failed — will still try to persist"
            fi
            _persist_cpupower max_freq "${max_khz}"
            echo "    ✓ Persisted via /etc/default/cpupower"
        elif [[ -n "$max_mhz" ]]; then
            echo "    ⚠ '$max_mhz' is not a positive integer — skipping"
        fi
    fi

    # ── 3. CPU governor ───────────────────────────────────────────
    if command -v cpupower &>/dev/null; then
        local available_gov
        available_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
        if [[ -n "$available_gov" ]]; then
            echo ""
            echo "  Available governors: $available_gov"
            read -p "  Set CPU governor (blank to skip): " governor
            if [[ -n "$governor" ]]; then
                # validate against the available list to avoid a confusing live-set failure
                if [[ " $available_gov " == *" $governor "* ]]; then
                    sudo cpupower frequency-set -g "$governor" >/dev/null 2>&1
                    _persist_cpupower governor "'${governor}'"
                    echo "    ✓ Governor → $governor (now and persistent)"
                else
                    echo "    ⚠ '$governor' not in available list — skipping"
                fi
            fi
        fi
    fi

    # Enable cpupower.service so /etc/default/cpupower applies on every boot
    if pacman -Qi cpupower &>/dev/null && [[ -f /etc/default/cpupower ]]; then
        if ! systemctl is-enabled --quiet cpupower.service 2>/dev/null; then
            sudo systemctl enable --now cpupower.service >/dev/null 2>&1 \
                && echo "  ✓ cpupower.service enabled"
        fi
    fi

    # ── 4. throttled (ThinkPad MSR fix) ───────────────────────────
    if $is_thinkpad; then
        echo ""
        echo "  ThinkPad detected — 'throttled' applies an MSR-based undervolt"
        echo "  + thermal-cap fix, configured via /etc/throttled.conf."
        echo "  A documented sample lives at shared/throttled.conf."
        read -p "  Install throttled from AUR? [y/N] " -n 1 -r; echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if ! pacman -Qi throttled &>/dev/null; then
                if [[ -n "$aur" ]]; then
                    "$aur" -S --needed throttled
                else
                    echo "    ⚠ No AUR helper (yay/paru) found. Re-run install with"
                    echo "      --deps to install yay first, then retry this wizard."
                fi
            else
                echo "    • throttled already installed"
            fi
            if pacman -Qi throttled &>/dev/null \
                && ! systemctl is-active --quiet throttled.service; then
                sudo systemctl enable --now throttled.service >/dev/null 2>&1 \
                    && echo "    ✓ throttled enabled (edit /etc/throttled.conf to tune)"
            fi
        fi
    fi

    echo ""
    echo "  Done. Verify with: cpupower frequency-info | head -20"
}

# ─────────────────────────────────────────
# Special update handlers (pull system → templates)
# ─────────────────────────────────────────

update_specials() {
    local template_dir="$1"
    local sed_expr="$2"

    # Firefox
    local ff_profile
    ff_profile="$(get_firefox_profile)"
    if [[ -n "$ff_profile" ]]; then
        for css in userChrome.css userContent.css; do
            if [[ -f "$ff_profile/chrome/$css" ]]; then
                sed "$sed_expr" "$ff_profile/chrome/$css" > "$template_dir/firefox/$css"
                echo "  ✓ Firefox $css"
            fi
        done
    fi

    # Cursor/VS Code
    for ext_dir in ~/.cursor/extensions ~/.vscode/extensions; do
        local src="$ext_dir/foxml-theme/themes/foxml-color-theme.json"
        if [[ -f "$src" ]]; then
            sed "$sed_expr" "$src" > "$template_dir/cursor/foxml-color-theme.json"
            echo "  ✓ foxml-color-theme.json"
            break
        fi
    done

    # Bat
    local bat_dir
    bat_dir="$(bat --config-dir 2>/dev/null || echo "$HOME/.config/bat")"
    if [[ -f "$bat_dir/themes/Fox ML.tmTheme" ]]; then
        sed "$sed_expr" "$bat_dir/themes/Fox ML.tmTheme" > "$template_dir/bat/foxml.tmTheme"
        echo "  ✓ Bat theme"
    fi

    # Gemini CLI — pull only the ui block back into the template; keeping
    # security/auth out of the captured template avoids leaking session creds
    # into the repo on `update.sh`.
    local gemini_dir="${GEMINI_CONFIG_HOME:-$HOME/.gemini}"
    local gemini_settings="$gemini_dir/settings.json"
    if [[ -f "$gemini_settings" ]]; then
        local tmp_ui; tmp_ui="$(mktemp)"
        if jq '{ui: .ui}' "$gemini_settings" > "$tmp_ui" 2>/dev/null; then
            mkdir -p "$template_dir/gemini"
            sed "$sed_expr" "$tmp_ui" > "$template_dir/gemini/settings.json"
            echo "  ✓ Gemini theme"
        fi
        rm -f "$tmp_ui"
    fi

    # Hyprland scripts
    if [[ -d ~/.config/hypr/scripts ]]; then
        mkdir -p "$SCRIPT_DIR/shared/hyprland_scripts"
        for script in ~/.config/hypr/scripts/*.sh; do
            [[ -f "$script" ]] || continue
            cp "$script" "$SCRIPT_DIR/shared/hyprland_scripts/$(basename "$script")"
            echo "  ✓ scripts/$(basename "$script")"
        done
    fi
}
