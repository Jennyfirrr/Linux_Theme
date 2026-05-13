// modules/amd_gpu.cpp — AMD GPU userspace.
//
// install.sh adds vulkan-radeon + libva-mesa-driver + mesa-vdpau to its
// pacman list when --amd is passed (or auto-detected). No kernel module
// changes (mesa already ships with the kernel-side bits). Safe to run
// alongside any other GPU module.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

namespace fox_install {

void run_amd_gpu(Context& ctx) {
    ui::section("AMD GPU userspace (Vulkan + VA-API)");
    if (!ctx.has_amd_gpu) {
        ui::warn("no AMD GPU detected — skipping (re-run with --amd to force)");
    }
    if (!sh::dry_run() && !sh::sudo_warmup()) {
        ui::err("sudo cache cold — `sudo -v` first");
        return;
    }
    int rc = sh::pacman({"vulkan-radeon", "libva-mesa-driver", "mesa-vdpau"});
    if (rc == 0) ui::ok("AMD userspace stack installed");
    else         ui::warn("pacman failed — packages may be partial");
}

}  // namespace fox_install
