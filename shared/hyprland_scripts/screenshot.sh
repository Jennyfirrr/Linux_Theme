#!/bin/bash
# Region screenshot → Edit with Swappy → save/copy.
# NOTE: `set -e` is intentionally NOT used. slurp on cancel exits non-zero
# but we want to handle that path explicitly, not abort with no message.
out_dir="$HOME/Pictures/Screenshots"
mkdir -p "$out_dir"
file="$out_dir/screenshot-$(date +%Y%m%d-%H%M%S).png"

# Region selection. -b = background (transparent), -c = selection border colour.
# slurp exits non-zero AND emits empty output when the user hits Escape;
# without an explicit guard the script previously fed grim an empty
# `-g ""` which is interpreted as "capture everything" — i.e. cancelling
# silently produced a full-screen capture, the opposite of what the user
# asked for.
geom=$(slurp -b 00000000 -c c4956eff 2>/dev/null)
slurp_rc=$?
if (( slurp_rc != 0 )) || [[ -z "$geom" ]]; then
    notify-send -t 2000 "Screenshot" "Cancelled"
    exit 0
fi

sleep 0.1
grim -g "$geom" - | swappy -f - -o "$file"

# Check if file was actually saved (user may have cancelled in swappy too).
if [[ -f "$file" ]]; then
    wl-copy --type image/png < "$file"
    notify-send -i "$file" "Screenshot saved" "File: $(basename "$file")\nSaved to: ~/Pictures/Screenshots"
fi
