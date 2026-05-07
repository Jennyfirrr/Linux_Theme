#!/bin/bash

# The FoxML Hub 2.0
# A dynamic, status-aware control center for your earthy desktop

while true; do
    # --- Gather System Status ---
    
    # WiFi Status
    wifi_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    [[ -z "$wifi_ssid" ]] && wifi_status="Disconnected" || wifi_status="Connected: $wifi_ssid"

    # Bluetooth Status
    bt_device=$(bluetoothctl info | grep "Name:" | cut -d' ' -f2-)
    [[ -z "$bt_device" ]] && bt_status="On (No Device)" || bt_status="Connected: $bt_device"
    if ! bluetoothctl show | grep -q "Powered: yes"; then bt_status="Off"; fi

    # Audio Status
    vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
    vol_percent=$(echo "$vol_raw * 100 / 1" | bc 2>/dev/null || awk "BEGIN {print int($vol_raw*100)}")
    mute=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED" && echo " (Muted)" || echo "")
    audio_status="Volume: ${vol_percent}%$mute"

    # Night Light Status
    if pkill -0 wlsunset 2>/dev/null; then nl_status="On"; else nl_status="Off"; fi

    # Idle Status
    if [[ -f "${XDG_RUNTIME_DIR:-/tmp}/hypridle_paused" ]]; then idle_status="Stay Awake (On)"; else idle_status="Normal (Off)"; fi

    # --- Build Menu ---
    # We use -no-custom and a theme-str to hide the entry box and ensure it feels static.
    # We add "Search Apps" and "Active Windows" to bridge the other Rofi modes.
    chosen=$(cat <<EOF | rofi -dmenu -i -no-custom -p "FoxML Hub" \
        -kb-row-up "k,Up" \
        -kb-row-down "j,Down" \
        -kb-accept-entry "l,Return" \
        -kb-row-left "h" \
        -theme-str 'inputbar {enabled: false;} window {location: north west; anchor: north west; x-offset: 12px; y-offset: 50px; width: 35%;} listview {lines: 15;}'
󰀻  Search Apps
󰖲  Active Windows
󰐥  Power Menu
󰖩  Network           󰇙  $wifi_status
󰂯  Bluetooth         󰇙  $bt_status
󰓃  Audio             󰇙  $audio_status
󰖔  Night Light       󰇙  $nl_status
󱑙  Idle Inhibitor    󰇙  $idle_status
󰸉  Next Wallpaper
󰚚  Sync Theme to Wallpaper
󰈋  Color Picker
🦊  System Cleanup
  Lock Screen
󰗼  Close Hub
EOF
)

    # --- Handle Selection ---
    case "$chosen" in
        *"Search Apps"*) 
            # Exit loop and launch app menu
            rofi -show drun -theme-str 'window {location: north; anchor: north; y-offset: 50px;}' &
            exit 0
            ;;
        *"Active Windows"*)
            # Exit loop and launch window switcher
            rofi -show window -kb-row-up "k,Up" -kb-row-down "j,Down" -kb-accept-entry "l,Return" -theme-str 'window {width: 50%;}' &
            exit 0
            ;;
        *"Power Menu"*) ~/.config/hypr/scripts/powermenu.sh ;;
        *"Network"*) ~/.config/hypr/scripts/network.sh ;;
        *"Bluetooth"*) ~/.config/hypr/scripts/bluetooth.sh ;;
        *"Audio"*) ~/.config/hypr/scripts/audio_switcher.sh ;;
        *"Night Light"*)
            if pkill wlsunset; then
                notify-send "Night Light" "Disabled"
            else
                wlsunset -t 3500 -T 6500 &
                notify-send "Night Light" "Enabled (3500K)"
            fi
            ;;
        *"Idle Inhibitor"*) ~/.config/hypr/scripts/toggle_dpms.sh ;;
        *"Next Wallpaper"*) ~/.config/hypr/scripts/rotate_wallpaper.sh --cycle ;;
        *"Sync Theme to Wallpaper"*)
            current_wp=$(swww query | grep 'currently displaying' | awk '{print $NF}')
            if [[ -f "$current_wp" ]]; then
                ~/.config/hypr/scripts/generate_palette.sh "$current_wp"
            else
                notify-send "Auto-Theme" "Could not detect current wallpaper."
            fi
            ;;
        *"Color Picker"*) hyprpicker -a ;;
        *"System Cleanup"*) kitty -e zsh -c "source ~/.zshrc && fox-clean; echo -e '\nPress enter to close...'; read" ;;
        *"Lock Screen"*) ~/.config/hypr/scripts/lock.sh ;;
        *"Close Hub"* | "") exit 0 ;;
    esac

    # Small sleep to allow system state to update before re-rendering the loop
    sleep 0.2
done
