# 🎨 Gradient colorizer for pastel rainbow text
function gradient_text() {
  local text=$1
  local -a colors=({{ANSI_ACCENT1}} {{ANSI_ACCENT2}} {{ANSI_ACCENT3}} {{ANSI_ACCENT4}} {{ANSI_ACCENT5}})
  local output=""
  for ((i=0; i<${#text}; i++)); do
    local c=${colors[i % ${#colors[@]}]}
    output+="%F{$c}${text:i:1}"
  done
  echo "$output%f"
}
