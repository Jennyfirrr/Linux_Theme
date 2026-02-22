# ─── Welcome splash ───────────────────────────

function _caramel_welcome() {
  local c1='\e[38;5;218m'    # hot pink
  local c2='\e[38;5;217m'    # pastel pink
  local c3='\e[38;5;211m'    # rose
  local c4='\e[38;5;224m'    # blush
  local DM='\e[2;38;5;218m'  # dim pink
  local O='\e[0m'

  # Right column position for name banner
  local rc=$((COLUMNS - 33))
  (( rc < 50 )) && rc=50
  local drc=$((rc + 8))

  # System info
  local day=$(date '+%A' | tr '[:upper:]' '[:lower:]')
  local date=$(date '+%b %d' | tr '[:upper:]' '[:lower:]')
  local time=$(date '+%H:%M')
  local up=$(uptime -p 2>/dev/null | sed 's/^up //')
  local kern=$(uname -r | cut -d- -f1)
  local sh_ver="zsh ${ZSH_VERSION}"
  local wm="${XDG_CURRENT_DESKTOP:-hyprland}"
  local term="${TERM_PROGRAM:-${TERM}}"

  local bat_icon="" bat_val=""
  if [[ -f /sys/class/power_supply/BAT1/capacity ]]; then
    local pct=$(</sys/class/power_supply/BAT1/capacity)
    local state=$(</sys/class/power_supply/BAT1/status)
    if [[ "$state" = "Charging" ]]; then bat_icon=""
    elif (( pct > 80 )); then bat_icon=""
    elif (( pct > 60 )); then bat_icon=""
    elif (( pct > 40 )); then bat_icon=""
    elif (( pct > 20 )); then bat_icon=""
    else bat_icon=""
    fi
    bat_val="${pct}%"
  fi

  local sep="${DM}──────────────────────────${O}"
  local dots="\e[38;5;211m●${O} \e[38;5;217m●${O} \e[38;5;218m●${O} \e[38;5;224m●${O} \e[38;5;210m●${O} \e[38;5;217m●${O} \e[38;5;211m●${O} \e[38;5;218m●${O}"

  echo ""
  echo -e "     ${c1}╱|、${O}\e[${rc}G${c1}  ▀${O} ${c2}█▀▀${O} ${c3}█▀█${O} ${c2}█▀█${O} ${c1} ▀ ${O} ${c4}█▀▀${O} ${c2}█▀▀${O} ${c3}█▀█${O}"
  echo -e "   ${c1}(${c3}˚${c1}ˎ ${c3}。${c1}7${O}      ${c1}${day}${O} ${DM}·${O} ${c2}${date}${O} ${DM}·${O} ${c4}${time}${O}\e[${rc}G${c1}  █${O} ${c2}█▀ ${O} ${c3}█ █${O} ${c2}█ █${O} ${c1} █ ${O} ${c4}█▀ ${O} ${c2}█▀ ${O} ${c3}█▀ ${O}"
  echo -e "    ${c1}|、${c3}˜${c1}〵${O}      ${sep}\e[${rc}G${c1}▀▀ ${O} ${c2}▀▀▀${O} ${c3}▀ ▀${O} ${c2}▀ ▀${O} ${c1} ▀ ${O} ${c4}▀  ${O} ${c2}▀▀▀${O} ${c3}▀ ▀${O}"
  echo -e "    ${c1}じし${c3}ˍ${c1},)ノ${O}     ${DM} ${O} ${c2}${up}${O}\e[${drc}G${dots}"
  echo -e "                  ${DM} ${O} ${c2}${kern}${O}"
  echo -e "                  ${DM} ${O} ${c2}${sh_ver}${O}"
  echo -e "                  ${DM} ${O} ${c2}${wm}${O}"
  echo -e "                  ${DM} ${O} ${c2}${term}${O}"
  [[ -n "$bat_val" ]] && \
  echo -e "                  ${DM} ${bat_icon}${O} ${c2}${bat_val}${O}"

  # Todo items (max 3, only if ~/.todo exists and has content)
  if [[ -s ~/.todo ]]; then
    echo -e "                  ${sep}"
    local i=0
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      (( i++ ))
      (( i > 3 )) && break
      echo -e "                  ${DM} ◇${O} ${c4}${line}${O}"
    done < ~/.todo
  fi
  echo ""
}

# ─── Todo helpers ─────────────────────────────
todo() {
  [[ -z "$1" ]] && { [[ -s ~/.todo ]] && nl -ba ~/.todo || echo "nothing to do"; return; }
  echo "$*" >> ~/.todo
  echo "added: $*"
}

todone() {
  [[ ! -s ~/.todo ]] && { echo "nothing to do"; return; }
  if [[ -z "$1" ]]; then
    sed -i '1d' ~/.todo
  elif [[ "$1" =~ ^[0-9]+$ ]]; then
    sed -i "${1}d" ~/.todo
  fi
  [[ ! -s ~/.todo ]] && rm -f ~/.todo
  echo "done!"
}

todos() {
  [[ -s ~/.todo ]] && nl -ba ~/.todo || echo "nothing to do"
}

_caramel_welcome
