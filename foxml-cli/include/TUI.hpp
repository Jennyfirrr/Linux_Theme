#pragma once

#include <iostream>
#include <vector>
#include <string>
#include <filesystem>
#include <termios.h>
#include <unistd.h>
#include "Palette.hpp"

namespace fs = std::filesystem;

namespace foxml {

class TUI {
public:
    static std::string selectTheme(const fs::path& themes_dir) {
        std::vector<std::string> themes;
        for (const auto& entry : fs::directory_iterator(themes_dir)) {
            if (entry.is_directory() && fs::exists(entry.path() / "palette.sh")) {
                themes.push_back(entry.path().filename().string());
            }
        }

        if (themes.empty()) return "";

        int selected = 0;
        bool done = false;

        // Hide cursor and clear screen
        std::cout << "\033[?25l\033[2J\033[H";
        
        while (!done) {
            std::cout << "\033[H";
            std::cout << "╭──────────────────────────────────────────────────╮" << std::endl;
            std::cout << "│            FoxML Theme Swapper (TUI)             │" << std::endl;
            std::cout << "╰──────────────────────────────────────────────────╯" << std::endl << std::endl;

            for (int i = 0; i < (int)themes.size(); ++i) {
                if (i == selected) {
                    std::cout << "  \033[1;33m● " << themes[i] << " (Active)\033[0m" << std::endl;
                    renderSwatches(themes_dir / themes[i] / "palette.sh");
                } else {
                    std::cout << "    " << themes[i] << std::endl;
                }
            }

            std::cout << "\n  [↑/↓] Navigate  [Enter] Select  [q] Quit" << std::endl;

            char c = getChar();
            if (c == 'q') {
                std::cout << "\033[?25h" << std::endl;
                return "";
            } else if (c == 10) { // Enter
                done = true;
            } else if (c == 27) { // Escape sequence
                getChar(); // Skip [
                char arrow = getChar();
                if (arrow == 'A') { // Up
                    selected = (selected - 1 + themes.size()) % themes.size();
                } else if (arrow == 'B') { // Down
                    selected = (selected + 1) % themes.size();
                }
            }
        }

        std::cout << "\033[?25h" << std::endl;
        return themes[selected];
    }

private:
    static char getChar() {
        char buf = 0;
        struct termios old = {0};
        if (tcgetattr(0, &old) < 0) perror("tcsetattr()");
        old.c_lflag &= ~ICANON;
        old.c_lflag &= ~ECHO;
        old.c_cc[VMIN] = 1;
        old.c_cc[VTIME] = 0;
        if (tcsetattr(0, TCSANOW, &old) < 0) perror("tcsetattr ICANON");
        if (read(0, &buf, 1) < 0) perror("read()");
        old.c_lflag |= ICANON;
        old.c_lflag |= ECHO;
        if (tcsetattr(0, TCSADRAIN, &old) < 0) perror("tcsetattr ~ICANON");
        return buf;
    }

    static void renderSwatches(const fs::path& palette_path) {
        try {
            auto palette = Palette::loadFromShell(palette_path.string());
            std::vector<std::string> keys = {"BG", "FG", "PRIMARY", "SECONDARY", "ACCENT", "SURFACE"};
            
            std::cout << "    ";
            for (const auto& key : keys) {
                std::string hex = palette.get(key);
                if (hex.length() == 6) {
                    int r = std::stoi(hex.substr(0, 2), nullptr, 16);
                    int g = std::stoi(hex.substr(2, 2), nullptr, 16);
                    int b = std::stoi(hex.substr(4, 2), nullptr, 16);
                    // Render truecolor block
                    std::cout << "\033[48;2;" << r << ";" << g << ";" << b << "m      \033[0m ";
                }
            }
            std::cout << std::endl;
        } catch (...) {}
    }
};

} // namespace foxml
