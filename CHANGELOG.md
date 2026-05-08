# Changelog

All notable changes to the Fox ML theme.

---

## 2026-05-07 — v1.5.9

FoxML OS & ISO Pipeline. Complete operating system specification, automated ISO build suite, and hardware-agnostic AI scaling.

### Distro — FoxML OS Experience
- **`archinstall` Profile**: Created `shared/foxml-profile.json` for fully automated OS deployment with **linux-zen** kernel and pre-configured hardware drivers.
- **ISO Build Suite**: Added `distro/` infrastructure (`profiledef.sh`, `packages.x86_64`) to package FoxML as a standalone bootable ISO.
- **`ai-distro-build`**: New utility to automate the creation of the FoxML-OS image.
- **`ai-distro-flash`**: New safety-first utility to flash the FoxML ISO to a USB drive with system-drive protection.
- **`ai-distro`**: Distro Guide utility for instant deployment instructions.

### AI — Hardware-Agnostic Scaling
- **`fox-hw-info`**: Implemented dynamic hardware detection. The system now categorizes itself into **Lite**, **Standard**, or **Pro** tiers based on actual RAM/VRAM.
- **Dynamic Stack**: `--models` now pulls a curated stack (e.g., 7B/14B/32B for Standard) optimized for the user's detected hardware.
- **Context-Aware Switcher**: `ai-swap` now dynamically labels model choices (Safe/Balanced/Heavy) based on detected system capacity.

### Maintenance & Safety
- **Universal Commands**: Generalized all `/slash` commands in `.agent/commands/` for use in any project.
- **Improved Backups**: Refined `backup_and_copy` logic to ensure system configs are safely versioned before being overwritten.
- **Emoji Purge**: Stripped emojis from installer and CLI tools for a high-discipline, professional terminal experience.

---

## 2026-05-07 — v1.5.8

Total Workstation Automation. Single-command workstation bootstrap, automated GitHub workspace, and integrated AI Lab.

### One-Command Bootstrap (`bootstrap.sh`)
- **Complete Environment Deployment**: The `bootstrap.sh` script now defaults to a full workstation stack (`--deps --ai --models --github`). A single `curl | bash` line now delivers a complete, professional dev environment from a fresh Arch install.

### GitHub — Automated Workspace (`--github`)
- **Seamless Repository Deployment**: New `--github` flag automates the creation of `~/code` and clones all public and private repositories for the user via `gh`.
- **Integrated Auth**: Synchronized with the SSH hardening wizard for a zero-password cloning experience once keys are authorized.
- **Git Identity Management**: Automatically prompts for and configures global Git name/email if missing.

### AI — Local LLM Workspace (Ollama & OpenCode)
- **Automated AI Stack**: `--ai` installs Ollama/OpenCode; `--models` automates pulling the **Qwen2.5-Coder stack (7B, 14B, 32B)**.
- **Universal Skills Vault**: Deploys a central vault at `~/.local/share/foxml/ai_skills/` and plugs high-discipline AI protocols (/readiness, /ship, /dust, etc.) into any project.
- **Model Management**: Added `ai-swap` (Tier switcher), `ai-purge` (VRAM/RAM flush), and `ai-bench` (Hardware performance tracking).
- **Project Tools**: Added `ai-new` (High-discipline project creator) and `ai-init` (Instant skill symlinking).

### Neovim — AI-Powered IDE
- **CodeCompanion.nvim**: Integrated for inline code generation and workspace chat.
- **Avante.nvim (Local)**: Cursor-style AI sidebar reconfigured for local-first privacy.

### Terminal — AI Superpowers
- **`??` Alias**: Natural language to Linux command generator.
- **`ai-commit`**: Automated Conventional Commit message generation.
- **`ai-log` / `ai-find`**: Instant error analysis and semantic codebase search.

### UI — Real-time AI Monitoring
- **Waybar AI Status**: Real-time tier display (7B/14B/32B) with **Live VRAM Tracking** for 4GB hardware.
- **SysHub Integration**: Added "Quick AI Chat" to the Rofi hub for floating, context-free queries.

---

## 2026-05-07 — v1.5.7

Performance, Privacy, and Vault pass. High-precision time, encrypted DNS, secure secret management, and Panic Button.

### Security — Vault, Panic Button & Auditing
- **Secure Vault (Pass)**: Integrated the `pass` (GPG-encrypted) password manager into the installer (`--vault`).
    - **Automated GPG**: Automatically detects or generates a personal GPG key to bootstrap the vault.
    - **SysHub Integration**: Added a "Vault (Passwords)" option to the Rofi Hub for instant searching/copying of secrets.
    - **Git Signing**: Automatically configures Git to cryptographically sign all commits with your GPG key.
- **The Panic Button**: Introduced a "Panic Button" script for instant system lockdown.
    - **Total Wipe**: Clears clipboard history (cliphist/wl-copy), kills sensitive apps (nvim, rofi-pass), stops trading engines, and locks the screen.
    - **Hotkeys**: Bound to **`Alt + Shift + K`** and available in the SysHub.
- **Lynis Auditing**: Added `lynis` to the security toolset. A full system security audit can now be launched directly from the SysHub.
- **Sudo Hardening**: Integrated a `NOPASSWD` sudoers drop-in for Waybar modules, enabling seamless security monitoring without password prompts.

### Performance & Privacy — Chrony & DoH
- **High-Precision Time (Chrony)**: Added the `--perf` flag to replace `systemd-timesyncd` with `chrony`. Provides sub-millisecond precision for trading engine logs and data correlation.
- **Encrypted DNS (DoH)**: Added the `--privacy` flag to enable **DNS-over-HTTPS** via `systemd-resolved`. Encrypts all DNS queries to prevent ISP tracking/spoofing (works seamlessly on restricted dorm/public WiFi).
- **Security Overwatch 2.0**:
    - **Always Visible**: The security shield icon (`󰒃`) is now always visible on the Waybar when secure (glowing green).
    - **Time Monitoring**: The shield now tracks `chronyd` status and alerts you if the system clock loses sync with atomic time.

### UI — Hub Expansion
- **SysHub 2.5**: Added "Vault", "Panic Button", and "Security Audit" entries to the primary Hub.

---

## 2026-05-07 — v1.5.6

Security hardening pass. Automated firewall, brute-force protection, and SSH hardening.

### Security — Automated Hardening & SSH Wizard
- **New `--secure` Installer Flag**: Added an opt-in `--secure` flag to `install.sh` that automates system-level security hardening.
- **Automated Firewall (UFW)**: The installer now configures `ufw` with a "Deny-by-Default" policy, explicitly allowing only the SSH port and outgoing traffic.
- **Brute-Force Protection (Fail2ban)**: Integrated `fail2ban` into the installation flow to automatically block IP addresses attempting brute-force attacks.
- **Interactive SSH Hardening Wizard**: Added a comprehensive wizard to `mappings.sh` that safely guides the user through:
    - **Custom SSH Port**: Configures a non-standard port (e.g., 5125) to reduce bot visibility and log spam.
    - **Automated Key Import**: Offers to fetch public keys directly from GitHub (`github.com/username.keys`) to simplify SSH key setup.
    - **Passwordless Auth**: Safely disables `PasswordAuthentication` only after verifying that SSH keys are present, preventing accidental lockouts.
- **Clean Configuration**: Hardening settings are written to `/etc/ssh/sshd_config.d/50-foxml-hardening.conf`, preserving the integrity of the main system `sshd_config` and ensuring settings survive OS updates.
- **Firewall/SSH Sync**: The script automatically updates UFW rules when a custom SSH port is selected, ensuring the firewall and SSH daemon stay in lockstep.

---

## 2026-05-07 — v1.5.5

A stability + UX pass. Hyprland 0.54.3 config errors resolved, Rofi popups seamlessly integrated with Waybar, and installer deployment logic fixed.

### UI — Seamless Rofi Dropdowns & Waybar Integration
- **Unified Launcher Box**: Grouped the Waybar `custom/logo` and `hyprland/workspaces` modules into a single, cohesive `group/launcher` box with a shared border and background.
- **Dynamic Popup Anchoring**: `start_waybar.sh` now dynamically calculates the exact pixel coordinates for the bottom edge of the Waybar and the left edge of the launcher box, exporting them as `ROFI_Y` and `ROFI_X`.
- **Flush Glass Theme**: Updated the Rofi `glass.rasi` theme to use a 1px 40%-opacity border (matching Waybar) and removed top padding. The popup now overlaps the Waybar border by exactly 1px, creating a seamless "drop-down" extension of the launcher box.
- **Global Toggle Wrapper**: Introduced `shared/hyprland_scripts/toggle_rofi.sh` to centralize Rofi toggling (killing active instances) and positioning injection. This fixes the "unexpected pixels" syntax error caused by Hyprland aggressively evaluating `$$` as PIDs instead of passing variables to the shell.
- **Centralized Hub Workflow**: Swapped the primary hotkey **`Alt + Shift + D`** (and the Waybar Fox icon) to open the **SysHub** directly. Standalone hotkeys for Search and Active Windows were removed to encourage a Hub-centric workflow.
- **Vim-Style Navigation & Exits**:
    - **`j/k`**: Scroll up/down through all menus.
    - **`l` or `Enter`**: Select/Execute items.
    - **`h`**: Instantly exits the Hub and sub-menus (Power, Network, etc.), providing a fast Vim-like escape.
- **Calculator & Emoji Picker**: Added `rofi-calc` and `rofi-emoji` to the installer dependencies and integrated them directly into the SysHub. Both use the unified `j/k/l` navigation.
- **Workspace App Icons**: Implemented Waybar's `window-rewrite` feature to display Nerd Font application icons next to the active workspace numbers (e.g., `1 󰈹` for Firefox), providing lightweight, real-time app tracking.
- **Fox Launcher Logo**: Swapped the default Arch Linux logo in the Waybar launcher for a Fox icon (`🦊`) to match the project's branding.
- **Polished Tooltips & Notifications**: Themed Waybar hover tooltips and system notifications (Dunst & Mako) to perfectly match the new Rofi glass aesthetic—featuring 90% opaque earthy backgrounds, 0px corner radii, and translucent 1px borders.
- **Tmux Git Ahead/Behind Counts**: The tmux status bar now tracks how many commits your current feature branch is ahead (↑) or behind (↓) the default branch (`main` or `master`), alongside the existing dirty indicator.

### Installer — Proper Deployment & Performance
- **Fixed `--render-only`**: The `install.sh --render-only` flag now correctly deploys updated `shared/` scripts, `bin/` helpers, and modules to your live config directories. Previously, it only regenerated templates, leaving the system running outdated logic.
- **Hub Speedup**: The SysHub (`hub.sh`) now uses `nmcli connection show --active` instead of a full WiFi scan, eliminating the 2-3 second startup lag.

