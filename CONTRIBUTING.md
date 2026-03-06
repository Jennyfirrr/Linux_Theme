# FoxML Theme - Organization Rules

## Folder Structure

```
FoxML/
  btop/              # btop theme file
  cursor/            # Cursor/VS Code color theme JSON
  dunst/             # dunstrc (legacy - actual daemon is mako)
  fastfetch/         # config.jsonc
  firefox/           # userChrome.css
  gtk-3.0/           # gtk.css + settings.ini
  gtk-4.0/           # gtk.css + settings.ini
  hyprland/          # theme.conf, hypridle.conf, scripts/
  hyprlock/          # hyprlock.conf
  hyprpaper/         # hyprpaper.conf
  kitty/             # kitty.conf
  mako/              # mako notification config
  nvim/              # init.lua, lazy-lock.json, ftplugin/
  rofi/              # glass.rasi, config.rasi
  screenshots/       # theme showcase images
  spicetify/         # color.ini, user.css
  tmux/              # .tmux.conf
  vencord/           # foxml.css (Discord)
  wallpapers/        # wallpaper images
  waybar/            # style.css
  yazi/              # theme.toml
  zsh/               # .zshrc, caramel.zsh-theme, colors.zsh, aliases.zsh, etc.
  KEYBINDS.md        # full keybind reference
  FoxML.md           # palette + design spec (in parent dir)
  README.md          # overview + install instructions
  install.sh         # fresh system installer
  update.sh          # pull current system configs into this folder
```

## Rules for Keeping Configs Updated

### When to run `update.sh`
- After any visual/theme change to a config
- Before committing to git
- After adding a new app to the theme

### What goes in vs. stays out
**Include:**
- Anything theme-related (colors, fonts, borders, opacity, styling)
- Keybinds and layout configs (they're part of the workflow)
- Shell prompt, aliases, welcome screen
- Wallpapers

**Exclude:**
- Secrets, tokens, API keys (`.env`, credentials)
- Machine-specific paths that won't transfer (conda paths, etc. - keep in `paths.zsh` but review before sharing)
- Plugin caches, build artifacts, lock files that auto-regenerate
- `.bak` / `.bak2` / `.bak3` files (these are local safety nets, not for the repo)

### Adding a new app
1. Create a folder: `FoxML/<app-name>/`
2. Copy the relevant config files into it
3. Add an `update_file` entry in `update.sh`
4. Add a `backup_and_copy` entry in `install.sh`
5. Add a row to the table in `README.md`
6. If the app has keybinds, add a section to `KEYBINDS.md`

### Commit discipline
- Commit message format: `<app>: <what changed>` (e.g. `nvim: add vimtex + texlab LSP`)
- Group related changes (e.g. changing a color across hyprland + kitty + tmux = one commit)
- Don't commit broken configs - test before pushing

### Color changes
When updating the palette:
1. Update `FoxML.md` (the spec is the source of truth)
2. Grep for the old hex across all configs: `grep -r '#old_hex' .`
3. Update every occurrence
4. Run `update.sh` to pull any system-side changes you made manually
5. Commit as: `palette: shift <color> from #old to #new`

### Syncing direction
- **System -> Repo**: Run `./update.sh` (pulls your live configs in)
- **Repo -> System**: Run `./install.sh` (pushes repo configs to system)
- Always run update.sh before install.sh if you've been tweaking configs manually

### Git workflow
```bash
cd ~/THEME/FoxML
./update.sh          # pull latest from system
git diff             # review changes
git add -A
git commit -m "description of changes"
```

### Periodic maintenance
- Review `KEYBINDS.md` when adding/changing binds
- Check for stale configs (apps you no longer use)
- Update screenshots after major visual changes
