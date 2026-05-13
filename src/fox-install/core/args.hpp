#ifndef FOX_INSTALL_ARGS_HPP
#define FOX_INSTALL_ARGS_HPP

#include "context.hpp"

#include <string>
#include <vector>

namespace fox_install::args {

struct Parsed {
    std::vector<bool> module_enabled;     // size = MODULES_COUNT, indexed by module order
    bool show_help    = false;
    bool show_version = false;
    bool quiet        = false;
    bool full         = false;            // alias for "enable every default + every major opt-in"
    bool resume       = false;            // --resume
    std::string phase;                    // --phase <slug>
};

// Parses argv into Parsed + populates global flags on `ctx`.
// Returns false on parse error (prints to stderr).
bool parse(int argc, char** argv, Parsed& out, Context& ctx);

// Renders --help text using the X-macro module list.
void print_help(const char* argv0);
void print_version();

// Runs an interactive TTY wizard to group and prompt for opt-ins.
// Updates `out.module_enabled` and `ctx` flags based on user input.
void run_wizard(Parsed& out, Context& ctx);

// Runs an interactive TTY wizard for --full. Walks every prompt-worthy
// module (skipping the always-on backbone) and asks [Y/n] with sane
// defaults — Y for safe modules, N for lockout-risk ones (fprint_pam,
// greetd_fingerprint). Skipped under --yes / no-TTY (those paths use
// the defaults that --full already set).
void run_full_review_wizard(Parsed& out, Context& ctx);

}  // namespace fox_install::args

#endif
