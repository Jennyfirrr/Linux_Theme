#pragma once

#include <string>
#include <iostream>
#include <vector>
#include <csignal>

namespace foxml {

class SystemController {
public:
    static void reloadAll() {
        std::cout << "Triggering system-wide reload..." << std::endl;

        execute("hyprctl reload");
        reloadProcess("waybar", SIGUSR2);
        execute("dunstctl reload");
        execute("makoctl reload");
        execute("kitty @ set-colors --all --configured ~/.config/kitty/kitty.conf");
        
        std::cout << "✓ Reload signals sent." << std::endl;
    }

private:
    static void execute(const std::string& cmd) {
        if (std::system((cmd + " > /dev/null 2>&1").c_str()) == 0) {
            std::cout << "  ✓ " << cmd << std::endl;
        }
    }

    static void reloadProcess(const std::string& name, int signal) {
        std::string cmd = "pkill -" + std::to_string(signal) + " " + name;
        if (std::system((cmd + " > /dev/null 2>&1").c_str()) == 0) {
            std::cout << "  ✓ Sent signal " << signal << " to " << name << std::endl;
        }
    }
};

} // namespace foxml
