// modules/deps.cpp — base package install.
//
// Mirrors install.sh's PACMAN_PKGS list (the base set; per-module deps
// like fail2ban/audit/lynis live in their own modules and get added
// when that module is enabled). Idempotent under `pacman --needed`.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <fstream>
#include <string>
#include <vector>

namespace fox_install {

void run_deps(Context& ctx) {
    (void)ctx;
    ui::section("Installing base packages");

    if (!sh::dry_run() && !sh::sudo_warmup()) {
        ui::err("sudo cache cold and no TTY — run `sudo -v` first");
        return;
    }

    // Grouped by purpose so future contributors can find the right
    // bucket. pacman --needed makes order and duplicates safe.
    const std::vector<std::string> pkgs = {
        // Fonts
        "ttf-hack-nerd", "ttf-jetbrains-mono-nerd",
        "noto-fonts", "noto-fonts-cjk", "noto-fonts-emoji",

        // Compositor, lock, wallpaper, idle
        "hyprland", "hyprlock", "awww", "hypridle",
        // Themed login
        "greetd", "greetd-regreet",

        // Secrets / keyring
        "gnome-keyring", "libsecret", "seahorse", "gnupg",

        // Editor / terminal / multiplexer
        "neovim", "kitty", "tmux",

        // Neovim runtime deps (Copilot LSP, Mason, tree-sitter latex grammar)
        "nodejs", "npm", "tree-sitter-cli",

        // Bar, launcher, notifications
        "waybar", "rofi-wayland", "mako", "dunst",

        // Build tools
        "cmake", "base-devel",

        // CLI tools
        "zsh", "fzf", "eza", "bat", "yazi", "btop", "fd", "zoxide",
        "jq", "git-delta", "github-cli", "pacman-contrib",
        "rofi-calc", "rofi-emoji", "lazygit", "ncspot", "cliphist",
        "cloc", "tree", "rsync", "shellcheck", "ripgrep",

        // Networking, audio, power telemetry
        "networkmanager", "wireplumber", "libnotify", "upower", "lm_sensors",

        // misc utilities install.sh's later sections rely on
        "unzip",
        "grim", "slurp", "wl-clipboard", "playerctl", "brightnessctl",
        "pavucontrol", "wlsunset", "swappy",

        // Bluetooth
        "bluez", "bluez-utils", "blueman",

        // Fingerprint
        "fprintd",

        // Apps + viewers
        "firefox", "zathura", "zathura-pdf-mupdf", "xdg-utils", "thunar", "steam",

        // Runtime libs commonly pulled by AUR/proprietary packages
        "libutf8proc", "xsimd",

        // Tools
        "hyprpicker", "imagemagick",

        // socat → Hyprland socket2 streaming for legacy bash watchers
        "socat",

        // Power profile switcher
        "power-profiles-daemon", "python-gobject",

        // ufw is always installed; the install_ufw_baseline equivalent
        // lives in the security module but the package is needed even
        // when --secure isn't passed (default-deny inbound).
        "ufw",
    };

    int rc = sh::pacman(pkgs);
    if (rc != 0) {
        ui::err("pacman failed (exit " + std::to_string(rc) + ") — "
                "if it was a dep conflict, run `sudo pacman -Syu` then re-run --deps");
        // Continue to post-install hooks anyway; user may want the
        // service enables / browser config even if a single package
        // refused to install.
    } else {
        ui::ok(std::to_string(pkgs.size()) + " base packages ensured");
    }

    // ─── Post-install hooks ───────────────────────────────────────
    // Things bash did in the same --deps section: enable bluez,
    // power-profiles-daemon, point xdg-open at Firefox. Each is a
    // small command and idempotent — re-runs are cheap no-ops.

    if (!sh::dry_run()) {
        // Default web browser → Firefox (so CLI auth flows like
        // gcloud / gh / oauth helpers actually spawn a browser).
        std::string out;
        if (sh::capture({"sh", "-c", "command -v xdg-settings"}, out) && !out.empty()
            && std::ifstream("/usr/share/applications/firefox.desktop")) {
            if (sh::run({"xdg-settings", "set", "default-web-browser",
                         "firefox.desktop"}) == 0) {
                ui::ok("default browser set to Firefox");
            }
        }

        auto enable_if_installed = [](const std::string& pkg,
                                       const std::string& unit,
                                       const std::string& label) {
            if (sh::run({"sh", "-c", "pacman -Qi " + pkg + " &>/dev/null"}) != 0) return;
            if (sh::run({"systemctl", "is-active", "--quiet", unit}) == 0) return;
            if (sh::run({"sh", "-c",
                         "sudo systemctl enable --now " + unit + " >/dev/null 2>&1"}) == 0) {
                ui::ok(label + " enabled");
            }
        };
        enable_if_installed("power-profiles-daemon", "power-profiles-daemon",
                            "power-profiles-daemon");
        enable_if_installed("bluez", "bluetooth", "bluetooth service");
    }
}

}  // namespace fox_install
