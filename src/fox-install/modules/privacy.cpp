// modules/privacy.cpp — DNS-over-HTTPS + DNSSEC strictness via systemd-resolved.
//
// Mirrors install_privacy() + install_resolved_dnssec() in mappings.sh:
//   * foxml-doh.conf  — DNS servers + DoH (NO DNSSEC line; lives in the
//                       separate drop-in below so a sibling-strip pass
//                       doesn't have to touch this file).
//   * 00-foxml-dnssec.conf — DNSSEC=allow-downgrade (laptop-safe default).
//   * comment out any explicit DNSSEC= in /etc/systemd/resolved.conf
//     (main config wins against drop-ins in some load orders).
//   * strip DNSSEC= from any sibling drop-ins so the lexically-first
//     foxml-dnssec.conf is the sole source of truth.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <filesystem>
#include <fstream>

namespace fs = std::filesystem;

namespace fox_install {

namespace {

constexpr const char* DOH_BODY =
    "[Resolve]\n"
    "DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com "
    "8.8.8.8#dns.google 8.8.4.4#dns.google\n"
    "DNSOverHTTPS=yes\n"
    "FallbackDNS=1.1.1.1 8.8.8.8\n";

constexpr const char* DOH_PATH       = "/etc/systemd/resolved.conf.d/foxml-doh.conf";
constexpr const char* DNSSEC_BODY    = "[Resolve]\nDNSSEC=allow-downgrade\n";
constexpr const char* DNSSEC_PATH    = "/etc/systemd/resolved.conf.d/00-foxml-dnssec.conf";

bool write_root_file(const fs::path& path, const std::string& body) {
    fs::path tmp = "/tmp/foxin-priv.conf.tmp";
    {
        std::ofstream o(tmp);
        o << body;
    }
    int rc = sh::run({"sudo", "install", "-d", path.parent_path().string()});
    if (rc != 0) { fs::remove(tmp); return false; }
    rc = sh::run({"sudo", "install", "-m", "0644", "-o", "root", "-g", "root",
                  tmp.string(), path.string()});
    fs::remove(tmp);
    return rc == 0;
}

}  // namespace

void run_privacy(Context& ctx) {
    (void)ctx;
    ui::section("Configuring DNS-over-HTTPS + DNSSEC strictness");

    if (sh::dry_run()) {
        ui::substep("[dry-run] would write " + std::string(DOH_PATH) +
                    " and " + DNSSEC_PATH +
                    ", comment any explicit DNSSEC= in /etc/systemd/resolved.conf, "
                    "strip DNSSEC= from sibling drop-ins, enable systemd-resolved");
        return;
    }
    if (!sh::sudo_warmup()) {
        ui::err("sudo cache cold — `sudo -v` first");
        return;
    }

    if (!write_root_file(DOH_PATH, DOH_BODY)) {
        ui::err("could not install " + std::string(DOH_PATH));
        return;
    }
    ui::ok("wrote " + std::string(DOH_PATH));

    if (!write_root_file(DNSSEC_PATH, DNSSEC_BODY)) {
        ui::warn("could not install " + std::string(DNSSEC_PATH));
    } else {
        ui::ok("wrote " + std::string(DNSSEC_PATH) + " (DNSSEC=allow-downgrade)");
    }

    // Comment any active DNSSEC= line in the main resolved.conf — leaving
    // it set there can override the drop-in in some systemd load orders
    // and cause the v2.4.7 chrony startup deadlock to re-appear.
    sh::run({"sudo", "sed", "-i",
             "s/^\\([[:space:]]*\\)DNSSEC=/\\1#DNSSEC=/",
             "/etc/systemd/resolved.conf"});

    // Strip DNSSEC= from sibling drop-ins so 00-foxml-dnssec.conf is the
    // single source of truth (foxml-doh.conf body above intentionally
    // does NOT include a DNSSEC= line for this reason).
    sh::run({"sh", "-c",
             "for f in /etc/systemd/resolved.conf.d/*.conf; do "
             "  case \"$f\" in *00-foxml-dnssec.conf) continue ;; esac; "
             "  if sudo grep -q '^DNSSEC=' \"$f\" 2>/dev/null; then "
             "    sudo sed -i '/^DNSSEC=/d' \"$f\"; "
             "  fi; "
             "done"});

    if (sh::systemctl_enable("systemd-resolved", /*user=*/false) != 0) {
        ui::warn("systemd-resolved enable failed — re-run after `sudo -v`");
        return;
    }

    if (!fs::is_symlink("/etc/resolv.conf")) {
        sh::run({"sudo", "ln", "-rsf",
                 "/run/systemd/resolve/stub-resolv.conf", "/etc/resolv.conf"});
        ui::ok("linked /etc/resolv.conf → stub-resolv.conf");
    }

    ui::ok("DoH + DNSSEC=allow-downgrade active");
}

}  // namespace fox_install
