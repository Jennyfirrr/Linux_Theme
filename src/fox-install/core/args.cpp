#include "args.hpp"

#include "module.hpp"

#include <cstdio>
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
        "  -y, --yes        assume yes for every prompt\n"
        "      --dry-run    print every command without executing it\n"
        "      --full       enable every default-on + every major opt-in module\n"
        "      --quiet      suppress per-step chatter (errors still print)\n"
        "  -h, --help       show this help and exit\n"
        "      --version    print version and exit\n\n"
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
            // For now this just turns every module on; later we'll honor
            // `default_on` as the discriminator between "default" and
            // "major opt-in" vs niche flags like --xgboost.
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                out.module_enabled[k] = true;
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
