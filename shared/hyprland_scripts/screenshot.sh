#!/bin/bash
# Region screenshot → Edit with Satty → save/copy.
set -e
out_dir="$HOME/Pictures/Screenshots"
mkdir -p "$out_dir"
file="$out_dir/screenshot-$(date +%Y%m%d-%H%M%S).png"

# Capture to stdout and pipe to satty
# Satty's 'trash' icon will correctly discard the capture.
grim -g "$(slurp)" - | satty --filename - --output-filename "$file"

# Check if file was actually saved
if [[ -f "$file" ]]; then
    wl-copy --type image/png < "$file"
    notify-send -i "$file" "Screenshot saved" "$file"
fi
