#!/bin/bash
# Fox ML Theme Installer
# Installs the Fox ML theme across all supported applications

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.foxtml-backup-$(date +%Y%m%d-%H%M%S)"

echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                    Fox ML Theme Installer                       │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo ""
echo "This will install the Fox ML theme for:"
echo "  - Hyprland (theme + hyprlock + hyprpaper)"
echo "  - Wallpaper"
echo "  - Waybar"
echo "  - Kitty"
echo "  - Tmux"
echo "  - Spicetify (Spotify)"
echo "  - Yazi"
echo "  - Dunst"
echo "  - Rofi"
echo "  - GTK 3 & 4"
echo "  - btop"
echo "  - Firefox"
echo "  - Cursor/VS Code"
echo "  - Discord (Vencord)"
echo ""
echo "Backups will be saved to: $BACKUP_DIR"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

mkdir -p "$BACKUP_DIR"

backup_and_copy() {
    local src="$1"
    local dest="$2"
    local dest_dir="$(dirname "$dest")"

    mkdir -p "$dest_dir"

    if [[ -f "$dest" ]]; then
        local backup_path="$BACKUP_DIR/${dest#$HOME/}"
        mkdir -p "$(dirname "$backup_path")"
        cp "$dest" "$backup_path" 2>/dev/null || true
    fi

    cp "$src" "$dest"
    echo "  ✓ $(basename "$dest")"
}

# ─────────────────────────────────────────
# Hyprland
# ─────────────────────────────────────────
echo ""
echo "Installing Hyprland theme..."
mkdir -p ~/.config/hypr/modules
backup_and_copy "$SCRIPT_DIR/hyprland/theme.conf" ~/.config/hypr/modules/theme.conf
backup_and_copy "$SCRIPT_DIR/hyprlock/hyprlock.conf" ~/.config/hypr/hyprlock.conf
backup_and_copy "$SCRIPT_DIR/hyprpaper/hyprpaper.conf" ~/.config/hypr/hyprpaper.conf

# ─────────────────────────────────────────
# Wallpaper
# ─────────────────────────────────────────
echo ""
echo "Installing wallpaper..."
mkdir -p ~/.wallpapers
if [[ -f "$SCRIPT_DIR/wallpapers/new_tmp.png" ]]; then
    cp "$SCRIPT_DIR/wallpapers/new_tmp.png" ~/.wallpapers/foxml.png
    echo "  ✓ foxml.png"
fi
if [[ -f "$SCRIPT_DIR/wallpapers/new2.jpg" ]]; then
    cp "$SCRIPT_DIR/wallpapers/new2.jpg" ~/.wallpapers/foxml-alt.jpg
    echo "  ✓ foxml-alt.jpg"
fi

# ─────────────────────────────────────────
# Waybar
# ─────────────────────────────────────────
echo ""
echo "Installing Waybar theme..."
mkdir -p ~/.config/waybar
backup_and_copy "$SCRIPT_DIR/waybar/style.css" ~/.config/waybar/style.css

# ─────────────────────────────────────────
# Kitty
# ─────────────────────────────────────────
echo ""
echo "Installing Kitty theme..."
mkdir -p ~/.config/kitty
backup_and_copy "$SCRIPT_DIR/kitty/kitty.conf" ~/.config/kitty/kitty.conf

# ─────────────────────────────────────────
# Tmux
# ─────────────────────────────────────────
echo ""
echo "Installing Tmux theme..."
backup_and_copy "$SCRIPT_DIR/tmux/.tmux.conf" ~/.tmux.conf

# ─────────────────────────────────────────
# Spicetify
# ─────────────────────────────────────────
echo ""
echo "Installing Spicetify theme..."
mkdir -p ~/.config/spicetify/Themes/FoxML
cp "$SCRIPT_DIR/spicetify/"* ~/.config/spicetify/Themes/FoxML/
echo "  ✓ FoxML theme"

if command -v spicetify &> /dev/null; then
    echo "  Configuring spicetify..."
    spicetify config current_theme FoxML 2>/dev/null || true
    spicetify config color_scheme Base 2>/dev/null || true
    echo "  Run 'spicetify apply' after installation to apply theme"
fi

# ─────────────────────────────────────────
# Yazi
# ─────────────────────────────────────────
echo ""
echo "Installing Yazi theme..."
mkdir -p ~/.config/yazi
backup_and_copy "$SCRIPT_DIR/yazi/theme.toml" ~/.config/yazi/theme.toml

