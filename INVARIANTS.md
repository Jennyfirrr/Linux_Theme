# FoxML Safety Invariants

Load-bearing rules. Breaking them causes silent drift or visible failure.

## [I-01] Path Agnosticism
- **Rule** — No hardcoded absolute paths (e.g. `/home/caramel`).
- **Standard** — Use `$HOME`, `$SCRIPT_DIR`, or `$XDG_CONFIG_HOME`.
- **Enforcement** — `grep -rn '/home/' --include='*.sh' --include='*.conf' --include='*.lua'` returns nothing.

## [I-02] Hyprland v0.54+ Syntax
- **Rule** — Use ONLY the unified syntax.
- **Standard** — Keyword: `windowrule`. Property: `col.active_border`.
- **Prohibited** — `windowrulev2`, `bordercolor`.
- **Enforcement** — `grep -rn 'windowrulev2\|bordercolor' shared/ templates/` returns nothing.

## [I-03] Safe System Mutex
- **Rule** — Never overwrite a system file without a backup.
- **Standard** — Use the `backup_and_copy` helper in `install.sh`. Backups land in `~/.theme_backups/foxml-backup-<timestamp>/`.
- **Enforcement** — Every `cp` or `mv` in `install.sh`/`mappings.sh` that targets `$HOME` or `/etc/` is wrapped by the helper or has an explicit reason in a comment.

## [I-04] Template Sync
- **Rule** — Templates must match live logic.
- **Standard** — Any logic change in `shared/` must be mirrored in the corresponding `templates/` with `{{TOKEN}}` placeholders, so the next theme swap doesn't drop the change.
- **Enforcement** — Run `./update.sh` after a manual edit; the resulting template diff should be color-only, not logic.

## [I-05] Per-machine config preservation
- **Rule** — Files containing per-machine state must not be clobbered by re-installs.
- **Standard** — `mappings.sh`'s deploy loops skip a destination file if it's flagged as per-machine and already exists. Currently flagged: `monitors.conf`.
- **Enforcement** — Re-running `./install.sh` on a configured machine leaves `~/.config/hypr/modules/monitors.conf` and `~/.config/foxml/monitor-layout.conf` untouched unless `configure_monitors` re-prompts and the user confirms.
