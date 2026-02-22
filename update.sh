#!/bin/bash
# Fox ML Theme Updater
# Pulls current configs from system into the theme folder

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                    Fox ML Theme Updater                         │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo ""
echo "This will update the theme folder with your current system configs."
echo ""

update_file() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        echo "  ✓ $name"
    else
        echo "  ⚠ $name (not found)"
    fi
}

# ─────────────────────────────────────────
# Hyprland
# ─────────────────────────────────────────
echo ""
echo "Updating Hyprland configs..."
update_file ~/.config/hypr/modules/theme.conf "$SCRIPT_DIR/hyprland/theme.conf" "theme.conf"
update_file ~/.config/hypr/hyprlock.conf "$SCRIPT_DIR/hyprlock/hyprlock.conf" "hyprlock.conf"
update_file ~/.config/hypr/hyprpaper.conf "$SCRIPT_DIR/hyprpaper/hyprpaper.conf" "hyprpaper.conf"

# ─────────────────────────────────────────
# Neovim
# ─────────────────────────────────────────
echo ""
echo "Updating Neovim..."
update_file ~/.config/nvim/init.lua "$SCRIPT_DIR/nvim/init.lua" "init.lua"
update_file ~/.config/nvim/lazy-lock.json "$SCRIPT_DIR/nvim/lazy-lock.json" "lazy-lock.json"
update_file ~/.config/nvim/ftplugin/cpp.lua "$SCRIPT_DIR/nvim/ftplugin/cpp.lua" "ftplugin/cpp.lua"

# ─────────────────────────────────────────
# Wallpapers
# ─────────────────────────────────────────
echo ""
echo "Updating wallpapers..."
if [[ -f ~/.wallpapers/foxml.png ]]; then
    update_file ~/.wallpapers/foxml.png "$SCRIPT_DIR/wallpapers/foxml.png" "foxml.png"
elif [[ -f ~/.wallpapers/new_tmp.png ]]; then
    update_file ~/.wallpapers/new_tmp.png "$SCRIPT_DIR/wallpapers/new_tmp.png" "new_tmp.png"
fi
if [[ -f ~/.wallpapers/foxml-alt.jpg ]]; then
    update_file ~/.wallpapers/foxml-alt.jpg "$SCRIPT_DIR/wallpapers/foxml-alt.jpg" "foxml-alt.jpg"
elif [[ -f ~/.wallpapers/new2.jpg ]]; then
    update_file ~/.wallpapers/new2.jpg "$SCRIPT_DIR/wallpapers/new2.jpg" "new2.jpg"
fi

# ─────────────────────────────────────────
# Waybar
# ─────────────────────────────────────────
echo ""
echo "Updating Waybar..."
update_file ~/.config/waybar/style.css "$SCRIPT_DIR/waybar/style.css" "style.css"

# ─────────────────────────────────────────
# Kitty
# ─────────────────────────────────────────
echo ""
echo "Updating Kitty..."
update_file ~/.config/kitty/kitty.conf "$SCRIPT_DIR/kitty/kitty.conf" "kitty.conf"

# ─────────────────────────────────────────
# Tmux
# ─────────────────────────────────────────
echo ""
echo "Updating Tmux..."
update_file ~/.tmux.conf "$SCRIPT_DIR/tmux/.tmux.conf" ".tmux.conf"

# ─────────────────────────────────────────
# Zsh
# ─────────────────────────────────────────
echo ""
echo "Updating Zsh..."
update_file ~/.zshrc "$SCRIPT_DIR/zsh/.zshrc" ".zshrc"
update_file ~/.config/zsh/colors.zsh "$SCRIPT_DIR/zsh/colors.zsh" "colors.zsh"
update_file ~/.config/zsh/aliases.zsh "$SCRIPT_DIR/zsh/aliases.zsh" "aliases.zsh"
update_file ~/.config/zsh/paths.zsh "$SCRIPT_DIR/zsh/paths.zsh" "paths.zsh"
update_file ~/.config/zsh/welcome.zsh "$SCRIPT_DIR/zsh/welcome.zsh" "welcome.zsh"
update_file ~/.config/zsh/conda.zsh "$SCRIPT_DIR/zsh/conda.zsh" "conda.zsh"
if [[ -f ~/.oh-my-zsh/themes/caramel.zsh-theme ]]; then
    update_file ~/.oh-my-zsh/themes/caramel.zsh-theme "$SCRIPT_DIR/zsh/caramel.zsh-theme" "caramel.zsh-theme"
