# zsh_history_scrub.zsh — keep secrets out of ~/.zsh_history.
#
# Two layers of defence:
#   1. zshaddhistory hook — returns 1 (drop from history) when the
#      command line matches a secret pattern. The command still runs
#      in the current shell; just isn't persisted.
#   2. HISTORY_IGNORE pattern — wider net, applied at read/write time.
#
# Catches the common foot-guns:
#   export PASSWORD=…  export *_TOKEN=…  export *_KEY=…  export *_SECRET=…
#   AWS_*_KEY / ACCESS_KEY / SECRET_ACCESS_KEY
#   curl -u user:pass …  curl -H "Authorization: Bearer xxx"
#   ssh / scp with password in URL  postgresql:// with password
#   anthropic / openai-style sk-… keys typed directly
#
# Does NOT scrub passwords typed via `read -s` or `sudo -S` — those
# never touch the command line in the first place. Does NOT defend
# against `echo $PASSWORD` — once the var is set, its expansion isn't
# in argv. So this is one layer of many; pair with a password manager.

zsh_history_scrub_preexec() {
    # Lowercase the command for case-insensitive matching.
    local lc=${1:l}
    # Patterns that should never persist. Conservative — false positives
    # are way less costly than letting a real secret hit history.
    case "$lc" in
        *' export '*'password='*  | export*'password='*  | *'=$('*pass*) return 1 ;;
        *' export '*'token='*     | export*'token='*) return 1 ;;
        *' export '*'_key='*      | export*'_key='*) return 1 ;;
        *' export '*'_secret='*   | export*'_secret='*) return 1 ;;
        *aws_access_key_id=*  | *aws_secret_access_key=*) return 1 ;;
        *anthropic_api_key=*  | *openai_api_key=*) return 1 ;;
        *' -u '*':'*' '*      | *'--user '*':'*' '*) return 1 ;;
        *'authorization: bearer '*) return 1 ;;
        *'sk-'[a-z0-9_-](#c40,)*) return 1 ;;
        *'ghp_'[a-z0-9](#c36)*    | *'github_pat_'*) return 1 ;;
    esac
    return 0
}

# zshaddhistory runs once per command, with the command line as $1.
# A non-zero return drops the line from history.
autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory zsh_history_scrub_preexec

# HISTORY_IGNORE is a broader regex-style filter zsh applies at write
# AND read time. Belt-and-suspenders against the preexec hook missing
# a pattern. Same shape as the case above.
HISTORY_IGNORE='([Ee][Xx][Pp][Oo][Rr][Tt] *([Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]|[Tt][Oo][Kk][Ee][Nn]|*_KEY|*_SECRET|AWS_*)=*|*authorization: *bearer*|*sk-[A-Za-z0-9_-]#(40,)*|*ghp_[A-Za-z0-9]#(36)*)'
