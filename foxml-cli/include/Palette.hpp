#pragma once

#include <string>
#include <vector>
#include <map>
#include <fstream>
#include <sstream>
#include <iostream>

namespace foxml {

struct Palette {
    std::map<std::string, std::string> variables;

    static Palette loadFromShell(const std::string& path) {
        Palette palette;
        std::ifstream file(path);
        if (!file.is_open()) {
            throw std::runtime_error("Could not open palette file: " + path);
        }

        std::string line;
        while (std::getline(file, line)) {
            line.erase(0, line.find_first_not_of(" \t"));
            line.erase(line.find_last_not_of(" \t") + 1);

            if (line.empty() || line[0] == '#') continue;

            size_t pos = line.find('=');
            if (pos != std::string::npos) {
                std::string key = line.substr(0, pos);
                std::string value = line.substr(pos + 1);

                if (value.size() >= 2 && value.front() == '"' && value.back() == '"') {
                    value = value.substr(1, value.size() - 2);
                }

                palette.variables[key] = value;
            }
        }
        return palette;
    }

    std::string get(const std::string& key) const {
        auto it = variables.find(key);
        return (it != variables.end()) ? it->second : "";
    }
};

} // namespace foxml
