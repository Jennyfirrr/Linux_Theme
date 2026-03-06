# 🎨 Gradient colorizer for pastel rainbow text
function gradient_text() {
  local text=$1
  local -a colors=(219 183 117 111 147)
  local output=""
  for ((i=0; i<${#text}; i++)); do
    local c=${colors[i % ${#colors[@]}]}
    output+="%F{$c}${text:i:1}"
  done
  echo "$output%f"
}
