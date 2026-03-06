#!/bin/bash

echo "Fixing mouse input...."

sudo udevadm control --reload-rules
sudo udevmadm trigger

hyprctl reload

sleep 1

if hyprctl devices | grep -i 'mouse'; then
	echo "Mouse detected..."
else
	echo "No Mouse detected"
	notify-send "Mouse not working, try fixing manually, rebooting, or trying a different usb port."
fi
