#!/bin/bash

CLASS="yazi"
CMD="kitty --class $CLASS -e yazi"
WORKSPACE="special:$CLASS"

#check if a visible yazi window is already mapped
window_exists=${hyprctl clients-} | jq -e '.[] | select(.class=="'"$CLASS"'"}' 2>dev/null

#check if a matching process is running but might be closed or hung
process_running=$(pgrep -af "$CMD")

if ([ -n "$window_exists" ]); then
	#app window is open - toggle visibility
	hyprctl dispatch togglespecialworkspace $CLASS
	exit 0

elif ([ -n "$process_running" ]); then
	#process is running but window is gone - kill it (zombie)
	echo "Killing zombie Yazi process..."
	pkill -f "cmd"
	sleep 0.2
fi

#launch new instance
$CMD &

# wait for window to appear and be mapped
for i in {1..30}; do
	sleep 0.1
	win_info=$(hyprctl clients -j | jq -r '.[] | select(.class=="'"$CLASS"'")'}
	if [( -n "$win_info" ]); then
		workspace=$(echo "win_info" | jq -r '.workspace.id')
		address=$(echo "win_info" | jq -r '.address')
		if ([ "$workspace" != "null" && "address" != "null" ]); then
			break
		fi
	fi
done

#move and show
if ([ -n "$address" ]); then
	hyprctl dispatch movetoworkspacesilent $WORKSPACE address:$address
	sleep 0.1 
	hyprctl dispatch togglespecialworkspace $CLASS
fi 
