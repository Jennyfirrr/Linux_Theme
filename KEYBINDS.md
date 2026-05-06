# Keybind Reference

Leader: **Space** | Local leader: **Space**

---

## Core Vim

### Movement
| Key | Action |
|-----|--------|
| `h/j/k/l` | Left / Down / Up / Right |
| `w` / `W` | Next word / WORD start |
| `b` / `B` | Previous word / WORD start |
| `e` / `E` | End of word / WORD |
| `0` / `$` | Start / End of line |
| `^` | First non-blank char |
| `gg` / `G` | Top / Bottom of file |
| `{` / `}` | Previous / Next paragraph |
| `%` | Jump to matching bracket |
| `Ctrl+d` / `Ctrl+u` | Half-page down / up |
| `Ctrl+f` / `Ctrl+b` | Full page down / up |
| `H` / `M` / `L` | Screen top / middle / bottom |
| `f{c}` / `F{c}` | Jump to next / prev char |
| `t{c}` / `T{c}` | Jump before next / prev char |
| `;` / `,` | Repeat / Reverse last f/t |

### Editing
| Key | Action |
|-----|--------|
| `i` / `a` | Insert before / after cursor |
| `I` / `A` | Insert at line start / end |
| `o` / `O` | New line below / above |
| `r{c}` | Replace single char |
| `R` | Enter replace mode |
| `x` | Delete char under cursor |
| `dd` / `D` | Delete line / to end of line |
| `cc` / `C` | Change line / to end of line |
| `yy` / `Y` | Yank line |
| `p` / `P` | Paste after / before |
| `u` / `Ctrl+r` | Undo / Redo |
| `.` | Repeat last change |
| `J` | Join line below |
| `~` | Toggle case |
| `>>` / `<<` | Indent / Unindent line |
| `gq{motion}` | Reformat text |

### Text Objects (use with d/c/y/v)
| Key | Selects |
|-----|---------|
| `iw` / `aw` | Inner / Around word |
| `i"` / `a"` | Inner / Around double quotes |
| `i'` / `a'` | Inner / Around single quotes |
| `i(` / `a(` | Inner / Around parentheses |
| `i{` / `a{` | Inner / Around braces |
| `i[` / `a[` | Inner / Around brackets |
| `it` / `at` | Inner / Around HTML tag |
| `ip` / `ap` | Inner / Around paragraph |
| `is` / `as` | Inner / Around sentence |
| `if` / `af` | Inner / Around function (treesitter) |
| `ic` / `ac` | Inner / Around class (treesitter) |
| `ia` / `aa` | Inner / Around parameter (treesitter) |
| `ii` / `ai` | Inner / Around conditional (treesitter) |
| `il` / `al` | Inner / Around loop (treesitter) |

### Treesitter Navigation
| Key | Action |
|-----|--------|
| `]m` / `[m` | Next / Prev function start |
| `]]` / `[[` | Next / Prev class start |
| `]a` / `[a` | Next / Prev parameter |
| `Space sa` | Swap parameter with next |
| `Space sA` | Swap parameter with previous |

### Flash (Jump Anywhere)
| Key | Action |
|-----|--------|
| `s{2 chars}` | Flash jump (labels all matches) |
| `S` | Flash treesitter select |

### Search
| Key | Action |
|-----|--------|
| `/{pattern}` | Search forward |
| `?{pattern}` | Search backward |
| `n` / `N` | Next / Previous match |
| `*` / `#` | Search word under cursor fwd / back |
| `:noh` | Clear search highlight |

### Visual Mode
| Key | Action |
|-----|--------|
| `v` | Character-wise visual |
| `V` | Line-wise visual |
| `Ctrl+v` | Block visual |
| `gv` | Reselect last visual |
| `o` | Jump to other end of selection |

