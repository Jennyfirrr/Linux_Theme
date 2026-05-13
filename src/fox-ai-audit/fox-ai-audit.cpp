// fox-ai-audit — priority sorter for lynis / arch-audit / fox-audit output.
//
// Raw security-audit reports dump dozens of findings, most of which are
// noise for a personal Arch+Hyprland laptop (server-only recommendations,
// generic Lynis suggestions, etc.). This binary captures whichever
// auditor outputs the user has and asks the model to surface the top 3
// genuinely actionable findings.

#include "../fox-intel/fox_intel.hpp"

#include <cerrno>
#include <cstdio>
#include <iostream>
#include <sstream>
#include <string>
#include <sys/wait.h>
#include <unistd.h>
#include <vector>

namespace {

bool capture(const std::vector<const char*>& argv, std::string& out) {
    int p[2];
    if (::pipe(p) < 0) return false;
    pid_t pid = ::fork();
    if (pid < 0) { ::close(p[0]); ::close(p[1]); return false; }
    if (pid == 0) {
        ::close(p[0]);
        ::dup2(p[1], STDOUT_FILENO);
        ::dup2(p[1], STDERR_FILENO);
        ::close(p[1]);
        std::vector<const char*> v(argv);
        v.push_back(nullptr);
        ::execvp(v[0], const_cast<char* const*>(v.data()));
        ::_exit(127);
    }
    ::close(p[1]);
    char buf[4096];
    for (;;) {
        ssize_t n = ::read(p[0], buf, sizeof(buf));
        if (n > 0) out.append(buf, static_cast<size_t>(n));
        else if (n == 0) break;
        else if (errno != EINTR) break;
    }
    ::close(p[0]);
    int status = 0;
    while (::waitpid(pid, &status, 0) < 0) if (errno != EINTR) return false;
    return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

bool have(const std::string& bin) {
    std::string out;
    std::string cmd = "command -v " + bin;
    return capture({"sh", "-c", cmd.c_str()}, out) && !out.empty();
}

std::string trim_tail(std::string s, size_t limit) {
    if (s.size() > limit) {
        s = s.substr(0, limit);
        s += "\n(... truncated)\n";
    }
    return s;
}

}  // namespace

int main(int argc, char** argv) {
    std::string model;
    for (int i = 1; i < argc; ++i) {
        std::string a = argv[i];
        if (a == "-h" || a == "--help") {
            std::printf("Usage: fox-ai-audit [--model <name>]\n\n"
                "Runs arch-audit + lynis (if installed) and asks the local model\n"
                "to rank the top 3 actionable findings for this machine.\n");
            return 0;
        }
        if (a == "--model" && i + 1 < argc) { model = argv[++i]; continue; }
    }

    FoxIntel ai = model.empty() ? FoxIntel{} : FoxIntel{model};
    if (!ai.ensure_ollama_running()) {
        std::fprintf(stderr, "fox-ai-audit: Ollama daemon unavailable\n");
        return 1;
    }

    std::cout << "\033[1;32m[fox-ai-audit: running scanners...]\033[0m\n";

    std::ostringstream ctx;

    if (have("arch-audit")) {
        std::string out;
        capture({"arch-audit", "-uf"}, out);
        ctx << "=== arch-audit -uf (upgradable CVEs) ===\n"
            << (out.empty() ? "(no upgradable CVEs)\n" : trim_tail(out, 4000)) << "\n";
    }

    if (have("lynis")) {
        std::string out;
        capture({"sudo", "lynis", "audit", "system", "--quick"}, out);
        // Lynis is verbose. Grep for findings + warnings only.
        std::string filtered;
        std::istringstream is(out);
        std::string line;
        while (std::getline(is, line)) {
            if (line.find("[ WARNING ]") != std::string::npos ||
                line.find("[ SUGGESTION ]") != std::string::npos ||
                line.find("Hardening index") != std::string::npos) {
                filtered += line + "\n";
            }
        }
        ctx << "=== lynis (warnings + suggestions + hardening index) ===\n"
            << trim_tail(filtered, 4000) << "\n";
    }

    if (have("fox-audit")) {
        std::string out;
        capture({"fox-audit"}, out);
        ctx << "=== fox-audit (foxml-specific posture) ===\n"
            << trim_tail(out, 3000) << "\n";
    }

    if (ctx.str().size() < 30) {
        std::cout << "\033[1;33m[no audit tools installed — install arch-audit / lynis / fox-audit]\033[0m\n";
        return 0;
    }

    std::string prompt =
        "You are reviewing security audit output on an Arch + Hyprland personal\n"
        "laptop that also runs trading software. Surface the top 3 findings ranked\n"
        "by severity. For each, give: (a) the finding, (b) the exact command/edit\n"
        "to fix it, (c) what NOT to bother with (e.g. server-only Lynis suggestions\n"
        "that don't apply to a desktop). Be terse. No markdown headings.\n\n"
        + ctx.str();

    std::cout << "\033[1;32m[asking the model...]\033[0m\n\n";
    ai.ask(prompt, /*stream=*/true);
    std::cout << "\n";
    return 0;
}
