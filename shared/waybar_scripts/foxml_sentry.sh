#!/usr/bin/env bash
# foxml_sentry.sh — unified waybar module.
#
# Replaces the previous `custom/overwatch` + `custom/security` pair with
# a single widget covering:
#   • hardening posture (UFW / fail2ban / auditd / AppArmor / chrony /
#     systemd-resolved / SSH hardening / kernel sysctls)
#   • intrusion watchers (fox-bouncer, fox-tripwire status)
#   • network anomalies (new listening sockets vs prior tick)
#   • spoofed-kthread / new-root-proc anomalies
#   • shared alert ledger (tripwire / bouncer / fail2ban / dispatch)
#
# Three states, each emits one JSON object:
#   ok       — class="ok"        text shows shield + count of active protections
#   warning  — class="warning"   yellow, one or more soft warnings
#   critical — class="critical"  red, hardening missing or active intrusion
#
# Tooltip in the ok state lists every active protection so the user can
# see at a glance what's covering them — replaces the previous bare "ok".

set -u

STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE="$STATE_DIR/foxml-sentry.state"
LEDGER="${XDG_DATA_HOME:-$HOME/.local/share}/foxml/alerts.log"
LEDGER_WINDOW=300

declare -a oks=()
declare -a warns=()
declare -a crits=()
class="ok"

# ─── helpers ──────────────────────────────────────────────────────
_bump() {
    # _bump <severity> <message>
    case "$1" in
        ok)       oks+=("$2") ;;
        warn)     warns+=("$2");  [[ "$class" != "critical" ]] && class="warning" ;;
        crit)     crits+=("$2");  class="critical" ;;
    esac
}

_svc_active() { systemctl is-active --quiet "$1" 2>/dev/null; }
_usvc_active() { systemctl --user is-active --quiet "$1" 2>/dev/null; }

# ─── hardening posture ────────────────────────────────────────────
if _svc_active ufw;       then _bump ok   "Firewall: UFW active"; else _bump crit "Firewall DOWN"; fi
if _svc_active fail2ban;  then _bump ok   "Brute-force: fail2ban active";  else _bump warn "fail2ban inactive"; fi
if _svc_active auditd;    then _bump ok   "Audit: auditd active";          else _bump warn "auditd inactive"; fi
if _svc_active usbguard;  then _bump ok   "USB policy: usbguard active";   else _bump warn "usbguard inactive"; fi
if _svc_active chronyd;   then
    if command -v chronyc >/dev/null && chronyc tracking 2>/dev/null | grep -q "Leap status     : Normal"; then
        _bump ok "Time: synced"
    else
        _bump warn "Time UNSYNCED"
    fi
else _bump warn "chronyd inactive"
fi
if [[ -d /sys/kernel/security/apparmor ]]; then _bump ok "MAC: AppArmor loaded"; else _bump warn "AppArmor not loaded (reboot pending)"; fi
if [[ -f /etc/sysctl.d/99-foxml-hardening.conf ]]; then _bump ok "Kernel: hardening sysctls applied"; fi

# SSH posture
ssh_conf=/etc/ssh/sshd_config.d/50-foxml-hardening.conf
if [[ -f "$ssh_conf" ]]; then
    port=$(awk '/^Port /{print $2}' "$ssh_conf" 2>/dev/null)
    pa=$(awk '/^PasswordAuthentication /{print $2}' "$ssh_conf" 2>/dev/null)
    if [[ "$pa" == "no" ]]; then
        _bump ok "SSH: keys-only on port ${port:-?}"
    else
        _bump warn "SSH passwords ENABLED"
    fi
fi

# Ollama sandbox
[[ -f /etc/systemd/system/ollama.service.d/foxml-hardening.conf ]] && _bump ok "Ollama: sandbox drop-in"

# Keyring components masked → SSH/GPG agent works
if [[ "$(systemctl --user is-enabled app-gnome-keyring-pkcs11@autostart.service 2>/dev/null)" == "masked" ]]; then
    _bump ok "Keyring: SSH+GPG components active"
fi

# ─── intrusion watchers ───────────────────────────────────────────
if _usvc_active fox-bouncer.service;   then _bump ok "Watcher: bouncer (USB while-locked)"; fi
if _usvc_active fox-tripwire.service;  then _bump ok "Watcher: tripwire (honeypot)"; fi

# fox-dispatch configured
if [[ -f "$HOME/.config/foxml/dispatch.conf" ]]; then
    _bump ok "Phone alerts: configured"
fi

# ─── shared ledger (last 5 min) ──────────────────────────────────
recent_findings=""
if [[ -f "$LEDGER" ]]; then
    cutoff=$(( $(date +%s) - LEDGER_WINDOW ))
    while IFS=$'\t' read -r ts source msg; do
        [[ "$ts" =~ ^[0-9]+$ ]] || continue
        if (( ts >= cutoff )); then
            # tripwire / bouncer / ssh-brute → critical. overwatch
            # anomaly → warning.
            case "$source" in
                ssh-brute|*tripwire*|*USB*locked*) _bump crit "recent: ${source}: ${msg}" ;;
                *)                                  _bump warn "recent: ${source}: ${msg}" ;;
            esac
        fi
    done < "$LEDGER"
