#include "args.hpp"

#include "module.hpp"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

namespace fox_install::args {

namespace {

// Look up a module by its `--foo` flag. Returns SIZE_MAX if no match.
std::size_t find_by_flag(const std::string& flag) {
    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        if (flag == MODULES[i].flag) return i;
    }
    return SIZE_MAX;
}

// Look up a module by its `--no-<slug>` form.
std::size_t find_by_no_slug(const std::string& flag) {
    if (flag.rfind("--no-", 0) != 0) return SIZE_MAX;
    std::string slug = flag.substr(5);
    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        if (slug == MODULES[i].slug) return i;
    }
    return SIZE_MAX;
}

}  // namespace

void print_help(const char* argv0) {
    std::printf(
        "fox-install — FoxML Theme Hub installer (C++ orchestrator)\n\n"
        "Usage: %s [theme] [flags]\n\n"
        "Global flags:\n"
        "  -y, --yes         assume yes for every prompt\n"
        "      --dry-run     print every command without executing it\n"
        "      --full        deps + perf + vault + ai + models + github +\n"
        "                    all default-on modules (excludes xgboost / mac-random /\n"
        "                    polkit-strict / cpp-pro — opt in to those explicitly)\n"
        "      --only <slugs> comma-separated allow-list; everything else skipped\n"
        "      --polkit-strict   add polkit strict mode (every GUI sudo re-prompts)\n"
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
        if (a == "--dry-run")              { ctx.dry_run = true;      continue; }
        if (a == "--quiet")                { ctx.quiet = true; out.quiet = true; continue; }
        if (a == "--full" || a == "--all") {
            out.full = true;
            // Curated --full: matches bash's INSTALL_* set. Every
            // default_on=true module already runs by default; --full
            // adds the major opt-in slugs from bash --full:
            //
            //   deps, perf, vault, ai, models, github
            //
            // Bash --full explicitly EXCLUDES (off-by-default,
            // require an explicit flag to opt in):
            //   xgboost          5-10 min from-source build
            //   mac_random       breaks captive-portal/dorm/enterprise WiFi
            //   polkit_strict    every GUI sudo re-prompts (daily-use pain)
            //   cpp_pro          dev-only toolchain extras
            //   throttling       interactive multi-step wizard
            //   ssh_harden       interactive multi-step wizard
            //   endlessh         depends on --ssh-harden moving sshd first
            //   fprint           detect.cpp gates this on hardware presence
            //
            // GPU modules (nvidia/amd_gpu/intel_gpu) gate on the
            // hardware-detect flags in ctx, so they're "always on if
            // hardware present" — same effect as bash's --full + auto-detect.
            static const char* FULL_OPT_INS[] = {
                "deps", "perf", "vault", "ai", "models", "github", nullptr,
            };
            for (auto** s = FULL_OPT_INS; *s; ++s) {
                for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                    if (std::string(MODULES[k].slug) == *s) {
                        out.module_enabled[k] = true;
                        break;
                    }
                }
            }
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

}  // namespace fox_install::args