### Marks & Jumps
| Key | Action |
|-----|--------|
| `m{a-z}` | Set local mark |
| `'{a-z}` | Jump to mark line |
| `` `{a-z} `` | Jump to mark position |
| `Ctrl+o` / `Ctrl+i` | Jump back / forward |
| `gi` | Go to last insert position |

### Windows & Splits
| Key | Action |
|-----|--------|
| `Space v` | Vertical split |
| `Space s` | Horizontal split |
| `Ctrl+w h/j/k/l` | Navigate splits |
| `Ctrl+w q` | Close split |
| `Ctrl+w o` | Close all other splits |
| `Ctrl+w =` | Equalize split sizes |
| `Ctrl+Left` / `Ctrl+Right` | Resize window width (-/+ 5 cols) |
| `Ctrl+Up` / `Ctrl+Down` | Resize window height (+/- 3 rows) |

### Buffers & Tabs
| Key | Action |
|-----|--------|
| `H` (Shift+h) | Previous buffer tab |
| `L` (Shift+l) | Next buffer tab |
| `Space bd` | Close current buffer |
| `Space bo` | Close all other buffers |
| `Space bh` | Close buffers to the left |
| `Space bl` | Close buffers to the right |
| `:e {file}` | Edit file |
| `:ls` | List buffers |
| `gt` / `gT` | Next / Previous tab |

### Registers
| Key | Action |
|-----|--------|
| `"{reg}y/d/p` | Yank/delete/paste with register |
| `"+y` | Yank to system clipboard |
| `"+p` | Paste from system clipboard |
| `:reg` | Show all registers |
| `"0p` | Paste last yank (not delete) |

### Macros
| Key | Action |
|-----|--------|
| `q{a-z}` | Start recording macro |
| `q` | Stop recording |
| `@{a-z}` | Play macro |
| `@@` | Replay last macro |
| `{n}@{a-z}` | Play macro n times |

---

## Custom Keymaps (init.lua)

### Telescope (Fuzzy Finder)
| Key | Action |
|-----|--------|
| `Space ff` | Find files |
| `Space fg` | Live grep (search content) |
| `Space fb` | Open buffers |
| `Space fh` | Help tags |

Inside Telescope:
| Key | Action |
|-----|--------|
| `Ctrl+n` / `Ctrl+p` | Next / Prev result |
| `Ctrl+j` / `Ctrl+k` | Next / Prev result (alt) |
| `Enter` | Open selected |
| `Ctrl+x` | Open in horizontal split |
| `Ctrl+v` | Open in vertical split |
| `Ctrl+t` | Open in new tab |
| `Ctrl+u` / `Ctrl+d` | Scroll preview up / down |
| `Esc` / `Ctrl+c` | Close |
| `Tab` | Toggle selection + move down |

### Neo-tree (File Tree Sidebar)
| Key | Action |
|-----|--------|
| `Space e` | Toggle file tree sidebar |
| `-` | Reveal current file in tree |
| `Ctrl+h` | Focus into neo-tree (from code) |
| `Ctrl+l` | Focus back to code (from neo-tree) |

Inside Neo-tree — Navigation:
| Key | Action |
|-----|--------|
| `j` / `k` | Move up / down |
| `l` / `Enter` | Open file / Expand folder |
| `h` | Collapse folder |
| `Backspace` | Navigate up a directory |
| `H` | Toggle hidden files |
| `.` | Toggle dotfiles |
| `/` | Filter / search |
| `<` / `>` | Navigate prev/next source (filesystem, buffers, git) |

Inside Neo-tree — Opening Files:
| Key | Action |
|-----|--------|
| `l` / `Enter` | Open in current window |
| `s` | Open in horizontal split |
| `v` | Open in vertical split |
| `t` | Open in new tab |
| `P` | Toggle preview |
| `S` | Open with system default |

Inside Neo-tree — File Operations:
| Key | Action |
|-----|--------|
| `a` | Add file/folder (end name with `/` for folder) |
| `d` | Delete |
| `r` | Rename |
| `y` | Copy file to clipboard |
| `x` | Cut file |
| `p` | Paste file |
| `c` | Copy (prompts for destination) |
| `m` | Move (prompts for destination) |

