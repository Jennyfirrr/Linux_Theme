#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <fstream>
#include <regex>
#include "CLI11.hpp"
#include "Palette.hpp"
#include "Renderer.hpp"
#include "Platform.hpp"
#include "SystemController.hpp"
#include "TUI.hpp"
#include "Generator.hpp"
#include "Daemon.hpp"

namespace fs = std::filesystem;

struct Mapping {
    std::string source;
    std::string destination;
};

fs::path findProjectRoot() {
    fs::path curr = fs::current_path();
    while (curr != curr.root_path()) {
        if (fs::exists(curr / "themes") && fs::exists(curr / "templates")) {
            return curr;
        }
        curr = curr.parent_path();
    }
    throw std::runtime_error("Could not find project root (missing themes/ or templates/ directory)");
}

std::vector<Mapping> parseMappings(const fs::path& mappings_sh) {
    std::vector<Mapping> mappings;
    std::ifstream file(mappings_sh);
    std::string line;
    std::regex mapping_regex(R"(\"(.+)\|(.+)\")");
    while (std::getline(file, line)) {
        std::smatch match;
        if (std::regex_search(line, match, mapping_regex)) {
            mappings.push_back({match[1], match[2]});
        }
    }
    return mappings;
}

std::string getFirefoxProfile() {
    std::vector<fs::path> bases = {
        foxml::Platform::expandPath("~/.config/mozilla/firefox"),
        foxml::Platform::expandPath("~/.mozilla/firefox")
    };
    for (const auto& base : bases) {
        if (!fs::exists(base)) continue;
        try {
            for (const auto& entry : fs::directory_iterator(base)) {
                if (entry.is_directory() && entry.path().filename().string().find(".default-release") != std::string::npos) {
                    return entry.path().string();
                }
            }
        } catch (...) {}
    }
    return "";
}

void performInstallation(const std::string& theme_name) {
    fs::path project_root = findProjectRoot();
    fs::path palette_path = project_root / "themes" / theme_name / "palette.sh";
    fs::path mappings_path = project_root / "mappings.sh";

    if (!fs::exists(palette_path)) throw std::runtime_error("Palette not found: " + palette_path.string());

    auto palette = foxml::Palette::loadFromShell(palette_path.string());
    auto mappings = parseMappings(mappings_path);

    std::cout << "Installing " << theme_name << " (" << mappings.size() << " mappings)..." << std::endl;

    std::string ff_profile = getFirefoxProfile();

    for (const auto& mapping : mappings) {
        std::string dest_str = mapping.destination;
        if (dest_str.find("FIREFOX_PROFILE") != std::string::npos) {
            if (ff_profile.empty()) continue;
            size_t pos = dest_str.find("FIREFOX_PROFILE");
            dest_str.replace(pos, 15, ff_profile);
        }
        if (dest_str.find("GEMINI_DIR") != std::string::npos) {
            const char* gemini_home = std::getenv("GEMINI_CONFIG_HOME");
            std::string gemini_base = gemini_home ? gemini_home : (std::string(std::getenv("HOME")) + "/.gemini");
            size_t pos = dest_str.find("GEMINI_DIR");
            dest_str.replace(pos, 10, gemini_base);
        }

        fs::path src = project_root / "templates" / mapping.source;
        fs::path dest = foxml::Platform::expandPath(dest_str);

        if (fs::exists(src)) {
            foxml::Platform::ensureParentDirs(dest);
            if (dest.filename() == "settings.json" && (dest_str.find("gemini") != std::string::npos || dest_str.find(".gemini") != std::string::npos)) {
                std::ifstream t_file(src);
                std::string content((std::istreambuf_iterator<char>(t_file)), std::istreambuf_iterator<char>());
                std::string rendered = foxml::Renderer::render(content, palette);
                foxml::Renderer::mergeJson(dest, rendered);
                std::cout << "  ✓ Gemini theme merged" << std::endl;
            } else {
                foxml::Renderer::renderToFile(src, dest, palette);
                std::cout << "  ✓ " << mapping.source << " -> " << dest.filename().string() << std::endl;
            }
        }
    }

    std::cout << "\nInstallation complete!" << std::endl;
    foxml::SystemController::reloadAll();
}

int main(int argc, char** argv) {
    CLI::App app{"FoxML CLI — High-performance theme manager"};

    std::string theme_name;
    auto install_cmd = app.add_subcommand("install", "Install a theme");
    install_cmd->add_option("theme", theme_name, "Theme name (e.g., FoxML_Classic)")->required();

    app.add_subcommand("swap", "Interactive TUI theme swapper");

    std::string image_path, new_theme_name;
    auto gen_cmd = app.add_subcommand("gen", "Generate a theme from an image");
    gen_cmd->add_option("image", image_path, "Path to wallpaper")->required()->check(CLI::ExistingFile);
    gen_cmd->add_option("name", new_theme_name, "Name for the new theme")->required();

    app.add_subcommand("daemon", "Background ambient sync service");

    CLI11_PARSE(app, argc, argv);

    if (app.got_subcommand("install")) {
        try {
            performInstallation(theme_name);
        } catch (const std::exception& e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return 1;
        }
    } else if (app.got_subcommand("swap")) {
        try {
            fs::path project_root = findProjectRoot();
            std::string selected = foxml::TUI::selectTheme(project_root / "themes");
            if (!selected.empty()) {
                performInstallation(selected);
            }
        } catch (const std::exception& e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return 1;
        }
    } else if (app.got_subcommand("gen")) {
        try {
            fs::path project_root = findProjectRoot();
            fs::path theme_dir = project_root / "themes" / new_theme_name;
            fs::create_directories(theme_dir);
            foxml::Generator::generate(image_path, (theme_dir / "palette.sh").string());
            std::ofstream conf(theme_dir / "theme.conf");
            conf << "type=dark\ndescription=Generated from " << image_path << "\n";
            std::cout << "Theme '" << new_theme_name << "' created. Apply it with: foxml install " << new_theme_name << std::endl;
        } catch (const std::exception& e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return 1;
        }
    } else if (app.got_subcommand("daemon")) {
        try {
            foxml::Daemon::start();
        } catch (const std::exception& e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return 1;
        }
    }

    return 0;
}
