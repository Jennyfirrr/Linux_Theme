#ifndef FOX_INSTALL_UI_HPP
#define FOX_INSTALL_UI_HPP

// fox-install reusable UI primitives.
//
// Header for everything pacman-style printable: sections, substeps,
// ok/warn/err lines, the progress bar, and the column-aligned summary
// row. Mirrors the helpers in render.sh so output looks consistent
// across the bash and native code paths during the migration.

#include <string>

namespace fox_install::ui {

void init();                                  // detect TTY + color support
bool tty();                                   // are we writing to a real TTY?

void section(const std::string& title);       // ":: Title"
void substep(const std::string& msg);         // " -> msg"
void ok     (const std::string& msg);         // "  + msg"
void warn   (const std::string& msg);         // "warning: msg"
void err    (const std::string& msg);         // "error: msg"

// One-line, right-aligned progress bar. Re-call on the same line until
// done; finalize() emits the trailing newline.
void progress(std::size_t current, std::size_t total, const std::string& label);
void progress_finalize();

// "  label                : value"  — used by the end-of-install summary.
void summary_row(const std::string& label, const std::string& value);

// Yes/no prompt. Returns `default_yes` under --yes mode or when stdin
// isn't a TTY. Empty input picks the default.
bool ask_yn(const std::string& question, bool default_yes, bool assume_yes);

}  // namespace fox_install::ui

#endif
