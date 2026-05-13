#include "sidecar.hpp"

#include <fstream>
#include <sstream>

namespace fox_install::sidecar {

namespace {

void trim(std::string& s) {
    size_t i = 0;
    while (i < s.size() && (s[i] == ' ' || s[i] == '\t' || s[i] == '\r')) ++i;
    s.erase(0, i);
    while (!s.empty() && (s.back() == ' ' || s.back() == '\t' || s.back() == '\r' ||
                          s.back() == '\n')) s.pop_back();
}

void strip_quotes(std::string& s) {
    if (s.size() >= 2 &&
        ((s.front() == '"'  && s.back() == '"') ||
         (s.front() == '\'' && s.back() == '\''))) {
        s.erase(s.size() - 1, 1);
        s.erase(0, 1);
    }
}

std::vector<std::string> ws_split(const std::string& s) {
    std::vector<std::string> out;
    std::istringstream is(s);
    std::string tok;
    while (is >> tok) out.push_back(tok);
    return out;
}

}  // namespace

Layout read(const std::filesystem::path& path) {
    Layout out;
    std::ifstream f(path);
    if (!f) return out;

    std::string line;
    while (std::getline(f, line)) {
        trim(line);
        if (line.empty() || line[0] == '#') continue;

        auto eq = line.find('=');
        if (eq == std::string::npos) continue;
        std::string key   = line.substr(0, eq);
        std::string value = line.substr(eq + 1);
        trim(key);
        trim(value);
        strip_quotes(value);

        if      (key == "PRIMARY")             out.primary             = value;
        else if (key == "PORTRAIT_OUTPUTS")     out.portrait_outputs    = ws_split(value);
        else if (key == "SECONDARY_OUTPUTS")    out.secondary_outputs   = ws_split(value);
        else if (key == "MONITOR_RESOLUTIONS")  out.monitor_resolutions = ws_split(value);
    }
    return out;
}

}  // namespace fox_install::sidecar
