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

// Look up a module by its --foo flag. Returns SIZE_MAX if no match.
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
        "      --monitor     surgical run of the multi-monitor wizard only\n"
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
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                out.module_enabled[k] = true;
            }
            ctx.install_polkit_strict = true;
            ctx.cpp_pro = true;
            ctx.force_reapply = true;
            continue;
        }

        if (a == "--arm" || a == "--paranoid") {
            ::setenv("FOXML_ARM", "1", 1);
            continue;
        }
        if (a == "--arm-heavy" || a == "--heavy") {
            ::setenv("FOXML_ARM", "1", 1);
            ::setenv("FOXML_ARM_HEAVY", "1", 1);
            continue;
        }

        if (a == "--polkit-strict") {
            ctx.install_polkit_strict = true;
            continue;
        }

        if (a == "--quick") {
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                std::string s = MODULES[k].slug;
                if (s == "deps" || s == "github" || s == "models") {
                    out.module_enabled[k] = false;
                }
            }
            continue;
        }

        if (a == "--monitor") {
            out.only = true;
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                out.module_enabled[k] = (std::string(MODULES[k].slug) == "monitors");
            }
            continue;
        }

        if (a == "--render-only") {
            out.only = true;
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

        if (a == "--only" && i + 1 < argc) {
            out.only = true;
            std::string list = argv[++i];
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

        if (!a.empty() && a[0] != '-') {
            std::size_t slug_idx = find_by_slug(a);
            if (slug_idx != SIZE_MAX) {
                // Positional module slug (e.g. `fox install monitors`)
                // On the FIRST module slug we see, if --only hasn't already
                // been set, we flip to exclusive mode.
                if (!out.only) {
                    out.only = true;
                    for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                        out.module_enabled[k] = false;
                    }
                }
                out.module_enabled[slug_idx] = true;
                continue;
            }

            if (ctx.theme_name.empty()) {
                ctx.theme_name = a;
                continue;
            }
        }

        std::fprintf(stderr, "fox-install: unknown argument: %s\n", a.c_str());
        return false;
    }
    return true;
}

}  // namespace fox_install::args
