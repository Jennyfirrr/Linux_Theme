// modules/render.cpp — drives fox-render-fast for the chosen theme.
//
// Pattern every module follows:
//   • read what it needs from Context
//   • emit a ui::section() heading
//   • do its work via the typed sh:: helpers (so --dry-run works for free)
//   • record results back on Context if other modules depend on it

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <filesystem>

namespace fs = std::filesystem;

namespace fox_install {

void run_render(Context& ctx) {
    ui::section("Rendering templates with " + ctx.theme_name + " palette");

    if (!fs::exists(ctx.palette_path)) {
        ui::err("palette not found: " + ctx.palette_path.string());
        return;
    }
    if (!fs::is_directory(ctx.templates_dir)) {
        ui::err("templates dir not found: " + ctx.templates_dir.string());
        return;
    }

    fs::create_directories(ctx.rendered_dir);

    // Prefer the installed binary; fall back to the in-tree build during
    // development so contributors don't need `make install` to iterate.
    std::string render_bin = "fox-render-fast";
    fs::path local = ctx.script_dir / "src/fox-render/fox-render-fast";
    if (fs::exists(local)) render_bin = local.string();

    int rc = sh::run({
        render_bin,
        ctx.palette_path.string(),
        ctx.templates_dir.string(),
        ctx.rendered_dir.string(),
    });
    if (rc != 0) {
        ui::err("render failed (exit " + std::to_string(rc) + ")");
        return;
    }
    ui::ok("templates rendered to " + ctx.rendered_dir.string());
}

}  // namespace fox_install
