# FoxML Workstation

A high-discipline, AI-powered development platform for senior engineers. 24+ apps themed, sharp corners, and a complete OS-level bootstrap engine with a built-in Semantic Intelligence Layer.

## Fox Intelligence Layer (RAG)

The workstation features a native, C++ powered semantic intelligence layer that gives your environment a "memory" of your codebase.

| Command | Role |
|---------|------|
| `fask` | **Semantic Assistant**: Ask questions about the project (RAG). |
| `findex` | **Project Indexer**: Generate semantic embeddings for your code. |
| `fcommit` | **Semantic Commit**: AI-analyzed high-discipline commits. |
| `fstatus` | **System Health**: Monitor AI stack, VRAM, and project drift. |
| `fproject` | **Bootstrap**: Create a new project with AGENT/INVARIANTS. |
| `fhelp` | **Interactive Docs**: Deep-dive help for the entire suite. |

> Run `fhelp` for the full command reference and usage examples.

### Project Awareness
The environment is project-aware. Whenever you `cd` into a directory containing an `AGENT.md`, the shell automatically exports project context, scoping your AI tools (`fask`, `findex`, etc.) to that specific workspace instantly.

New to Linux? This runs on [Arch Linux](https://archlinux.org/) with the [Hyprland](https://hyprland.org/) Wayland compositor. If you're coming from Windows or macOS, [archinstall](https://wiki.archlinux.org/title/Archinstall) makes getting started much easier than the manual install process.

## Theme

### [FoxML Classic](themes/FoxML_Classic/) (dark)
Dark theme with earthy, muted tones — warm peach, dusty rose, sage, and wheat on a deep plum background.

| Role | Color | |
|------|-------|-|
| Background | `#1a1214` | Warm dark |
| Foreground | `#d5c4b0` | Warm cream |
| Primary | `#c4956e` | Peach |
| Secondary | `#b8967a` | Dusty rose |
| Accent | `#8a9a7a` | Sage |
| Surface | `#3a414b` | Slate |

## Screenshots

![Terminal](shared/screenshots/terminal.png?v=2)

![Neovim](shared/screenshots/nvim.png?v=2)

![Neovim + Avante](shared/screenshots/nvim_avante.png?v=2)

## Prerequisites

- **Arch Linux** (the installer uses `pacman` for dependencies)
- **Hyprland** (Wayland compositor)
- **greetd + regreet** (login screen — optional but included)
- `bash`, `git`, `sed`
- Apps you want themed should already be installed, or use `--deps` to install them

### Agent Mandates
- **AGENT.md** — Architectural mandates and refactor notes for the AI Agent.
- **.agent/commands/** — Project-specific AI skills and protocols.

### OpenCode — Local AI Coding Agent

The `--ai` flag installs and configures [OpenCode](https://opencode.ai/) as a fully local Claude-Code-style TUI backed by Ollama. The installer wires it up end-to-end:

- **FoxML theme** — palette-driven custom theme (`templates/opencode/foxml.json`) rendered through the same `{{TOKEN}}` system as every other config. Swap the active palette via `swap.sh` and the OpenCode theme re-renders to match.
- **Multi-model picker** — provider config is generated from `ollama list`, so every model you've pulled (1.5B/3B/7B/14B/32B/70B per tier) appears in the in-app picker.
- **Skill discovery** — `skills.paths` is populated by globbing `~/code/*/claude-skills/`; any workspace with `SKILL.md` files (Linux_Theme + private repos) gets wired in automatically.
- **Auto-wake** — `opencode` is shell-wrapped to start the Ollama daemon on demand if it isn't running.

### Key Dependencies

| Package | Purpose |
|---------|---------|
| `hyprland` | Wayland compositor |
| `greetd`, `greetd-regreet` | Login manager + graphical greeter |
| `kitty` | Terminal emulator |
| `waybar` | Status bar |
| `rofi-wayland` | App launcher |
| `awww` | Wallpaper manager |
| `hypridle`, `hyprlock` | Idle/lock screen |
| `mako` or `dunst` | Notifications |
| `zsh`, `oh-my-zsh` | Shell |
| `neovim` | Editor (with 30+ plugins) |

> [!NOTE]
> The FoxML installer and bootstrap script have been significantly tested and are considered stable for Arch Linux. However, as with any automated system deployment, edge cases may exist depending on specific hardware configurations.

Run `./install.sh --deps` to install most of these automatically.

## Quick Start

**One-command workstation bootstrap** (fresh Arch + Hyprland — installs deps, clones repo, sets up AI Lab, GitHub workspace, and applies FoxML Classic):

```bash
curl -fsSL https://raw.githubusercontent.com/Jennyfirrr/Linux_Theme/main/bootstrap.sh | bash
```

This single command provides a complete, professional development environment out-of-the-box.

## FoxML OS — The Distro Experience

You can deploy FoxML as a complete, pre-configured operating system using the official Arch Linux installer.

1. Boot any official Arch Linux ISO.
2. Run the following command to load the FoxML profile:
   ```bash
   archinstall --config https://raw.githubusercontent.com/Jennyfirrr/Linux_Theme/main/shared/foxml-profile.json
   ```
This will automatically install the **linux-zen** kernel, NVIDIA drivers, and trigger the full workstation bootstrap on the first boot.

**Manual install** (clone first if you want to read the scripts before running them):

```bash
git clone https://github.com/Jennyfirrr/Linux_Theme.git
cd Linux_Theme

# Full Workstation Stack (AI + GitHub + Deps)
./install.sh FoxML_Classic --deps --ai --models --github --yes

# Interactive — shows available themes and prompts before each step
./install.sh

# Integrated AI Lab (Ollama, OpenCode, Qwen 7B/14B/32B models, AI Skills)
./install.sh FoxML_Classic --ai --models

# GitHub Workspace Automation (clones all your repos into ~/code)
./install.sh FoxML_Classic --github

# Hardened security (UFW, Fail2ban, Auditd, SSH hardening wizard)
./install.sh FoxML_Classic --secure

# High-precision time sync (Chrony) for trading logs
./install.sh FoxML_Classic --perf

# Privacy & DNS-over-HTTPS (encrypted DNS lookups)
./install.sh FoxML_Classic --privacy

# Secure Vault (GPG-encrypted 'pass' manager + Git signing)
./install.sh FoxML_Classic --vault

# With system dependencies (Arch packages, Oh My Zsh, zsh plugins)
./install.sh FoxML_Classic --deps

# Fully unattended (auto-yes every prompt; same defaults bootstrap.sh uses)
./install.sh FoxML_Classic --deps --yes

# Run the whole Wayland session on the discrete NVIDIA GPU (Optimus laptops).
# Installs nvidia-open-dkms + linux-headers, sets MODULES in mkinitcpio,
# adds nvidia_drm.modeset=1 to the kernel cmdline, and points Hyprland's
# Aquamarine backend at the dGPU. Reboot afterwards. Requires systemd-boot
# (other bootloaders print manual instructions).
./install.sh FoxML_Classic --deps --nvidia

# Switch between themes (shows color previews)
./swap.sh

# Pull live system config edits back into templates
# (replaces rendered colors with {{PLACEHOLDER}} tokens so your changes are preserved across themes)
./update.sh
```

## How It Works

Configs live as **templates** with `{{COLOR}}` placeholders. Each theme is just a `palette.sh` file defining ~60 color variables. At install time, the render engine fills in the placeholders and copies the result to your system.

```
templates/                  <- config files with {{PLACEHOLDER}} tokens
  kitty/kitty.conf            background #{{BG}}, foreground #{{PRIMARY}}, ...
  nvim/init.lua               style = "{{NVIM_STYLE}}", colors with #{{RED}}, ...
  waybar/style.css            @define-color bg #{{BG}}, rgba({{PRIMARY_R}}, ...), ...
  zsh/.zshrc                  %F{{{ANSI_ACCENT1}}}, fg=#{{ZSH_SUGGEST}}, ...
  hyprlock/hyprlock.conf      rgb({{PRIMARY_R}}, {{PRIMARY_G}}, {{PRIMARY_B}}), ...
  regreet/regreet.css           background rgba({{BG_R}}, ...), color #{{PRIMARY}}, ...
  ... (30+ files across 22+ app directories)

themes/
  FoxML_Classic/
    palette.sh              <- defines all colors for Classic
    theme.conf              <- name, type=dark, description
shared/                     <- non-color files copied as-is (keybinds, scripts, etc.)

render.sh                   <- template engine (hex, RGB, ANSI, metadata substitution)
mappings.sh                 <- source -> destination file routing + special handlers
install.sh                  <- renders templates + copies to system
update.sh                   <- reverse-renders system configs back into templates
swap.sh                     <- interactive theme switcher with color previews
```

**Adding a new theme** = writing one `palette.sh` file. All 23+ app configs are generated from templates.

**Editing a config** = edit the template, it applies to all themes. Run `./update.sh` to pull changes from your live system back into templates.

## Themed Applications

Every one of these gets its colors from the active theme's `palette.sh`:

| App | Template | Installs To |
|-----|----------|-------------|
| Hyprland | `templates/hyprland/theme.conf` | `~/.config/hypr/modules/theme.conf` |
| Hyprlock | `templates/hyprlock/hyprlock.conf` | `~/.config/hypr/hyprlock.conf` |
| Neovim | `templates/nvim/init.lua` | `~/.config/nvim/init.lua` |
| Kitty | `templates/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| Waybar | `templates/waybar/style.css` | `~/.config/waybar/style.css` |
| Tmux | `templates/tmux/.tmux.conf` | `~/.tmux.conf` |
| Zsh | `templates/zsh/` (7 files) | `~/.zshrc` + `~/.config/zsh/` + caramel prompt |
| Rofi | `templates/rofi/glass.rasi` | `~/.config/rofi/glass.rasi` |
| Dunst | `templates/dunst/dunstrc` | `~/.config/dunst/dunstrc` |
| Mako | `templates/mako/config` | `~/.config/mako/config` |
| Fastfetch | `templates/fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` |
| GTK 3 | `templates/gtk-3.0/gtk.css` | `~/.config/gtk-3.0/gtk.css` |
| GTK 4 | `templates/gtk-4.0/gtk.css` | `~/.config/gtk-4.0/gtk.css` |
| btop | `templates/btop/foxml.theme` | `~/.config/btop/themes/foxml.theme` |
| Yazi | `templates/yazi/theme.toml` | `~/.config/yazi/theme.toml` |
| Zathura | `templates/zathura/zathurarc` | `~/.config/zathura/zathurarc` |
| Firefox | `templates/firefox/` (2 files) | `<profile>/chrome/userChrome.css` |
| Cursor/VS Code | `templates/cursor/` | `~/.cursor/extensions/foxml-theme/` |
| Bat | `templates/bat/foxml.tmTheme` | `~/.config/bat/themes/Fox ML.tmTheme` |
| ReGreet (login) | `templates/regreet/regreet.css` | `/etc/greetd/regreet.css` (via sudo) |

## Shared (Non-Color) Files

These are copied as-is regardless of theme — keybinds, scripts, layout configs:

| File | Description |
|------|-------------|
| `shared/hyprland_modules/` | 12 Hyprland modules (keybinds, rules, monitors, scratchpads, etc.) |
| `shared/hyprland_scripts/` | 12 helper scripts (lock, startup, yazi, fingerprint, etc.) |
| `shared/launchers/` | Toggle scripts for btop, yazi |
| `shared/wallpapers/` | Wallpaper files |
| `shared/nvim_lazy-lock.json` | Neovim plugin lock file |
| `shared/nvim_ftplugin/` | Neovim filetype plugins |
| `shared/rofi_config.rasi` | Rofi layout config |
| `shared/waybar_config` | Waybar module/layout config |
| `shared/gtk-{3,4}.0_settings.ini` | GTK settings (font, icon theme) |
| `shared/zsh_aliases.zsh` | Shell aliases |
| `shared/zsh_git.zsh` | Git workflow functions (gpush, gnew, gsave, gbr, etc.) |
| `shared/zsh_paths.zsh` | PATH setup |
| `shared/zsh_conda.zsh` | Conda/mamba init |
| `shared/regreet.toml` | ReGreet greeter config (font, cursor, clock, env vars) |
| `shared/greetd_hyprland.conf` | Minimal Hyprland config for the greeter session |

## Zsh / Shell

Templates in `templates/zsh/` include the full shell setup:

| File | Description |
|------|-------------|
| `.zshrc` | Main config — Oh My Zsh, completions, fzf, tmux auto-attach |
| `caramel.zsh-theme` | Custom prompt with gradient path, git, conda/venv, elapsed time |
| `colors.zsh` | LS_COLORS and zsh-syntax-highlighting |
| `welcome.zsh` | Terminal splash with system info and todo list |

Requires: [Oh My Zsh](https://ohmyz.sh/), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat)

### Git Workflow Functions

`git.zsh` adds workflow shortcuts that complement the Oh My Zsh `git` plugin (which provides simple aliases like `gst`, `ga`, `gd`, `gco`). These chain multiple git commands into common workflows:

| Command | What it does |
|---------|-------------|
| `gpush` | Push current branch — auto-sets upstream on first push |
| `gnew [name]` | Create + switch to new branch (prompts for name if omitted) |
| `gsave <msg>` | Stage all + commit in one shot |
| `gquick` | WIP checkpoint commit with timestamp |
| `gundo` | Undo last commit, keep changes staged |
| `gamend` | Fold new changes into last commit |
| `gbr` | fzf branch switcher, sorted by most recent |
| `grecent` | List recent branches with relative timestamps |
| `gsync` | Fetch + rebase current branch onto latest main |
| `gclean` | Delete local branches already merged into main |
| `gstash [msg]` | Named stash (no args = list stashes) |
| `gpop` | fzf picker for which stash to pop |
| `gtoday` | Show your commits from today |
| `gds` | Diff staged changes |

## Neovim

See [`shared/nvim_NVIM-KEYBINDS.md`](shared/nvim_NVIM-KEYBINDS.md) for the complete keybind reference.

**AI integration:**
- **copilot.lua** — inline ghost-text completions + copilot-cmp source (toggle with `<Space>Ci`)
- **avante.nvim** — Cursor-style AI chat panel using Copilot provider (Claude Sonnet 4)
- **claudecode.nvim** — Claude Code terminal integration (`<Space>Ct` toggle, `<Space>Cs` send selection)

**Highlights:** LSP via mason, DAP debugging, cmake-tools, neotest, lazygit, telescope, harpoon, neo-tree, treesitter, zen-mode

## Login Screen (greetd + regreet)

The login screen is themed via regreet (a GTK4 greeter for greetd) running inside a minimal Hyprland session — no cage, no TTY flash.

`./install.sh --deps` installs `greetd` + `greetd-regreet` and `install_greetd()` auto-runs: it deploys regreet css/toml + the wallpaper to `/etc/greetd/` and `/usr/share/wallpapers/`, writes `/etc/greetd/config.toml` to launch Hyprland as the greeter, and enables the systemd unit. Idempotent — rerunning preserves a customized `config.toml`.

On first login, select your Hyprland session from the Session dropdown — regreet remembers it for next time.

## Creating a New Theme

1. Copy an existing palette: `cp themes/FoxML_Classic/palette.sh themes/My_Theme/palette.sh`
2. Edit the colors in your new `palette.sh`
3. Create `themes/My_Theme/theme.conf` with name/type/description
4. Run `./install.sh My_Theme`

The palette defines ~60 variables across several categories:
- **Core colors** — BG, FG, PRIMARY, SECONDARY, ACCENT, SURFACE + variants
- **ANSI colors** — RED, GREEN, YELLOW, BLUE, CYAN + bright variants
- **ANSI 256 codes** — terminal color indices for zsh prompts
- **Tmux colors** — `colour216`-style tmux palette
- **App overrides** — per-app background tweaks (dunst, spicetify, vencord)
- **Font** — `FONT_FAMILY` sets the font across all templated apps (default: `Hack Nerd Font`)
- **Metadata** — NVIM_STYLE, KITTY_BG_OPACITY, VSCODE_UI_THEME, etc.

### Changing the Font

Set `FONT_FAMILY` in your theme's `palette.sh` to any installed Nerd Font:

```bash
FONT_FAMILY="Hack Nerd Font"          # default — blocky, sturdy
FONT_FAMILY="JetBrainsMono Nerd Font"  # clean, rounded
FONT_FAMILY="IBM Plex Mono Nerd Font"  # industrial, wide
```

This updates all templated configs (kitty, waybar, rofi, dunst, mako, hyprlock, regreet CSS, spicetify, zathura). Shared configs (GTK settings, regreet.toml, hyprland general) use the font directly — update those manually if switching fonts.

See `themes/FoxML_Classic/palette.sh` for the full variable list.

## Post-Install

1. `hyprctl reload`
2. Restart terminals/apps
3. Firefox: enable `toolkit.legacyUserProfileCustomizations.stylesheets` in `about:config`
4. Cursor: Select "Fox ML" in color theme picker

## License

Do whatever you want with it.
