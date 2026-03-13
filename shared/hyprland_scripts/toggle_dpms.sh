#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypridle_paused"

if [[ -f "$STATE_FILE" ]]; then
  # resume hypridle
  rm -f "$STATE_FILE"
  systemctl --user start hypridle || hypridle -d &
  notify-send "Hypridle" "Resumed idle/lock"
else
  # pause hypridle
  touch "$STATE_FILE"
  systemctl --user stop hypridle || pkill -SIGTERM hypridle
  notify-send "Hypridle" "Idle/lock disabled"
fi
