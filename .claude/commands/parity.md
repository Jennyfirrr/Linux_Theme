Check for configuration drift between the FoxML repository and the live system.

Instructions:
1. **Source/System Parity**:
   - Compare files in `shared/` with their system destinations (defined in `mappings.sh`).
   - Specifically check:
     - `shared/hyprland.conf` vs `~/.config/hypr/hyprland.conf`
     - `shared/waybar_config` vs `~/.config/waybar/config`
     - `shared/zsh_aliases.zsh` vs `~/.config/zsh/aliases.zsh`
2. **Template Parity**:
   - Check if the `rendered/` directory exists and contains files generated from the current `.active-theme`.
3. **Git Status**:
   - Run `git status` to see if there are uncommitted changes in the repo that differ from the "truth."
4. **Drift Report**:
   - List any files that have "drifted" (live version is different from the repo version).
   - Suggest `update.sh` to pull changes back to the repo, or `install.sh` to push repo changes to the system.
