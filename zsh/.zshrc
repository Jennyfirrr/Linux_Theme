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
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7d5e6b'
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
zstyle ':completion:*:descriptions' format '%F{218}── %d ──%f'
zstyle ':completion:*:warnings' format '%F{203}no matches%f'
zstyle ':completion:*:default' list-prompt '%F{218}%l%f'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' squeeze-slashes true

# ─── Colored man pages ───────────────────────
export LESS_TERMCAP_mb=$'\e[1;38;5;211m'
export LESS_TERMCAP_md=$'\e[1;38;5;218m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[38;5;232;48;5;217m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;38;5;211m'

# ─── fzf ──────────────────────────────────────
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
export FZF_DEFAULT_OPTS="
  --color=bg+:#3a414b,bg:#1f242b,fg:#f5f5f7,fg+:#f5f5f7
  --color=hl:#e8a0bf,hl+:#ffafd7,info:#e8a0bf,marker:#ffafd7
  --color=prompt:#ffafd7,spinner:#e8a0bf,pointer:#ffafd7,header:#e8a0bf
  --color=border:#3a414b
  --border=sharp --prompt='❯ ' --pointer='▸' --marker='●'
"

# ─── Auto-attach tmux ─────────────────────────
if [ -z "$TMUX" ]; then
  tmux attach -t main || tmux new -s main
fi
