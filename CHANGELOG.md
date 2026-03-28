# Changelog

All notable changes to the Fox ML theme.

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
