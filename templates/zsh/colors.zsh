# ╭──────────────────────────────────────────────╮
# │          Fox ML — terminal colors            │
# ╰──────────────────────────────────────────────╯

# ─── LS_COLORS (pink palette) ────────────────
export LS_COLORS="\
di=38;5;{{ANSI_ACCENT2}};1:\
ln=38;5;{{ANSI_ACCENT1}}:\
ex=38;5;{{ANSI_ACCENT3}};1:\
fi=38;5;{{ANSI_TEXT}}:\
mi=38;5;{{ANSI_ERROR}}:\
or=38;5;{{ANSI_ERROR}};9:\
pi=38;5;{{ANSI_ACCENT1}}:\
so=38;5;{{ANSI_ACCENT3}}:\
bd=38;5;{{ANSI_ACCENT1}}:\
cd=38;5;{{ANSI_ACCENT1}}:\
*.md=38;5;{{ANSI_ACCENT1}}:\
*.txt=38;5;{{ANSI_TEXT}}:\
*.py=38;5;{{ANSI_ACCENT2}}:\
*.lua=38;5;{{ANSI_ACCENT1}}:\
*.sh=38;5;{{ANSI_ACCENT3}}:\
*.zsh=38;5;{{ANSI_ACCENT3}}:\
*.c=38;5;{{ANSI_ACCENT2}}:\
*.cpp=38;5;{{ANSI_ACCENT2}}:\
*.h=38;5;{{ANSI_ACCENT1}}:\
*.hpp=38;5;{{ANSI_ACCENT1}}:\
*.rs=38;5;{{ANSI_ACCENT2}}:\
*.go=38;5;{{ANSI_ACCENT2}}:\
*.js=38;5;{{ANSI_ACCENT1}}:\
*.ts=38;5;{{ANSI_ACCENT1}}:\
*.json=38;5;{{ANSI_TEXT}}:\
*.yaml=38;5;{{ANSI_TEXT}}:\
*.yml=38;5;{{ANSI_TEXT}}:\
*.toml=38;5;{{ANSI_TEXT}}:\
*.conf=38;5;{{ANSI_TEXT}}:\
*.cfg=38;5;{{ANSI_TEXT}}:\
*.ini=38;5;{{ANSI_TEXT}}:\
*.css=38;5;{{ANSI_ACCENT3}}:\
*.html=38;5;{{ANSI_ACCENT1}}:\
*.xml=38;5;{{ANSI_TEXT}}:\
*.jpg=38;5;{{ANSI_ACCENT3}}:\
*.jpeg=38;5;{{ANSI_ACCENT3}}:\
*.png=38;5;{{ANSI_ACCENT3}}:\
*.gif=38;5;{{ANSI_ACCENT3}}:\
*.svg=38;5;{{ANSI_ACCENT3}}:\
*.mp4=38;5;{{ANSI_ACCENT3}}:\
*.mkv=38;5;{{ANSI_ACCENT3}}:\
*.mp3=38;5;{{ANSI_ACCENT1}}:\
*.flac=38;5;{{ANSI_ACCENT1}}:\
*.wav=38;5;{{ANSI_ACCENT1}}:\
*.zip=38;5;{{ANSI_ACCENT5}}:\
*.tar=38;5;{{ANSI_ACCENT5}}:\
*.gz=38;5;{{ANSI_ACCENT5}}:\
*.xz=38;5;{{ANSI_ACCENT5}}:\
*.7z=38;5;{{ANSI_ACCENT5}}:\
*.git=38;5;{{ANSI_MUTED}}:\
*.gitignore=38;5;{{ANSI_MUTED}}:\
*.log=38;5;{{ANSI_MUTED}}:\
*.bak=38;5;{{ANSI_MUTED}}:\
*.tmp=38;5;{{ANSI_MUTED}}:\
"

# ─── zsh-syntax-highlighting (FoML) ────────────
typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[default]='fg={{ANSI_TEXT}}'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#{{RED}}'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg={{ANSI_ACCENT3}},bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#{{GREEN_BRIGHT}}'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#{{GREEN_BRIGHT}}'
ZSH_HIGHLIGHT_STYLES[function]='fg=#{{GREEN_BRIGHT}}'
ZSH_HIGHLIGHT_STYLES[command]='fg=#{{GREEN_BRIGHT}}'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#{{GREEN_BRIGHT}},underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg={{ANSI_ACCENT1}}'
ZSH_HIGHLIGHT_STYLES[path]='fg={{ANSI_ACCENT2}},underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg={{ANSI_ACCENT1}}'
ZSH_HIGHLIGHT_STYLES[globbing]='fg={{ANSI_ACCENT3}}'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg={{ANSI_ACCENT3}}'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg={{ANSI_ACCENT2}}'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg={{ANSI_ACCENT2}}'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg={{ANSI_ACCENT1}}'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg={{ANSI_ACCENT1}}'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg={{ANSI_ACCENT3}}'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg={{ANSI_ACCENT3}}'
ZSH_HIGHLIGHT_STYLES[assign]='fg={{ANSI_TEXT}}'
ZSH_HIGHLIGHT_STYLES[redirection]='fg={{ANSI_ACCENT3}}'
ZSH_HIGHLIGHT_STYLES[comment]='fg={{ANSI_MUTED}},italic'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#{{GREEN_BRIGHT}}'

# ─── Tab completion uses LS_COLORS ─────────────
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
