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

    # Eww

    # Bat
    "bat/foxml.tmTheme|~/.config/bat/themes/Fox ML.tmTheme"

    # Border colors for scripts
    "hyprland/border_colors.sh|~/.config/hypr/modules/border_colors.sh"

    # AI Agent — AGENT_DIR placeholder is resolved by the special handler,
    # which jq-merges into the user's settings.json to preserve security.auth.
    "gemini/settings.json|AGENT_DIR/settings.json"

    # OpenCode TUI theme — palette-driven; deploy as a custom theme that
    # opencode.json references via "theme": "foxml".
    "opencode/foxml.json|~/.config/opencode/themes/foxml.json"

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
    "bin/fox-ai-swap|~/.local/bin/fox-ai-swap"
    "bin/fox-ai-status|~/.local/bin/fox-ai-status"
    "bin/fox-ai-commit|~/.local/bin/fox-ai-commit"
    "bin/fox-ai-purge|~/.local/bin/fox-ai-purge"
    "bin/fox-ai-log|~/.local/bin/fox-ai-log"
    "bin/fox-ai-quick|~/.local/bin/fox-ai-quick"
    "bin/fox-ai-find|~/.local/bin/fox-ai-find"
    "bin/fox-ai-bench|~/.local/bin/fox-ai-bench"
    "bin/fox-ai-setup-project|~/.local/bin/fox-ai-setup-project"
    "bin/fox-new-project|~/.local/bin/fox-new-project"
    "bin/fox-distro-guide|~/.local/bin/fox-distro-guide"
    "bin/fox-distro-build|~/.local/bin/fox-distro-build"
    "bin/fox-distro-flash|~/.local/bin/fox-distro-flash"
    "bin/findex|~/.local/bin/findex"
    "bin/fask|~/.local/bin/fask"
    "bin/fhelp|~/.local/bin/fhelp"

    # Distro profiles
    "foxml-profile.json|~/.local/share/foxml/distro/foxml-profile.json"

    # Waybar config
    "waybar_config|~/.config/waybar/config.tmpl"
    "waybar_config_secondary|~/.config/waybar/config_secondary.tmpl"

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
                echo "  Firefox $css"
            fi
        done
        # Set the legacy stylesheet pref via user.js so userChrome/userContent
        # actually load — user.js is read on every launch and overrides
        # prefs.js, so this stays correct even if Firefox rewrites prefs.
        local ff_userjs="$ff_profile/user.js"
        local ff_pref='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
        if ! grep -qF 'toolkit.legacyUserProfileCustomizations.stylesheets' "$ff_userjs" 2>/dev/null; then
            printf '// FoxML theming\n%s\n' "$ff_pref" >> "$ff_userjs"
            echo "  Firefox user.js (legacy stylesheet pref)"
        fi
    else
        echo "  No Firefox profile found, skipping"
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
            echo "  $(basename "$ext_dir" | sed 's/^\.//') theme"
        fi
    done

    # Bat cache rebuild
    if command -v bat &>/dev/null; then
        bat cache --build &>/dev/null
        echo "  Bat cache rebuilt"
    fi

    # AI Agent (Gemini) — merge the rendered config into the user's settings.json.
    # `.hooks` and `.ui` are *replaced* wholesale (not deep-merged) so a removed
    # event (e.g. a previous install's bogus SubagentStop) doesn't linger; other
    # top-level keys like `security` are preserved.
    local gemini_dir="${GEMINI_CONFIG_HOME:-$HOME/.gemini}"
    local gemini_settings="$gemini_dir/settings.json"
    if [[ -f "$rendered_dir/gemini/settings.json" ]]; then
        if [[ -f "$gemini_settings" ]]; then
            local tmp_settings; tmp_settings="$(mktemp)"
            if jq --slurpfile new "$rendered_dir/gemini/settings.json" '
                    . * $new[0]
                    | .hooks = $new[0].hooks
                    | .ui    = $new[0].ui
                ' "$gemini_settings" > "$tmp_settings" 2>/dev/null; then
                mv "$tmp_settings" "$gemini_settings"
                echo "  Gemini settings (hooks + theme) merged"
            else
                rm -f "$tmp_settings"
                echo "  Gemini merge failed (jq error), skipping"
            fi
        else
            mkdir -p "$(dirname "$gemini_settings")"
            cp "$rendered_dir/gemini/settings.json" "$gemini_settings"
            echo "  Gemini settings installed"
        fi
    fi

    # Claude CLI — ensure Stop / SubagentStop / Notification hooks are wired
    # in ~/.claude/settings.json. Hooks shell out to agent_notify.sh, which
    # sources border_colors.sh at fire time — so a palette swap takes effect
    # without re-running install.sh, and the embedded command is short enough
    # to round-trip through jq cleanly.
    local claude_settings="$HOME/.claude/settings.json"
    if command -v claude &>/dev/null || [[ -d "$HOME/.claude" ]]; then
        mkdir -p "$HOME/.claude"

        local hooks_json; hooks_json="$(mktemp)"
        cat > "$hooks_json" << 'JSON'
{
  "hooks": {
    "Stop": [
      {"matcher":"","hooks":[{"type":"command","command":"~/.config/hypr/scripts/agent_notify.sh claude stop"}]}
    ],
    "SubagentStop": [
      {"matcher":"","hooks":[{"type":"command","command":"~/.config/hypr/scripts/agent_notify.sh claude subagent"}]}
    ],
    "Notification": [
      {"matcher":"","hooks":[{"type":"command","command":"~/.config/hypr/scripts/agent_notify.sh claude notification"}]}
    ]
  }
}
JSON

        if [[ ! -f "$claude_settings" ]]; then
            if command -v jq &>/dev/null; then
                jq '. + {theme: "dark"}' "$hooks_json" > "$claude_settings"
            else
                cp "$hooks_json" "$claude_settings"
            fi
            echo "  Claude settings (hooks) created"
        elif command -v jq &>/dev/null; then
            # Deep-merge: replaces .hooks.Stop / .hooks.SubagentStop /
            # .hooks.Notification arrays wholesale, preserves everything else.
            local tmp_claude; tmp_claude="$(mktemp)"
            if jq -s '.[0] * .[1]' "$claude_settings" "$hooks_json" > "$tmp_claude" 2>/dev/null; then
                mv "$tmp_claude" "$claude_settings"
                echo "  Claude settings (hooks) merged"
            else
                rm -f "$tmp_claude"
                echo "  Claude merge failed (jq error), skipping"
            fi
        fi
        rm -f "$hooks_json"
    fi

    # ~/.local/bin helpers (tmux pane-label, etc.) — referenced by configs but
    # too small for their own subdir; kept executable on copy.
    if [[ -d "$SCRIPT_DIR/shared/bin" ]]; then
        mkdir -p "$HOME/.local/bin"
        for bin in "$SCRIPT_DIR/shared/bin/"*; do
            [[ -f "$bin" ]] || continue
            cp "$bin" "$HOME/.local/bin/$(basename "$bin")"
            chmod +x "$HOME/.local/bin/$(basename "$bin")"
            echo "  bin/$(basename "$bin")"
        done
    fi

    # Hyprland scripts
    if [[ -d "$SCRIPT_DIR/shared/hyprland_scripts" ]]; then
        mkdir -p ~/.config/hypr/scripts
        for script in "$SCRIPT_DIR/shared/hyprland_scripts/"*.sh; do
            [[ -f "$script" ]] || continue
            cp "$script" "$HOME/.config/hypr/scripts/$(basename "$script")"
            chmod +x "$HOME/.config/hypr/scripts/$(basename "$script")"
            echo "  scripts/$(basename "$script")"
        done
    fi

    # Waybar scripts
    if [[ -d "$SCRIPT_DIR/shared/waybar_scripts" ]]; then
        mkdir -p ~/.config/waybar/scripts
        for script in "$SCRIPT_DIR/shared/waybar_scripts/"*.sh; do
            [[ -f "$script" ]] || continue
            cp "$script" "$HOME/.config/waybar/scripts/$(basename "$script")"
            chmod +x "$HOME/.config/waybar/scripts/$(basename "$script")"
            echo "  waybar/$(basename "$script")"
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
            # monitors.conf is per-machine — configure_monitors() writes it.
            # Only seed the catch-all default on first run when the file is absent.
            if [[ "$basename" == "monitors.conf" && -f "$HOME/.config/hypr/modules/monitors.conf" ]]; then
                continue
            fi
            cp "$mod" "$HOME/.config/hypr/modules/$basename"
            echo "  modules/$basename"
        done
    fi

    # ReGreet (login screen) — stage files for install_greetd() to consume.
    # The actual sudo install to /etc/greetd/ happens in install_greetd()
    # (called from install.sh after install_specials).
    if [[ -f "$rendered_dir/regreet/regreet.css" ]]; then
        mkdir -p ~/.config/regreet
        cp "$rendered_dir/regreet/regreet.css" ~/.config/regreet/regreet.css
        cp "$SCRIPT_DIR/shared/regreet.toml" ~/.config/regreet/regreet.toml
        cp "$SCRIPT_DIR/shared/greetd_hyprland.conf" ~/.config/regreet/hyprland.conf
        echo "  ReGreet staged to ~/.config/regreet/ (install_greetd will deploy)"
    fi

    # KEYBINDS.md — deployed to ~/.local/share/foxml/ so fox-cheatsheet
    # can find it on installed systems without depending on the repo path.
    if [[ -f "$SCRIPT_DIR/KEYBINDS.md" ]]; then
        mkdir -p "$HOME/.local/share/foxml"
        cp "$SCRIPT_DIR/KEYBINDS.md" "$HOME/.local/share/foxml/KEYBINDS.md"
        echo "  KEYBINDS.md → ~/.local/share/foxml/"
    fi

    # Wallpapers (image files only — skip README etc.)
    if [[ -d "$SCRIPT_DIR/shared/wallpapers" ]]; then
        mkdir -p ~/.wallpapers
        shopt -s nullglob nocaseglob
        for wp in "$SCRIPT_DIR/shared/wallpapers/"*.{jpg,jpeg,png,webp}; do
            cp "$wp" ~/.wallpapers/
            echo "  $(basename "$wp")"
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
            echo "  cursor theme: $cursor_name"
        else
            echo "  cursor download failed; install from AUR or skip"
        fi
    else
        echo "  cursor theme already present"
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
            echo "  Papirus icon theme"
        else
            echo "  Papirus install failed; skipping folder recolor"
        fi
    else
        echo "  Papirus already present"
    fi

    if [[ -d "$icons_dir/Papirus" ]]; then
        # Inject Catppuccin folder SVGs (Papirus-Dark/Light symlink to Papirus)
        local cat_tmp; cat_tmp="$(mktemp -d)"
        if git clone --depth 1 --quiet \
                https://github.com/catppuccin/papirus-folders.git "$cat_tmp/repo" 2>/dev/null; then
            cp -r "$cat_tmp/repo/src/"* "$icons_dir/Papirus/" 2>/dev/null || true
            echo "  Catppuccin folder palette injected"
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
            echo "  folders → cat-mocha-peach"
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
        echo "  bat --theme=\"Fox ML\""
    fi

    # delta — wire the rendered FoxML gitconfig in via [include] so the user's
    # ~/.gitconfig (identity, etc.) stays untouched. git-config -e replaces the
    # same key on re-runs, and we only add the include if delta is installed.
    if command -v delta &>/dev/null && [[ -f "$rendered_dir/git/delta.gitconfig" ]]; then
        local delta_inc="$HOME/.config/git/delta-foxml.gitconfig"
        if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$delta_inc"; then
            git config --global --add include.path "$delta_inc"
        fi
        echo "  git delta include → $delta_inc"
    fi

    # btop — point btop.conf at the FoxML theme. If btop hasn't run yet there's
    # no btop.conf; create a one-line config (btop auto-fills the rest of the
    # defaults on first launch). Without this branch the theme silently no-ops
    # on first install.
    local btop_conf="$HOME/.config/btop/btop.conf"
    if [[ ! -f "$btop_conf" ]]; then
        mkdir -p "$(dirname "$btop_conf")"
        echo 'color_theme = "foxml"' > "$btop_conf"
        echo "  btop.conf created with FoxML theme"
    elif grep -qE '^color_theme\s*=\s*"foxml"' "$btop_conf"; then
        echo "  btop already on FoxML theme"
    elif grep -qE '^color_theme\s*=' "$btop_conf"; then
        sed -i -E 's|^(color_theme\s*=\s*).*|\1"foxml"|' "$btop_conf"
        echo "  btop color_theme → foxml"
    else
        echo 'color_theme = "foxml"' >> "$btop_conf"
        echo "  btop color_theme → foxml"
    fi

    # Systemd user units (wallpaper rotation timer, etc.)
    if [[ -d "$SCRIPT_DIR/shared/systemd_user" ]]; then
        mkdir -p ~/.config/systemd/user
        local installed_any=0
        for unit in "$SCRIPT_DIR/shared/systemd_user/"*.{service,timer}; do
            [[ -f "$unit" ]] || continue
            cp "$unit" "$HOME/.config/systemd/user/$(basename "$unit")"
            echo "  systemd/$(basename "$unit")"
            installed_any=1
        done
        if (( installed_any )); then
            systemctl --user daemon-reload &>/dev/null || true
            for timer in "$SCRIPT_DIR/shared/systemd_user/"*.timer; do
                [[ -f "$timer" ]] || continue
                systemctl --user enable --now "$(basename "$timer")" &>/dev/null || true
            done
            echo "  systemd user timers enabled"
        fi
    fi

    # Reload the live notification daemon so the freshly-rendered [app-name=Claude]
    # / [app-name=Gemini] rules are active without a relog. Hook config in
    # ~/.claude/settings.json and ~/.gemini/settings.json is read by the agent
    # processes at startup, so already-running agent sessions still need to be
    # restarted to pick up new hooks — that part can't be fixed from here.
    if pgrep -x mako >/dev/null 2>&1 && command -v makoctl >/dev/null 2>&1; then
        makoctl reload &>/dev/null || true
        echo "  mako reloaded"
    fi
    if pgrep -x dunst >/dev/null 2>&1; then
        # dunst has no reload command; SIGUSR2 is a no-op, so kick it cleanly.
        # killall is preferred so any running instance picks up the new config
        # via the user's autostart.
        killall -HUP dunst &>/dev/null || true
        echo "  dunst reloaded (SIGHUP)"
    fi
}

