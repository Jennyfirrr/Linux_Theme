# Fox ML prompt: peach tag + lavender path + newline
PS1='\[\e[38;5;216m\]❀ foxml > \[\e[38;5;140m\]\w\[\e[0m\]\n\$ '

# Conda env name in lavender
export CONDA_PROMPT_MODIFIER="\[\e[38;5;140m\](\[\e[0m\]\[\e[38;5;216m\]\$(basename \"$CONDA_DEFAULT_ENV\")\[\e[0m\]\[\e[38;5;140m\]) \[\e[0m\]"
