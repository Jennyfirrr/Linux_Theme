#!/bin/bash
# Waybar Security Overwatch
# Monitors firewall, sshd, and failed logins

warnings=()
class="normal"

# 1. Firewall (UFW)
if command -v ufw >/dev/null 2>&1; then
    if ! sudo ufw status | grep -q "Status: active"; then
        warnings+=("Firewall is DISABLED")
        class="critical"
    fi
else
    warnings+=("UFW is not installed")
    class="warning"
fi

# 2. SSH Root Login / Password Auth
# Check the hardening config we created
hard_conf="/etc/ssh/sshd_config.d/50-foxml-hardening.conf"
if [[ -f "$hard_conf" ]]; then
    if grep -q "PasswordAuthentication yes" "$hard_conf"; then
        warnings+=("SSH Passwords ENABLED")
        class="warning"
    fi
else
    warnings+=("SSH Hardening Missing")
    class="warning"
fi

# 3. Failed SSH Attempts (Fail2ban)
if systemctl is-active --quiet fail2ban; then
    # Count total banned IPs across all jails
    banned_count=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned:" | awk '{print $4}')
    if [[ "$banned_count" -gt 0 ]]; then
        warnings+=("$banned_count IPs currently BANNED")
    fi
else
    warnings+=("Fail2ban is INACTIVE")
    [[ "$class" != "critical" ]] && class="warning"
fi

if [[ ${#warnings[@]} -gt 0 ]]; then
    # Show different icons based on severity
    icon="󰒃"
    [[ "$class" == "critical" ]] && icon="󰀦"
    
    text="$icon SECURITY"
    tooltip="Security Overwatch:\\n"
    for w in "${warnings[@]}"; do
        tooltip+="  • $w\\n"
    done
    echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
else
    echo ""
fi
