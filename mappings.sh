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

    # Waybar
    "waybar/style.css|~/.config/waybar/style.css"

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

    # Zathura
    "zathura/zathurarc|~/.config/zathura/zathurarc"

    # Vencord
    "vencord/foxml.css|~/.config/Vencord/themes/foxml.css"

    # Spicetify
    "spicetify/color.ini|~/.config/spicetify/Themes/FoxML/color.ini"
    "spicetify/user.css|~/.config/spicetify/Themes/FoxML/user.css"

    # Bat
    "bat/foxml.tmTheme|~/.config/bat/themes/Fox ML.tmTheme"

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
    "hyprland_hypridle.conf|~/.config/hypr/hypridle.conf"
    "hyprpaper.conf|~/.config/hypr/hyprpaper.conf"

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
    "zsh_paths.zsh|~/.config/zsh/paths.zsh"
    "zsh_conda.zsh|~/.config/zsh/conda.zsh"

    # Waybar config
    "waybar_config|~/.config/waybar/config"

    # ReGreet (login screen — needs sudo to install to /etc/greetd/)
    # "regreet.toml|/etc/greetd/regreet.toml"
)

# ─────────────────────────────────────────
# Special install handlers
# ─────────────────────────────────────────

get_firefox_profile() {
    find ~/.mozilla/firefox -maxdepth 1 -name "*.default-release*" -type d 2>/dev/null | head -1
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
        echo "  Note: Enable toolkit.legacyUserProfileCustomizations.stylesheets in about:config"
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

    # Spicetify config
    if command -v spicetify &>/dev/null; then
        spicetify config current_theme FoxML 2>/dev/null || true
        spicetify config color_scheme Base 2>/dev/null || true
        echo "  Run 'spicetify apply' to activate"
    fi

    # Bat cache rebuild
    if command -v bat &>/dev/null; then
        bat cache --build &>/dev/null
        echo "  ✓ Bat cache rebuilt"
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

    # Hyprland modules
    if [[ -d "$SCRIPT_DIR/shared/hyprland_modules" ]]; then
        mkdir -p ~/.config/hypr/modules
        for mod in "$SCRIPT_DIR/shared/hyprland_modules/"*.conf; do
            [[ -f "$mod" ]] || continue
            local basename="$(basename "$mod")"
            [[ "$basename" == "theme.conf" ]] && continue  # theme.conf comes from templates
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

    # Wallpapers
    if [[ -d "$SCRIPT_DIR/shared/wallpapers" ]]; then
        mkdir -p ~/.wallpapers
        for wp in "$SCRIPT_DIR/shared/wallpapers/"*; do
            [[ -f "$wp" ]] || continue
            cp "$wp" ~/.wallpapers/
            echo "  ✓ $(basename "$wp")"
        done
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

    # Spicetify
    local spice_dir="$HOME/.config/spicetify/Themes/FoxML"
    if [[ -d "$spice_dir" ]]; then
        for f in color.ini user.css; do
            [[ -f "$spice_dir/$f" ]] && sed "$sed_expr" "$spice_dir/$f" > "$template_dir/spicetify/$f"
        done
        echo "  ✓ Spicetify"
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
