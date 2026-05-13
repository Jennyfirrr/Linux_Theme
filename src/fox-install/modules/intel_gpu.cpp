// modules/intel_gpu.cpp — Intel GPU userspace.
//
// VA-API drivers + Vulkan ICD. Mesa already ships the kernel-side i915
// bits, so no kernel module work needed.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

namespace fox_install {

void run_intel_gpu(Context& ctx) {
    ui::section("Intel GPU userspace (Vulkan + VA-API)");
    if (!ctx.has_intel_gpu) {
        ui::warn("no Intel GPU detected — skipping (re-run with --intel to force)");
    }
    if (!sh::dry_run() && !sh::sudo_warmup()) {
        ui::err("sudo cache cold — `sudo -v` first");
        return;
    }
    int rc = sh::pacman({"intel-media-driver", "libva-intel-driver", "vulkan-intel"});
    if (rc == 0) ui::ok("Intel userspace stack installed");
    else         ui::warn("pacman failed — packages may be partial");
}

}  // namespace fox_install