Inside Neo-tree — Other:
| Key | Action |
|-----|--------|
| `i` | Show file info |
| `R` | Refresh |
| `q` | Close tree |
| `?` | Show full help / all keybinds |

### LSP (active in any LSP buffer)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover documentation |
| `Space rn` | Rename symbol |
| `Space ca` | Code action |
| `[d` / `]d` | Prev / Next diagnostic |
| `Space f` | Format buffer |

### C/C++ Specific
| Key | Action |
|-----|--------|
| `Space ch` | Switch header / source (clangd) |

### CMake (cmake-tools.nvim)
| Key | Action |
|-----|--------|
| `Space cg` | CMake generate |
| `Space cb` | CMake build |
| `Space cr` | CMake run target |
| `Space ct` | Select build type (Debug/Release) |
| `Space cl` | Select launch target |

### DAP (Debugger)
| Key | Action |
|-----|--------|
| `F5` | Continue / Start debugging |
| `F9` | Toggle breakpoint |
| `F10` | Step over |
| `F11` | Step into |

DAP UI opens/closes automatically on debug start/stop.

### Neotest
| Key | Action |
|-----|--------|
| `Space tn` | Run nearest test |
| `Space ts` | Toggle test summary panel |

### Aerial (Symbol Outline)
| Key | Action |
|-----|--------|
| `Space so` | Toggle symbols outline |

Inside Aerial:
| Key | Action |
|-----|--------|
| `Enter` | Jump to symbol |
| `{` / `}` | Prev / Next symbol |
| `Ctrl+j` / `Ctrl+k` | Prev / Next symbol + scroll code |

### Trouble (Diagnostics Panel)
| Key | Action |
|-----|--------|
| `Space xx` | Toggle diagnostics list |
| `Space xq` | Toggle quickfix list |

Inside Trouble:
| Key | Action |
|-----|--------|
| `Enter` | Jump to item |
| `o` | Jump + close |
| `q` | Close |

### Surround (nvim-surround)
| Key | Action |
|-----|--------|
| `ysiw"` | Surround word with `"` |
| `ysiw(` | Surround word with `( )` (with spaces) |
| `ysiw)` | Surround word with `()` (no spaces) |
| `ys$"` | Surround to end of line with `"` |
| `yss"` | Surround entire line with `"` |
| `cs"'` | Change `"` to `'` |
| `cs({` | Change `()` to `{}` |
| `ds"` | Delete surrounding `"` |
| `ds(` | Delete surrounding `()` |
| `S"` (visual) | Surround selection with `"` |

### Harpoon (File Bookmarks)
| Key | Action |
|-----|--------|
| `Space ha` | Add current file to harpoon |
| `Space hh` | Open harpoon menu |
| `Ctrl+1` | Jump to harpoon file 1 |
| `Ctrl+2` | Jump to harpoon file 2 |
| `Ctrl+3` | Jump to harpoon file 3 |
| `Ctrl+4` | Jump to harpoon file 4 |

### Undotree
| Key | Action |
|-----|--------|
| `Space u` | Toggle undo tree panel |

Inside Undotree:
| Key | Action |
|-----|--------|
| `j/k` | Navigate undo states |
| `Enter` | Switch to state |
| `q` | Close |

### Diffview (Git)
| Key | Action |
|-----|--------|
| `Space gd` | Open git diff view |
| `Space gh` | File history (current file) |
| `Space gq` | Close diff view |

Inside Diffview:
| Key | Action |
|-----|--------|
| `Tab` | Next file |
| `Shift+Tab` | Prev file |
| `gf` | Open file |
| `q` | Close |

### Comment.nvim
| Key | Action |
|-----|--------|
| `Space /` | Toggle comment (line) |
| `gcc` | Toggle comment (line, default) |
| `gbc` | Toggle block comment |
| `gc{motion}` | Comment over motion (e.g. `gcap` = comment paragraph) |

