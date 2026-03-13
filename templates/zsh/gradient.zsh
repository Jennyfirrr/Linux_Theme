# 🎨 Gradient colorizer for pastel rainbow text
function gradient_text() {
  local text=$1
  local -a colors=({{GRAD1}} {{GRAD2}} {{GRAD3}} {{GRAD4}} {{GRAD5}})
  local output=""
  for ((i=0; i<${#text}; i++)); do
    local c=${colors[i % ${#colors[@]}]}
    output+="%F{$c}${text:i:1}"
  done
  echo "$output%f"
}
