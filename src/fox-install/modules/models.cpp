// modules/models.cpp — pull a tier-appropriate Ollama model stack.
//
// install.sh has its own bash hardware tiering in fox-hw-info; we
// inline a minimal RAM+VRAM tier picker here so the C++ orchestrator
// doesn't shell out to a bash helper. Logic intentionally matches
// install.sh's case "$TIER" block so users get the same model set.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <algorithm>
#include <filesystem>
#include <fstream>
#include <string>
#include <sys/statvfs.h>
#include <vector>

namespace fs = std::filesystem;

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

std::vector<std::string> discover_custom_models(const Context& ctx) {
    std::vector<std::string> out;
    std::vector<fs::path> candidates;

    // 1. ~/.config/foxml/models.private (one-off local overrides)
    candidates.push_back(ctx.config_home / "foxml" / "models.private");

    // 2. ~/code/*/foxml-models.txt (private repository discovery)
    fs::path code_dir = ctx.home / "code";
    std::error_code ec;
    if (fs::is_directory(code_dir, ec)) {
        for (const auto& entry : fs::directory_iterator(code_dir, ec)) {
            if (entry.is_directory()) {
                candidates.push_back(entry.path() / "foxml-models.txt");
            }
        }
    }

    for (const auto& p : candidates) {
        if (!fs::exists(p, ec)) continue;
        std::ifstream f(p);
        std::string line;
        while (std::getline(f, line)) {
            // Trim whitespace
            line.erase(0, line.find_first_not_of(" \t\r\n"));
            auto last = line.find_last_not_of(" \t\r\n");
            if (last != std::string::npos) line.erase(last + 1);

            if (line.empty() || line[0] == '#') continue;
            out.push_back(line);
        }
    }
    return out;
}

}  // namespace

// Returns $HOME free space in GB, or -1 if statvfs fails.
long home_free_gb(const Context& ctx) {
    struct statvfs vfs{};
    if (::statvfs(ctx.home.c_str(), &vfs) != 0) return -1;
    return static_cast<long>((vfs.f_bavail * vfs.f_bsize) / (1024L * 1024L * 1024L));
}

void run_models(Context& ctx) {
    ui::section("Pulling Ollama model stack");

    // Disk-space gate: bash auto-disabled --models when $HOME had less
    // than 25 GB free (qwen2.5-coder:32b alone is ~20 GB, plus the
    // chat sibling and intermediate sizes). Skip cleanly with a clear
    // message rather than letting `ollama pull` half-finish and leave
    // a partial model on disk.
    long free_gb = home_free_gb(ctx);
    if (free_gb >= 0 && free_gb < 25) {
        ui::warn("$HOME has only " + std::to_string(free_gb) +
                 " GB free — models module needs 25+ GB. Skipping.");
        ui::substep("free space then re-run: fox-install --only models");
        return;
    }

    int ram  = read_ram_gb();
    int vram = read_vram_gb();
    std::string tier = pick_tier(ram, vram);
    ui::ok("RAM: " + std::to_string(ram) + "GB, VRAM: " +
           std::to_string(vram) + "GB — tier: " + tier);

    auto models = models_for(tier);
    auto custom = discover_custom_models(ctx);
    if (!custom.empty()) {
        ui::ok("discovered " + std::to_string(custom.size()) + " custom models");
        models.insert(models.end(), custom.begin(), custom.end());
    }

    // Uniquify
    std::sort(models.begin(), models.end());
    models.erase(std::unique(models.begin(), models.end()), models.end());

    for (const auto& m : models) {
        ui::substep("pulling " + m);
        if (sh::run({"ollama", "pull", m}) != 0) {
            ui::warn("pull failed: " + m + " — retry with `ollama pull " + m + "`");
        }
    }
    ui::ok(std::to_string(models.size()) + " models requested");
}

}  // namespace fox_install