In visual mode:
| Key | Action |
|-----|--------|
| `gc` | Toggle comment on selection |
| `gb` | Toggle block comment on selection |

### Which-Key
| Key | Action |
|-----|--------|
| (any prefix, wait) | Shows available continuations |

Press `Space` and wait — which-key will pop up showing all leader binds.

### Gitsigns (in-buffer git)
| Key | Action |
|-----|--------|
| `]c` / `[c` | Next / Prev hunk |
| `:Gitsigns preview_hunk` | Preview change |
| `:Gitsigns stage_hunk` | Stage hunk |
| `:Gitsigns undo_stage_hunk` | Undo stage |
| `:Gitsigns reset_hunk` | Reset hunk |
| `:Gitsigns blame_line` | Show git blame |
| `:Gitsigns diffthis` | Diff against index |

### Autocomplete (nvim-cmp, Insert Mode)
| Key | Action |
|-----|--------|
| `Tab` | Next completion / Expand snippet / Jump snippet |
| `Shift+Tab` | Previous completion / Jump snippet back |
| `Enter` | Confirm completion |
| `Ctrl+Space` | Trigger completion manually |
| `Ctrl+b` / `Ctrl+f` | Scroll docs up / down |
| `Ctrl+e` | Close completion menu |

### LuaSnip (Snippets)
| Key | Action |
|-----|--------|
| `Tab` | Expand snippet / Jump to next field |
| `Shift+Tab` | Jump to previous field |

