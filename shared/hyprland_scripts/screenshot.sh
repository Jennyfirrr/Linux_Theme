#!/bin/bash
# Region screenshot → save to ~/Pictures/Screenshots and copy to clipboard.
set -e
out_dir="$HOME/Pictures/Screenshots"
mkdir -p "$out_dir"
file="$out_dir/screenshot-$(date +%Y%m%d-%H%M%S).png"
geom=$(slurp) || exit 0
grim -g "$geom" "$file"
wl-copy --type image/png < "$file"
notify-send -i "$file" "Screenshot saved" "$file"
