// modules/preflight.cpp — fail fast on hard problems.
//
// Mirrors install.sh's pre-flight checks: disk space at $HOME and /,
// outbound network reachable, no obviously-conflicting WM/DE running.
// Soft warnings only — never aborts; the user can override by re-running.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <cstdlib>
#include <string>
#include <sys/statvfs.h>

namespace fox_install {

namespace {

long free_mb(const char* path) {
    struct statvfs vfs{};
    if (::statvfs(path, &vfs) != 0) return -1;
    return static_cast<long>((vfs.f_bavail * vfs.f_bsize) / (1024 * 1024));
}

bool can_reach_internet() {
    return sh::run({"curl", "-sf", "-m", "5", "-o", "/dev/null",
                    "https://archlinux.org/"}) == 0;
}

}  // namespace

void run_preflight(Context& ctx) {
    ui::section("Pre-flight checks");

    long home_mb = free_mb(ctx.home.c_str());
    long root_mb = free_mb("/");
    if (home_mb >= 0) ui::summary_row("$HOME free", std::to_string(home_mb) + " MB");
    if (root_mb >= 0) ui::summary_row("/ free",     std::to_string(root_mb) + " MB");

    if (home_mb >= 0 && home_mb < 2048) {
        ui::warn("$HOME has <2 GB free — installs that pull AI models may fail");
    }
    if (root_mb >= 0 && root_mb < 512) {
        ui::warn("/ has <512 MB free — pacman installs may fail");
    }

    if (sh::dry_run()) {
        ui::substep("[dry-run] skipping connectivity probe");
    } else if (can_reach_internet()) {
        ui::ok("network reachable");
    } else {
        ui::warn("can't reach archlinux.org — offline? pacman + AUR steps will fail");
    }

    // Conflicting session-leader hint. Not fatal — many users dual-boot
    // Hyprland and another WM intentionally.
    const char* desktop = std::getenv("XDG_CURRENT_DESKTOP");
    if (desktop && std::string(desktop).find("Hyprland") == std::string::npos
                && *desktop != '\0') {
        ui::warn(std::string("current session is `") + desktop +
                 "` — Hyprland-specific steps will succeed but apply on next login");
    }

    // Installed WM/DE coexistence check via pacman -Qi. Catches the
    // installed-but-not-active case that the XDG_CURRENT_DESKTOP check
    // above misses (e.g. plasma-desktop installed alongside Hyprland —
    // configs coexist fine but Hyprland binds only apply inside a
    // Hyprland session). Mirrors install.sh.legacy's preflight.
    static const char* WM_PKGS[][2] = {
        {"plasma-desktop", "KDE Plasma"},
        {"gnome-shell",    "GNOME"},
        {"sway",           "sway"},
        {"i3-wm",          "i3"},
        {"xfce4-session",  "XFCE"},
        {nullptr, nullptr},
    };
    std::string conflicts;
    for (auto* pair : WM_PKGS) {
        if (!pair[0]) break;
        if (sh::run({"sh", "-c",
                     std::string("pacman -Qi ") + pair[0] + " &>/dev/null"}) == 0) {
            if (!conflicts.empty()) conflicts += ", ";
            conflicts += pair[1];
        }
    }
    if (!conflicts.empty()) {
        ui::warn("another desktop / WM installed: " + conflicts);
        ui::substep("configs coexist; Hyprland binds only apply inside a Hyprland session");
    }
}

}  // namespace fox_install
