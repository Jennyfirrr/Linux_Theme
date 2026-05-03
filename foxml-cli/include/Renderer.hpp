#pragma once

#include "Palette.hpp"
#include <string>
#include <string_view>
#include <vector>
#include <fstream>
#include <filesystem>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/uio.h>
#include <fcntl.h>
#include <unistd.h>
#include "json.hpp"

using json = nlohmann::json;

namespace foxml {

class Renderer {
public:
    struct Replacement {
        std::string placeholder;
        std::string value;
    };

    /**
     * Legacy string-based render
     */
    static std::string render(const std::string& template_content, const Palette& palette) {
        std::vector<Replacement> replacements;
        for (const auto& [key, value] : palette.variables) {
            replacements.push_back({"{{" + key + "}}", value});
            if (value.length() == 6 && isHex(value)) {
                int r, g, b;
                if (hexToRgb(value, r, g, b)) {
                    replacements.push_back({"{{" + key + "_R}}", std::to_string(r)});
                    replacements.push_back({"{{" + key + "_G}}", std::to_string(g)});
                    replacements.push_back({"{{" + key + "_B}}", std::to_string(b)});
                }
            }
        }

        std::string result = template_content;
        for (const auto& rep : replacements) {
            size_t pos = 0;
            while ((pos = result.find(rep.placeholder, pos)) != std::string::npos) {
                result.replace(pos, rep.placeholder.length(), rep.value);
                pos += rep.value.length();
            }
        }
        return result;
    }

    /**
     * High-performance Zero-Copy Render using mmap() and writev()
     * Scans the template once and assembles the output via vector I/O.
     */
    static void renderToFile(const std::filesystem::path& src, const std::filesystem::path& dest, const Palette& palette) {
        int fd = open(src.c_str(), O_RDONLY);
        if (fd == -1) throw std::runtime_error("Failed to open source template: " + src.string());

        struct stat st;
        fstat(fd, &st);
        size_t size = st.st_size;

        char* map = (char*)mmap(nullptr, size, PROT_READ, MAP_PRIVATE, fd, 0);
        close(fd);
        if (map == MAP_FAILED) throw std::runtime_error("mmap failed for: " + src.string());

        // Pre-calculate replacements and store them in a way that avoids re-allocation
        std::map<std::string, std::string> full_palette = palette.variables;
        for (const auto& [key, value] : palette.variables) {
            if (value.length() == 6 && isHex(value)) {
                int r, g, b;
                if (hexToRgb(value, r, g, b)) {
                    full_palette[key + "_R"] = std::to_string(r);
                    full_palette[key + "_G"] = std::to_string(g);
                    full_palette[key + "_B"] = std::to_string(b);
                }
            }
        }

        std::vector<struct iovec> iov;
        size_t last_pos = 0;
        std::string_view view(map, size);

        size_t pos = 0;
        while ((pos = view.find("{{", last_pos)) != std::string_view::npos) {
            size_t end = view.find("}}", pos);
            if (end == std::string_view::npos) break;

            // Add the literal text before the placeholder
            if (pos > last_pos) {
                iov.push_back({(void*)(map + last_pos), pos - last_pos});
            }

            std::string token(view.substr(pos + 2, end - pos - 2));
            auto it = full_palette.find(token);
            if (it != full_palette.end()) {
                // We must ensure the value string stays alive!
                // For this high-perf pass, we'll assume full_palette lives long enough.
                iov.push_back({(void*)it->second.data(), it->second.size()});
            } else {
                // Token not found, keep original text
                iov.push_back({(void*)(map + pos), end + 2 - pos});
            }

            last_pos = end + 2;
        }

        // Add remaining literal text
        if (last_pos < size) {
            iov.push_back({(void*)(map + last_pos), size - last_pos});
        }

        int out_fd = open(dest.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (out_fd != -1) {
            writev(out_fd, iov.data(), iov.size());
            close(out_fd);
        }

        munmap(map, size);
    }

    static void mergeJson(const std::filesystem::path& target_path, const std::string& rendered_json_content) {
        json themed_json = json::parse(rendered_json_content);
        if (std::filesystem::exists(target_path)) {
            std::ifstream file(target_path);
            json existing_json;
            try { file >> existing_json; } catch (...) { existing_json = json::object(); }
            for (auto& [key, value] : themed_json.items()) {
                existing_json[key] = value;
            }
            std::ofstream out(target_path);
            out << existing_json.dump(2);
        } else {
            std::ofstream out(target_path);
            out << themed_json.dump(2);
        }
    }

private:
    static bool isHex(const std::string& s) {
        for (char c : s) {
            if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')))
                return false;
        }
        return true;
    }

    static bool hexToRgb(const std::string& hex, int& r, int& g, int& b) {
        try {
            r = std::stoi(hex.substr(0, 2), nullptr, 16);
            g = std::stoi(hex.substr(2, 2), nullptr, 16);
            b = std::stoi(hex.substr(4, 2), nullptr, 16);
            return true;
        } catch (...) { return false; }
    }
};

} // namespace foxml
