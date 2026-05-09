# Linux_Theme — Agent Mandates

Persistent context for AI assistants working on this repo.

## Core Mandates

- **Path Agnosticism** — All install/render logic must use `$HOME`, `$SCRIPT_DIR`, or `$XDG_CONFIG_HOME`. No hardcoded `/home/<user>` strings.
- **Mapping Patterns** — New app configs are added to `TEMPLATE_MAPPINGS` in `mappings.sh`. If the app needs special install logic (JSON merging, sudo, extension installation), add a handler in `install_specials()` and gate the simple mapping with a continue-skip in the deploy loops.
- **Hyprland v0.54+** — Use the unified `windowrule` keyword and `col.active_border` property name only. `windowrulev2` and `bordercolor` are prohibited (they silently break the theme).
- **Backups before overwrites** — Use the `backup_and_copy` helper in `install.sh` for any file that already exists at the destination. Never overwrite a system file without a timestamped backup under `~/.theme_backups/`.

## Architecture

- **Templates** — App-specific styles live in `templates/<app>/` and use `{{TOKEN}}` placeholders.
- **Palettes** — Themes are bash scripts in `themes/<name>/palette.sh` defining ~60 color/metadata variables.
- **Special Handlers** — Reserved for logic `backup_and_copy` can't handle: merging JSON sections, installing browser extensions, rebuilding caches, sudo operations.
- **Multi-monitor** — `configure_monitors()` writes name-keyed Hyprland rules + a sidecar at `~/.config/foxml/monitor-layout.conf`. Downstream consumers (`start_waybar.sh`, `rotate_wallpaper.sh`) source the sidecar.

## See also

- [INVARIANTS.md](INVARIANTS.md) — load-bearing rules with explicit enforcement criteria
- [CONTRIBUTING.md](CONTRIBUTING.md) — add-an-app and add-a-theme workflows
