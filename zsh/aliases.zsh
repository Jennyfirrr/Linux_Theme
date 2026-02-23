# ─── Modern tool replacements ─────────────────
alias ls='eza --color=always --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first --git --time-style=relative'
alias la='eza -lah --icons --group-directories-first --git --time-style=relative'
alias lt='eza -T --icons --level=2 --group-directories-first'
alias cat='bat --style=plain --paging=never'
alias catp='bat'
alias grep='grep --color=auto'

# ─── Navigation ───────────────────────────────
alias proj='cd ~/Projects/BlackNode'
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ─── Utilities ────────────────────────────────
alias myip='curl ifconfig.me'
alias sizeof='du -sh'
alias ports='ss -tulnp'
alias psg='ps aux | grep -v grep | grep -i'
alias cls='clear'
alias dashboard="~/dashboard.sh"
alias dtop='ssh desktop'
alias lock='sudo systemctl restart greetd'
alias stop='systemd-inhibit --what=idle:sleep:handle-lid-switch --why="Training models" tail -f /dev/null'

# ─── LLM / AI ────────────────────────────────
alias @recall='~/.contextai/src/recall_with_context.sh'
alias flush='~/.contextai/src/flush_llm_cache.sh'

# ─── Functions ────────────────────────────────
give() {
}

pdf() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: pdf <file.pdf>"
    return 1
  fi

  local pdf_file="$1"

  if [[ ! -f "$pdf_file" ]]; then
    echo "pdf: no such file: $pdf_file"
    return 1
  fi

  pdftotext "$pdf_file" - | less -R
}

gpp() {
  if [[ -z "$1" ]]; then
    echo "Usage: gpp file.cpp"
    return 1
  fi

  local src="$1"
  local out="${src%.cpp}"

  echo "Compiling your questionable code..."
  g++ -std=c++17 -Wall -Wextra -O2 "$src" -o "$out"
}
