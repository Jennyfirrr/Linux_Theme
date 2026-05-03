# FoxML CLI — Project Roadmap & Over-Engineering Goals

This document tracks the "Side Project" goals for the C++ rewrite of the FoxML theme engine. The objective is to move from simple bash scripts to a high-performance, intelligent system utility.

## 🎯 Current Status
- [x] Core C++ Installer (`foxml install <theme>`)
- [x] Basic Path Agnosticism (`~`, `$GEMINI_CONFIG_HOME`, Firefox Profile discovery)
- [x] Data-Oriented Renderer (pre-calculated replacements)
- [x] Native JSON Merging (Gemini CLI settings)
- [x] Live System Reloads (`hyprctl`, `waybar` signals, `mako`)

---

## 🚀 The "Flex" Goals (Upcoming Features)

### 1. The `foxml-swatch` TUI
**Goal**: A rich interactive terminal interface for theme selection.
- **Features**: 
    - Scrolling list of available themes.
    - Live-rendered color swatches in the terminal using truecolor ANSI.
    - Mini-preview of the selected theme (e.g., a mock Zsh prompt or terminal window).
- **The Tech**: C++ with `ftxui` or raw escape codes for zero-dependency speed.

### 2. Wallpaper-to-Theme Generator (`foxml gen <image>`)
**Goal**: Generate a brand new `palette.sh` based on any image.
- **Features**:
    - Extract dominant color clusters using K-Means.
    - Map extracted colors to FoxML semantic roles (BG, PRIMARY, ACCENT, etc.).
    - Use "color theory" rules to ensure the generated theme is readable.
- **The Tech**: `libpng`/`libjpeg` for image parsing; SIMD-optimized K-Means clustering.

### 3. "Ambient" Sync Daemon
**Goal**: A background process that manages the environment.
- **Features**:
    - **Time-of-Day Sync**: Auto-switch between light/dark variants based on the sun.
    - **Active Window Sync**: Change terminal/bar colors slightly to match the active application.
- **The Tech**: C++ daemon with a `inotify` watcher or `hyprland` socket listener.

### 4. Zero-Copy Template Engine
**Goal**: Make the renderer the fastest in the world (for no reason other than "because we can").
- **Features**:
    - Use `mmap()` to map template files directly into memory.
    - Implement a branchless scanner to find `{{` tokens.
    - Use `writev()` to perform gathered I/O, stitching the rendered file together in the kernel buffer without extra copies.

---

## 🛠 Project Structure Mandates
- **Single Binary**: All features should eventually be subcommands of the `foxml` tool.
- **Path Agnostic**: No hardcoded `/home/caramel`. Everything must be discoverable.
- **Hybrid Support**: Ensure the `templates/` and `themes/` directories remain compatible with the legacy Bash scripts.

## 📦 Distribution Goal
- [ ] Create a `PKGBUILD` for the Arch User Repository (AUR).
- [ ] Target `/usr/bin/foxml` as the final installation path.
