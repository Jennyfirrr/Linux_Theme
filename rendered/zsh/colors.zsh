# ╭──────────────────────────────────────────────╮
# │          Fox ML — terminal colors            │
# ╰──────────────────────────────────────────────╯

# ─── LS_COLORS (pink palette) ────────────────
export LS_COLORS="\
di=38;5;180;1:\
ln=38;5;173:\
ex=38;5;138;1:\
fi=38;5;253:\
mi=38;5;167:\
or=38;5;167;9:\
pi=38;5;173:\
so=38;5;138:\
bd=38;5;173:\
cd=38;5;173:\
*.md=38;5;173:\
*.txt=38;5;253:\
*.py=38;5;180:\
*.lua=38;5;173:\
*.sh=38;5;138:\
*.zsh=38;5;138:\
*.c=38;5;180:\
*.cpp=38;5;180:\
*.h=38;5;173:\
*.hpp=38;5;173:\
*.rs=38;5;180:\
*.go=38;5;180:\
*.js=38;5;173:\
*.ts=38;5;173:\
*.json=38;5;253:\
*.yaml=38;5;253:\
*.yml=38;5;253:\
*.toml=38;5;253:\
*.conf=38;5;253:\
*.cfg=38;5;253:\
*.ini=38;5;253:\
*.css=38;5;138:\
*.html=38;5;173:\
*.xml=38;5;253:\
*.jpg=38;5;138:\
*.jpeg=38;5;138:\
*.png=38;5;138:\
*.gif=38;5;138:\
*.svg=38;5;138:\
*.mp4=38;5;138:\
*.mkv=38;5;138:\
*.mp3=38;5;173:\
*.flac=38;5;173:\
*.wav=38;5;173:\
*.zip=38;5;139:\
*.tar=38;5;139:\
*.gz=38;5;139:\
*.xz=38;5;139:\
*.7z=38;5;139:\
*.git=38;5;240:\
*.gitignore=38;5;240:\
*.log=38;5;240:\
*.bak=38;5;240:\
*.tmp=38;5;240:\
"

# ─── zsh-syntax-highlighting (FoML) ────────────
typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[default]='fg=253'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#b05555'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=138,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#7aab88'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7aab88'
ZSH_HIGHLIGHT_STYLES[function]='fg=#7aab88'
ZSH_HIGHLIGHT_STYLES[command]='fg=#7aab88'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#7aab88,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=173'
ZSH_HIGHLIGHT_STYLES[path]='fg=180,underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=173'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=138'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=138'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=180'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=180'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=173'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=173'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=138'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=138'
ZSH_HIGHLIGHT_STYLES[assign]='fg=253'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=138'
ZSH_HIGHLIGHT_STYLES[comment]='fg=240,italic'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#7aab88'
