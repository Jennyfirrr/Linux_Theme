#!/bin/bash
# Region screenshot → Edit with Swappy → save/copy.
set -e
out_dir="$HOME/Pictures/Screenshots"
mkdir -p "$out_dir"
file="$out_dir/screenshot-$(date +%Y%m%d-%H%M%S).png"

# Capture to stdout and pipe to swappy
grim -g "$(slurp)" - | swappy -f - -o "$file"

# Check if file was actually saved (swappy might be cancelled)
if [[ -f "$file" ]]; then
    wl-copy --type image/png < "$file"
    notify-send -i "$file" "Screenshot saved" "$file"
fi
