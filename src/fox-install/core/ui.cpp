#include "ui.hpp"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <sys/ioctl.h>
#include <unistd.h>

namespace fox_install::ui {

namespace {

bool g_tty    = false;
bool g_color  = false;

// SGR escapes (only emitted when g_color is true).
constexpr const char* C_RESET = "\033[0m";
constexpr const char* C_BOLD  = "\033[1m";
constexpr const char* C_DIM   = "\033[2m";
constexpr const char* C_RED   = "\033[31m";
constexpr const char* C_GRN   = "\033[32m";
constexpr const char* C_YLW   = "\033[33m";
constexpr const char* C_CYN   = "\033[36m";

const char* c(const char* code) { return g_color ? code : ""; }

int terminal_cols() {
    winsize ws{};
    if (::ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0 && ws.ws_col > 0) {
        return ws.ws_col;
    }
    const char* env = std::getenv("COLUMNS");
    if (env) return std::atoi(env);
    return 80;
}

}  // namespace

void init() {
    g_tty = ::isatty(STDOUT_FILENO);
    const char* term = std::getenv("TERM");
    g_color = g_tty && term && std::strcmp(term, "dumb") != 0;
}

bool tty() { return g_tty; }

void section(const std::string& title) {
    std::printf("%s%s::%s %s%s%s\n",
        c(C_BOLD), c(C_CYN), c(C_RESET),
        c(C_BOLD), title.c_str(), c(C_RESET));
}

void substep(const std::string& msg) {
    std::printf(" %s->%s %s\n", c(C_BOLD), c(C_RESET), msg.c_str());
}

void ok(const std::string& msg) {
    std::printf("  %s+%s %s\n", c(C_GRN), c(C_RESET), msg.c_str());
}

void warn(const std::string& msg) {
    std::fprintf(stderr, "%swarning:%s %s\n", c(C_YLW), c(C_RESET), msg.c_str());
}

void err(const std::string& msg) {
    std::fprintf(stderr, "%serror:%s %s\n", c(C_RED), c(C_RESET), msg.c_str());
}

void progress(std::size_t current, std::size_t total, const std::string& label) {
    if (total == 0) return;
    constexpr int bar_w = 30;
    int pct    = static_cast<int>((current * 100) / total);
    int filled = static_cast<int>((current * bar_w) / total);
    std::string bar(filled, '#');
    bar.append(bar_w - filled, '-');

    char tail[80];
    int  tail_len = std::snprintf(tail, sizeof(tail), " [%s] %3d%% (%zu/%zu)",
                                  bar.c_str(), pct, current, total);
    int cols = terminal_cols();
    int label_w = cols - 3 - tail_len;        // "::: " prefix = 3
    if (label_w < 10) label_w = 10;
    std::printf("\r:: %-*s%s", label_w, label.c_str(), tail);
    std::fflush(stdout);
}

void progress_finalize() {
    std::putchar('\n');
    std::fflush(stdout);
}

void summary_row(const std::string& label, const std::string& value) {
    std::printf("  %s%-22s%s : %s\n",
        c(C_DIM), label.c_str(), c(C_RESET), value.c_str());
}

bool ask_yn(const std::string& question, bool default_yes, bool assume_yes) {
    if (assume_yes || !::isatty(STDIN_FILENO)) return default_yes;
    std::printf("%s [%s] ", question.c_str(), default_yes ? "Y/n" : "y/N");
    std::fflush(stdout);
    std::string line;
    if (!std::getline(std::cin, line)) return default_yes;
    if (line.empty()) return default_yes;
    return line[0] == 'y' || line[0] == 'Y';
}

}  // namespace fox_install::ui