fi

# ─────────────────────────────────────────
# Spicetify
# ─────────────────────────────────────────
echo ""
echo "Updating Spicetify..."
update_file ~/.config/spicetify/Themes/FoxML/color.ini "$SCRIPT_DIR/spicetify/color.ini" "color.ini"
update_file ~/.config/spicetify/Themes/FoxML/user.css "$SCRIPT_DIR/spicetify/user.css" "user.css"

# ─────────────────────────────────────────
# Yazi
# ─────────────────────────────────────────
echo ""
echo "Updating Yazi..."
update_file ~/.config/yazi/theme.toml "$SCRIPT_DIR/yazi/theme.toml" "theme.toml"

# ─────────────────────────────────────────
# Dunst
# ─────────────────────────────────────────
echo ""
echo "Updating Dunst..."
update_file ~/.config/dunst/dunstrc "$SCRIPT_DIR/dunst/dunstrc" "dunstrc"

# ─────────────────────────────────────────
# Rofi
# ─────────────────────────────────────────
echo ""
echo "Updating Rofi..."
update_file ~/.config/rofi/glass.rasi "$SCRIPT_DIR/rofi/glass.rasi" "glass.rasi"
update_file ~/.config/rofi/config.rasi "$SCRIPT_DIR/rofi/config.rasi" "config.rasi"

# ─────────────────────────────────────────
# GTK
# ─────────────────────────────────────────
echo ""
echo "Updating GTK..."
update_file ~/.config/gtk-3.0/gtk.css "$SCRIPT_DIR/gtk-3.0/gtk.css" "gtk-3.0/gtk.css"
update_file ~/.config/gtk-3.0/settings.ini "$SCRIPT_DIR/gtk-3.0/settings.ini" "gtk-3.0/settings.ini"
update_file ~/.config/gtk-4.0/gtk.css "$SCRIPT_DIR/gtk-4.0/gtk.css" "gtk-4.0/gtk.css"
update_file ~/.config/gtk-4.0/settings.ini "$SCRIPT_DIR/gtk-4.0/settings.ini" "gtk-4.0/settings.ini"

# ─────────────────────────────────────────
# btop
# ─────────────────────────────────────────
echo ""
echo "Updating btop..."
update_file ~/.config/btop/themes/foxml.theme "$SCRIPT_DIR/btop/foxml.theme" "foxml.theme"

# ─────────────────────────────────────────
# Firefox
# ─────────────────────────────────────────
echo ""
echo "Updating Firefox..."
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -name "*.default-release*" -type d 2>/dev/null | head -1)
if [[ -n "$FIREFOX_PROFILE" ]]; then
    update_file "$FIREFOX_PROFILE/chrome/userChrome.css" "$SCRIPT_DIR/firefox/userChrome.css" "userChrome.css"
else
    echo "  ⚠ No Firefox profile found"
fi

# ─────────────────────────────────────────
# Cursor / VS Code
# ─────────────────────────────────────────
echo ""
echo "Updating Cursor/VS Code..."
if [[ -f ~/.cursor/extensions/foxml-theme/themes/foxml-color-theme.json ]]; then
    update_file ~/.cursor/extensions/foxml-theme/themes/foxml-color-theme.json "$SCRIPT_DIR/cursor/foxml-color-theme.json" "foxml-color-theme.json (Cursor)"
elif [[ -f ~/.vscode/extensions/foxml-theme/themes/foxml-color-theme.json ]]; then
    update_file ~/.vscode/extensions/foxml-theme/themes/foxml-color-theme.json "$SCRIPT_DIR/cursor/foxml-color-theme.json" "foxml-color-theme.json (VS Code)"
else
    echo "  ⚠ No Cursor/VS Code theme found"
fi

# ─────────────────────────────────────────
# Vencord (Discord)
# ─────────────────────────────────────────
echo ""
echo "Updating Vencord/Discord..."
update_file ~/.config/Vencord/themes/foxml.css "$SCRIPT_DIR/vencord/foxml.css" "foxml.css"

# ─────────────────────────────────────────
# Done
# ─────────────────────────────────────────
echo ""
echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                      Update Complete!                           │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo ""
echo "Theme folder updated at: $SCRIPT_DIR"
echo ""
