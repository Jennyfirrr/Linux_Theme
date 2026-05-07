#!/bin/bash
# Region screenshot → Edit with Swappy → save/copy.
set -e
out_dir="$HOME/Pictures/Screenshots"
mkdir -p "$out_dir"
file="$out_dir/screenshot-$(date +%Y%m%d-%H%M%S).png"

# Capture to stdout and pipe to swappy
# We use a slight delay to ensure slurp's selection box is cleared from the compositor
# and use a fully transparent background for slurp to avoid 'white out' artifacts.
geom=$(slurp -b 00000000 -c c4956eff)
sleep 0.1
grim -g "$geom" - | swappy -f - -o "$file"

# Check if file was actually saved
if [[ -f "$file" ]]; then
    wl-copy --type image/png < "$file"
    notify-send -i "$file" "Screenshot saved" "File: $(basename "$file")\nSaved to: ~/Pictures/Screenshots"
fi
