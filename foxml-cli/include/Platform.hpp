#pragma once

#include <string>
#include <filesystem>
#include <cstdlib>
#include <wordexp.h>

namespace foxml {

class Platform {
public:
    static std::filesystem::path expandPath(const std::string& path) {
        if (path.empty()) return "";

        wordexp_t p;
        if (wordexp(path.c_str(), &p, 0) == 0) {
            if (p.we_wordc > 0) {
                std::filesystem::path result(p.we_wordv[0]);
                wordfree(&p);
                return result;
            }
            wordfree(&p);
        }
        
        if (path[0] == '~') {
            const char* home = std::getenv("HOME");
            if (home) {
                return std::filesystem::path(home) / path.substr(1);
            }
        }

        return std::filesystem::path(path);
    }

    static void ensureParentDirs(const std::filesystem::path& path) {
        std::filesystem::create_directories(path.parent_path());
    }
};

} // namespace foxml
