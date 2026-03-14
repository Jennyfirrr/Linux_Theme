# Fox ML prompt: peach tag + lavender path + newline
PS1='\[\e[38;5;{{ANSI_ACCENT1}}m\]❀ foxml > \[\e[38;5;{{ANSI_ACCENT5}}m\]\w\[\e[0m\]\n\$ '

# Conda env name in lavender
export CONDA_PROMPT_MODIFIER="\[\e[38;5;{{ANSI_ACCENT5}}m\](\[\e[0m\]\[\e[38;5;{{ANSI_ACCENT1}}m\]\$(basename \"$CONDA_DEFAULT_ENV\")\[\e[0m\]\[\e[38;5;{{ANSI_ACCENT5}}m\]) \[\e[0m\]"