### Hyprland — Window-Rule Compatibility
- **Swappy windowrules fixed for 0.54.3**: The inline form (`windowrule = float, class:^(swappy)$`) was failing parser validation because the colon in the regex matcher was being read as a key/value separator (`invalid field class:^(swappy)$: missing a value`). Converted to the unified block form already used throughout `rules.conf`:
  ```
  windowrule {
      name = swappy-float
      match:class = ^(swappy)$
      float = true
      size = 1200 800
      center = true
  }
  ```

### UI — Rofi Popup Alignment
- **Top-left anchor across the board**: The drun launcher (`Mod+Shift+D`) and the `Mod+Tab` window switcher both anchor `north west` with `x-offset: 12px` and `y-offset: 50px`, so popups land directly under the workspaces in the bar instead of top-center. Folds in the recent `force top-alignment on Rofi drun launcher` and `align Rofi to top and update layer animations` commits.
- **Robust theme loading**: Standardized on `-theme-str` overrides where positional offsets matter, so the override wins regardless of `~/.config/rofi/config.rasi` ordering. Fixes Alt+Shift+D occasionally picking up the wrong theme.

### Waybar — GPU Tooltip
- **GPU metrics folded into CPU tooltip**: Removed the standalone GPU pill; the CPU bubble's hover tooltip now lists CPU temp/load and GPU usage/temp together, matching the v1.5.4 density direction.

### Eww Control Center — Paused
- **Experiment, then revert**: Tried replacing the Rofi syshub with a graphical Eww panel + right-extending drawer for sub-menus (Audio, Network, Bluetooth, Power). Eww 0.5.0 has no native `hjkl` navigation (only GTK Tab/arrow keys), and matching the Rofi syshub UX — close handling, toggle behavior, keyboard nav — needed more plumbing than the visual upgrade justified.
- **Disabled, not removed**: Templates (`templates/eww/eww.yuck`, `eww.scss`), the action dispatcher (`shared/hyprland_scripts/eww_action.sh`), and the toggle script remain in the repo. Disabled at three integration points so nothing auto-launches: the `Mod+Shift+H` keybind reverted to `hub.sh`, the Rofi hub's "Open Control Center (Eww)" entry removed, and `eww daemon &` commented out in `startup.sh`. Re-enabling is a one-line flip if revisited later.
- **Toggle-loop bug fixed in the dormant script** for if/when it's re-enabled: `eww active-windows` outputs `<id>: <name>`, so the previous `^control_center$` grep never matched and the close path was unreachable. Switched to `eww list-windows` with a more lenient pattern.

---

## 2026-05-07 — v1.5.4

Power tuning gets a guided installer pass, and Waybar is consolidated from a 15-module sprawl into 10 dense bubbles with everything else folded into hover tooltips.

### Installer — CPU Throttling Wizard
- **Always-prompt setup**: New `install_throttling()` runs at the end of every interactive install (skipped under `-y`). Each step is its own y/N so users can pick & choose.
- **Intel turbo disable**: Writes `/etc/tmpfiles.d/disable-turbo.conf` so `no_turbo=1` re-applies on every boot — survives suspend/wake and kernel resets.
- **`cpupower` max-frequency cap**: Prompts for an MHz value (showing the hardware max as a hint), persists via `/etc/default/cpupower`, and enables `cpupower.service` so the cap survives reboots — fixing the common gotcha where `cpupower frequency-set -u` is a one-shot.
- **CPU governor**: Validates the requested governor against the kernel-reported list before applying, then persists it alongside `max_freq`.
- **`throttled` (ThinkPad MSR fix)**: Auto-detected via DMI. Installs from AUR using `yay`/`paru` and enables the service. Tunables (PL1/PL2, `Trip_Temp_C`, voltage offsets) stay hand-edited in `/etc/throttled.conf` — wrong undervolts crash silently, so no risky defaults are imposed.
- **Sample config**: New `shared/throttled.conf` ships a documented starting point (P15 Gen 2i, conservative PL1/PL2, no undervolt) with per-CPU tuning notes in the header.

### Aesthetics — Waybar Streamlining
- **Density cut from 15 → 10 modules**. Six standalone pills folded into composite tooltips so the right-hand cluster has room to breathe.
- **`custom/clock`**: Date + time in the bubble (with the `` calendar glyph and the same peach-bold + glow as before). Hover reveals weather (via `wttr.in`, cached 30 min) and pending pacman updates (via `checkupdates`, cached 10 min).
- **`custom/battery`**: Capacity + charge icon in the bubble. Hover reveals current speaker volume and screen brightness. Charging / warning / critical states preserved via JSON `class` field — same color set as the old built-in module.
- **`custom/net_speed` tooltip**: When on a wireless link, hover now shows the active SSID and signal strength (read via `nmcli`) — the standalone `network` module is gone.
- **Removed from bar**: `weather`, `network`, `updates`, `pulseaudio`, `backlight`, `project_name`. Their data lives in tooltips now.
- **Pure-bash `net_speed`**: Dropped the `bc` runtime dependency — speed formatting now uses integer math.

