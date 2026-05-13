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
#include <fstream>
#include <string>
#include <vector>
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

    // Call interactive wizard if no specialized flags are set.
    if (!ctx.assume_yes && !parsed.full && parsed.phase.empty() && !parsed.resume) {
        args::run_wizard(parsed, ctx);
    }

    fs::path state_file = ctx.home / ".local/share/foxml/install_state";

    // Handle --resume
    if (parsed.resume) {
        if (fs::exists(state_file)) {
            std::ifstream f(state_file);
            int last_idx = -1;
            if (f >> last_idx) {
                ctx.resume_idx = last_idx + 1;
                ui::substep("resuming from module index " + std::to_string(ctx.resume_idx));
            }
        } else {
            ui::warn("no resume state found; starting from beginning");
        }
    }

    // Handle --phase <slug> (overrides --resume if both set)
    if (!parsed.phase.empty()) {
        bool found = false;
        for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
            if (parsed.phase == MODULES[i].slug) {
                ctx.resume_idx = static_cast<int>(i);
                found = true;
                break;
            }
        }
        if (!found) {
            ui::err("unknown phase: " + parsed.phase);
            return 1;
        }
        ui::substep("skipping to phase: " + parsed.phase);
    }

    if (!fs::exists(ctx.palette_path)) {
        ui::err("theme palette not found: " + ctx.palette_path.string());
        ui::err("available themes live under " + ctx.themes_dir.string());
        return 1;
    }

    // Run `detect` upfront so the dry-run plan and main loop see the
    // final enable state of hardware-gated modules (nvidia/amd_gpu/
    // intel_gpu/fprint). detect is read-only — re-running it is cheap.
    // confirm_hw inside detect honors ctx.assume_yes (--yes auto-accepts;
    // interactive mode still asks per-piece). After detect we toggle
    // module_enabled to mirror the resolved ctx.has_* flags, then mark
    // detect as already-run so the main loop skips it.
    {
        auto find_idx = [](const char* slug) -> int {
            for (std::size_t k = 0; k < MODULES_COUNT; ++k) {
                if (std::string(MODULES[k].slug) == slug) return static_cast<int>(k);
            }
            return -1;
        };
        int detect_idx = find_idx("detect");
        if (detect_idx >= 0 && parsed.module_enabled[detect_idx]) {
            MODULES[detect_idx].fn(ctx);
            parsed.module_enabled[detect_idx] = false;

            auto enable_slug = [&](const char* slug) {
                int k = find_idx(slug);
                if (k >= 0) parsed.module_enabled[k] = true;
            };
            if (ctx.has_nvidia)    enable_slug("nvidia");
            if (ctx.has_amd_gpu)   enable_slug("amd_gpu");
            if (ctx.has_intel_gpu) enable_slug("intel_gpu");
            if (ctx.has_fprint)    enable_slug("fprint");
        }
    }

    // Pre-install marker detect. Bash printed a nudge about --quick on
    // every invocation when ~/.local/share/foxml/.installed-version
    // existed. We do the same — silent first install, nudge thereafter.
    {
        fs::path marker = ctx.home / ".local/share/foxml/.installed-version";
        if (fs::exists(marker) && !ctx.dry_run) {
            std::ifstream f(marker);
            std::string line;
            std::string prior_theme;
            while (std::getline(f, line)) {
                if (line.rfind("theme=", 0) == 0) {
                    prior_theme = line.substr(6);
                    break;
                }
            }
            std::printf(" -> existing FoxML install detected"
                        "%s%s — pass --quick to skip deps + clones + model pulls\n",
                        prior_theme.empty() ? "" : " (",
                        prior_theme.empty() ? "" : (prior_theme + ")").c_str());
        }
    }

    if (ctx.dry_run) {
        ui::section("Dry-run plan");
        for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
            std::string status = parsed.module_enabled[i] ? "will run" : "skipped";
            if (ctx.resume_idx > 0 && static_cast<int>(i) < ctx.resume_idx) {
                status = "skipped (before resume point)";
            }
            ui::summary_row(MODULES[i].slug, status);
        }
    }

    ui::section("FoxML installer (fox-install) — theme: " + ctx.theme_name);

    std::vector<std::string> failed_modules;
    for (std::size_t i = 0; i < MODULES_COUNT; ++i) {
        if (!parsed.module_enabled[i]) continue;
        if (ctx.resume_idx > 0 && static_cast<int>(i) < ctx.resume_idx) continue;

        const Module& m = MODULES[i];
        try {
            m.fn(ctx);
            
            // Update resume state after success
            if (!ctx.dry_run) {
                fs::create_directories(state_file.parent_path());
                std::ofstream f(state_file);
                f << i << std::endl;
            }
        } catch (const std::exception& e) {
            ui::err(std::string(m.slug) + ": " + e.what());
            failed_modules.emplace_back(m.slug);
            // On failure, we don't advance the state_file so --resume
            // will retry the failing module.
            break; 
        }
    }

    // Clear resume state on clean completion
    if (failed_modules.empty() && !ctx.dry_run && fs::exists(state_file)) {
        fs::remove(state_file);
    }

    ui::section("Done");
    ui::summary_row("theme",     ctx.theme_name);
    ui::summary_row("modules",   std::to_string(MODULES_COUNT) + " registered");
    ui::summary_row("failures",  std::to_string(failed_modules.size()));

    // Mid-install errors (failed pacman calls, missing packages, etc.)
    // can scroll past while the user is watching. Re-list them at the
    // tail so they're impossible to miss, with the suggested fix in
    // one line. This keeps the bash habit of "run --deps after a
    // pacman -Syu" actionable instead of buried.
    if (!failed_modules.empty()) {
        std::printf("\n");
        ui::err("modules with failures (scroll up for details):");
        for (auto& m : failed_modules) {
            std::printf("    • %s — re-run with: fox-install --only %s\n",
                        m.c_str(), m.c_str());
        }
        std::printf("\n  Common fixes:\n"
                    "    • pacman dep-resolution errors → sudo pacman -Syu, then retry\n"
                    "    • systemctl enable failures → sudo -v, then retry\n"
                    "    • module-specific errors → check the error line above\n");
    }
    return failed_modules.empty() ? 0 : 1;
}
