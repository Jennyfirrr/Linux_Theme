# ─── PATH ────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
typeset -U path PATH

# ─── FoxML Project Awareness ──────────────────
_fox_project_check() {
    if [[ -f "AGENT.md" || -d ".agent" ]]; then
        export FOXML_PROJECT_ROOT=$(pwd)
        export FOXML_PROJECT_NAME=$(basename $(pwd))
    else
        unset FOXML_PROJECT_ROOT
        unset FOXML_PROJECT_NAME
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _fox_project_check
_fox_project_check
