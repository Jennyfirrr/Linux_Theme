# Changelog

All notable changes to the Fox ML theme.

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
