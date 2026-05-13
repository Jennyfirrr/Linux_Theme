#include "args.hpp"

#include "module.hpp"
#include "ui.hpp"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

namespace fox_install::args {

namespace {

// Look up a module by its slug. Returns SIZE_MAX if no match.
std::size_t find_by_slug(const std::string& slug) {
    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        if (slug == MODULES[i].slug) return i;
    }
    return SIZE_MAX;
}

// Look up a module by its `--foo` flag. Returns SIZE_MAX if no match.
std::size_t find_by_flag(const std::string& flag) {
    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        if (flag == MODULES[i].flag) return i;
    }
    return SIZE_MAX;
}

// Look up a module by its negated form. Accepts both:
//   * --no-<flag-tail>  e.g. --no-mac-random  (matches MODULES[].flag)
//   * --no-<slug>       e.g. --no-mac_random  (matches MODULES[].slug)
// The flag form is the user-facing convention (hyphens); the slug form
// (underscores) is the internal name. Either works.
std::size_t find_by_no_slug(const std::string& flag) {
    if (flag.rfind("--no-", 0) != 0) return SIZE_MAX;
    std::string tail = flag.substr(5);
    std::string reconstructed_flag = "--" + tail;
    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        if (reconstructed_flag == MODULES[i].flag) return i;
        if (tail == MODULES[i].slug) return i;
    }
    return SIZE_MAX;
}

}  // namespace

void print_help(const char* argv0) {
    std::printf(
        "fox-install — FoxML Theme Hub installer (C++ orchestrator)\n\n"
        "Usage: %s [theme] [flags]\n\n"
        "Global flags:\n"
        "  -y, --yes         assume yes for every prompt (disables wizard)\n"
        "      --resume      resume from the last successful module\n"
        "      --phase <s.>  skip ahead to a specific module slug\n"
        "      --dry-run     print every command without executing it\n"
        "      --full        enable every registered module + every sub-toggle\n"
        "                    (polkit-strict, cpp-pro). Use --no-<slug> to exclude\n"
        "                    individual modules (e.g. --full --no-mac-random).\n"
        "      --quick       skip slow + network-heavy parts (deps, github, models)\n"
        "      --only <slugs> comma-separated allow-list; everything else skipped\n"
        "      --polkit-strict   add polkit strict mode (every GUI sudo re-prompts)\n"
        "      --cpp-pro     C++ toolchain extras (clang/lldb/mold/perf/etc)\n"
        "      --arm, --paranoid chain into fox-arm at end of install\n"
        "      --arm-heavy, --heavy   ditto, runs fox-arm --heavy\n"
        "      --quiet       suppress per-step chatter (errors still print)\n"
        "  -h, --help        show this help and exit\n"
        "      --version     print version and exit\n\n"
        "Modules (default-on shown with *):\n",
        argv0);
    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        const Module& m = MODULES[i];
        std::printf("  %s %-14s %s  %s\n",
                    m.default_on ? "*" : " ",
                    m.flag, m.slug, m.description);
    }
    std::printf(
        "\nDisable a default module with --no-<slug>, e.g. --no-render.\n");
}

void print_version() {
    std::printf("fox-install 0.1.0 (orchestrator skeleton)\n");
}

