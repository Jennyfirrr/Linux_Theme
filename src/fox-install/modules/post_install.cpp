// modules/post_install.cpp — final live-apply step (runs last by design).
//
// Mirrors install.sh.legacy::apply_post_install:
//   * Restart waybar + dunst if currently running so the new palette
//     loads without a fresh login.
//   * Nvim Lazy + treesitter sync (60s / 120s timeouts to avoid hangs).
//   * Cursor / VS Code: jq-merge workbench.colorTheme="Fox ML".
//
// Hyprland reload is intentionally NOT triggered (legacy comment: avoids
// breaking portrait monitor configurations during install testing).

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include "../../fox-intel/json.hpp"

#include <cstdlib>
#include <filesystem>
#include <fstream>

namespace fs = std::filesystem;
using json   = nlohmann::json;

namespace fox_install {

namespace {

bool have(const std::string& bin) {
    std::string out;
    return sh::capture({"sh", "-c", "command -v " + bin}, out) && !out.empty();
}

bool process_running(const std::string& name) {
    return sh::run({"sh", "-c", "pgrep -x " + name + " >/dev/null 2>&1"}) == 0;
}

void restart_detached(const std::string& killname, const std::string& spawn_cmd) {
    sh::run({"sh", "-c", "pkill -x " + killname + " 2>/dev/null || true"});
    sh::run({"sh", "-c", "setsid -f " + spawn_cmd + " >/dev/null 2>&1 || true"});
}

void cursor_vscode_set_theme(const Context& ctx) {
    if (!have("jq") && false) return;        // pure-native — no jq dependency
    for (const char* ide : { "Cursor", "Code" }) {
        fs::path root = ctx.config_home / ide;
        fs::path user = root / "User";
        if (!fs::is_directory(root)) continue;
        fs::create_directories(user);
        fs::path settings = user / "settings.json";

        json existing = json::object();
        if (fs::exists(settings)) {
            try {
                std::ifstream f(settings);
                f >> existing;
                if (!existing.is_object()) existing = json::object();
            } catch (...) { existing = json::object(); }
        }
        existing["workbench.colorTheme"] = "Fox ML";
        std::ofstream o(settings);
        o << existing.dump(2);
        ui::ok(std::string(ide) + ": workbench.colorTheme = Fox ML");
    }
}

}  // namespace

void run_post_install(Context& ctx) {
    ui::section("Applying post-install actions");

    if (sh::dry_run()) {
        ui::substep("[dry-run] would: restart waybar+dunst if running, "
                    "Lazy sync + TSUpdateSync (60s/120s caps), "
                    "Cursor/VS Code workbench.colorTheme=Fox ML");
        return;
    }

    // Hyprland reload deliberately skipped (legacy comment about portrait monitor
    // configs). Users wanting it: `hyprctl reload`.
    if (std::getenv("HYPRLAND_INSTANCE_SIGNATURE") && have("hyprctl")) {
        ui::ok("Hyprland reload skipped (run `hyprctl reload` manually if desired)");
    }

    if (process_running("waybar")) {
        fs::path start_waybar = ctx.home / ".config/hypr/scripts/start_waybar.sh";
        if (fs::exists(start_waybar)) {
            restart_detached("waybar", start_waybar.string());
            ui::ok("Waybar restarted");
        }
    }

    if (process_running("dunst")) {
        restart_detached("dunst", "dunst");
        ui::ok("Dunst restarted");
    }

    if (have("nvim") && fs::is_directory(ctx.home / ".local/share/nvim/lazy")) {
        ui::substep("nvim Lazy sync (headless, 60s cap)");
        if (sh::run({"timeout", "60", "nvim", "--headless",
                     "+Lazy! sync", "+qa"}) == 0) {
            ui::ok("Nvim plugins synced");
        } else {
            ui::warn("Lazy sync didn't complete cleanly — run `:Lazy sync` manually");
        }
        if (fs::is_directory(ctx.home / ".local/share/nvim/lazy/nvim-treesitter")) {
            ui::substep("rebuilding treesitter parsers (headless, 120s cap)");
            if (sh::run({"timeout", "120", "nvim", "--headless",
                         "+TSUpdateSync", "+qa"}) == 0) {
                ui::ok("Treesitter parsers rebuilt");
            } else {
                ui::warn("TSUpdateSync didn't complete cleanly — run `:TSUpdateSync` manually");
            }
        }
    }

    cursor_vscode_set_theme(ctx);
}

}  // namespace fox_install