# ─────────────────────────────────────────
# Dunst
# ─────────────────────────────────────────
echo ""
echo "Installing Dunst theme..."
mkdir -p ~/.config/dunst
backup_and_copy "$SCRIPT_DIR/dunst/dunstrc" ~/.config/dunst/dunstrc

# ─────────────────────────────────────────
# Rofi
# ─────────────────────────────────────────
echo ""
echo "Installing Rofi theme..."
mkdir -p ~/.config/rofi
backup_and_copy "$SCRIPT_DIR/rofi/glass.rasi" ~/.config/rofi/glass.rasi
backup_and_copy "$SCRIPT_DIR/rofi/config.rasi" ~/.config/rofi/config.rasi

# ─────────────────────────────────────────
# GTK
# ─────────────────────────────────────────
echo ""
echo "Installing GTK themes..."
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
backup_and_copy "$SCRIPT_DIR/gtk-3.0/gtk.css" ~/.config/gtk-3.0/gtk.css
backup_and_copy "$SCRIPT_DIR/gtk-3.0/settings.ini" ~/.config/gtk-3.0/settings.ini
backup_and_copy "$SCRIPT_DIR/gtk-4.0/gtk.css" ~/.config/gtk-4.0/gtk.css
backup_and_copy "$SCRIPT_DIR/gtk-4.0/settings.ini" ~/.config/gtk-4.0/settings.ini

# ─────────────────────────────────────────
# btop
# ─────────────────────────────────────────
echo ""
echo "Installing btop theme..."
mkdir -p ~/.config/btop/themes
backup_and_copy "$SCRIPT_DIR/btop/foxml.theme" ~/.config/btop/themes/foxml.theme
echo "  Set theme in btop with: color_theme = \"foxml\""

# ─────────────────────────────────────────
# Firefox
# ─────────────────────────────────────────
echo ""
echo "Installing Firefox theme..."
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -name "*.default-release*" -type d 2>/dev/null | head -1)
if [[ -n "$FIREFOX_PROFILE" ]]; then
    mkdir -p "$FIREFOX_PROFILE/chrome"
    backup_and_copy "$SCRIPT_DIR/firefox/userChrome.css" "$FIREFOX_PROFILE/chrome/userChrome.css"
    echo "  Note: Enable toolkit.legacyUserProfileCustomizations.stylesheets in about:config"
else
    echo "  ⚠ No Firefox profile found, skipping"
fi

# ─────────────────────────────────────────
# Cursor / VS Code
# ─────────────────────────────────────────
echo ""
echo "Installing Cursor/VS Code theme..."
# Try Cursor first, then VS Code
if [[ -d ~/.cursor/extensions ]]; then
    mkdir -p ~/.cursor/extensions/foxml-theme/themes
    cp "$SCRIPT_DIR/cursor/foxml-color-theme.json" ~/.cursor/extensions/foxml-theme/themes/
    cat > ~/.cursor/extensions/foxml-theme/package.json << 'EOF'
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
EOF
    echo "  ✓ Cursor theme installed"
fi

if [[ -d ~/.vscode/extensions ]]; then
    mkdir -p ~/.vscode/extensions/foxml-theme/themes
    cp "$SCRIPT_DIR/cursor/foxml-color-theme.json" ~/.vscode/extensions/foxml-theme/themes/
    cat > ~/.vscode/extensions/foxml-theme/package.json << 'EOF'
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
EOF
    echo "  ✓ VS Code theme installed"
fi

# ─────────────────────────────────────────
# Vencord (Discord)
# ─────────────────────────────────────────
echo ""
echo "Installing Vencord/Discord theme..."
mkdir -p ~/.config/Vencord/themes
backup_and_copy "$SCRIPT_DIR/vencord/foxml.css" ~/.config/Vencord/themes/foxml.css
echo "  Note: Install Vencord first, then enable theme in Discord settings"

# ─────────────────────────────────────────
# Done
# ─────────────────────────────────────────
echo ""
echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                    Installation Complete!                       │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo ""
echo "Post-install steps:"
echo "  1. Reload Hyprland: hyprctl reload"
echo "  2. Restart hyprpaper: pkill hyprpaper && hyprpaper &"
echo "  3. Restart Waybar, Dunst: pkill waybar && waybar & pkill dunst && dunst &"
echo "  4. Apply Spicetify: spicetify backup apply"
echo "  5. Restart Firefox and enable userChrome in about:config"
echo "  6. Select 'Fox ML' theme in Cursor/VS Code"
echo "  7. Enable foxml.css in Discord > Vencord > Themes"
echo ""
echo "Backups saved to: $BACKUP_DIR"
echo ""
