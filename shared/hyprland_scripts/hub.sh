#!/bin/bash

# The FoxML Hub 2.0 (Optimized)
# A dynamic, status-aware control center for your earthy desktop
# Uses faster status gathering to eliminate startup lag.

# SysHub anchors top-right by default (system menu zone).
ROFI_ZONE="${ROFI_ZONE:-ne}"
source ~/.config/hypr/scripts/_rofi_zone.sh

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

    # Audio Status (Fast). wpctl can return empty / non-numeric mid-restart
    # of pipewire — passing that into awk arithmetic crashes the hub. Cache
    # the wpctl output once, validate vol_raw matches a float pattern, and
    # default to "—" on no signal.
    wpctl_out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    vol_raw=$(awk '{print $2}' <<<"$wpctl_out")
    if [[ "$vol_raw" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        vol_percent=$(awk -v v="$vol_raw" 'BEGIN {print int(v*100)}')
    else
        vol_percent="—"
    fi
    mute=""
    grep -q "MUTED" <<<"$wpctl_out" && mute=" (Muted)"
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
        -theme-str "$ROFI_POS_THEME inputbar {enabled: false;} window {width: 35%;} listview {lines: 15;}"
󰀻  Search Apps
󰖲  Active Windows
󱉩  Vault (Passwords)
󰀦  Panic Button
󰒃  Security Audit
󰐥  Power Menu
󰖩  Network           󰇙  $wifi_status
󰂯  Bluetooth         󰇙  $bt_status
󰓃  Audio             󰇙  $audio_status
󰖔  Night Light       󰇙  $nl_status
󱑙  Idle Inhibitor    󰇙  $idle_status
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
        *"Sync Theme to Wallpaper"*)
            # awww query prints one line per monitor; on multi-monitor
            # setups awk '{print $NF}' returned NEWLINE-separated paths
            # and the [[ -f ]] check failed. Take just the first line.
            # Prefer the primary monitor's wallpaper if the sidecar names one.
            primary=""
            if [[ -f "$HOME/.config/foxml/monitor-layout.conf" ]]; then
                primary=$(awk -F'"' '/^PRIMARY=/{print $2; exit}' "$HOME/.config/foxml/monitor-layout.conf")
            fi
            if [[ -n "$primary" ]]; then
                current_wp=$(awww query 2>/dev/null \
                    | awk -v m="$primary" '$0 ~ m {print $NF; exit}')
            fi
            # Fallback to first line if the primary lookup didn't match.
            if [[ -z "${current_wp:-}" || ! -f "${current_wp:-}" ]]; then
                current_wp=$(awww query 2>/dev/null \
                    | grep -m1 'currently displaying' | awk '{print $NF}')
            fi
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
