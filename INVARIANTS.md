# FoxML Safety Invariants

This file defines the "Load-Bearing Assumptions" of the FoxML project. Breaking these rules will lead to silent drift or system failure. Use `/context` to audit the codebase against these rules.

## [I-01] Path Agnosticism
- **Rule**: No hardcoded absolute paths (e.g., `/home/caramel`).
- **Standard**: Use `XDG_CONFIG_HOME`, `HOME`, or `SCRIPT_DIR`.
- **Enforcement**: Scan for `/home/` strings in any `.sh`, `.conf`, or `.lua` file.

## [I-02] Hyprland v0.54+ Standard
- **Rule**: Use ONLY the unified syntax.
- **Standard**: Keyword: `windowrule`, Property: `col.active_border`.
- **Prohibited**: `windowrulev2`, `bordercolor`.
- **Enforcement**: Grep for prohibited keywords in all `shared/` and `templates/` files.

## [I-03] Data-Oriented Refactor (C++)
- **Rule**: C++ code MUST follow DOD principles.
- **Standard**: Favor SoA (Struct-of-Arrays), composition over inheritance, and branchless logic.
- **Library**: Use `nlohmann/json` for all JSON operations.
- **Enforcement**: Verify C++ files do not use deep virtual hierarchies or branchy conditionals in the hot path.

## [I-04] Safe System Mutex
- **Rule**: Never overwrite a system file without a backup.
- **Standard**: Use the `backup_and_copy` bash helper.
- **Enforcement**: Verify all `cp` or `mv` commands in `install.sh` and `mappings.sh` are wrapped by the helper.

## [I-05] Template Sync
- **Rule**: Templates must match the live logic.
- **Standard**: Any logic change in `shared/` must be mirrored in the corresponding `templates/` with `{{PLACEHOLDER}}` tokens.
- **Enforcement**: Run `/parity` to detect stale templates.
