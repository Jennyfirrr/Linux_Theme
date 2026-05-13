#ifndef FOX_INSTALL_SIDECAR_HPP
#define FOX_INSTALL_SIDECAR_HPP

// Parser for ~/.config/foxml/monitor-layout.conf, the sidecar file
// written by configure_monitors / fox-monitor-watch.
//
// Format: bash-style KEY="value" assignments. Only these four keys are
// recognized; everything else is ignored. Values may be unquoted, double
// or single quoted. Spaces inside the quoted value are preserved.

#include <filesystem>
#include <string>
#include <vector>

namespace fox_install::sidecar {

struct Layout {
    std::string              primary;
    std::vector<std::string> portrait_outputs;
    std::vector<std::string> secondary_outputs;
    // entries shaped like "<name>:<WxH>" — matches bash MONITOR_RESOLUTIONS.
    std::vector<std::string> monitor_resolutions;
};

// Returns a Layout populated from `path`. Missing file or unparseable
// content yields an empty Layout — call sites check primary.empty().
Layout read(const std::filesystem::path& path);

}  // namespace fox_install::sidecar

#endif
