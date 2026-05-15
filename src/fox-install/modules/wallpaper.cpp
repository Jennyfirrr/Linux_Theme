#include "../core/context.hpp"
#include "../core/ui.hpp"

namespace fox_install {

void run_wallpaper(Context& ctx) {
    ui::section("Wallpaper configuration");

    if (!ctx.assume_yes && ui::tty()) {
        ctx.rotate_wallpapers = ui::ask_yn("Enable time-of-day wallpaper rotation?", ctx.rotate_wallpapers, false);
    }

    if (ctx.rotate_wallpapers) {
        ui::ok("Wallpaper mode: rotating (time-of-day buckets)");
    } else {
        ui::ok("Wallpaper mode: static (FoxML Earthy)");
    }
}

}  // namespace fox_install
