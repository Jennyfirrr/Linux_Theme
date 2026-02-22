# ╭──────────────────────────────────────────────╮
# │          Fox ML — terminal colors            │
# ╰──────────────────────────────────────────────╯

# ─── LS_COLORS (pink palette) ────────────────
export LS_COLORS="\
di=38;5;217;1:\
ln=38;5;218:\
ex=38;5;211;1:\
fi=38;5;253:\
mi=38;5;203:\
or=38;5;203;9:\
pi=38;5;218:\
so=38;5;211:\
bd=38;5;218:\
cd=38;5;218:\
*.md=38;5;218:\
*.txt=38;5;253:\
*.py=38;5;217:\
*.lua=38;5;218:\
*.sh=38;5;211:\
*.zsh=38;5;211:\
*.c=38;5;217:\
*.cpp=38;5;217:\
*.h=38;5;218:\
*.hpp=38;5;218:\
*.rs=38;5;217:\
*.go=38;5;217:\
*.js=38;5;218:\
*.ts=38;5;218:\
*.json=38;5;253:\
*.yaml=38;5;253:\
*.yml=38;5;253:\
*.toml=38;5;253:\
*.conf=38;5;253:\
*.cfg=38;5;253:\
*.ini=38;5;253:\
*.css=38;5;211:\
*.html=38;5;218:\
*.xml=38;5;253:\
*.jpg=38;5;211:\
*.jpeg=38;5;211:\
*.png=38;5;211:\
*.gif=38;5;211:\
*.svg=38;5;211:\
*.mp4=38;5;211:\
*.mkv=38;5;211:\
*.mp3=38;5;218:\
*.flac=38;5;218:\
*.wav=38;5;218:\
*.zip=38;5;210:\
*.tar=38;5;210:\
*.gz=38;5;210:\
*.xz=38;5;210:\
*.7z=38;5;210:\
*.git=38;5;240:\
*.gitignore=38;5;240:\
*.log=38;5;240:\
*.bak=38;5;240:\
*.tmp=38;5;240:\
"

# ─── zsh-syntax-highlighting (FoML) ────────────
typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[default]='fg=253'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff6b6b'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=211,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#b8e6c8'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#b8e6c8'
ZSH_HIGHLIGHT_STYLES[function]='fg=#b8e6c8'
ZSH_HIGHLIGHT_STYLES[command]='fg=#b8e6c8'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#b8e6c8,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=218'
ZSH_HIGHLIGHT_STYLES[path]='fg=217,underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=218'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=211'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=211'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=217'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=217'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=218'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=218'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=211'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=211'
ZSH_HIGHLIGHT_STYLES[assign]='fg=253'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=211'
ZSH_HIGHLIGHT_STYLES[comment]='fg=240,italic'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#b8e6c8'

# ─── Tab completion uses LS_COLORS ─────────────
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
