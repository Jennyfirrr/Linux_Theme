#!/bin/bash

# The FoxML Hub 2.0 (Optimized)
# A dynamic, status-aware control center for your earthy desktop
# Uses faster status gathering to eliminate startup lag.

# Ensure we have the positioning variables
ROFI_X=${ROFI_X:-12}
ROFI_Y=${ROFI_Y:-50}

while true; do
    # --- Gather System Status (High-Speed Path) ---
    
    # WiFi Status: Query active connections (much faster than scanning dev wifi)
    wifi_ssid=$(nmcli -t -f NAME,TYPE connection show --active | grep ':802-11-wireless' | head -1 | cut -d: -f1)
    [[ -z "$wifi_ssid" ]] && wifi_status="Disconnected" || wifi_status="Connected: $wifi_ssid"

    # Bluetooth Status: Use a lighter check if possible
    if ! bluetoothctl show | grep -q "Powered: yes"; then 
        bt_status="Off"
    else
        bt_device=$(bluetoothctl info | grep "Name:" | cut -d' ' -f2-)
        [[ -z "$bt_device" ]] && bt_status="On (No Device)" || bt_status="Connected: $bt_device"
    fi

    # Audio Status (Fast)
    vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
    vol_percent=$(awk "BEGIN {print int($vol_raw*100)}")
    mute=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED" && echo " (Muted)" || echo "")
    audio_status="Volume: ${vol_percent}%$mute"

    # Night Light Status (Fast)
    if pkill -0 wlsunset 2>/dev/null; then nl_status="On"; else nl_status="Off"; fi

    # Idle Status (Fast)
    if [[ -f "${XDG_RUNTIME_DIR:-/tmp}/hypridle_paused" ]]; then idle_status="Stay Awake (On)"; else idle_status="Normal (Off)"; fi

    # --- Build Menu ---
    chosen=$(cat <<EOF | rofi -dmenu -i -no-custom -p "FoxML Hub" \
        -kb-row-up "k,Up" \
        -kb-row-down "j,Down" \
        -kb-accept-entry "l,Return" \
        -kb-cancel "Escape,h" \
        -theme-str "inputbar {enabled: false;} window {location: north west; anchor: north west; x-offset: ${ROFI_X}px; y-offset: ${ROFI_Y}px; width: 35%;} listview {lines: 15;}"
󰀻  Search Apps
󰖲  Active Windows
󰪚  Calculator
󰱫  Emoji Picker
   Quick AI Chat
󱉩  Vault (Passwords)
󰀦  Panic Button
󰒃  Security Audit
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
            ~/.config/hypr/scripts/toggle_rofi.sh rofi -show drun -kb-row-up "k,Up" -kb-row-down "j,Down" -kb-accept-entry "l,Return" &
            exit 0
            ;;
        *"Active Windows"*)
            ~/.config/hypr/scripts/toggle_rofi.sh rofi -show window -kb-row-up "k,Up" -kb-row-down "j,Down" -kb-accept-entry "l,Return" -kb-cancel "Escape,h" -theme-str 'inputbar {enabled: false;}' &
            exit 0
            ;;
        *"Calculator"*)
            ~/.config/hypr/scripts/toggle_rofi.sh rofi -show calc -modi calc -no-show-match -no-sort -kb-row-up "k,Up" -kb-row-down "j,Down" -kb-accept-entry "l,Return" &
            exit 0
            ;;
        *"Emoji Picker"*)
            ~/.config/hypr/scripts/toggle_rofi.sh rofi -show emoji -modi emoji -kb-row-up "k,Up" -kb-row-down "j,Down" -kb-accept-entry "l,Return" &
            exit 0
            ;;
        *"Quick AI Chat"*)
            fox-ai-quick &
            exit 0
            ;;
        *"Vault (Passwords)"*)
            ~/.config/hypr/scripts/toggle_rofi.sh rofi-pass &
            exit 0
            ;;
        *"Panic Button"*)
            ~/.config/hypr/scripts/panic.sh
            exit 0
            ;;
        *"Security Audit"*)
            kitty -e bash -c "sudo lynis audit system; echo -e '\nPress enter to close...'; read"
            ;;
        *"Power Menu"*) 
            ~/.config/hypr/scripts/powermenu.sh
            ;;
        *"Network"*) 
            ~/.config/hypr/scripts/network.sh
            ;;
        *"Bluetooth"*) 
            ~/.config/hypr/scripts/bluetooth.sh
            ;;
        *"Audio"*) 
            ~/.config/hypr/scripts/audio_switcher.sh
            ;;
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
    sleep 0.1
done
