[[ -o interactive ]] || return

# ─── Shell options ────────────────────────────
setopt correct

# ─── Environment ──────────────────────────────
export QT_QPA_PLATFORMTHEME=qt5ct

# ─── Oh My Zsh ────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="caramel"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source "$ZSH/oh-my-zsh.sh"

# ─── Autosuggestions style ────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#{{ZSH_SUGGEST}}'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ─── Config (sourced after omz so plugins are loaded) ─
ZSHCONF="$HOME/.config/zsh"
source "$ZSHCONF/colors.zsh"
source "$ZSHCONF/aliases.zsh"
source "$ZSHCONF/paths.zsh"
source "$ZSHCONF/conda.zsh"
source "$ZSHCONF/welcome.zsh"

# ─── Completion styling ───────────────────────
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{{{ANSI_ACCENT1}}}── %d ──%f'
zstyle ':completion:*:warnings' format '%F{{{ANSI_ERROR}}}no matches%f'
zstyle ':completion:*:default' list-prompt '%F{{{ANSI_ACCENT1}}}%l%f'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' squeeze-slashes true

# ─── Colored man pages ───────────────────────
export LESS_TERMCAP_mb=$'\e[1;38;5;{{ANSI_ACCENT3}}m'
export LESS_TERMCAP_md=$'\e[1;38;5;{{ANSI_ACCENT1}}m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[38;5;{{ANSI_STANDOUT_BG}};48;5;{{ANSI_ACCENT2}}m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;38;5;{{ANSI_ACCENT3}}m'

# ─── fzf ──────────────────────────────────────
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
export FZF_DEFAULT_OPTS="
  --color=bg+:#{{SURFACE}},bg:#{{BG_DUNST}},fg:#{{FG}},fg+:#{{FG}}
  --color=hl:#{{FZF_ACCENT1}},hl+:#{{FZF_ACCENT2}},info:#{{FZF_ACCENT1}},marker:#{{FZF_ACCENT2}}
  --color=prompt:#{{FZF_ACCENT2}},spinner:#{{FZF_ACCENT1}},pointer:#{{FZF_ACCENT2}},header:#{{FZF_ACCENT1}}
  --color=border:#{{SURFACE}}
  --border=sharp --prompt='❯ ' --pointer='▸' --marker='●'
"

# ─── Auto-attach tmux ─────────────────────────
if [ -z "$TMUX" ]; then
  tmux attach -t main || tmux new -s main
fi
