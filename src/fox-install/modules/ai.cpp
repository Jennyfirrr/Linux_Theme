// modules/ai.cpp — Ollama + OpenCode install (no models).
//
// Mirrors install.sh's --ai block:
//   1. Install Ollama (AUR signature-verified via yay/paru, fallback to
//      curl|sh only if no AUR helper is present).
//   2. Ensure ollama.service is enabled and the HTTP endpoint is up.
//   3. Pull nomic-embed-text (the embedding model libfox-intel depends
//      on for RAG; pulling it here so every fox-* AI tool can rely on
//      it being present).
//   4. Install OpenCode (AUR-first, same fallback).
//
// Models module (--models) is separate so users can pull big stuff
// independently of getting ollama running.

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <string>
#include <thread>
#include <chrono>

namespace fox_install {

namespace {

std::string aur_helper() {
    std::string out;
    if (sh::capture({"sh", "-c", "command -v yay"}, out) && !out.empty())  return "yay";
    if (sh::capture({"sh", "-c", "command -v paru"}, out) && !out.empty()) return "paru";
    return {};
}

bool have(const std::string& bin) {
    std::string out;
    return sh::capture({"sh", "-c", "command -v " + bin}, out) && !out.empty();
}

void install_via_aur_or_script(const std::string& aur_pkg,
                               const std::string& fallback_url,
                               const std::string& fallback_interp) {
    std::string aur = aur_helper();
    if (!aur.empty()) {
        if (sh::run({aur, "-S", "--needed", "--noconfirm", aur_pkg}) == 0) return;
        ui::warn("AUR install of " + aur_pkg + " failed, falling back to upstream script");
    } else {
        ui::substep("no AUR helper on PATH — using upstream installer");
    }
    // Falling back to curl | <interp>.
    sh::run({"sh", "-c",
             "curl -fsSL " + fallback_url + " | " + fallback_interp});
}

void wait_for_http(const std::string& url, int max_attempts, int sleep_ms) {
    for (int i = 0; i < max_attempts; ++i) {
        if (sh::run({"curl", "-sf", "-m", "1", "-o", "/dev/null", url.c_str()}) == 0) return;
        std::this_thread::sleep_for(std::chrono::milliseconds(sleep_ms));
    }
}

}  // namespace

void run_ai(Context& ctx) {
    (void)ctx;
    ui::section("Installing AI tooling (Ollama + OpenCode)");

    if (!sh::dry_run() && !sh::sudo_warmup()) {
        ui::err("sudo cache cold — `sudo -v` first");
        return;
    }

    // 1. Ollama
    if (have("ollama")) {
        ui::ok("Ollama already installed");
    } else {
        ui::substep("installing Ollama");
        install_via_aur_or_script("ollama-bin",
            "https://ollama.com/install.sh", "sh");
    }

    // 2. Daemon up + HTTP endpoint reachable
    if (!sh::dry_run()) {
        std::string out;
        bool active = sh::capture({"systemctl", "is-active", "--quiet", "ollama"}, out);
        if (!active) {
            if (sh::systemctl_enable("ollama", /*user=*/false) == 0) {
                wait_for_http("http://127.0.0.1:11434/", 50, 200);
                ui::ok("ollama.service started");
            } else {
                ui::warn("could not enable ollama via systemd — start it manually");
            }
        } else {
            ui::ok("ollama.service already active");
        }
    }

    // 3. Embedding model (libfox-intel RAG dep)
    ui::substep("pulling nomic-embed-text (embedding model)");
    for (int attempt = 1; attempt <= 3; ++attempt) {
        if (sh::run({"ollama", "pull", "nomic-embed-text"}) == 0) break;
        if (attempt == 3) {
            ui::warn("nomic-embed-text pull failed after 3 attempts — retry: `ollama pull nomic-embed-text`");
            break;
        }
        ui::substep("retrying in 3s (attempt " + std::to_string(attempt + 1) + "/3)");
        std::this_thread::sleep_for(std::chrono::seconds(3));
    }

    // 4. OpenCode (chat-style CLI client that uses Ollama)
    if (have("opencode")) {
        ui::ok("OpenCode already installed");
    } else {
        ui::substep("installing OpenCode");
        install_via_aur_or_script("opencode-bin",
            "https://opencode.ai/install", "bash");
    }

    ui::ok("AI tooling ready");
}

}  // namespace fox_install