# ─────────────────────────────────────────
# Multi-monitor setup — interactive picker for position + orientation.
# Writes ~/.config/hypr/modules/monitors.conf (per-machine, name-keyed so
# unplugged monitors are silently ignored) and a small sidecar at
# ~/.config/foxml/monitor-layout.conf consumed by start_waybar.sh and
# rotate_wallpaper.sh.
# ─────────────────────────────────────────

_generate_portrait_wallpapers() {
    # Center-crop each landscape wallpaper into a 1080x1920 portrait variant.
    # Idempotent: skips files that already have a _portrait sibling. Silent
    # no-op if imagemagick isn't installed (rotate_wallpaper.sh falls back to
    # awww --resize crop on the landscape source).
    local wall_dir="${HOME}/.wallpapers"
    [[ -d "$wall_dir" ]] || return 0

    local magick_bin=""
    command -v magick  >/dev/null 2>&1 && magick_bin="magick"
    command -v convert >/dev/null 2>&1 && [[ -z "$magick_bin" ]] && magick_bin="convert"
    [[ -z "$magick_bin" ]] && {
        echo "  imagemagick not found — portrait wallpapers will use crop-fit on landscape"
        return 0
    }

    local generated=0
    for src in "$wall_dir"/*.{jpg,jpeg,png}; do
        [[ -f "$src" ]] || continue
        local base ext name out
        base="$(basename "$src")"
        ext="${base##*.}"
        name="${base%.*}"
        # Skip files that are already portrait variants
        [[ "$name" == *_portrait ]] && continue
        out="${wall_dir}/${name}_portrait.${ext}"
        [[ -f "$out" ]] && continue
        # Scale source so the smaller dimension is 1920 (preserves aspect),
        # then center-crop to 1080x1920 — same math awww --resize crop would
        # do at runtime, but pre-rendered so we don't rebuild on every fade.
        "$magick_bin" "$src" -resize "1920x1920^" -gravity center \
            -extent 1080x1920 "$out" 2>/dev/null && generated=$((generated + 1))
    done
    if (( generated > 0 )); then
        echo "  + ${generated} portrait wallpaper(s) generated"
    fi
    # Explicit success — the (( )) test returns 1 when no new files were
    # generated (every re-run after the first), and `set -e` in install.sh
    # would treat that as a failure and abort before install_throttling.
    return 0
}

configure_monitors() {
    if ! command -v hyprctl &>/dev/null; then
        echo "  hyprctl not found — skipping monitor configuration"
        return
    fi
    if ! command -v jq &>/dev/null; then
        echo "  jq not installed — skipping monitor configuration"
        return
    fi

    local monitors_json
    monitors_json=$(hyprctl monitors -j 2>/dev/null) || {
        echo "  Hyprland not running — skipping monitor configuration"
        echo "  (Re-run install.sh from inside a Hyprland session to configure)"
        return
    }

    local count
    count=$(echo "$monitors_json" | jq 'length')

    mkdir -p "$HOME/.config/foxml"
    local layout="$HOME/.config/foxml/monitor-layout.conf"

    if (( count <= 1 )); then
        # Single monitor — clear any stale layout from a previous dock.
        : > "$layout"
        echo "PRIMARY=\"$(echo "$monitors_json" | jq -r '.[0].name // ""')\"" >> "$layout"
        echo 'PORTRAIT_OUTPUTS=""' >> "$layout"
        echo 'SECONDARY_OUTPUTS=""' >> "$layout"
        return
    fi

    echo ""
    echo "╭──────────────────────────────────────────────────────────────────╮"
    echo "│   Multi-Monitor Setup                                            │"
    echo "├──────────────────────────────────────────────────────────────────┤"
    printf "│   Detected %d monitors:                                            \n" "$count"
    echo "$monitors_json" | jq -r '.[] | "│     • \(.name)  \(.width)x\(.height)  — \(.description)"'
    echo "╰──────────────────────────────────────────────────────────────────╯"

    # Primary picker: prefer eDP-* (laptop panel), fall back to first listed.
    local primary
    primary=$(echo "$monitors_json" | jq -r '[.[] | select(.name | startswith("eDP"))] | .[0].name // empty')
    [[ -z "$primary" ]] && primary=$(echo "$monitors_json" | jq -r '.[0].name')

    if ! $ASSUME_YES; then
        read -p "Configure layout interactively? [y/N] " -n 1 -r; echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "  Skipping — current monitors.conf left as-is"
            return
        fi
    fi

    local primary_w primary_h
    primary_w=$(echo "$monitors_json" | jq -r --arg n "$primary" '.[] | select(.name==$n) | .width')
    primary_h=$(echo "$monitors_json" | jq -r --arg n "$primary" '.[] | select(.name==$n) | .height')

    local rules="" portrait_outputs="" secondary_outputs=""
    local externals
    externals=$(echo "$monitors_json" | jq -r --arg p "$primary" '.[] | select(.name != $p) | .name')

    # Read externals from FD 3 so the inner read prompts still hit stdin/tty.
    while IFS= read -r -u 3 ext; do
        [[ -z "$ext" ]] && continue
        local ext_w ext_h
        ext_w=$(echo "$monitors_json" | jq -r --arg n "$ext" '.[] | select(.name==$n) | .width')
        ext_h=$(echo "$monitors_json" | jq -r --arg n "$ext" '.[] | select(.name==$n) | .height')

        local pos="right" orient="landscape"

        if ! $ASSUME_YES; then
            echo ""
            echo "  External: $ext  (${ext_w}x${ext_h})"
            echo "    Position relative to ${primary}:"
            echo "      [1] left   [2] right   [3] above   [4] below"
            read -p "    Choice [2]: " p_choice
            case "$p_choice" in
                1) pos="left" ;;
                3) pos="above" ;;
                4) pos="below" ;;
                *) pos="right" ;;
            esac

            echo "    Orientation:"
            echo "      [1] landscape   [2] portrait, rotated left   [3] portrait, rotated right"
            read -p "    Choice [1]: " o_choice
            case "$o_choice" in
                2) orient="portrait-left" ;;
                3) orient="portrait-right" ;;
                *) orient="landscape" ;;
            esac
        fi

        # Effective dimensions (after rotation)
        local eff_w="$ext_w" eff_h="$ext_h" transform=0
        case "$orient" in
            portrait-left)  eff_w="$ext_h"; eff_h="$ext_w"; transform=3 ;;  # 270°
            portrait-right) eff_w="$ext_h"; eff_h="$ext_w"; transform=1 ;;  #  90°
        esac

        # Position relative to primary anchored at 0,0. Hyprland accepts
        # negative coords, so we just compute and let it normalize visually.
        local ext_x=0 ext_y=0
        case "$pos" in
            right) ext_x=$primary_w;       ext_y=$(( (primary_h - eff_h) / 2 )) ;;
            left)  ext_x=$(( -eff_w ));    ext_y=$(( (primary_h - eff_h) / 2 )) ;;
            above) ext_x=$(( (primary_w - eff_w) / 2 )); ext_y=$(( -eff_h )) ;;
            below) ext_x=$(( (primary_w - eff_w) / 2 )); ext_y=$primary_h ;;
        esac

        if (( transform != 0 )); then
            rules+="monitor = ${ext}, preferred, ${ext_x}x${ext_y}, 1, transform, ${transform}"$'\n'
            portrait_outputs+="${ext} "
        else
            rules+="monitor = ${ext}, preferred, ${ext_x}x${ext_y}, 1"$'\n'
        fi
        secondary_outputs+="${ext} "
    done 3<<< "$externals"

    # Write monitors.conf
    local conf="$HOME/.config/hypr/modules/monitors.conf"
    {
        echo "# ╭──────────────────────────────────────────────────────────────────╮"
        echo "# │                          Monitors                                │"
        echo "# ╰──────────────────────────────────────────────────────────────────╯"
        echo "# Generated by install.sh — re-run to reconfigure."
        echo "# Per-monitor rules below; if a monitor is unplugged, Hyprland"
        echo "# silently ignores its rule. The catch-all at the bottom handles"
        echo "# unknown displays at runtime."
        echo ""
        echo "monitor = ${primary}, preferred, 0x0, 1"
        printf '%s' "$rules"
        echo ""
        echo "# Catch-all for any unknown/disconnected displays at runtime"
        echo "monitor = , preferred, auto, 1"
    } > "$conf"

    # Write layout sidecar (consumed by start_waybar.sh and rotate_wallpaper.sh)
    {
        echo "# Auto-generated by install.sh"
        echo "PRIMARY=\"${primary}\""
        echo "PORTRAIT_OUTPUTS=\"${portrait_outputs% }\""
        echo "SECONDARY_OUTPUTS=\"${secondary_outputs% }\""
    } > "$layout"

    echo ""
    echo "  + monitors.conf written ($conf)"
    echo "  + layout sidecar       ($layout)"

    # Auto-generate portrait wallpapers if any output was rotated.
    if [[ -n "$portrait_outputs" ]]; then
        _generate_portrait_wallpapers
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
        echo "  No NVIDIA GPU found, skipping nvidia setup"
        return
    fi

    # Resolve by-path symlinks to /dev/dri/cardN — aquamarine splits
    # AQ_DRM_DEVICES on ':', and the by-path names contain ':' themselves
    # (pci-0000:01:00.0-card), which shreds the list. cardN is colon-free.
    local nvidia_drm intel_drm
    nvidia_drm="$(readlink -f "/dev/dri/by-path/pci-${nvidia_addr}-card" 2>/dev/null)"
    if [[ -z "$nvidia_drm" || ! -e "$nvidia_drm" ]]; then
        echo "  Could not resolve /dev/dri/by-path/pci-${nvidia_addr}-card — is the nvidia driver loaded?"
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
        echo "  modules/nvidia.conf (AQ_DRM_DEVICES → ${aq_drm_devices})"

        local hypr_main="$HOME/.config/hypr/hyprland.conf"
        if [[ -f "$hypr_main" ]] && ! grep -qF 'modules/nvidia.conf' "$hypr_main"; then
            printf '\n# Nvidia (added by install.sh --nvidia)\nsource = ~/.config/hypr/modules/nvidia.conf\n' \
                >> "$hypr_main"
            echo "  hyprland.conf sources nvidia.conf"
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
            echo "  /boot has only ${boot_free_mb} MB free — skipping mkinitcpio edit"
            echo "    nvidia-bearing initramfs needs ~135 MB. Free space in /boot"
            echo "    (older kernels, fallback initramfs) and re-run, or skip this"
            echo "    step — the dGPU will still render via udev module loading."
        else
            sudo sed -i.foxml-bak \
                's/^MODULES=([^)]*)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
                "$mkinit"
            echo "  mkinitcpio MODULES updated (backup: ${mkinit}.foxml-bak)"
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
            echo "  kernel cmdline updated (backup: ${boot_entry}.foxml-bak)"
        else
            echo "  • kernel cmdline already has nvidia_drm.modeset=1"
        fi
    elif [[ -f /etc/default/grub ]]; then
        echo "  GRUB detected — add 'nvidia_drm.modeset=1 nvidia_drm.fbdev=1'"
        echo "    to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub, then"
        echo "    run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    else
        echo "  Unknown bootloader — add 'nvidia_drm.modeset=1 nvidia_drm.fbdev=1'"
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
        echo "  curl not found — install curl or fetch $theme manually"
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
        echo "  Couldn't resolve $asset from $api — skipping cursor install"
        return
    fi

    local tmp
    tmp=$(mktemp -d)
    if ! curl -fsSL -o "$tmp/$asset" "$url"; then
        echo "  Download failed: $url"
        rm -rf "$tmp"
        return
    fi

    if ! command -v unzip >/dev/null 2>&1; then
        echo "  unzip not found — pacman -S unzip then re-run"
        rm -rf "$tmp"
        return
    fi

    mkdir -p "$user_dir"
    unzip -q -o "$tmp/$asset" -d "$user_dir"
    rm -rf "$tmp"

    if [[ -d "$user_dir/$theme" ]]; then
        echo "  $theme → $user_dir"
    else
        echo "  Extraction did not produce $user_dir/$theme — check asset layout"
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
        echo "  Staged regreet files missing in $staged — skipping"
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
        echo "  Login wallpaper $wall_src missing — copy your wallpaper to ~/.wallpapers/ first"
        return
    fi

    sudo install -d /etc/greetd /usr/share/wallpapers
    sudo install -m 644 "$staged/regreet.css"     /etc/greetd/regreet.css
    sudo install -m 644 "$staged/regreet.toml"    /etc/greetd/regreet.toml
    sudo install -m 644 "$staged/hyprland.conf"   /etc/greetd/hyprland.conf
    sudo install -m 644 "$wall_src"               "$wall_path"
    echo "  regreet css/toml/hyprland.conf → /etc/greetd/"
    echo "  login wallpaper → $wall_path"

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
        echo "  /etc/greetd/config.toml (Hyprland greeter session)"
    else
        echo "  • /etc/greetd/config.toml already customized — leaving as-is"
    fi

    if ! systemctl is-enabled --quiet greetd 2>/dev/null; then
        sudo systemctl enable greetd && echo "  greetd enabled (login screen on next boot)"
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
            echo "    Intel Turbo disabled (now and on every boot)"
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
                echo "    Max set to ${max_mhz} MHz (live)"
            else
                echo "    Live cap failed — will still try to persist"
            fi
            _persist_cpupower max_freq "${max_khz}"
            echo "    Persisted via /etc/default/cpupower"
        elif [[ -n "$max_mhz" ]]; then
            echo "    '$max_mhz' is not a positive integer — skipping"
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
                    echo "    Governor → $governor (now and persistent)"
                else
                    echo "    '$governor' not in available list — skipping"
                fi
            fi
        fi
    fi

    # Enable cpupower.service so /etc/default/cpupower applies on every boot
    if pacman -Qi cpupower &>/dev/null && [[ -f /etc/default/cpupower ]]; then
        if ! systemctl is-enabled --quiet cpupower.service 2>/dev/null; then
            sudo systemctl enable --now cpupower.service >/dev/null 2>&1 \
                && echo "  cpupower.service enabled"
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
                    echo "    No AUR helper (yay/paru) found. Re-run install with"
                    echo "      --deps to install yay first, then retry this wizard."
                fi
            else
                echo "    • throttled already installed"
            fi
            if pacman -Qi throttled &>/dev/null \
                && ! systemctl is-active --quiet throttled.service; then
                sudo systemctl enable --now throttled.service >/dev/null 2>&1 \
                    && echo "    throttled enabled (edit /etc/throttled.conf to tune)"
            fi
        fi
    fi

    echo ""
    echo "  Done. Verify with: cpupower frequency-info | head -20"
}

# ─────────────────────────────────────────
# Performance — opt-in via install.sh --perf
# Enables high-precision time sync (Chrony).
# ─────────────────────────────────────────

install_performance() {
    if pacman -Qi chrony &>/dev/null; then
        if ! systemctl is-active --quiet chronyd; then
            echo "  Configuring Chrony (High-Precision Time)..."
            # Disable systemd-timesyncd first
            sudo systemctl disable --now systemd-timesyncd >/dev/null 2>&1
            sudo systemctl enable --now chronyd >/dev/null 2>&1
            echo "    chronyd enabled (replaces timesyncd)"
            echo "    Precision sync active (check with: chronyc tracking)"
        else
            echo "  • chronyd already active"
        fi
    else
        echo "  chrony package not found — run with --deps --perf"
    fi
}

# ─────────────────────────────────────────
# Privacy — opt-in via install.sh --privacy
# Enables DNS-over-HTTPS (DoH) via systemd-resolved.
# ─────────────────────────────────────────

install_privacy() {
    echo "  Configuring DNS-over-HTTPS (DoH)..."
    local res_conf="/etc/systemd/resolved.conf"
    
    # 1. Update resolved.conf
    # Uses Cloudflare (1.1.1.1) and Google (8.8.8.8) with DoH enabled
    sudo mkdir -p /etc/systemd/resolved.conf.d/
    sudo tee /etc/systemd/resolved.conf.d/foxml-doh.conf >/dev/null <<EOF
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 8.8.8.8#dns.google 8.8.4.4#dns.google
DNSOverHTTPS=yes
DNSSEC=yes
FallbackDNS=1.1.1.1 8.8.8.8
EOF

    # 2. Enable and start resolved
    sudo systemctl enable --now systemd-resolved >/dev/null 2>&1
    
    # 3. Link /etc/resolv.conf to systemd-resolved
    if [[ ! -L /etc/resolv.conf ]]; then
        sudo ln -rsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    fi
    
    echo "    systemd-resolved configured with DoH (Cloudflare/Google)"
    echo "    DNS traffic now encrypted via HTTPS (Port 443)"
}

# ─────────────────────────────────────────
# Vault — opt-in via install.sh --vault
# Enables secure password management (Pass).
# ─────────────────────────────────────────

install_vault() {
    if pacman -Qi pass &>/dev/null; then
        echo "  Configuring Secure Vault (Pass)..."
        
        # 1. Detect or Generate GPG key
        local gpg_key
        gpg_key=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d/ -f2 | head -n 1)
        
        if [[ -z "$gpg_key" ]]; then
            echo "    No GPG key found. Generating one for you..."
            gpg --batch --passphrase '' --quick-gen-key "$USER <${USER}@foxml.local>" default default 0
            gpg_key=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d/ -f2 | head -n 1)
        fi
        
        # 2. Initialize pass
        if [[ ! -d "$HOME/.password-store" ]]; then
            pass init "$gpg_key" >/dev/null
            echo "    Password store initialized with key $gpg_key"
        else
            echo "    • Password store already exists"
        fi

        # 3. Git GPG Signing
        if command -v git &>/dev/null; then
            git config --global user.signingkey "$gpg_key"
            git config --global commit.gpgsign true
            echo "    Git configured to sign commits with key $gpg_key"
        fi

        # 4. AUR helper check for rofi-pass-wayland
        local aur=""
        command -v yay  &>/dev/null && aur="yay"
        [[ -z "$aur" ]] && command -v paru &>/dev/null && aur="paru"

        if [[ -n "$aur" ]]; then
            if ! pacman -Qi rofi-pass-wayland-git &>/dev/null; then
                read -p "    Install rofi-pass (Wayland) for SysHub integration? [y/N] " -n 1 -r; echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    "$aur" -S --needed rofi-pass-wayland-git
                    echo "    rofi-pass installed"
                fi
            fi
        fi
    else
        echo "  pass package not found — run with --deps --vault"
    fi
}

# ─────────────────────────────────────────
# Security Hardening — opt-in via install.sh --secure
# Enables and configures UFW (firewall) and Fail2ban.
# ─────────────────────────────────────────

install_security() {
    # 1. UFW (Uncomplicated Firewall)
    if pacman -Qi ufw &>/dev/null; then
        if ! systemctl is-active --quiet ufw; then
            echo "  Configuring UFW..."
            sudo ufw default deny incoming >/dev/null
            sudo ufw default allow outgoing >/dev/null
            sudo ufw allow ssh >/dev/null
            # y| ensures it doesn't pause for confirmation
            echo "y" | sudo ufw enable >/dev/null
            sudo systemctl enable --now ufw >/dev/null 2>&1
            echo "    UFW enabled (Deny incoming, Allow outgoing/ssh)"
        else
            echo "  • UFW already active"
        fi
    else
        echo "  ufw package not found — run with --deps --secure"
    fi

    # 2. Fail2ban (Brute-force protection)
    if pacman -Qi fail2ban &>/dev/null; then
        if ! systemctl is-active --quiet fail2ban; then
            sudo systemctl enable --now fail2ban >/dev/null 2>&1
            echo "    fail2ban service enabled"
        else
            echo "  • fail2ban already active"
        fi
    else
        echo "  fail2ban package not found — run with --deps --secure"
    fi

    # 3. Auditd (System Auditing)
    if pacman -Qi audit &>/dev/null; then
        if ! systemctl is-active --quiet auditd; then
            echo "  Configuring Auditd..."
            sudo systemctl enable --now auditd >/dev/null 2>&1
            # Add basic watch rules
            sudo auditctl -w /etc/passwd -p wa -k passwd_changes >/dev/null 2>&1
            sudo auditctl -w /etc/shadow -p wa -k shadow_changes >/dev/null 2>&1
            sudo auditctl -w /etc/ssh/sshd_config.d/ -p wa -k sshd_config_changes >/dev/null 2>&1
            echo "    auditd enabled and watching sensitive files"
        else
            echo "  • auditd already active"
        fi
    fi

    # 4. Waybar Sudoers (Seamless Overwatch)
    local waybar_sudo="/etc/sudoers.d/99-foxml-waybar"
    if [[ ! -f "$waybar_sudo" ]]; then
        echo "  Configuring sudoers for Waybar Overwatch..."
        echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/ufw status, /usr/bin/fail2ban-client status *" | sudo tee "$waybar_sudo" >/dev/null
        sudo chmod 440 "$waybar_sudo"
        echo "    Sudoers rule added for UFW/Fail2ban status"
    fi

    # 5. SSH Hardening Wizard
            if ! $ASSUME_YES; then
        echo ""
        echo "╭──────────────────────────────────────────────────────────────────╮"
        echo "│   SSH Hardening Wizard                                          │"
        echo "├──────────────────────────────────────────────────────────────────┤"
        echo "│ This will configure a custom port and disable password login.   │"
        echo "│ WARNING: Ensure you have SSH keys set up before proceeding.    │"
        echo "╰──────────────────────────────────────────────────────────────────╯"
        read -p "Run SSH hardening wizard? [y/N] " -n 1 -r; echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local sshd_conf_dir="/etc/ssh/sshd_config.d"
            local hardening_conf="${sshd_conf_dir}/50-foxml-hardening.conf"
            sudo mkdir -p "$sshd_conf_dir"

            # 1. Custom Port
            read -p "  Enter custom SSH port [default: 22]: " custom_port
            custom_port=${custom_port:-22}
            
            # 2. Key Check & Import
            local has_keys=false
            [[ -f "$HOME/.ssh/authorized_keys" ]] && has_keys=true
            
            if ! $has_keys; then
                echo "  No ~/.ssh/authorized_keys found."
                read -p "  Import public keys from GitHub? (Enter username or leave blank to skip): " gh_user
                if [[ -n "$gh_user" ]]; then
                    mkdir -p "$HOME/.ssh"
                    chmod 700 "$HOME/.ssh"
                    if curl -fsSL "https://github.com/${gh_user}.keys" >> "$HOME/.ssh/authorized_keys"; then
                        chmod 600 "$HOME/.ssh/authorized_keys"
                        echo "    Imported keys from GitHub (${gh_user})"
                        has_keys=true
                    else
                        echo "    Failed to fetch keys for user: ${gh_user}"
                    fi
                fi
            fi

            local disable_pass="yes"
            if $has_keys; then
                read -p "  Disable password authentication? (Keys detected) [y/N] " -n 1 -r; echo ""
                [[ $REPLY =~ ^[Yy]$ ]] && disable_pass="no"
            else
                echo "  No authorized_keys found. Forcing 'PasswordAuthentication yes' to prevent lockout."
                disable_pass="yes"
            fi

            # 3. Apply Config
            sudo tee "$hardening_conf" >/dev/null <<EOF
# FoxML Security Hardening
Port $custom_port
PasswordAuthentication $disable_pass
PubkeyAuthentication yes
EOF
            echo "    SSH config written to $hardening_conf"

            # 4. Update UFW
            if [[ "$custom_port" != "22" ]]; then
                sudo ufw allow "$custom_port/tcp" >/dev/null
                sudo ufw delete allow 22 >/dev/null
                echo "    UFW updated: Allowed $custom_port, Blocked 22"
            fi

            # 5. Restart SSH
            sudo systemctl restart sshd
            echo "    sshd restarted"
            
            if [[ "$disable_pass" == "no" ]]; then
                echo ""
                echo "  SSH is now LOCKED DOWN to keys-only on port $custom_port."
            else
                echo ""
                echo "  SSH is on port $custom_port, but password login is still ENABLED."
                echo "    Add your key to ~/.ssh/authorized_keys to disable passwords later."
            fi
        fi
    fi
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
                echo "  Firefox $css"
            fi
        done
    fi

    # Cursor/VS Code
    for ext_dir in ~/.cursor/extensions ~/.vscode/extensions; do
        local src="$ext_dir/foxml-theme/themes/foxml-color-theme.json"
        if [[ -f "$src" ]]; then
            sed "$sed_expr" "$src" > "$template_dir/cursor/foxml-color-theme.json"
            echo "  foxml-color-theme.json"
            break
        fi
    done

    # Bat
    local bat_dir
    bat_dir="$(bat --config-dir 2>/dev/null || echo "$HOME/.config/bat")"
    if [[ -f "$bat_dir/themes/Fox ML.tmTheme" ]]; then
        sed "$sed_expr" "$bat_dir/themes/Fox ML.tmTheme" > "$template_dir/bat/foxml.tmTheme"
        echo "  Bat theme"
    fi

    # AI Agent — pull config back into the template; keeping security/auth out
    # of the captured template avoids leaking session creds into the repo.
    local gemini_dir="${GEMINI_CONFIG_HOME:-$HOME/.gemini}"
    local gemini_settings="$gemini_dir/settings.json"
    if [[ -f "$gemini_settings" ]]; then
        local tmp_captured; tmp_captured="$(mktemp)"
        # Capture theme, hooks, and notifications but skip security
        if jq '{ui: .ui, hooks: .hooks, hooksConfig: .hooksConfig, general: .general}' "$gemini_settings" > "$tmp_captured" 2>/dev/null; then
            mkdir -p "$template_dir/gemini"
            sed "$sed_expr" "$tmp_captured" > "$template_dir/gemini/settings.json"
            echo "  Gemini settings (captured hooks + theme)"
        fi
        rm -f "$tmp_captured"
    fi

    # Hyprland scripts
    if [[ -d ~/.config/hypr/scripts ]]; then
        mkdir -p "$SCRIPT_DIR/shared/hyprland_scripts"
        for script in ~/.config/hypr/scripts/*.sh; do
            [[ -f "$script" ]] || continue
            cp "$script" "$SCRIPT_DIR/shared/hyprland_scripts/$(basename "$script")"
            echo "  scripts/$(basename "$script")"
        done
    fi
}