fi

# ─── new listeners diff (formerly hw_overwatch's responsibility) ──
if command -v ss >/dev/null 2>&1; then
    current_listen=$(ss -tlnp 2>/dev/null \
        | awk 'NR>1 && $4 !~ /^127\./ && $4 !~ /^\[::1\]/ && $4 !~ /^\*:/ {
                  match($0, /users:\(\("[^"]+"/)
                  proc=substr($0, RSTART+8, RLENGTH-9)
                  print $4 "\t" proc
              }' \
        | sort -u)
    prev_listen=""
    if [[ -f "$STATE" ]]; then
        prev_listen=$(awk '/^LISTEN:/{print substr($0,8)}' "$STATE" \
                      | tr '|' '\n' | grep -v '^$' | sort -u)
    fi
    new_lines=$(comm -23 <(echo "$current_listen") <(echo "$prev_listen") 2>/dev/null)
    if [[ -n "$new_lines" ]]; then
        _bump warn "new listener(s): $(echo "$new_lines" | head -3 | tr '\n' ',' | sed 's/,$//')"
    fi
fi

# ─── new root processes (spoof-resistant kthread check) ──────────
_is_kernel_thread() {
    local pid="$1"
    [[ -d "/proc/$pid" ]] || return 1
    [[ -L "/proc/$pid/exe" && -e "/proc/$pid/exe" ]] && return 1
    local ppid
    ppid=$(awk '/^PPid:/{print $2}' "/proc/$pid/status" 2>/dev/null)
    [[ "$ppid" == "2" ]]
}
_kthread_pat='^(kworker(/[^[:space:]]*)?|kdmflush[^[:space:]]*|kthreadd|rcu_[^[:space:]]*|ksoftirqd[^[:space:]]*|migration[^[:space:]]*|irq/[^[:space:]]*|kcompactd[^[:space:]]*|khugepaged|writeback|kswapd[^[:space:]]*)$'
_user_pat='^(sudo|polkitd|sshd|cron|systemd[^[:space:]]*|udevd|udevadm)$'

new_roots_raw=$(ps -eo pid,euser,etime,comm 2>/dev/null \
    | awk '$2=="root" {
              t=$3; n=split(t, a, /[-:]/)
              if (n==2 && a[1]+0 == 0 && a[2]+0 < 30) print $1 "\t" $4
           }')
flagged=""
while IFS=$'\t' read -r pid comm; do
    [[ -z "$pid" || -z "$comm" ]] && continue
    if [[ "$comm" =~ $_kthread_pat ]]; then
        if _is_kernel_thread "$pid"; then continue
        else
            _bump crit "SPOOFED kthread name: $comm (pid $pid)"
            continue
        fi
    fi
    [[ "$comm" =~ $_user_pat ]] && continue
    flagged+="$comm "
done <<<"$new_roots_raw"
flagged=$(echo "$flagged" | tr ' ' '\n' | sort -u | grep -v '^$' | head -3 | tr '\n' ',' | sed 's/,$//')
[[ -n "$flagged" ]] && _bump warn "new root proc(s): $flagged"

# ─── persist listen state for next tick ──────────────────────────
{
    printf 'LISTEN:%s\n' "$(echo "${current_listen:-}" | tr '\n' '|')"
} > "$STATE" 2>/dev/null

# ─── compose JSON ────────────────────────────────────────────────
_compose_tooltip() {
    local out=""
    if (( ${#crits[@]} > 0 )); then
        out+="🚨 Critical:\\n"
        for m in "${crits[@]}"; do out+="  • $m\\n"; done
        out+="\\n"
    fi
    if (( ${#warns[@]} > 0 )); then
        out+="⚠ Warnings:\\n"
        for m in "${warns[@]}"; do out+="  • $m\\n"; done
        out+="\\n"
    fi
    if (( ${#oks[@]} > 0 )); then
        out+="✓ Active protections (${#oks[@]}):\\n"
        for m in "${oks[@]}"; do out+="  · $m\\n"; done
    fi
    # Escape double quotes for JSON.
    out="${out//\"/\\\"}"
    printf '%s' "$out"
}

case "$class" in
    critical)
        text="󰀦 ALERT ${#crits[@]}"
        ;;
    warning)
        text="⚠ ${#warns[@]}"
        ;;
    ok)
        # Replace the previous bare "ok" with something meaningful: shield
        # glyph + active-protection count. At a glance: "I'm covered by
        # 12 layers right now." Tooltip lists each.
        text="󰒃 sentry · ${#oks[@]}"
        ;;
esac

tooltip="$(_compose_tooltip)"
# Strip trailing escape sequences and emit valid JSON.
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
