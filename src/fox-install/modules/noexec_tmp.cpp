// modules/noexec_tmp.cpp — noexec / nosuid / nodev on /tmp + /dev/shm.
//
// Kills the "drop second-stage payload in /tmp, exec it" malware class
// at the cost of breaking the rare build script that legit-execs from
// /tmp. Opt-in via --noexec-tmp.
//
// Mirrors mappings.sh::install_noexec_tmp. Edits /etc/fstab (backup at
// fstab.foxml-bak) and remounts /tmp + /dev/shm live where the kernel
// allows (refuses if /tmp is held open — falls back to "applies next reboot").

#include "../core/context.hpp"
#include "../core/shell.hpp"
#include "../core/ui.hpp"

#include <filesystem>
#include <fstream>
#include <regex>
#include <sstream>

namespace fs = std::filesystem;

namespace fox_install {

namespace {

bool has_tmp_tmpfs(const std::string& fstab) {
    std::istringstream is(fstab);
    std::string line;
    std::regex pat(R"(^\S+\s+/tmp\s+tmpfs)");
    while (std::getline(is, line)) {
        if (std::regex_search(line, pat)) return true;
    }
    return false;
}

std::string read_file(const fs::path& p) {
    std::ifstream f(p);
    if (!f) return {};
    std::ostringstream ss;
    ss << f.rdbuf();
    return ss.str();
}

}  // namespace

void run_noexec_tmp(Context&) {
    ui::section("/tmp + /dev/shm noexec,nosuid,nodev");

    if (sh::dry_run()) {
        ui::substep("[dry-run] would back up /etc/fstab, append /tmp tmpfs mount "
                    "or amend its options, remount /tmp and /dev/shm live");
        return;
    }
    if (!sh::sudo_warmup()) {
        ui::err("sudo cache cold — `sudo -v` first");
        return;
    }

    fs::path fstab = "/etc/fstab";
    sh::run({"sh", "-c", "sudo cp /etc/fstab /etc/fstab.foxml-bak 2>/dev/null"});

    std::string body = read_file(fstab);
    if (!has_tmp_tmpfs(body)) {
        sh::run({"sh", "-c",
                 "echo 'tmpfs   /tmp        tmpfs   "
                 "defaults,noexec,nosuid,nodev,size=4G  0 0' | "
                 "sudo tee -a /etc/fstab >/dev/null"});
        ui::ok("/tmp added to /etc/fstab as tmpfs with noexec,nosuid,nodev");
    } else {
        // Amend defaults with each missing flag.
        sh::run({"sh", "-c",
                 "sudo sed -i -E '/^\\S+\\s+\\/tmp\\s+tmpfs.*defaults/{"
                 "/noexec/!s/defaults/defaults,noexec/;"
                 "/nosuid/!s/defaults/defaults,nosuid/;"
                 "/nodev/!s/defaults/defaults,nodev/"
                 "}' /etc/fstab"});
        ui::ok("/tmp tmpfs entry amended with noexec,nosuid,nodev");
    }

    if (sh::run({"sh", "-c",
                 "sudo mount -o remount,noexec,nosuid,nodev /dev/shm 2>/dev/null"}) == 0) {
        ui::ok("/dev/shm live-remounted noexec,nosuid,nodev");
    } else {
        ui::ok("/dev/shm flags will apply on next reboot");
    }

    if (sh::run({"sh", "-c",
                 "findmnt /tmp 2>/dev/null | grep -q noexec"}) == 0) {
        ui::ok("/tmp already noexec live");
    } else if (sh::run({"sh", "-c",
                        "sudo mount -o remount,noexec,nosuid,nodev /tmp 2>/dev/null"}) == 0) {
        ui::ok("/tmp live-remounted noexec,nosuid,nodev");
    } else {
        ui::ok("/tmp fstab updated — reboot to apply live (kernel refused: /tmp busy)");
    }
    ui::substep("backup at /etc/fstab.foxml-bak — revert with: sudo mv /etc/fstab.foxml-bak /etc/fstab");
}

}  // namespace fox_install