### ToggleTerm
| Key | Action |
|-----|--------|
| `:ToggleTerm` | Open/close terminal |
| `Ctrl+\` | Toggle terminal (default) |

Inside terminal:
| Key | Action |
|-----|--------|
| `Ctrl+\ Ctrl+n` | Exit terminal mode (back to normal) |

### Claude Code (AI Terminal)
| Key | Action |
|-----|--------|
| `Space Ct` | Toggle Claude terminal (show/hide) |
| `Space Cs` | Send selection to Claude (visual) |

Claude Code sees all open buffers (the ones you cycle with `H`/`L`) automatically via WebSocket — file contents, paths, and diagnostics are shared without pasting. Use `Space Cs` in visual mode to explicitly point Claude at a specific code block.

Commands:
| Command | Action |
|---------|--------|
| `:ClaudeCode` | Simple show/hide toggle |
| `:ClaudeCodeFocus` | Smart focus toggle (swap between code and terminal) |
| `:ClaudeCodeOpen` | Open terminal (no toggle) |
| `:ClaudeCodeSend` | Send visual selection |
| `:ClaudeCodeAdd` | Add file to context |
| `:ClaudeCodeStatus` | Check WebSocket server status |

### VimTeX (LaTeX)
| Key | Action |
|-----|--------|
| `\ll` | Start/stop continuous compile |
| `\lv` | View PDF (zathura) |
| `\lc` | Clean aux files |
| `\lC` | Clean + PDF |
| `\lt` | Open ToC |
| `\le` | Show errors |
| `\lk` | Stop compilation |

(`\` = localleader, which is Space in your config — so `Space ll`, etc.)

### Overseer (Task Runner)
| Key | Action |
|-----|--------|
| `:OverseerRun` | Run a task |
| `:OverseerToggle` | Toggle task list |

### Projects
| Key | Action |
|-----|--------|
| `Space pp` | Browse recent projects (Telescope) |

### Fidget (LSP Progress)
Shows LSP indexing/progress automatically in the bottom-right. No keybinds.

### DAP Virtual Text
Shows variable values inline while debugging. Automatic when DAP is running.

### Treesitter Context
Shows the current function/class context at the top of the window automatically. No keybinds needed.

### Indent Blankline
Shows indent guides automatically. No keybinds.

---

## Useful Commands

| Command | Action |
|---------|--------|
| `:Lazy` | Plugin manager (install/update/clean) |
| `:Mason` | LSP/DAP/Linter installer |
| `:LspInfo` | Show active LSP servers |
| `:LspLog` | View LSP log |
| `:TSUpdate` | Update treesitter parsers |
| `:checkhealth` | Diagnose issues |
| `:Telescope keymaps` | Search all keymaps |
| `:CMake*` | All cmake-tools commands |
| `:Trouble *` | All trouble commands |

---

## Hyprland (ALT = mainMod)

### Core Workflow
| Key | Action |
|-----|--------|
| `ALT + Shift + H` | **FoxML Hub** (Power, BT, Wi-Fi, Wallpapers) |
| `ALT + Tab` | **App Switcher** (Rofi Window Search) |
| `ALT + Shift + R` | Reload Hyprland |
| `ALT + Shift + X` | Power Menu (Themed Rofi) |
| `ALT + V` | **Clipboard History** (Searchable Rofi) |

### Applications
| Key | Action |
|-----|--------|
| `ALT + Enter` | Terminal (Kitty + Tmux) |
| `ALT + F` | Firefox |
| `ALT + Shift + C` | Cursor (VS Code) |
| `ALT + Shift + D` | Rofi App Launcher |
| `ALT + Shift + V` | Steam |
| `ALT + Shift + Y` | Yazi (File Manager) |
| `ALT + Shift + T` | btop (Task Manager) |
| `ALT + Shift + I` | Discord |
| `ALT + Shift + O` | Screenshot (GUI Editor) |

### Music & Audio
| Key | Action |
|-----|--------|
| `ALT + Shift + S` | Spotify (GUI) |
| `ALT + Shift + M` | ncspot (Thermal-friendly Terminal Spotify) |
| `ALT + Shift + A` | **Audio Output Switcher** (Device list) |
| `Media Keys` | Play/Pause, Next, Prev, Stop |

### Connectivity
| Key | Action |
|-----|--------|
| `ALT + Shift + B` | Bluetooth Manager (Rofi) |
| `ALT + Shift + N` | Network/Wi-Fi Manager (Rofi) |

### Tools & Utilities
| Key | Action |
|-----|--------|
| `ALT + Shift + P` | **Color Picker** (Copy Hex to clipboard) |
| `ALT + Shift + L` | Toggle DPMS (Screen Sleep) |
| `ALT + B` | Toggle Waybar Visibility |
| `ALT + W` | Cycle Wallpaper (Fade transition) |
| `fox-clean` | Zsh: System maintenance utility |
| `fox-fingerprint` | Zsh: Biometric setup automation |

### Windows
| Key | Action |
|-----|--------|
| `ALT + Shift + Q` | Kill window |
| `ALT + Shift + G` | Toggle floating |
| `ALT + P` | Pin window |
| `ALT + S` | Toggle split |
| `ALT + h/j/k/l` | Focus left/down/up/right |

### Workspaces
| Key | Action |
|-----|--------|
| `ALT + .` | Next workspace |
| `ALT + ,` | Previous workspace |
| `ALT + 1-9` | Workspace 1-9 |
| `ALT + Shift + 1-9` | Move window to workspace |
| `ALT + Scroll` | Switch workspaces |
| `ALT + Left drag` | Move window |
| `ALT + Right drag` | Resize window |

---

## Tmux (Ctrl+a prefix)

| Key | Action |
|-----|--------|
| `Ctrl+a c` | New window |
| `Ctrl+a Tab` | Last window |
| `Ctrl+a \|` | Split horizontal |
| `Ctrl+a -` | Split vertical |
| `Ctrl+a h/j/k/l` | Navigate panes |
| `Ctrl+a H/J/K/L` | Resize panes |
| `Ctrl+a q` | Show pane numbers |
| `Ctrl+a m` | Move pane to new session |
| `Ctrl+a r` | Reload config |
| `Ctrl+a [` | Enter copy mode |
| `v` (copy mode) | Begin selection |
| `y` (copy mode) | Copy to clipboard |
| `Ctrl+Shift+a` | Send prefix to nested tmux |
