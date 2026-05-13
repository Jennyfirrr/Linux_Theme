// fox-render-fast — drop-in C++ replacement for render.sh CLI mode.
//
//   fox-render-fast <palette.sh> <template_dir> <output_dir>
//
// Output layout and placeholder semantics match render.sh exactly so the
// installer can swap one for the other transparently.

#include "palette.hpp"
#include "render.hpp"

#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <string>
#include <unistd.h>

namespace fs = std::filesystem;

static void usage(const char* argv0) {
    std::fprintf(stderr,
        "Usage: %s <palette.sh> <template_dir> <output_dir>\n", argv0);
}

int main(int argc, char** argv) {
    if (argc < 4) { usage(argv[0]); return 2; }

    const std::string palette_path = argv[1];
    const std::string template_dir = argv[2];
    const std::string output_dir   = argv[3];

    if (!fs::exists(palette_path)) {
        std::fprintf(stderr, "fox-render-fast: palette not found: %s\n",
                     palette_path.c_str());
        return 1;
    }
    if (!fs::is_directory(template_dir)) {
        std::fprintf(stderr, "fox-render-fast: not a directory: %s\n",
                     template_dir.c_str());
        return 1;
    }

    auto table = fox_render::parse_palette(palette_path);
    if (table.empty()) {
        std::fprintf(stderr,
            "fox-render-fast: no substitutions derived from %s\n",
            palette_path.c_str());
        return 1;
    }

    bool show_progress = isatty(fileno(stderr));
    auto t0 = std::chrono::steady_clock::now();
    size_t n = fox_render::render_tree(template_dir, output_dir, table, show_progress);
    auto t1 = std::chrono::steady_clock::now();
    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(t1 - t0).count();

    std::fprintf(stderr, "Rendered %zu templates to: %s (%lld ms)\n",
                 n, output_dir.c_str(), static_cast<long long>(ms));
    return 0;
}
