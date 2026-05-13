// modules/detect.cpp — hardware auto-detect.
//
// Walks /sys/, lspci (where present), and the chassis DMI to fill the
// hardware flags on Context. Read-only, fast, no privileges needed.
// Other modules (nvidia/amd/intel/fprint/laptop) gate on these.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <cctype>
#include <filesystem>
#include <fstream>
#include <string>

namespace fs = std::filesystem;

namespace fox_install {

namespace {

std::string lower(std::string s) {
    for (auto& c : s) c = std::tolower(static_cast<unsigned char>(c));
    return s;
}

bool lspci_has(const std::string& needle_lower) {
    std::string out;
    if (!sh::capture({"lspci"}, out)) return false;
    return lower(out).find(needle_lower) != std::string::npos;
}

bool laptop_via_dmi() {
    // /sys/class/dmi/id/chassis_type values: 8=Portable, 9=Laptop,
    // 10=Notebook, 14=Sub-Notebook. Anything in that range = laptop.
    std::ifstream f("/sys/class/dmi/id/chassis_type");
    int code = 0;
    if (!(f >> code)) return false;
    return code == 8 || code == 9 || code == 10 || code == 14;
}

bool fprint_via_lsusb() {
    // Common fingerprint reader vendor IDs. Matches what install.sh's
    // bash detect does — Synaptics, Goodix, Validity, Elan, AuthenTec.
    static const char* VENDORS[] = {
        "06cb", "27c6", "138a", "04f3", "08ff", nullptr,
    };
    std::string out;
    if (!sh::capture({"lsusb"}, out)) return false;
    std::string low = lower(out);
    for (auto** v = VENDORS; *v; ++v) {
        if (low.find(std::string("id ") + *v) != std::string::npos) return true;
    }
    return false;
}

}  // namespace

void run_detect(Context& ctx) {
    ui::section("Detecting hardware");

    ctx.has_nvidia    = lspci_has("nvidia");
    ctx.has_amd_gpu   = lspci_has("amd/ati") || lspci_has("radeon");
    ctx.has_intel_gpu = lspci_has("intel corporation") &&
                       (lspci_has("graphics") || lspci_has("vga"));
    ctx.is_laptop     = laptop_via_dmi();
    ctx.has_fprint    = ctx.is_laptop && fprint_via_lsusb();

    ui::ok(std::string("GPU: ") +
           (ctx.has_nvidia ? "NVIDIA " : "") +
           (ctx.has_amd_gpu ? "AMD " : "") +
           (ctx.has_intel_gpu ? "Intel " : "") +
           ((!ctx.has_nvidia && !ctx.has_amd_gpu && !ctx.has_intel_gpu) ? "(none detected)" : ""));
    ui::ok(std::string("Chassis: ") + (ctx.is_laptop ? "laptop" : "desktop"));
    if (ctx.has_fprint) ui::ok("Fingerprint reader present");
}

}  // namespace fox_install
