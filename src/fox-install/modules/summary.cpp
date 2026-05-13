// modules/summary.cpp — end-of-install summary report.
//
// Always runs last (registered at the end of modules.def). Prints a
// pacman-style block of "what got configured" so the user sees a clean
// recap regardless of how many other modules ran. Bash's equivalent
// listed each detected monitor with its WxH and the wallpaper count;
// this native version reads the monitor-layout sidecar + .wallpapers/
// dir to reproduce those rows.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/sidecar.hpp"
#include "../core/ui.hpp"

#include <filesystem>
#include <string>

namespace fs = std::filesystem;

namespace fox_install {

namespace {

std::size_t count_wallpapers(const fs::path& wall_dir) {
    std::error_code ec;
    if (!fs::is_directory(wall_dir, ec)) return 0;
    std::size_t n = 0;
    for (auto& e : fs::directory_iterator(wall_dir, ec)) {
        if (!e.is_regular_file()) continue;
        std::string ext = e.path().extension().string();
        for (auto& c : ext) c = std::tolower(static_cast<unsigned char>(c));
        if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".webp") {
            ++n;
        }
    }
    return n;
}

}  // namespace

void run_summary(Context& ctx) {
    ui::section("Installation summary");
    ui::summary_row("theme",        ctx.theme_name);
    ui::summary_row("script_dir",   ctx.script_dir.string());
    ui::summary_row("rendered_dir", ctx.rendered_dir.string());
    ui::summary_row("config_home",  ctx.config_home.string());

    std::string hw;
    if (ctx.has_nvidia)    hw += "NVIDIA ";
    if (ctx.has_amd_gpu)   hw += "AMD ";
    if (ctx.has_intel_gpu) hw += "Intel ";
    if (hw.empty())        hw = "(none detected)";
    ui::summary_row("gpu",       hw);
    ui::summary_row("chassis",   ctx.is_laptop ? "laptop" : "desktop");
    if (ctx.has_fprint) ui::summary_row("fingerprint", "present");

    // Per-monitor enumeration — bash listed each entry from
    // MONITOR_RESOLUTIONS. Sidecar is the source of truth post-install.
    fs::path layout_path = ctx.config_home / "foxml/monitor-layout.conf";
    auto layout = sidecar::read(layout_path);
    if (!layout.primary.empty()) {
        ui::summary_row("primary monitor", layout.primary);
    }
    if (!layout.monitor_resolutions.empty()) {
        std::string row = std::to_string(layout.monitor_resolutions.size()) + " (";
        for (std::size_t i = 0; i < layout.monitor_resolutions.size(); ++i) {
            if (i > 0) row += ", ";
            row += layout.monitor_resolutions[i];
        }
        row += ")";
        ui::summary_row("monitors", row);
    }
    if (!layout.portrait_outputs.empty()) {
        std::string row;
        for (std::size_t i = 0; i < layout.portrait_outputs.size(); ++i) {
            if (i > 0) row += " ";
            row += layout.portrait_outputs[i];
        }
        ui::summary_row("portrait", row);
    }

    // Wallpaper count.
    std::size_t w = count_wallpapers(ctx.home / ".wallpapers");
    if (w > 0) ui::summary_row("wallpapers", std::to_string(w) + " file(s)");

    if (ctx.dry_run) {
        ui::substep("dry-run: no changes were applied");
    }
}

}  // namespace fox_install