bool parse(int argc, char** argv, Parsed& out, Context& ctx) {
    out.module_enabled.assign(MODULES_COUNT, false);
    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        out.module_enabled[i] = MODULES[i].default_on;
    }

    for (int i = 1; i < argc; ++i) {
        std::string a = argv[i];

        if (a == "-h" || a == "--help")    { out.show_help = true;    continue; }
        if (a == "--version")              { out.show_version = true; continue; }
        if (a == "-y" || a == "--yes")     { ctx.assume_yes = true;   continue; }
        if (a == "--resume")               { out.resume = true;       continue; }
        if (a == "--dry-run")              { ctx.dry_run = true;      continue; }
        if (a == "--quiet")                { ctx.quiet = true; out.quiet = true; continue; }

        if (a == "--phase" && i + 1 < argc) {
            out.phase = argv[++i];
            continue;
        }

        if (a == "--cpp-pro") {
            ctx.cpp_pro = true;
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                if (std::string(MODULES[k].slug) == "cpp_pro") {
                    out.module_enabled[k] = true;
                    break;
                }
            }
            continue;
        }

        if (a == "--full" || a == "--all") {
            out.full = true;
            // --full means FULL. Every registered module is enabled,
            // every fine-grained sub-toggle (install_polkit_strict,
            // cpp_pro) is flipped on. The user opts out of specific
            // modules with --no-<slug>, e.g.
            //   ./install.sh --full --yes --no-mac-random --no-fprint-pam
            //
            // Hardware-gated modules (nvidia/amd_gpu/intel_gpu/fprint)
            // still bail internally when ctx.has_* is false, so enabling
            // them here on hardware-less boxes is a cheap no-op.
            //
            // Interactive wizards (throttling, ssh_harden, monitors)
            // honor ctx.assume_yes — --full --yes runs them
            // non-interactively with sane defaults.
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                out.module_enabled[k] = true;
            }
            ctx.install_polkit_strict = true;
            ctx.cpp_pro = true;
            ctx.force_reapply = true;
            continue;
        }

        // --paranoid: bash alias for --arm. Both flip the env var that
        // next_steps.cpp reads to chain into `fox-arm` at end-of-install.
        if (a == "--arm" || a == "--paranoid") {
            ::setenv("FOXML_ARM", "1", 1);
            continue;
        }
        if (a == "--arm-heavy" || a == "--heavy") {
            ::setenv("FOXML_ARM", "1", 1);
            ::setenv("FOXML_ARM_HEAVY", "1", 1);
            continue;
        }

        // --polkit-strict: enable the security module's polkit-strict
        // sub-step (off by default, NOT included in --full per above).
        if (a == "--polkit-strict") {
            ctx.install_polkit_strict = true;
            continue;
        }

        // --quick: bash mode that skips the slow + network-heavy parts
        // (pacman --needed sweep, github clone, ollama model pulls)
        // when re-running just to refresh themes/configs.
        if (a == "--quick") {
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                std::string s = MODULES[k].slug;
                if (s == "deps" || s == "github" || s == "models") {
                    out.module_enabled[k] = false;
                }
            }
            continue;
        }

        // --render-only: bash had it. Run render + symlinks + specials +
        // personalize + post_install only — everything else off. Useful
        // for "just push the rendered configs out, don't touch system".
        if (a == "--render-only") {
            static const char* KEEP[] = {
                "detect", "preflight", "theme",
                "render", "symlinks", "specials",
                "personalize", "post_install", "summary", nullptr,
            };
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                out.module_enabled[k] = false;
            }
            for (auto** s = KEEP; *s; ++s) {
                for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                    if (std::string(MODULES[k].slug) == *s) {
                        out.module_enabled[k] = true;
                        break;
                    }
                }
            }
            continue;
        }

        // --only <slug>[,<slug>...]  → disable every module except the
        // listed ones. Used by fox-pulse handlers and any other caller
        // that wants a focused partial run (e.g.
        // `fox-install --only monitors,personalize --yes` on Hyprland
        // monitor hot-swap).
        if (a == "--only" && i + 1 < argc) {
            std::string list = argv[++i];
            // Reset all modules to disabled, then enable the requested
            // ones by slug.
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                out.module_enabled[k] = false;
            }
            std::size_t pos = 0;
            while (pos <= list.size()) {
                std::size_t comma = list.find(',', pos);
                std::string slug = list.substr(
                    pos, comma == std::string::npos ? std::string::npos : comma - pos);
                if (!slug.empty()) {
                    bool found = false;
                    for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                        if (slug == MODULES[k].slug) {
                            out.module_enabled[k] = true;
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        std::fprintf(stderr,
                            "fox-install: --only: unknown slug '%s'\n", slug.c_str());
                        return false;
                    }
                }
                if (comma == std::string::npos) break;
                pos = comma + 1;
            }
            continue;
        }

        std::size_t idx = find_by_flag(a);
        if (idx != SIZE_MAX) { out.module_enabled[idx] = true; continue; }

        idx = find_by_no_slug(a);
        if (idx != SIZE_MAX) { out.module_enabled[idx] = false; continue; }

        // Positional: first non-flag token is the theme name.
        if (!a.empty() && a[0] != '-') {
            if (ctx.theme_name.empty()) { ctx.theme_name = a; continue; }
        }

        std::fprintf(stderr, "fox-install: unknown argument: %s\n", a.c_str());
        return false;
    }
    return true;
}

