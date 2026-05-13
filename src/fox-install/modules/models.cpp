// modules/models.cpp — pull a tier-appropriate Ollama model stack.
//
// install.sh has its own bash hardware tiering in fox-hw-info; we
// inline a minimal RAM+VRAM tier picker here so the C++ orchestrator
// doesn't shell out to a bash helper. Logic intentionally matches
// install.sh's case "$TIER" block so users get the same model set.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <fstream>
#include <string>
#include <vector>

namespace fox_install {

namespace {

// MemTotal (KB) → GB, ceiling.
int read_ram_gb() {
    std::ifstream f("/proc/meminfo");
    std::string key;
    long kb = 0;
    while (f >> key) {
        if (key == "MemTotal:") { f >> kb; break; }
    }
    return static_cast<int>((kb + 1024L * 1024L - 1) / (1024L * 1024L));
}

// Best-effort: parse `nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits`.
// Returns 0 when nvidia-smi isn't present (CPU-only / AMD / Intel).
int read_vram_gb() {
    std::string out;
    if (!sh::capture({"nvidia-smi", "--query-gpu=memory.total",
                      "--format=csv,noheader,nounits"}, out)) return 0;
    long mb = std::strtol(out.c_str(), nullptr, 10);
    return static_cast<int>((mb + 1023) / 1024);
}

const char* pick_tier(int ram_gb, int vram_gb) {
    // Same thresholds as install.sh / fox-hw-info.
    if (ram_gb >= 32 && vram_gb >= 16) return "pro";
    if (ram_gb >= 16 && vram_gb >= 8)  return "standard";
    return "lite";
}

std::vector<std::string> models_for(const std::string& tier) {
    if (tier == "lite") {
        return {"qwen2.5:3b", "qwen2.5-coder:1.5b",
                "qwen2.5-coder:3b", "qwen2.5-coder:7b"};
    }
    if (tier == "standard") {
        return {"qwen2.5:7b", "qwen2.5-coder:7b",
                "qwen2.5-coder:14b", "qwen2.5-coder:32b"};
    }
    return {"qwen2.5:14b", "qwen2.5-coder:14b", "qwen2.5-coder:32b"};
}

}  // namespace

void run_models(Context& ctx) {
    (void)ctx;
    ui::section("Pulling Ollama model stack");

    int ram  = read_ram_gb();
    int vram = read_vram_gb();
    std::string tier = pick_tier(ram, vram);
    ui::ok("RAM: " + std::to_string(ram) + "GB, VRAM: " +
           std::to_string(vram) + "GB — tier: " + tier);

    auto models = models_for(tier);
    for (const auto& m : models) {
        ui::substep("pulling " + m);
        if (sh::run({"ollama", "pull", m}) != 0) {
            ui::warn("pull failed: " + m + " — retry with `ollama pull " + m + "`");
        }
    }
    ui::ok(std::to_string(models.size()) + " models requested");
}

}  // namespace fox_install