### Branding — Fox ASCII Repair
- **Welcome banner**: Fixed a corrupted escape sequence (`/\\\\_∕\\\\` → `/\_/\`) so the Fox face renders cleanly in `welcome.zsh` and the Neovim dashboard header.
- **Quieter post-submit prompt**: The caramel theme's accept-line indicator changed from `❯` (accent2) to `•` (ANSI_OK) — softer visual hand-off after each command.

---

## 2026-05-06 — v1.5.3

Final UI refinement for a distraction-free experience.

### Aesthetics — Distraction-Free UI & Scaling
- **Hidden Search Bars**: Removed the search bar from all non-launcher Rofi menus (Bluetooth, Network, Audio, Hub, and App Switcher). These menus now feel like clean, native desktop utilities.
- **Universal `j/k` Navigation**: All utility menus now use **plain `j` and `k`** for navigation and **`l`** for selection. This allows for unified, home-row navigation without modifier conflicts.
- **Resolution Scaling**: Replaced hardcoded pixel widths with **relative percentages**. All menus now automatically scale to your screen size, ensuring they remain perfectly centered and proportional on 1080p, 1440p, and 4K displays.
- **Persistent Launcher**: The search bar remains active only in the main Application Launcher (`ALT + Shift + D`), where it is functionally required for fuzzy searching.

---

## 2026-05-06 — v1.5.2

Aesthetic refinement and power-user window management. Perfected UI transparency, bar alignment, and browser integration.

### Workflow — Tabbed Window Groups
- **Themed Groupbar**: Enabled Hyprland "Groups" (Window Tabs) with a custom FoxML look. Active tabs use the earthy Peach palette, while inactive tabs stay in the subtle Slate color.
- **Group Keybinds**:
    - **`ALT + G`**: Toggle the current window into/out of a group.
    - **`ALT + [`** and **`ALT + ]`**: Cycle between tabs in the current group.

### Aesthetics — Perfect Transparency & Glass
- **Rofi Fixed**: Resolved "opacity stacking" where inner elements were making the menus look opaque. Transparency is now applied only at the window level, allowing for a pure frosted glass look.
- **Waybar Alignment**: The top bar now dynamically reads your Hyprland `gaps_out` and sets its margins to match. It now aligns perfectly with your windows for a seamless "floating" aesthetic.
- **Improved Scaling**: Refined font sizes and heights across all resolution profiles to ensure UI elements are proportional and highly readable on 1080p, 1440p, and 4K displays.

### Firefox — Distro-Grade UI Refinement
- **Context Menu Fix**: Eliminated the "white background" glitch on context menus by aggressively forcing earthy backgrounds and disabling native theme overrides.
- **URL Bar Dropdown**: Refined the search suggestion dropdown with proper dark backgrounds, sharp borders, and high-contrast peach selection highlights.
- **Unified Sharpness**: Ensured all popups, panels, and menus maintain 0px rounding for a consistent FoxML aesthetic.

---

## 2026-05-06 — v1.5.1


Major suite of Workflow and Creative upgrades. This release transitions FoxML from a "Theme" to a complete "Distro Lite" experience for developers.

### Installer — "Distro Lite" Features
- **Biometric Automation**: New `fox-fingerprint` command automates enrollment and PAM setup for the Lenovo P15.
- **Dependency Sync**: Integrated Steam (multilib), Bluetooth drivers, and creative tools into the core installer.
- **Thermal Awareness**: Gated heavy dependencies and optimized keybinds for lower resource usage.

### Workflow — Centralized Control
- **FoxML Hub**: Unified control center (**`ALT + Shift + H`**) for Power, Connectivity, and Maintenance.
- **Fast Switching**: Themed **`ALT + Tab`** window switcher and rapid workspace cycling (**`ALT + , / .`**).
- **Audio Switcher**: Dedicated Rofi menu for device switching.

### Creative — Design & Annotation
- **Color Picker**: Integrated `hyprpicker`. Press **`ALT + Shift + P`** to click any pixel on screen and instantly copy its Hex code to your clipboard.
- **Pro Screenshots**: Upgraded the screenshot utility with `swappy`. Region screenshots now open a lightweight GUI editor that always floats in the center of your screen. 
- **User UX**: Fixed the "heavy app" feel by forcing the editor to float. To discard a screenshot, simply hit **`ESC`**. To save and copy, click the **Save** icon.

### Documentation & UX
- **Keybind Overhaul**: Full refresh of `KEYBINDS.md` covering all new desktop-wide features.
- **Aesthetic Refinement**: Perfected Frosted Glass transparency and Waybar alignment.

---

## 2026-05-06 — v1.4.2

Aesthetic refinement and hardware-software synchronization. Fixed transparency issues and improved bar alignment.

### Aesthetics — Perfect Transparency & Glass
- **Rofi Fixed**: Resolved "opacity stacking" where inner elements were making the menus look opaque. Transparency is now applied only at the window level, allowing for a pure frosted glass look.
- **Waybar Alignment**: The top bar now dynamically reads your Hyprland `gaps_out` and sets its margins to match. It now aligns perfectly with your windows for a seamless "floating" aesthetic.
- **Improved Scaling**: Refined font sizes and heights across all resolution profiles to ensure UI elements are proportional and highly readable on 1080p, 1440p, and 4K displays.

---

## 2026-05-06 — v1.4.1

Project cleanup and focus refinement. Removed all Spotify/Spicetify components as requested.

### Cleanup — Spotify Removal
- **Deleted Integration**: Removed `spotify` and `spicetify-cli` from the installer and dependency lists.
- **Removed Themes**: Deleted all Spicetify theme templates (`color.ini`, `user.css`) and mappings.
- **UI Decoupling**: Removed the Spotify Waybar module and associated helper scripts.
- **Keybind Cleanup**: Deleted dedicated Spotify/ncspot keybinds. Standard media keys now use generic `playerctl` commands for maximum compatibility with any running player.

---

## 2026-05-06 — v1.4.0

Complete biometric automation for the FoxML environment.

### Hardware — FoxML Fingerprint
- **`fox-fingerprint`**: New automated setup utility. One command to enroll fingerprints, configure PAM for `sudo`, `login`, and `greetd`, and integrate SSH Keyring auto-unlocking.
- **Biometric Sudo**: Optimized the authentication flow so `sudo` commands can be authorized with a touch, while maintaining a password fallback.
- **SSH Automation**: Integrated GNOME Keyring with Zsh to automatically manage SSH passphrases, allowing biometrics to unlock your Git workflow.

---

## 2026-05-06 — v1.3.9

Integrated hardware support for the Lenovo P15's fingerprint reader.

### Hardware — Fingerprint Support
- **Dependencies**: Added `fprintd` to the base installer.
- **Auto-Detection**: The installer now detects Synaptics (and other) fingerprint readers via `lsusb` and provides a themed setup guide for enrollment and PAM (auth) integration.
- **Git/Sudo Integration**: Unified the hardware with the system auth stack, allowing for fingerprint-authorized `sudo` and SSH key unlocking for GitHub pushes.

---

## 2026-05-06 — v1.3.8

Created a unified "Seamless Navigation" system and addressed critical thermal issues.

### Workflow — Seamless Navigation
- **Unified `ALT + hjkl`**: Navigation is now identical across the entire desktop.
  - **Hyprland**: Moves focus between windows.
  - **Tmux**: Moves focus between panes (no prefix required).
  - **Neovim**: Moves focus between splits.
- **Rapid Workspaces**: Added **`ALT + ,`** and **`ALT + .`** to cycle through workspaces instantly without using the number row.

### Performance — Thermal Management
- **`ncspot` by Default**: Switched the primary music keybind to `ncspot` (terminal client). It uses ~90% less CPU/RAM than the Spotify Electron app, keeping your laptop cool while you work.

---

## 2026-05-06 — v1.3.7

Refined the Rofi experience with Vim-like navigation and a distraction-free Hub.

### Workflow — Vim Navigation
- **Global `Alt + hjkl`**: All Rofi menus (Launcher, Bluetooth, Network, etc.) now support navigation using **`Alt + k`** (Up), **`Alt + j`** (Down), and **`Alt + l`** (Select).
- **Clean Hub**: The **FoxML Hub** and **Power Menu** now have the search bar hidden for a cleaner "app-like" look. Since there is no search conflict, you can navigate these menus with **plain `j` and `k`** and select with **`l`**.

---

## 2026-05-06 — v1.3.6

Aesthetic and functional unification. Upgraded all major UI elements to a frosted glass look and added a central control hub.

### Aesthetics — Frosted Glass Upgrades
- **Rofi**: Dropped opacity to 70% and enabled backdrop blur. The launcher and manager menus now have a beautiful frosted glass aesthetic.
- **Waybar**: Increased transparency (70%) for a lighter, more integrated feel on the desktop.

### Workflow — FoxML Hub & Night Light
- **FoxML Hub**: Introduced a unified control center (**`ALT + Shift + H`**). Access Power, Bluetooth, Network, Wallpapers, and Cleanup from a single menu.
- **Night Light**: Integrated `wlsunset` for an automated earthy blue-light filter. Automatically warms the screen to 4500K after sunset.
- **Interactive Wallpapers**: Added a "Next Wallpaper" option to the Hub to quickly cycle through the FoxML collection with a fade transition.

---

## 2026-05-06 — v1.3.5

Enhanced system management and maintenance utilities.

### Connectivity — Rofi Managers
- **Bluetooth Manager**: Added a themed Rofi menu (**`ALT + Shift + B`**) to power on/off, scan, and connect to paired devices.
- **Network Manager**: Added a Rofi Wi-Fi selector (**`ALT + Shift + N`**) for quick network switching.
- **Keybind Refactor**: Moved `btop` to **`ALT + Shift + T`** (Task manager) to make room for the new connectivity binds.

### Maintenance — FoxML Cleanup
- **`fox-clean`**: New Zsh utility for automated system maintenance. Purges package cache (keeping 2 versions), removes orphans, rotates system logs (7 days), and trims clipboard history (keeping last 100).

---

## 2026-05-06 — v1.3.4

Introduced a suite of themed Quality of Life (QL) upgrades for a smoother desktop experience.

### Hyprland — Clipboard & Power Management
- **Clipboard History**: Integrated `cliphist`. Press **`ALT + V`** to see a searchable Rofi menu of your recent copies (text and images).
- **Power Menu**: Added a themed Rofi power menu. Press **`ALT + Shift + X`** for Shutdown, Reboot, Suspend, Lock, and Logout options.
- **Themed OSD**: Created a new On-Screen Display (OSD) system for Volume and Brightness. Changes now trigger a transient, themed notification with a progress bar that matches the FoxML palette.

### System — Lock Screen Sync
- **Hyprlock Sync**: Replaced legacy `swaylock` references with `hyprlock`. The lock screen now perfectly matches your active theme's colors, wallpaper, and blur settings.
- **Autostart**: Added clipboard background services to the autostart sequence.

---

## 2026-05-06 — v1.3.3

Cleaned up dependencies and removed broken components to ensure a reliable out-of-the-box experience.

### Installer — Dependency Sync
- **Added Core Apps**: Added `lazygit`, `ncspot`, `steam`, and `thunar` to the mandatory `PACMAN_PKGS` list.
- **Multilib Support**: The installer now detects if Steam is requested and automatically offers to enable the `[multilib]` repository in `/etc/pacman.conf` if it's missing (required for 32-bit apps like Steam).
- **Removed Vencord**: Deleted all Vencord (Discord) theme templates and mappings as they were reported as non-functional.

---

## 2026-05-06 — v1.3.2

Refined the Spotify experience for performance and aesthetics. Gated heavy dependencies for better thermals and upgraded the theme to a modern glass look.

### Installer — Thermal Management
- **Gated Spotify**: Spotify and Spicetify are now moved to an optional `--spotify` flag. `./install.sh --deps` no longer installs these heavy apps by default, protecting system thermals on low-spec hardware.

### Spotify — Glassmorphism & UX
- **Theme Upgrade**: Rewrote the Spicetify `user.css` with a "Glassmorphism" aesthetic. Includes `16px` backdrop blur, 70% transparency, and sage (lavender) accents for a more balanced, premium feel.
- **Scratchpad Fix**: Improved `toggle_spotify.sh` to handle "ghost" processes. It now detects if Spotify is running in the tray without a window and restarts it automatically when the keybind (**ALT + Shift + S**) is pressed.
- **Waybar Interaction**: The new Waybar module now supports scrolling to skip tracks and right-clicking to toggle the scratchpad.

---

## 2026-05-06 — v1.3.1

Automated the remaining manual steps for Spotify and Bluetooth support. This release makes the installation process truly "one-command" for users needing music and wireless audio.

### Installer — Spotify & AUR Support
- **AUR Helper Automation**: The installer now detects `yay` or `paru`. If neither is found, it offers to automatically install `yay-bin` from the AUR (requires confirmation or `--yes`).
- **Spotify & Spicetify**: Added `spotify` and `spicetify-cli` to the automated dependency list. When `--deps` and `--yes` are passed, they are installed unattended.
- **Auto-Theming**: The installer now handles the `chmod` permissions for `/opt/spotify` and runs `spicetify backup apply` automatically. Spotify now boots fully themed on the first run.

### Installer — Bluetooth Support
- **Dependencies**: Added `bluez`, `bluez-utils`, and `blueman` (GUI manager) to the base `PACMAN_PKGS`.
- **Auto-Enable**: The installer now automatically enables and starts the `bluetooth` systemd service.
- **Audio Integration**: Integrated with `pavucontrol` and `playerctl` (already in deps) for a seamless wireless audio experience.

---

## 2026-05-06 — v1.3.0

Frictionless first-boot pass. The previous release got the login screen and waybar to the user without manual steps; this one closes the remaining holes that surfaced on a clean Arch box: CLI auth flows that died with `xdg-open ENOENT`, btop launching unthemed because no `btop.conf` existed yet, and the AI CLIs (Gemini, Claude Code) needing a separate manual install pass. Also adds Gemini CLI to the themed-app list and gates the heavy XGBoost source build behind its own flag.

### Installer — XDG default browser + `xdg-utils`
- **`xdg-utils`** added to `PACMAN_PKGS` (Apps + viewers group). Without it, CLI auth helpers — gcloud, gh, oauth flows — try to spawn a browser via `xdg-open` and die with `ENOENT` on a fresh install.
- New post-pacman block runs `xdg-settings set default-web-browser firefox.desktop` automatically (idempotent — writes `~/.config/mimeapps.list`). Guarded on `xdg-settings` being on PATH and `firefox.desktop` existing in `/usr/share/applications`, so re-runs and non-firefox systems are no-ops.

### Installer — AI CLIs via npm
- New global-CLI block in `--deps` installs `@google/gemini-cli` (→ `gemini`) and `@anthropic-ai.agent-code` (→ .agent`) via `sudo npm install -g`. Idempotent: probes PATH for each command name and only installs the missing ones, so re-runs print `✓ Gemini CLI + Claude Code already installed`.
- Sits after the Oh My Zsh step and depends on `nodejs npm` already being in `PACMAN_PKGS` (was added in v1.0.1 for nvim Mason).

### Installer — `--xgboost` flag (source build)
- New top-level `if $INSTALL_XGBOOST;` section, gated behind `--xgboost`. Clones `dmlc/xgboost` (recursive) to `~/code/xgboost`, runs `cmake .. -DBUILD_STATIC_LIB=OFF && make -j$(nproc) && sudo make install && sudo ldconfig`. ~5–10 min compile, opt-in because most users won't need it.
- Idempotent at three levels: skipped entirely if `/usr/local/lib/libxgboost.so` already exists; clone is guarded by an `[[ -d ... ]]` check; the build runs in a subshell with its own `set -e` so a compile failure doesn't abort the rest of the installer.
- Hard-fails early if `cmake` is missing with a hint to run `--deps` first or `pacman -S cmake`.
- `--xgboost` joins `--deps` / `--nvidia` in the unattended-mode sudo-cache check, so `-y --xgboost` doesn't pause for a password mid-build.
- `cmake` added to `PACMAN_PKGS` (new "Build tools" group) so `--deps --xgboost` works in one pass.