void run_full_review_wizard(Parsed& out, Context& ctx) {
    if (ctx.assume_yes || !ui::tty()) return;

    ui::section("--full review: every module is selectable");
    std::printf(
        "  Default is YES for each module. Press Enter to accept, n to skip.\n"
        "  Lockout-risk modules (fprint_pam, greetd_fingerprint) default to\n"
        "  NO even under --full — opt in only if you know the recovery path\n"
        "  (su -, faillock --reset, restore .foxml-bak).\n\n");

    // Backbone modules always run — no prompt.
    static const char* BACKBONE[] = {
        "detect", "preflight", "theme",
        "render", "symlinks", "specials",
        "post_install", "summary", "next_steps",
        nullptr,
    };
    auto is_in = [](const char* slug, const char* const* list) -> bool {
        for (const char* const* s = list; *s; ++s) {
            if (std::string(*s) == slug) return true;
        }
        return false;
    };

    // Default-N modules: lockout-risk PAM edits.
    static const char* DEFAULT_NO[] = {
        "fprint_pam", "greetd_fingerprint", nullptr,
    };

    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        const char* slug = MODULES[i].slug;
        if (is_in(slug, BACKBONE)) continue;

        bool risky = is_in(slug, DEFAULT_NO);
        std::string warning = risky ? " [LOCKOUT RISK]" : "";
        std::string prompt = "  • " + std::string(slug) + warning + " — " +
                             MODULES[i].description + "?";
        out.module_enabled[i] = ui::ask_yn(prompt, /*default_yes=*/!risky,
                                           /*assume_yes=*/false);
    }

    // Sub-flag inside the security module: polkit-strict.
    ctx.install_polkit_strict = ui::ask_yn(
        "  • polkit-strict (every GUI sudo re-prompts — annoying for daily use)?",
        /*default_yes=*/true, /*assume_yes=*/false);
    // cpp_pro is its own module — already covered by the loop above. Keep
    // ctx.cpp_pro in sync with the user's choice on the module prompt so
    // post-install hooks that read ctx.cpp_pro see the right state.
    for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
        if (std::string(MODULES[k].slug) == "cpp_pro") {
            ctx.cpp_pro = out.module_enabled[k];
            break;
        }
    }

    std::printf("\n");
}

void run_wizard(Parsed& out, Context& ctx) {
    if (ctx.assume_yes || !ui::tty()) return;

    ui::section("Interactive Wizard: Opt-in Modules");
    std::printf("  You can opt into extra security, AI models, and dev tools below.\n"
                "  Default-on modules are already queued (use --no-<slug> to skip them).\n\n");

    auto ask = [&](const std::string& slug, const std::string& desc, bool& flag_out) {
        std::size_t idx = find_by_slug(slug);
        if (idx == SIZE_MAX) return;
        // If already enabled by flag, don't ask.
        if (out.module_enabled[idx]) return;

        if (ui::ask_yn("  • " + slug + " (" + desc + ")?", false, false)) {
            out.module_enabled[idx] = true;
            flag_out = true;
        }
    };

    // Group 1: Core Security
    std::printf("  [ Security & Privacy ]\n");
    bool dummy = false;
    ask("noexec_tmp", "mount /tmp and /dev/shm with noexec", dummy);
    ask("iommu",      "IOMMU + kernel lockdown=integrity", dummy);
    ask("mac_random", "Randomize MAC addresses on every connection", dummy);
    if (!ctx.install_polkit_strict) {
        if (ui::ask_yn("  • polkit-strict (every GUI sudo re-prompts)?", false, false)) {
            ctx.install_polkit_strict = true;
        }
    }

    // Group 2: Productivity & AI
    std::printf("\n  [ Productivity & AI ]\n");
    ask("vault",      "fox-vault: systemd user service for encrypted secrets", dummy);
    ask("ai",         "Ollama + OpenCode local LLM stack", dummy);
    ask("models",     "Pull tier-appropriate Ollama chat/coder models", dummy);
    ask("github",     "Clone workspace repos + gh CLI auth", dummy);

    // Group 3: Hardware & Power
    std::printf("\n  [ Hardware & Services ]\n");
    ask("throttling", "CPU power management / thermal wizard", dummy);
    ask("fprint",     "Fingerprint reader support (fprintd)", dummy);
    ask("ssh_harden", "SSH hardening wizard (custom port + keys only)", dummy);
    ask("endlessh",   "SSH tarpit on port 22", dummy);

    // Group 4: Dev Extras
    std::printf("\n  [ Development Extras ]\n");
    ask("xgboost",    "Build XGBoost from source (5-10 min)", dummy);
    if (!ctx.cpp_pro) {
        if (ui::ask_yn("  • cpp-pro (clang/lldb/mold/perf/valgrind)?", false, false)) {
            ctx.cpp_pro = true;
            std::size_t idx = find_by_slug("cpp_pro");
            if (idx != SIZE_MAX) out.module_enabled[idx] = true;
        }
    }
    std::printf("\n");
}

}  // namespace fox_install::args
