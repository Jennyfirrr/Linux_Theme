// fox-install — typed C++ orchestrator for the FoxML Theme Hub installer.
//
// The point of this binary is the X-macro module registry in
// core/modules.def. Everything else (arg parser, --help, dispatcher,
// dry-run preview) is generated from that single list. To add a new
// install step you write one .cpp under modules/, declare the symbol
// with one line in modules.def, and rebuild.

#include "core/args.hpp"
#include "core/context.hpp"
#include "core/module.hpp"
#include "core/shell.hpp"
#include "core/ui.hpp"

#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <filesystem>
#include <string>
#include <unistd.h>

namespace fs = std::filesystem;

namespace {

constexpr const char* DEFAULT_THEME = "FoxML_Classic";

fs::path detect_script_dir(const char* argv0) {
    // argv0 typically points inside the repo or at $HOME/.local/bin.
    // For dev runs (./src/fox-install/fox-install …) we want the repo
    // root so templates/, themes/, shared/ resolve correctly.
    fs::path p = argv0;
    if (!p.is_absolute()) {
        std::error_code ec;
        p = fs::absolute(p, ec);
    }
    p = fs::weakly_canonical(p);
    // Walk up until we find a dir containing both `templates/` and `themes/`.
    fs::path dir = p.parent_path();
    while (!dir.empty() && dir != dir.root_path()) {
        if (fs::is_directory(dir / "templates") &&
            fs::is_directory(dir / "themes")) {
            return dir;
        }
        dir = dir.parent_path();
    }
    return fs::current_path();
}

void fill_paths(fox_install::Context& ctx, const char* argv0) {
    ctx.script_dir    = detect_script_dir(argv0);
    ctx.templates_dir = ctx.script_dir / "templates";
    ctx.themes_dir    = ctx.script_dir / "themes";
    ctx.shared_dir    = ctx.script_dir / "shared";
    ctx.rendered_dir  = ctx.script_dir / "rendered";

    const char* home_env = std::getenv("HOME");
    ctx.home = home_env ? fs::path(home_env) : fs::path("/tmp");

    const char* xdg = std::getenv("XDG_CONFIG_HOME");
    ctx.config_home = (xdg && *xdg) ? fs::path(xdg) : (ctx.home / ".config");

    if (ctx.theme_name.empty()) ctx.theme_name = DEFAULT_THEME;
    ctx.palette_path = ctx.themes_dir / ctx.theme_name / "palette.sh";

    // Timestamped backup root (matches bash
    // BACKUP_DIR=$HOME/.theme_backups/foxml-backup-YYYYMMDD-HHMMSS).
    char ts[32]{};
    std::time_t now = std::time(nullptr);
    std::tm* tm_now = std::localtime(&now);
    if (tm_now) std::strftime(ts, sizeof(ts), "%Y%m%d-%H%M%S", tm_now);
    ctx.backup_dir = ctx.home / ".theme_backups" /
                     (std::string("foxml-backup-") + ts);
}

}  // namespace

int main(int argc, char** argv) {
    using namespace fox_install;

    ui::init();

    Context ctx;
    args::Parsed parsed;
    if (!args::parse(argc, argv, parsed, ctx)) return 2;
    if (parsed.show_help)    { args::print_help(argv[0]);    return 0; }
    if (parsed.show_version) { args::print_version();        return 0; }

    fill_paths(ctx, argv[0]);
    sh::set_dry_run(ctx.dry_run);

    if (!fs::exists(ctx.palette_path)) {
        ui::err("theme palette not found: " + ctx.palette_path.string());
        ui::err("available themes live under " + ctx.themes_dir.string());
        return 1;
    }

    if (ctx.dry_run) {
        ui::section("Dry-run plan");
        for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
            ui::summary_row(MODULES[i].slug,
                parsed.module_enabled[i] ? "will run" : "skipped");
        }
    }

    ui::section("FoxML installer (fox-install) — theme: " + ctx.theme_name);

    int failures = 0;
    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        if (!parsed.module_enabled[i]) continue;
        const Module& m = MODULES[i];
        try {
            m.fn(ctx);
        } catch (const std::exception& e) {
            ui::err(std::string(m.slug) + ": " + e.what());
            ++failures;
        }
    }

    ui::section("Done");
    ui::summary_row("theme",     ctx.theme_name);
    ui::summary_row("modules",   std::to_string(MODULES_COUNT) + " registered");
    ui::summary_row("failures",  std::to_string(failures));
    return failures == 0 ? 0 : 1;
}
