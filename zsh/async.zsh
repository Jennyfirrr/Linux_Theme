# ⏳ Async load time
source ~/.oh-my-zsh/custom/plugins/zsh-async/async.zsh
zmodload zsh/datetime
async_init
async_start_worker load_time_worker
EPOCH_START=$EPOCHREALTIME

function precmd_async() {
  async_job load_time_worker zsh -c '
    zmodload zsh/datetime
    echo $((EPOCHREALTIME - '"$EPOCH_START"'))'
}

function load_time_prompt() {
  [[ -n "$async_worker_load_time_worker_result" ]] &&
    echo "%F{180}⏳${async_worker_load_time_worker_result:.2f}s%f"
}
