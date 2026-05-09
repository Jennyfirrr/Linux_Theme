# Contributing

How the repo is laid out, how to add a new app to the theme, and how to add a new theme.

## Layout

```
templates/<app>/        config files containing {{TOKEN}} placeholders
themes/<theme>/         palette.sh + theme.conf
shared/                 non-color files copied verbatim (scripts, modules, wallpapers)
rendered/               throwaway output of render.sh — not committed
mappings.sh             TEMPLATE_MAPPINGS + SHARED_MAPPINGS + special handlers
render.sh               template engine (hex, RGB, ANSI, metadata substitution)
install.sh              renders templates → copies to system
update.sh               reverse: pulls live system configs back into templates
swap.sh                 interactive theme switcher
```

The repo is path-agnostic — it never assumes any particular `$HOME` and uses `$SCRIPT_DIR` / `$HOME` everywhere. See [INVARIANTS.md](INVARIANTS.md) for the full set of load-bearing rules.

## Adding a new app

1. **Create the template directory** — `templates/<app>/`
2. **Drop in the config file with `{{TOKEN}}` placeholders** instead of literal hex values. See `themes/FoxML_Classic/palette.sh` for the full token list (BG, FG, PRIMARY, RED, etc).
3. **Wire it up** in `mappings.sh` by adding a row to `TEMPLATE_MAPPINGS`:
   ```bash
   "<app>/<file>|<dest path>"
   ```
   Use `~` for `$HOME` — the installer expands it. Example:
   ```bash
   "lazygit/config.yml|~/.config/lazygit/config.yml"
   ```
4. **If the app needs special install logic** (JSON merging, sudo, extension installation, file rebuilds), add a handler in `install_specials()` in `mappings.sh` and gate the simple mapping with a continue-skip in the deploy loops. Examples in the file: Firefox userChrome (profile path resolution), Gemini CLI (jq merge to preserve auth keys), regreet (sudo to `/etc/greetd/`).
5. **Verify it round-trips** — run `./install.sh` (deploys), edit a color in the live config, run `./update.sh` (pulls back into the template with `{{TOKEN}}`s restored), then `./install.sh` again. The diff should be empty.
6. **Document it** — add a row to the "Themed apps" table in `README.md`, and if the app has keybinds, an entry in `KEYBINDS.md`.

## Adding a new theme

Cheaper than adding an app — you only need a palette.

1. **Copy an existing palette as a starting point**:
   ```bash
   cp themes/FoxML_Classic/palette.sh themes/My_Theme/palette.sh
   cp themes/FoxML_Classic/theme.conf themes/My_Theme/theme.conf
   ```
2. **Edit `palette.sh`** — set BG, FG, PRIMARY, SECONDARY, ACCENT, the ANSI 16, and the metadata fields (NVIM_STYLE, KITTY_BG_OPACITY, etc).
3. **Edit `theme.conf`** — set name, type (`dark` or `light`), and description.
4. **Apply**:
   ```bash
   ./install.sh My_Theme
   ```
   `install.sh` re-renders every templated config with your new palette.

`swap.sh` will pick up the new theme automatically — it's just a directory under `themes/` with both files.

## Editing a config

**Edit the template, not the live config.** If you forget and edit live, `update.sh` exists to pull the changes back:

```bash
./update.sh
```

This reverse-renders your `~/.config/<app>/...` files into `templates/<app>/...`, replacing rendered colors with the corresponding `{{TOKEN}}` placeholders so theme swaps still work.

Always run `./update.sh` before `./install.sh` if you've been tweaking configs by hand — otherwise install will overwrite your edits with the last template state.

## What goes in vs. what doesn't

**Include:**
- Theme files (colors, fonts, opacity, borders) and the templates that produce them
- Keybinds, layout configs, scripts that ship as part of the workflow
- Wallpapers
- Shell prompt, aliases, welcome screen

**Exclude (and gitignored):**
- Secrets — `.env`, credentials, API keys
- Per-user state — `claude-skills/`, `plans/`, `.active-theme`
- Build artifacts — `rendered/`, compiled binaries from `src/`
- Editor backup files — `*.bak`, `*~`

## Commit style

`git log --oneline` shows the existing convention. Short version:

- `feat:` for new features (new app, new theme, new keybind)
- `fix:` for bugs
- `refactor:` for reorganization without behavior change
- `docs:` for doc-only changes
- `chore:` for tooling, gitignore, build files

Group related changes — a color shift across hyprland + kitty + tmux is one commit, not three.

## Hyprland version contract

The repo targets Hyprland v0.54+. That means the unified `windowrule` keyword and `col.active_border` property name. The pre-unification forms (`windowrulev2`, `bordercolor`) won't render and will silently break the theme. See [INVARIANTS.md](INVARIANTS.md) [I-02].

## Testing checklist before pushing

- [ ] `./install.sh <theme>` runs end-to-end without errors
- [ ] `./update.sh` is a no-op on a freshly-installed config (round-trip clean)
- [ ] `./swap.sh` shows your new theme/app
- [ ] Visual check: `hyprctl reload`, restart waybar/dunst, open the apps you touched
- [ ] If you touched `mappings.sh` or `install.sh`: re-run with `--render-only` to verify nothing accidentally requires `--deps`
