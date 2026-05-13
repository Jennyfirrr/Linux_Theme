// modules/summary.cpp — end-of-install summary report.
//
// Always runs last (registered at the end of modules.def). Prints a
// pacman-style block of "what got configured" so the user sees a clean
// recap regardless of how many other modules ran.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <string>

namespace fox_install {

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

    if (ctx.dry_run) {
        ui::substep("dry-run: no changes were applied");
    }
}

}  // namespace fox_install