### Themes — Gemini CLI integration
- `templates/gemini/settings.json` (placeholders for the FoxML custom theme) and `rendered/gemini/settings.json` (FoxML_Classic-rendered output) added. Uses placeholders already present in both shipping palettes (`BG`, `FG`, `PRIMARY`, `SURFACE`, `YELLOW`, `BLUE`, `GREEN_BRIGHT`, `RED`, `COMMENT`, `DIFF_ADD`, `DIFF_DELETE`).
- New `GEMINI_DIR` placeholder in `TEMPLATE_MAPPINGS` (`mappings.sh`), resolved to `${GEMINI_CONFIG_HOME:-$HOME/.gemini}` by the special handler. Skip-guards added in `install.sh` and `update.sh` so the generic copy loop bypasses the entry — the merge can't be a plain copy or it would clobber `security.auth`.
- `install_specials()` jq-merges the rendered `ui` block into `~/.gemini/settings.json` (`jq -s '.[0] * .[1]'`), so existing keys (auth, MCP servers, model selection) are preserved across re-installs. Falls back to a plain copy if the file doesn't exist yet, or prints a warning if jq fails.
- `update_specials()` reverses the flow: `jq '{ui: .ui}'` extracts only the UI block back into `templates/gemini/settings.json`, keeping security/auth state out of the captured template (so `update.sh` doesn't leak session creds into the repo).
- `AGENT.md` ported from the cpp-rewrite branch — architectural mandates and refactor notes for the future C++ CLI.

### Bugfix — btop on fresh install
- `mappings.sh` btop handler now creates `~/.config/btop/btop.conf` with `color_theme = "foxml"` if the file doesn't exist. Previously the handler only flipped an existing config, so on a fresh box (no `btop.conf` yet — btop creates it on first launch) the theme silently no-op'd: the rendered `foxml.theme` landed in `~/.config/btop/themes/`, but nothing pointed at it. btop auto-fills the rest of the defaults on first run, so the one-line config is enough.
- Three explicit branches: missing file → create; `color_theme = "foxml"` already → noop; `color_theme = ` line present → sed; line entirely absent → append.

---

## 2026-05-06 — v1.2.0

Hands-off install pass. The previous release left three things to the user as manual post-install dances: copy regreet files into `/etc/greetd/` and write `config.toml`, fetch the Catppuccin cursor theme by hand, and re-tune the waybar by hand when moving between a 4K and a 1080p screen. All three are now driven by the installer + a single runtime wrapper.

### Installer — Login screen, cursor, deps
- **`install_greetd()`** (in `mappings.sh`) auto-runs whenever `greetd-regreet` is installed. It deploys regreet css/toml + the staged Hyprland greeter config to `/etc/greetd/`, copies the wallpaper referenced by `regreet.toml` into `/usr/share/wallpapers/` (creating the dir), writes `/etc/greetd/config.toml` to launch Hyprland as the greeter, and `systemctl enable greetd`. Idempotent — preserves a customized `config.toml` and skips when the system already has the right state.
- **`install_catppuccin_cursor()`** fetches `catppuccin-mocha-peach-cursors` from the upstream `catppuccin/cursors` GitHub releases and extracts it to `~/.local/share/icons/` (XDG user dir, no sudo). Runs unconditionally because every theme references this cursor; bails early if already present, if the asset URL can't be resolved, or if `unzip`/`curl` are missing.
- **New `PACMAN_PKGS` entries:** `greetd`, `greetd-regreet` (login screen now installs by default), `gnome-keyring`, `libsecret` (the keyring/secrets stack the autostart line and `seahorse` askpass already assumed was present), `unzip` (consumed by `install_catppuccin_cursor`).
- **`XCURSOR_PATH`** added to `env-init.sh` and `environment.conf` so apps actually find `~/.local/share/icons` — the default path (`~/.icons:/usr/share/icons:/usr/share/pixmaps`) doesn't include the XDG user dir, which is why a previously-extracted Catppuccin theme was silently ignored.

### Waybar — Auto-scaling per monitor
- New `shared/hyprland_scripts/start_waybar.sh` wrapper. Reads `hyprctl monitors -j` for the primary monitor's effective width (pixels ÷ scale), picks one of three profiles, sed-substitutes `__SIZE__` tokens into `~/.config/waybar/{style.css,config}` from `.tmpl` source files, then `exec waybar`.
  - **1080p (≤1920):** font 9.5pt, bar height 32, margin 6, cursor 24
  - **1440p (≤2560):** font 11pt, bar height 40, margin 8, cursor 28
  - **4K (else):** font 12.5pt, bar height 52, margin 12, cursor 32 *(the original 4K-tuned values)*
- `templates/waybar/style.css` and `shared/waybar_config` now carry `__FONT_BASE__`, `__FONT_LOGO__`, `__FONT_STATS__`, `__PAD_WIN__`, `__PAD_MOD__`, `__MARGIN_MOD__`, `__HEIGHT__`, `__MARGIN_BAR__`, `__TRAY_ICON__` placeholders. Mappings deploy them as `style.css.tmpl` / `config.tmpl`; the wrapper writes the live files.
- `--render-only` mode lets `install.sh` produce the live files without launching waybar, so a fresh install ends up with a correctly-sized config before the next Hyprland session.
- Cursor sizing piggybacks on the same profile pick: the wrapper also `hyprctl setcursor`s the running session and `setenv`s `XCURSOR_SIZE` for new children. The hardcoded `XCURSOR_SIZE=30` in `env-init.sh` / `environment.conf` is now a 24 fallback that the wrapper overrides on the first apply pass.
- `startup.sh` calls the wrapper instead of `waybar &` directly.

### Kitty — CJK fallback for the welcome banner
- Added `symbol_map U+3000-U+30FF,U+FF00-U+FFEF,U+4E00-U+9FFF Noto Sans CJK JP` to `templates/kitty/kitty.conf`. The fox banner's kaomoji glyphs (`じ`, `し`, `ノ`, `〵`, etc.) were rendering as tofu boxes because `noto-fonts-cjk` is installed but fontconfig picks Latin-only Noto Sans for those codepoints — kitty needs the explicit map.

### Docs
- README "Login Screen" section: removed the manual `sudo cp` + `tee` post-install dance — now a one-paragraph note that `install.sh --deps` does it.
- README "Post-Install" step 7 (manual greetd copy) dropped.
- `install.sh` summary line for restarting waybar updated to `~/.config/hypr/scripts/start_waybar.sh` so you don't need to remember to bypass the wrapper.

---

## 2026-04-30 — v1.1.0

Major update to the wallpaper system, moving from random rotation to time-of-day "buckets" that match the solar cycle.

### Wallpaper — Time-of-Day Rotation ("Buckets")
- Converted `rotate_wallpaper.sh` from random selection to a bucket-based system. The wallpaper now automatically matches the current hour:
  - **05:00 – 10:00 (Dawn):** `foxml_misty_dawn.jpg`
  - **10:00 – 18:00 (Midday):** `foxml_earthy.jpg`
  - **18:00 – 22:00 (Sunset):** `foxml_sunrise_sunbeams.jpg`
  - **22:00 – 05:00 (Night):** `foxml_night_woods.jpg`
- Added `foxml_night_woods.jpg` (4K) to the wallpaper pool for the night slot.
- Rotation is now **idempotent**: if the correct wallpaper for the current slot is already active, the script exits silently without triggering a fade or notification.
- New `--cycle` flag for manual rotation (ALT+W). It advances one slot forward regardless of the time, allowing manual "mood" changes that persist until the next scheduled bucket transition.

### Systemd — Precise Rotation Timer
- Updated `wallpaper-rotate.timer` to fire exactly on slot boundaries (05, 10, 18, 22) plus a 30-minute mid-hour check.
- Added `Persistent=true` to the timer so missed fires during suspend or power-off are caught up immediately on wake.

### Hyprland — Integration Improvements
- **Autostart:** `autostart.conf` now calls `rotate_wallpaper.sh` directly on startup. This ensures the correct time-of-day wallpaper is applied immediately on login, replacing the old behavior of just restoring the last-saved symlink.
- **Keybinds:** Added `--cycle` to the `ALT+W` bind so manual rotation always changes the image instead of snapping to the current hour's bucket.

---

## 2026-04-28 — v1.0.1

Patch release covering the missing-deps gap discovered immediately post-v1.0.0.

### Installer — Neovim runtime deps
- Added `nodejs`, `npm`, `tree-sitter-cli` to `install.sh`'s `PACMAN_PKGS`. v1.0.0 worked on the verifying box because these were already present from earlier setup, but a fresh Arch laptop hit four cascading errors on first nvim launch:
  - `Copilot.lua: Could not determine Node.js version` → no `node` in `PATH`
  - `Failed to run config for avante.nvim` → cascaded from the copilot failure
  - `mason-lspconfig.nvim` failed to install pyright / bashls / jsonls / yamlls → all are npm-distributed
  - `tree-sitter CLI not found: latex parser must be generated from grammar definitions` → the latex parser on the current `nvim-treesitter` line generates from source

### Neovim — Pin nvim-treesitter to `master`
- `nvim-treesitter` and `nvim-treesitter-textobjects` shipped a major rewrite on their default `main` branches that dropped the `nvim-treesitter.configs` module entirely. Our `init.lua` calls `require("nvim-treesitter.configs").setup({...})`, which errors with `module not found` against `main`.
- Pinned both lazy specs to `branch = "master"` — the legacy v0.x branch that retains the `configs.setup()` API. The migration to the new API is a separate (larger) task; pinning is the right move for a 1.0 stability line.

### Neovim — Drop `latex` parser from `ensure_installed`
- `tree-sitter-cli 0.26.x` changed how `--no-bindings` is passed to `tree-sitter generate` (now requires `-- --no-bindings` to disambiguate from a flag), and `nvim-treesitter` `master`'s build script still calls the old form. The `latex` parser on this line generates from source so it hit the error every nvim launch
- Removed `latex` from the `ensure_installed` list. Other parsers in the list ship pre-compiled grammars and are unaffected. Add `latex` back when nvim-treesitter updates its build script for the 0.26.x CLI

---

## 2026-04-27 — v1.0.0 <3

First tagged release. The earthy palette is settled, the installer is one-command, and a fresh Arch+Hyprland laptop boots into the full FoxML experience without manual surgery. Verified end-to-end on a Dell Precision 5540 (Quadro T2000 + Intel UHD 630).

### Hyprland — NVIDIA Optimus Support (`install.sh --nvidia`)
- New `install_nvidia()` hook routes the entire Wayland session to the discrete GPU on hybrid Optimus laptops where the iGPU bottlenecks under compositor + multi-Chromium + transparent windows + TUIs sharing it
- Pulls `nvidia-open-dkms` + `linux-headers` + `libva-nvidia-driver` (auto-rebuilds on kernel updates), drops env vars into `~/.config/hypr/modules/nvidia.conf`, sets `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)` in `mkinitcpio.conf`, and appends `nvidia_drm.modeset=1 nvidia_drm.fbdev=1` to the kernel cmdline (systemd-boot only; GRUB/refind users get manual instructions)
- Lists **both** GPUs in `AQ_DRM_DEVICES` (dGPU first as primary render, iGPU second for eDP scanout) — Optimus eDP is hardwired to the iGPU at the hardware level, so dGPU-only would leave Hyprland with no outputs
- Resolves `/dev/dri/by-path/...` symlinks to `/dev/dri/cardN` before joining — the by-path names contain colons (PCI BDF) that shredded Aquamarine's `:`-split device list
- Refuses to touch `mkinitcpio.conf` if `/boot` has under 80 MB free — the nvidia-bearing initramfs is ~135 MB and a half-written `.img` on a full ESP bricks boot
- Idempotent. Backups of every system file edited go to `<file>.foxml-bak`. Recovery instructions print at the end. Battery cost flagged in docs (~5W idle vs ~1-2W on iGPU)
- `bootstrap.sh` auto-detects an NVIDIA dGPU by walking `/sys/bus/pci/devices` for vendor `0x10de` class `0x03*` and appends `--nvidia` for you — works on a freshly-imaged box before pciutils is installed

### Hyprland — Layer Blur, Peach-Glow Active Window, Lockscreen Widgets
- `layerrule` block (Hyprland 0.53+ syntax) blurs rofi/notifications/mako/dunst — launcher and toasts now sit on the desktop instead of pasted on top, matching window blur. Collapsed all four namespaces into one alternation regex
- Active-window shadow tinted to `PRIMARY` (peach) at 0.40 alpha, range 20→24. Inactive stays a neutral dark drop-shadow at 0.30 — focus gets a subtle warm halo without changing the border
- Hyprlock gains a `BAT %` widget (top-right) and a now-playing line (`♪ artist — title` via `playerctl`, exits silently when nothing's playing)
- Stripped `general.conf` of a dead `general{}` block silently overridden by `theme.conf` (it included a `layout=master` conflicting with theme's `dwindle`) and a duplicate `input{}` already owned by `input.conf`

### Hyprland — Window Rules
- Steam launcher/library/store/friends pinned to 85% opacity (exact-match regex on class `steam` so game windows stay opaque) — `[3963a20]` opens Steam to main library view rather than restoring last-active tab
- `engine_gui` (custom trading app) gets the same 85% treatment as `foxml_suite`

### Wallpaper — `awww` (swww fork) replaces hyprpaper
- hyprpaper 0.8.3 and Hyprland 0.54 disagreed on IPC protocol version, so every IPC call failed and rotation always fell back to a kill+restart with a fixed `0.3s sleep` (where the "sometimes wallpaper rotation just doesn't work" came from)
- `awww` talks raw `wlr-layer-shell` so it doesn't care about Hyprland's IPC version. Bonus: real fade transitions on rotation
- Autostart waits for the daemon socket and restores the last-picked wallpaper from `~/.wallpapers/.current`. Templates removed; deploy path simplified

### Waybar — Stats Bar, Power Profile, Updates, Idle Inhibitor
- New CPU/RAM/GPU/DISK modules with temps + totals. CPU resolves `coretemp` by hwmon name (not index, which drifts on reboot). GPU module is **Optimus-aware**: skips `nvidia-smi` while the dGPU is runtime-suspended so polling doesn't keep it awake on battery, and validates exit code + numeric output to handle the post-wake window where the driver is reachable but `nvidia-smi` still errors
- `pacman` updates count via `checkupdates` (hides at 0; click opens the list in kitty); 30-min poll
- `power-profiles-daemon` cycle on click (balanced → performance → power-saver). Pulls `power-profiles-daemon` + `pacman-contrib` into `--deps` and enables the service post-install
- Idle-inhibitor toggle for video / long reads
- Battery tooltip shows time remaining and current draw (W)

### SSH — Themed Askpass via Seahorse
- Pulls `seahorse` via `--deps` so the GTK askpass binary exists; auto-picks up the FoxML GTK theme instead of the bright-blue x11-ssh-askpass dialog
- Exports `SSH_ASKPASS` / `SSH_ASKPASS_REQUIRE=prefer` / `SSH_AUTH_SOCK` to all Hyprland-launched processes (and to interactive shells via `.zshrc` for ssh-into-the-box / TTY logins). Agent socket comes from `gnome-keyring-daemon` already started in `autostart.conf`

### Firefox — XDG Profile Path + Auto-Set Legacy Stylesheet Pref
- Firefox 150 on Arch switched to `~/.config/mozilla/firefox` (XDG-compliant) instead of `~/.mozilla/firefox`. The old profile resolver returned empty and theming silently skipped on fresh installs — now probes both, prefers XDG
- Writes `toolkit.legacyUserProfileCustomizations.stylesheets = true` into `user.js` so `userChrome.css` / `userContent.css` actually load. `user.js` overrides `prefs.js` on every launch, so this can't drift back

### Tooling — zoxide, fd, jq, git-delta, gh, themed delta diff
- `--deps` pulls `fd`, `zoxide`, `jq`, `git-delta`, `github-cli`. `.zshrc` initializes zoxide if installed
- New `templates/git/delta.gitconfig` with a themed `[delta]` block, deployed to `~/.config/git/delta-foxml.gitconfig` and pulled in via `include.path` from `~/.gitconfig` so the user's commit identity stays untouched
- `shared/bin/tmux-git-pane-label`: the missing helper that `.tmux.conf` has always called — pane border was silently empty in git directories. New install loop deploys `shared/bin/*` to `~/.local/bin`

---

### Icons — Papirus-Dark with Catppuccin Mocha Peach folders
- The GTK ini referenced `Papirus-Dark` but the theme files weren't installed, so Thunar (and other GTK apps) silently fell back to Adwaita's default blue folder icons — clashing with the warm peach UI chrome
- Added an install hook that runs the upstream Papirus `install.sh` with `DESTDIR=~/.local/share/icons` (no sudo), then clones `catppuccin/papirus-folders` shallowly to inject the Catppuccin folder SVGs into `Papirus/` (Papirus-Dark and Papirus-Light symlink to it for size dirs, so they inherit), then applies the `cat-mocha-peach` color via the `papirus-folders` helper. Sets `gsettings icon-theme` so GTK apps pick it up immediately
- Folder hue now matches the cursor and the peach `#d4985a` primary

### Cursor — Catppuccin Mocha Peach
- The Hyprland env and GTK settings already pointed at `catppuccin-mocha-peach-cursors` but the theme files were never installed, so everything was silently falling back to the default Adwaita cursor
- Added an install hook in `mappings.sh::install_specials` that fetches the v2.0.0 release zip from `github.com/catppuccin/cursors` into `~/.local/share/icons/` if it's not already present, then sets `cursor-theme`/`cursor-size` via `gsettings` so GTK/Adwaita apps pick it up too
- Catppuccin Mocha Peach (peach hue + dark base) lines up cleanly with the FoxML earthy palette's primary `#d4985a`

### Wallpapers — Curation Pass
- Removed `foxml_redwood_mist.jpg` and `foxml_path_sunbeams.jpg` — both had a person in a brightly-colored jacket in frame; humans break the moody-landscape feel of the FoxML earthy palette
- Removed `foxml_autumn_sunlit.jpg` — central sunburst was too white/washed-out for the muted earthy aesthetic
- Final rotation pool is 3 atmospheric foggy-forest wallpapers (`foxml_earthy`, `foxml_misty_dawn`, `foxml_sunrise_sunbeams`) — all warm-toned mist over dark forest, no sunbursts, no humans

### Wallpapers — Active Wallpaper Tracking
- `shared/hyprland_scripts/rotate_wallpaper.sh` now writes a `~/.wallpapers/.current` symlink each rotation, so anything pointing at it follows the active wallpaper instead of a fixed path
- Pointed `templates/hyprlock/hyprlock.conf` at `~/.wallpapers/.current`. Previously the lock screen always showed `foxml_earthy.jpg` regardless of what the desktop wallpaper had rotated to
- Rotation now drops the current wallpaper from the pool before picking, so consecutive rotations always change image (was hitting the same `RANDOM % N` slot too often with a 6-image pool)
- Added a `notify-send` toast on rotation showing the new wallpaper name

### Hyprland — Manual Rotation Keybind
- `ALT+W` → run `rotate_wallpaper.sh` immediately. Pairs well with the 4h timer for when you just want a different image right now

### Power — Battery-Aware Idle Timeouts
- Split `shared/hyprland_hypridle.conf` into `shared/hyprland_hypridle_ac.conf` (lock 5min, DPMS off 6min) and `shared/hyprland_hypridle_battery.conf` (lock 3min, DPMS off 4min). On battery the panel goes dark sooner, saving juice and tightening burn-in protection
- Added `shared/hyprland_scripts/power_state_watcher.sh`: polls `/sys/class/power_supply/A{C,DP}*/online` every 30s, and on AC↔battery transitions copies the right config into `~/.config/hypr/hypridle.conf` and restarts hypridle
- Added `shared/systemd_user/power-state-watcher.service` (Type=simple, Restart=on-failure, WantedBy=graphical-session.target). The new install hook for `shared/systemd_user/` enables it automatically
- Removed `exec-once = hypridle` from `shared/hyprland_modules/autostart.conf`. The watcher now owns hypridle's lifecycle — running both would race on startup
- Updated `SHARED_MAPPINGS` to deploy the new AC/battery configs to `~/.config/hypr/hypridle-{ac,battery}.conf`

### Installer — Bat Theme Activation
- Added a hook in `mappings.sh::install_specials` that writes `--theme="Fox ML"` to `~/.config/bat/config`. Idempotent — updates the existing line if present, appends if not. `bat` was already getting the FoxML `tmTheme` deployed but had no config telling it to use it, so it was sitting on the default theme

### Cleanup — Stale Backups
- Deleted `themes/FoxML_Classic/palette.sh.bak` and `palette.sh.bak2` — leftovers from earlier palette edits, no longer referenced

### OLED — Burn-In Mitigations
- Tightened `shared/hyprland_hypridle.conf` DPMS-off listener from `600` → `360` seconds, so the lock screen sits visible for at most ~1 minute before the panel goes dark (was 5 minutes of static lockscreen)
- Dimmed `templates/hyprlock/hyprlock.conf` background: `brightness 0.75 → 0.10`, `vibrancy 0.25 → 0.10`, `contrast 1.15 → 1.05`, and bumped `blur_size 8 → 12` / `blur_passes 3 → 4`. The lock screen still shows the wallpaper but at near-black luminance during its short window before DPMS off
- Added `ALT+B` waybar toggle (`killall -SIGUSR1 waybar`) in `shared/hyprland_modules/keybinds.conf` so the always-on top bar — the largest static-pixel surface on a tiling-WM setup — can be hidden on demand

### Wallpapers — Rotation
- Added `shared/hyprland_scripts/rotate_wallpaper.sh`: random pick from `~/.wallpapers/`, excluding dotfiles and `cave_data_center*` (other-theme image). Tries hyprpaper IPC first, falls back to a kill-and-relaunch when IPC returns "invalid hyprpaper request" on older versions
- Added `shared/systemd_user/wallpaper-rotate.{service,timer}` — fires 10 min after boot, then every 4 hours
- Extended `mappings.sh::install_specials` to copy any `shared/systemd_user/*.{service,timer}` units into `~/.config/systemd/user/`, run `daemon-reload`, and `enable --now` every `.timer`. Generic, so future user units drop in without editing the installer

### Wallpapers — Curated Earthy 4K Set
- Replaced `shared/wallpapers/foxml_earthy.jpg` with a 4K upscale (`1920x1280` → `3840x2560`) produced by `waifu2x-ncnn-vulkan` with the `models-upconv_7_photo` model. Native-res on a 4K eDP-1 panel; previous version was being bilinearly stretched by 2× at display time
- Added 5 palette-matched 4K wallpapers from Unsplash: `foxml_misty_dawn`, `foxml_autumn_sunlit`, `foxml_redwood_mist`, `foxml_path_sunbeams`, `foxml_sunrise_sunbeams` — all warm-fog / golden-hour / autumn forest tones that match the FoxML earthy palette (peach `#d4985a`, sage `#8a9a7a`, dark `#1a1214`)
- Removed `foxml.png`, `foxml-alt.jpg`, `foxml-alt-original.jpg`, `new2.jpg`, `new_tmp.png`. The first two were the OG vaporwave/Firewatch-purple FoxML wallpapers — they fit the original purple palette but clash with the current earthy one. The other three were duplicates (matching md5 of `foxml-alt.jpg`) or staging temp files

### Installer — btop Theme Activation
- Added a sed hook in `mappings.sh::install_specials` that flips `color_theme` in `~/.config/btop/btop.conf` to `"foxml"`. Idempotent (skips if already set). Previously `install.sh` deployed `templates/btop/foxml.theme` to `~/.config/btop/themes/` but never told btop to use it, so the theme file sat unused until manually selected. `btop.conf` itself stays user-owned (not templated) since btop rewrites it on every config change

---

## 2026-04-24

### Installer — CJK + Emoji Font Fallback
- Added `noto-fonts`, `noto-fonts-cjk`, `noto-fonts-emoji` to `PACMAN_PKGS` so the welcome-banner cat (じ し ノ kana) and other Unicode glyphs that Hack Nerd Font doesn't cover fall back to Noto instead of rendering as tofu boxes

### Installer — One-Command Bootstrap
- Added `bootstrap.sh` for `curl | bash` install on a fresh Arch+Hyprland laptop. Caches sudo upfront, installs `git`/`curl` if missing, clones the repo to `~/FoxML_Workstation` (or `git pull`s if already there), then runs `install.sh THEME --deps --yes`
- Added `-y` / `--yes` flag to `install.sh`. In yes-mode every `read -p` prompt is skipped, `pacman -S` runs with `--noconfirm`, oh-my-zsh installs unattended, and the theme defaults to `FoxML_Classic` if no name is given
- `--yes` primes the sudo cache via `sudo -v` and keeps it alive in a background loop so dep install runs unattended end-to-end
- Updated README Quick Start to lead with the one-liner; manual `git clone && ./install.sh` flow is documented as the read-before-running alternative

### Hyprland — Frictionless First-Boot
- Added `shared/hyprland.conf` — the missing main config that sources every module under `~/.config/hypr/modules/` (skipping `main_mod.conf` and `hyprlock.conf`). Without this, fresh installs left Hyprland on its default example config and none of the FoxML modules ever loaded
- Mapped `hyprland.conf` and the four `launchers/toggle/*.sh` scripts in `SHARED_MAPPINGS` so they actually install
- Made `monitors.conf` portable: `monitor = , preferred, auto, 1` with per-machine overrides commented out, instead of hardcoding a Surface Pro `2736x1824@60` that broke on every other panel

### Hyprland — Hyprland 0.54+ Syntax Migration
- Converted `scratchpads.conf` and `workspace_layout.conf` to the new `windowrule { match:class = ...; float = yes; ... }` block syntax. The old `windowrule = float, class:^(yazi)$` form errors out on 0.54+
- Removed deprecated `general:no_border_on_floating` from `general.conf`
- Replaced `noborder` (no longer a valid field) with `border_size = 0` inside the yazi rule
- Cleaned `workspace_layout.conf`: dropped duplicate `kitty --title Terminal1` exec-once (already in autostart) and the wrong `monitor:DP-1` workspace binding

### Hyprland — Removed Conflicting/Orphan Files
- Deleted `main_mod.conf` (a near-duplicate of `keybinds.conf` that registered every binding twice — `ALT+ENTER` was launching two terminals)
- Deleted orphan `hyprland_modules/hyprlock.conf` (hyprlock-syntax sitting in the Hyprland modules dir; the real hyprlock config is rendered from `templates/hyprlock/hyprlock.conf`)
- Commented out `pulseaudio --start` in `autostart.conf` — modern Arch defaults to pipewire via systemd-user

### Scripts — Region Screenshot
- Added `shared/hyprland_scripts/screenshot.sh` (grim + slurp + wl-copy + notify-send), saving to `~/Pictures/Screenshots`
- Updated `keybinds.conf` so `ALT+SHIFT+O` points at the new script instead of the never-shipped `~/screenshot/screenshot.sh`

### Installer — Dependencies & Plugin Install
- Expanded `PACMAN_PKGS` with everything the configs actually reference: `ttf-hack-nerd` (default font), `mako`, `hypridle`, `grim`, `slurp`, `wl-clipboard`, `playerctl`, `brightnessctl`, `pavucontrol`
- Moved zsh plugin clones (`zsh-syntax-highlighting`, `zsh-autosuggestions`, `zsh-completions`) out of the `--deps` block — they now install whenever oh-my-zsh is present, so a fresh install never opens to "[oh-my-zsh] plugin not found"
- Filtered the wallpaper copy loop to image extensions (`*.{jpg,jpeg,png,webp}`) so `README.md` stops landing in `~/.wallpapers/`

### Waybar — Strip Broken Modules
- Removed `custom/system_health`, `custom/media`, `custom/weather` modules whose backing scripts were never shipped (they spammed `No such file or directory` in waybar's stderr)
- Dropped hardcoded `"bat": "BAT1"` so the battery module auto-detects (`BAT0` / `BAT1` / etc.)

### Cleanup
- Deleted empty `shared/hyprland_scripts/set-theme.sh` (just a `#!/bin/bash` shebang)
- Deleted empty `shared/hyprpaper.conf` stub (the real config is rendered from `templates/hyprpaper/hyprpaper.conf`)

---

## 2026-04-12

### Shell — Git Workflow Functions
- Added `shared/zsh_git.zsh` with git workflow shortcuts that complement the Oh My Zsh `git` plugin
- `gpush` — push current branch, auto-sets upstream on first push
- `gnew` — create + switch to new branch (prompts for name if omitted)
- `gsave` / `gquick` — stage all + commit in one shot / WIP checkpoint with timestamp
- `gundo` / `gamend` — undo last commit (soft reset) / amend last commit with new changes
- `gbr` / `grecent` — fzf branch switcher / list recent branches with relative dates
- `gsync` / `gclean` — rebase on latest main / delete merged branches
- `gstash` / `gpop` — named stash / fzf stash picker
- `gtoday` / `gds` — today's commits / diff staged changes
- Added mapping in `mappings.sh` and source line in `.zshrc` template
- Removed stale `prompt.zsh`, `gradient.zsh`, `async.zsh` references from README (files were deleted in 2026-03-16)

---

## 2026-03-28

### Theme — New Cave Data Center Theme
- Added second theme: Cave Data Center — dark navy palette with blue (`#2ea3f2`) and gold (`#ffb200`) accents, inspired by HRT's website colors
- Themes can be hotswapped with `./swap.sh`, switching nvim, kitty, hyprland, waybar, tmux, zsh, wallpaper, and all other configs in one command

### Theme — Templatize Nvim & Wallpaper
- Nvim `init.lua` palette table now renders from `palette.sh` instead of hardcoded hex values — all themes share one template
- Added `NVIM_BG_HL`, `NVIM_SEL`, `WARM`, `SAND`, `WHEAT`, `CLAY` palette variables for nvim-specific colors
- Moved `hyprpaper.conf` from shared to templates with `{{WALLPAPER}}` variable so wallpaper swaps per-theme
- Added `SHOW_BANNER` toggle to show/hide the FOXML block text in the zsh welcome (cat stays)
- Added `SHOW_WELCOME` toggle to disable the entire welcome splash per-theme
- Added 4K dark blue textured wallpaper for Cave Data Center

### Theme — Render Engine
- Added `WARM`, `SAND`, `WHEAT`, `CLAY`, `NVIM_BG_HL`, `NVIM_SEL` to `render.sh` hex variable lists (forward and reverse)
- Added `SHOW_WELCOME`, `SHOW_BANNER`, `WALLPAPER` to `render.sh` string variable lists

---

## 2026-03-20

### Shell — New `trade` Alias
- Added `trade` alias that disables screensaver/DPMS before running `./engine`, then re-enables it after

---

## 2026-03-19

### Bat — Expanded tmTheme for Richer Syntax Highlighting
- Expanded bat theme from ~15 to ~40 TextMate scope rules to match Neovim's highlighting
- Added distinct colors for: string escapes/regex/interpolation (cyan), preprocessor directives (cyan), define/macro keywords (pink), booleans (bold peach), return keyword (bold lavender), import keywords (cyan), operators (lavender), variable parameters (yellow_br), variable builtins/self/this (pink), namespaces/modules (pink), brackets (sand), punctuation separators/delimiters (peach), constructors, function macros, type qualifiers, inherited classes, decorators/annotations
- Added language-specific scopes: JSON/YAML/TOML keys (green), CSS properties/selectors/values/units, shell variables
- Added markup scopes: bold, italic, strikethrough, code/raw blocks (green), list markers (pink), diff changed (yellow), deprecated (italic yellow)
- Updated template, rendered Classic, and installed theme; rebuilt bat cache

---

## 2026-03-19

### Nvim — Fix indent-blankline Startup Error & Deprecation Cleanup
- Fixed indent-blankline crash on startup — `RainbowIndent` highlight groups are now defined before `ibl.setup()` runs (previously only existed in `apply_foxml_theme()` which runs later)
- Replaced deprecated `lsp_fallback = true` with `lsp_format = "fallback"` in conform.nvim config
- Replaced deprecated `vim.diagnostic.goto_prev`/`goto_next` with `vim.diagnostic.jump()` (Neovim 0.11+)
- Removed duplicate `signcolumn` setting (was set twice, consolidated to `"yes:2"`)

---

## 2026-03-17

### Font — Templated FONT_FAMILY + Switch to Hack Nerd Font
- Added `FONT_FAMILY` variable to `palette.sh` — font is now configurable per-theme
- Added `FONT_FAMILY` to render engine (`render.sh`) for forward and reverse rendering
- Replaced hardcoded `JetBrainsMono Nerd Font` with `{{FONT_FAMILY}}` in all templates: kitty, waybar, rofi, dunst, mako, regreet CSS, spicetify, zathura, hyprlock
- Updated shared configs (GTK 3/4 settings, regreet.toml, hyprland general/hyprlock) to Hack Nerd Font
- Default font changed from JetBrainsMono Nerd Font → Hack Nerd Font (blockier, sturdier)
- Documented font customization in README

---

## 2026-03-16

### Nvim — Dashboard Fox Art
- Replaced plain ASCII `FoxML` logo with the fox character from zsh welcome splash in snacks dashboard

### ReGreet — FoxML Login Screen
- Added ReGreet (GTK4 greetd greeter) template with full FoxML theming
- CSS theme: dark background with wallpaper, peach borders/accents, sharp corners, frosted login box
- Config: wallpaper background, dark theme, peach cursor, Papirus-Dark icons, JetBrains Mono font
- Added template and shared mappings for install/sync support
- To switch from tuigreet: `sudo pacman -S greetd-regreet` then update `/etc/greetd/config.toml`

### Nvim — Gitsigns Blame, Beacon, Notifications Cleanup
- Added inline git blame on current line (author, relative time, summary) via gitsigns `current_line_blame`
- Added beacon.nvim — cursor flashes peach on large jumps for visual tracking
- Replaced nvim-notify with snacks.nvim minimal notifier (single-line, bottom-right, less screen clutter)
- Removed nvim-notify plugin dependency from noice
- Synced cursor blink: removed `guicursor` blink to match kitty's `cursor_blink_interval 0`
- Added `BeaconDefault` and `GitSignsCurrentLineBlame` highlight groups to FoxML colorscheme

### Tmux — Pane Border Shows Running Command
- Pane border format now includes `#{pane_current_command}` (shows `nvim`, `python`, `zsh`, etc.)

### Cursor — Peach Theme + Size Fix
- Hyprland cursor theme: `catppuccin-latte-pink-cursors` → `catppuccin-mocha-peach-cursors`
- Kitty terminal cursor color: `SECONDARY` (dusty rose) → `PRIMARY` (peach)
- GTK 3/4: added `gtk-cursor-theme-name=catppuccin-mocha-peach-cursors` and `gtk-cursor-theme-size=30`
- Fixed cursor size mismatch (GTK apps were 30, Hyprland was defaulting smaller) — set `XCURSOR_SIZE=30` in `env-init.sh` for early session export
- Added Hyprland `cursor {}` section to `general.conf`

### Zsh — Hardening, Cleanup & Dead Code Removal
- Removed `async.zsh` (never sourced, callback never registered, output unused)
- Removed `gradient.zsh` (`gradient_text()` defined but never called anywhere)
- Removed `prompt.zsh` (bash-style PS1 fallback that doesn't work in zsh — caramel handles everything)
- Removed `welcome.zsh.bak` (identical to `welcome.zsh`)
- Removed duplicate `list-colors` zstyle from `colors.zsh` (already set in `.zshrc`)
- Cleaned up `mappings.sh` to remove references to deleted files
- Template dir reduced from 8 files to 3 focused ones: caramel theme, colors, welcome

### Zsh — Shell Options & History
- Added `NO_CLOBBER` (prevents accidental file overwrites with `>`, use `>|` to force)
- Added `HIST_IGNORE_DUPS`, `HIST_IGNORE_SPACE`, `EXTENDED_HISTORY`, `SHARE_HISTORY`, `HIST_REDUCE_BLANKS`
- Added explicit `HISTFILE`, `HISTSIZE=50000`, `SAVEHIST=50000`
- Added `typeset -U path PATH` to deduplicate PATH in nested shells/tmux

### Zsh — fzf & Completions
- Added `zsh-completions` plugin (extended completions for docker, systemctl, etc.)
- Added `zsh-completions` to `--deps` installer in `install.sh`
- fzf now uses `fd` as default command (faster, respects `.gitignore`)
- Added hidden preview panel to fzf (`ctrl-/` to toggle — bat for files, eza for dirs)

### Zsh — Robustness
- Tmux auto-attach now skips IDE terminals (VS Code, IntelliJ) to prevent hijacking embedded terminals
- `todo()` now checks for duplicates before adding
- Welcome splash now shows active theme name next to the fox (e.g. `▸ FoxML Classic`)

### Caramel Theme — Configurable Timer
- Elapsed time threshold is now configurable via `CARAMEL_CMD_THRESHOLD` (defaults to 3s)

---

## 2026-03-14

### Firefox — Earthy Theme Overhaul
- Rewrote `userContent.css` for Firefox 140+ (new CSS variable names, modern card selectors)
- Forced `border-radius: 0` globally on new tab page — kills rounded cards/buttons
- Swapped plum `BG_ALT` (#2d1a2d) for warm dark brown (#2a2018) in both `userChrome.css` and `userContent.css`
- Added theming for `about:preferences` and `about:addons` pages
- Added follow/topic button, weather widget, and link color overrides

### Thunar — Transparency & Earthy Styling
- Added GTK CSS transparency for Thunar (`rgba` bg at 85% opacity, no compositor opacity — avoids rubberband trail artifacts)
- Filenames use peach (`PRIMARY`) for readability on transparent background
- Sidebar labels use `FG_PASTEL`, selected sidebar items use peach
- Icon view cells: removed bordered boxes, selection highlight uses warm clay (`rgba(176,96,58,0.35)`)
- Rubberband (drag selection) uses wheat fill (`rgba(212,180,131,0.20)`) with wheat border

### Hyprland — Window Rule Syntax Fix
- Migrated Thunar opacity rule to Hyprland 0.54 `match:class` syntax (old `class:` field caused parse errors)
- Removed compositor opacity rule for Thunar (caused rubberband rendering artifacts on some GPUs)

### Nvim — External Edit QOL (Claude Code / git)
- Added `autoread`, `undofile`, `swapfile=false`, `writebackup=false`, `autowriteall` options
- Added `checktime` autocmds on `FocusGained`, `BufEnter`, `CursorHold`, `CursorHoldI` — buffers now auto-reload when changed on disk (e.g. by Claude Code or `git checkout`)
- Added `FileChangedShellPost` notification so reloads aren't silent
- Disabled swap files (git is the safety net) and enabled persistent undo across sessions

---

## 2026-03-13

### Neovim — Struct Field Color Variation & LSP Token Fix
- Added color variation for struct member access chains (e.g. `pool->slots[index].price.price`)
- Fields/properties (`@variable.member`, `@property`) now use `green` (#6b9a7a) instead of blending with foreground
- Punctuation delimiters (`.`, `;`) now use `peach` (#c4956e) for visible structure
- Brackets (`[]`, `()`) now use `sand` (#a89a7a) for subtle differentiation
- Added `@lsp.typemod.variable.member` highlight (+ `.c`/`.cpp` variants) — fixes clangd semantic tokens overriding treesitter colors after ~2s
- LSP property/member groups now `link` to treesitter groups so only one color change is needed
- Added `sand` (#a89a7a) to palette

### Cohesive Earthy Theme — Full System Sync
- Removed all remaining neon pink/pastel references from shared configs, READMEs, and comments
- Fixed Hyprland `general.conf` — hardcoded neon pink borders updated to earthy peach/wheat gradient
- Fixed Hyprland `theme.conf` — updated color palette comment block and active border to earthy tones
- Migrated all `windowrulev2` → `windowrule` across scratchpads, workspace_layout, and rules configs (deprecated in Hyprland 0.54+)
- GTK-4 settings: switched from `Catppuccin-Mocha-Pink-Standard` to `Adwaita` dark (lets custom `gtk.css` apply)
- Icon theme: switched from `Papirus-Dark-Pink` to `Papirus-Dark` with palebrown folder color
- Firefox: enabled `toolkit.legacyUserProfileCustomizations.stylesheets` on active profile, deployed earthy `userChrome.css` and `userContent.css`
- Updated FoxML Classic theme README with current earthy palette values
- Cleaned up firefox template comments (pastel pink → tinted)

### Palette Overhaul — Neon → Earthy
- Reworked entire FoxML Classic palette from neon pastels to muted earthy tones
- Primary: `#f4b58a` → `#c4956e` (peach), Secondary: `#f5a9b8` → `#b8967a` (warm pink → dusty rose), Accent: `#9a8ac4` → `#8a9a7a` (lavender → sage)
- FG: `#f5f5f7` → `#d5c4b0` (cold white → warm cream), all ANSI colors shifted to lower-saturation earthy variants
- ANSI 256-color codes updated for zsh prompts/gradients (pink rainbow → clay/wheat/sage gradient)
- FZF, ZSH command highlight, OK/WARN semantic colors all updated to match
- Kitty opacity raised from 0.45 → 0.6 for readability with new palette

### Tmux — Pane Visibility Rework
- Active border now uses PRIMARY peach (`#c4956e`) with bold (thicker border)
- Removed solid background on active pane — all panes fully transparent (`bg=default`)
- Dimmed inactive pane text from `#555555` → `#3a3a3a` for stronger active/inactive contrast
- Hyprland active window border updated: peach → wheat gradient

### Nvim — Transparency & Separator Fixes
- Fixed `colorful-winsep.nvim` config: plugin API changed from `hi = { fg = ... }` table to `highlight = "..."` string — was silently falling back to default lavender `#957CC6`
- Active window separator now renders earthy wheat (`#b8a87e`)
- Visual selection background warmed from `#2d1f27` → `#3d2a1e` (muted plum → warm brown)
- `NormalNC` (inactive windows) set to transparent instead of solid bg
- `StatusLine`/`StatusLineNC` backgrounds set to transparent
- `VertSplit`/`WinSeparator` changed from solid `bg_deep` to wheat fg on transparent bg
- Variables (`@variable`) changed from lavender to default fg for cleaner code readability

### Zsh — Simplified Welcome Splash
- Condensed welcome screen: removed system info block (kernel, shell, WM, terminal, battery)
- Cleaner date/time format, compact FoxML ASCII banner
- Updated color comments to match earthy palette names

### Misc
- Wallpaper changed to `foxml_earthy.jpg`
- Removed packages line from fastfetch config
- Updated README screenshots (terminal, nvim, nvim+avante) — removed outdated desktop screenshot
- Updated README to remove old desktop screenshot reference

### Neovim - Syntax Color Refinement & Window Fixes
- Improved syntax color differentiation: types (peach italic), functions (peach), variables (lavender), parameters (cyan), members (soft pink), operators (pink), keywords (pink bold)
- Updated LSP semantic token highlights to match treesitter palette — fixes colors shifting 1-2 seconds after file open when clangd attaches
- Added `ColorScheme` autocmd to re-apply FoxML theme after plugin/treesitter loads
- Fixed which-key popup transparency — added `WhichKeyNormal` highlight group with solid `bg_deep` background
- Set inactive window background to solid `bg` — provides visual distinction from active (transparent) window
- Removed `tint.nvim` plugin (inactive window dimming)
- Updated README screenshots (nvim 3-pane layout + avante sidebar)

### Neovim - Custom FoxML Colorscheme (Tokyo Night removed)
- Replaced `folke/tokyonight.nvim` dependency with a fully self-contained FoxML colorscheme — all highlights now live in `apply_foxml_theme()` inside init.lua
- Added `local P = { ... }` palette table (32 colors) as single source of truth — all hex values reference `P.xxx` instead of repeating strings
- Added built-in Vim syntax groups (~35): Comment, String, Function, Keyword, Type, Statement, PreProc, Special, etc.
- Added full diagnostics coverage (~18): Error/Warn/Info/Hint with undercurl underlines, virtual text, and sign variants
- Added Treesitter highlight groups (~55): all @function, @keyword, @string, @constant, @markup, @tag families
- Added LSP semantic token groups (~21): @lsp.type.class, @lsp.type.function, @lsp.mod.deprecated, etc.
- Added Diff & Spell groups (8): DiffAdd/Change/Delete/Text, SpellBad/Cap/Rare/Local with undercurl
- Added terminal ANSI colors (16): vim.g.terminal_color_0 through _15 mapped to FoxML palette
- Registered as proper colorscheme via `vim.g.colors_name = "foxml"`
- Converted all plugin opts (bufferline, notify, scrollbar, colorful-winsep, lualine) from hardcoded hex to `P.xxx` references
- Removed tokyonight from lazy-lock.json
- Changed default fg from cold white `#f5f5f7` to warm coffee cream `#d5c4b0`
- Fixed sidebar transparency — neo-tree, Avante, Trouble, and aerial panels now get solid `bg_deep` backgrounds via `NormalSidebar` + FileType autocmd (prevents terminal opacity bleeding through)
- Removed transparent gap between splits — WinSeparator and VertSplit use solid `bg_deep` on both fg/bg, fillchars vert changed to space
- Removed global `winblend = 15` (was making all floats semi-transparent); kept `pumblend = 15` for popup menu only
- Improved Avante edit (`<leader>ae`) UX — removed Visual blend for solid selection highlight, brighter prompt input background, bolder inline hints

### Neovim - Avante & Copilot QoL
- Set `auto_add_current_file = false` — visual selections now send only the selected code to Copilot, not the entire file
- Added `<leader>ae` — edit selection in-place with Avante (visual mode)
- Added `<leader>ar` — refresh Avante response
- Added `<leader>aS` — stop Avante generation
- Enabled `auto_apply_diff_after_generation` — diffs apply automatically after Avante responds
- Show model name in Avante sidebar header
- Bumped Avante history token limit to 8192 for longer conversations
- Added 150ms debounce to Copilot suggestions to reduce keystroke lag
- Disabled Copilot ghost text in Avante input/sidebar buffers
- Added Copilot status indicator in lualine (green = ready, yellow = thinking, red = error)
- Fixed `vim.tbl_filter` deprecation warnings → `vim.iter():filter():totable()` (nvim 0.11+)
- Suppressed `vim.lsp.buf_get_clients` deprecation from project.nvim/telescope (upstream issue)
- Full FoxML theme for all Avante highlights — sidebar, titles, buttons, spinners, conflict markers, task status, thinking indicator
- Themed missing core UI groups: PmenuSbar/Thumb, CurSearch, Folded, TabLine, StatusLine, WildMenu, Title, Directory, Question, SpecialKey, NonText, Conceal
- Themed noice message split window and :messages highlights (MsgArea, WarningMsg, ErrorMsg, ModeMsg, MoreMsg)

---

## 2026-03-12

### Neovim - Visual Polish (Round 2)
- Added **noice.nvim** — floating cmdline popup, search popup, and message routing (replaces bottom cmdline)
- Added **nvim-notify** — animated notification popups with FoxML-themed borders
- Added **nvim-colorizer** — renders hex colors inline with their actual color
- Added **rainbow-delimiters.nvim** — colors nested brackets/parens in rotating FoxML palette (peach → pink → mint → yellow → cyan → red)
- Added **colorful-winsep.nvim** — highlights active window border in peach when using splits
- Added **nvim-scrollbar** + **nvim-hlslens** — scrollbar showing diagnostics, git changes, and search hits; search match counter overlay
- Added **tint.nvim** — subtly dims inactive splits so focused window stands out
- Full FoxML palette highlights for all new plugins (noice, notify, rainbow delimiters, scrollbar, hlslens)
- Disabled colorizer for C/C++/H files — hex constants like `0xFFFFFFFF` no longer get painted as literal colors
- Made number/hex literals bold warm yellow for better glow against dark background
- Backed up pre-polish config as `init.lua.bak`

### Neovim - Visual Polish
- Custom FoxML lualine theme — peach normal, mint insert, pink visual, red replace, yellow command
- Replaced encoding/fileformat statusline clutter with active LSP server name
- Enabled native smooth scrolling (`smoothscroll`)
- Enabled cursorline highlight and guicursor (block/beam/blink)
- Added warm-tinted window separator using `bg_highlight`
- Fixed deprecated `vim.loop` → `vim.uv` calls

### Removed FoxML Paper Theme
- Removed WIP light theme (FoxML Paper) — keeping only FoxML Classic
- Cleaned up README references to Paper

### Neovim - Window & Buffer Keybind Fixes
- `Space q` is now smart — won't leave neo-tree filling the whole screen when closing the last file window
- `Space bd` no longer silently fails on empty/unnamed buffers
- Added `Space o` to unsplit (close all other windows, keep current)

### Multi-Theme Hub Restructure
- Converted from single-theme repo to **multi-theme hub** with template-based rendering
- All 23+ app configs are now **templates** with `{{COLOR}}` placeholders — one set of configs, any number of themes
- Each theme is just a `palette.sh` file defining ~60 color variables; adding a new theme = writing one file
- New render engine (`render.sh`) handles hex, RGB decomposition, ANSI codes, and metadata substitution
- New `mappings.sh` with source→destination mappings and special handlers (Firefox, Cursor, Spicetify, Bat, Hyprland)
- New `swap.sh` — theme swapper with 24-bit truecolor color swatches in terminal
- Shared (non-color) files split into `shared/` directory
- Updated install.sh and update.sh to work with the template system
- Reverse rendering: `update.sh` pulls system configs back into templates by replacing colors with placeholders

### Docs
- Friendly note added to README for fellow CS students

### Neovim - Plugin Cleanup
- Removed `oil.nvim` — neo-tree covers all file management needs
- Remapped `-` to reveal current file in neo-tree sidebar
- Removed Oil highlight groups and keybinds

### Docs
- Added `CHANGELOG.md` with full project history
- Added `/changelog` skill for auto-updating changelog
- Expanded neo-tree keybinds in `KEYBINDS.md` (navigation, file ops, opening, help)
- Added nvim screenshot to README

### Neovim - RAM Reduction & IDE Features
- Dropped `noice.nvim`, `neoscroll.nvim`, `neotest-ctest`, standalone `dressing.nvim`
- Disabled snacks.nvim notifier
- Lazy-loaded 15+ plugins (copilot, vimtex, neotest, diffview, undotree, trouble, spectre, aerial, dap, cmake-tools, overseer, toggleterm, project.nvim)
- Added **neo-tree.nvim** — file tree sidebar (`Space e`)
- Added **bufferline.nvim** — buffer tabs at top (`Shift+H/L` to cycle, `Space bd` to close)
- Added window management keybinds (`Space v/s` for splits, `Ctrl+Arrow` to resize)
- Moved neotest setup into lazy config function
- Removed all `Noice*` highlight groups, added `NeoTree*` highlights in Fox ML palette
- Silenced project.nvim CWD notifications

### Neovim - QoL Improvements
- `Ctrl+h/j/k/l` to navigate splits directly
- `Alt+j/k` in visual mode to move lines up/down
- `Ctrl+d/u` and `n/N` keep cursor centered
- `Esc` clears search highlights and exits terminal mode
- Visual mode `<`/`>` indent without losing selection
- `Space q` to close window
- Auto yank highlight (200ms flash)
- Auto cursor position restore on file reopen
- Auto trailing whitespace strip on save
- Smarter `Space bd` — prevents neo-tree from expanding when closing last buffer

### Docs
- Added nvim screenshot to README
- Updated KEYBINDS.md with neo-tree, bufferline, split, and QoL keybinds
- Removed neoscroll references from KEYBINDS.md
- Updated README nvim section (removed noice, added neo-tree/bufferline)

---

## 2026-03-11

### Neovim - AI & Plugin Expansion
- Added copilot.lua (inline ghost-text completions, `Ctrl+l` to accept)
- Added avante.nvim (Cursor-style AI chat panel with Copilot provider)
- Added noice.nvim, snacks.nvim (dashboard), dropbar.nvim (breadcrumbs)
- Added mini.ai, flash.nvim, nvim-surround, harpoon, undotree
- Added diffview.nvim, nvim-spectre, lazygit.nvim, persistence.nvim
- Added friendly-snippets, zen-mode.nvim, clangd_extensions.nvim
- Added neotest + gtest/ctest adapters, cmake-tools, overseer, toggleterm
- Added DAP debugging with CodeLLDB via mason-nvim-dap
- Added treesitter textobjects and context
- Fixed copilot keybinds: Alt to Ctrl (Alt conflicts with Hyprland mainMod)
- Fixed Ctrl+[ breaking Escape, switched to Ctrl+k/j for copilot prev/dismiss

### Theme Polish
- Fixed background color mismatches and typos across theme configs
- Added zathura and bat themes
- Enhanced hyprland animations
- Full Fox ML palette applied to all 60+ nvim plugins

### Hyprland
- Reduced blur intensity (size 2, 1 pass)
- Synced repo with live system configs

### Wallpaper
- Warm-shifted wallpaper to match palette
- Adjusted kitty opacity for readability
- Reverted wallpaper to original after testing

---

## 2026-03-06

### Hyprland & System
- Added hyprland, waybar, mako, fastfetch, launcher configs
- Added KEYBINDS.md with full hyprland and tmux reference
- Cleaned up launcher scripts

---

## 2026-02-22

### Shell
- Added full zsh config (caramel theme, aliases, colors, welcome screen)
- Added screenshots to repo and README
- Added pacman deps and zsh install to installer
- Added zsh config backup to update script

---

## 2026-02-18

### Initial Release
- First commit with Fox ML theme files
- Kitty, tmux, nvim, GTK, rofi, spicetify, vencord, firefox configs
- Install script and wallpapers
