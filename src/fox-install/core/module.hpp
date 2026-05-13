#ifndef FOX_INSTALL_MODULE_HPP
#define FOX_INSTALL_MODULE_HPP

// Single source of truth for installable modules.
//
// To register a new install module:
//
//   1. Write `void run_foo(Context&);` in src/fox-install/modules/foo.cpp.
//   2. Add ONE line to modules.def:
//
//          FOX_MODULE(foo, run_foo, "--foo", "What it does", false)
//
//   3. Rebuild. --help, the arg parser, the dispatcher, and the
//      end-of-install summary all pick it up automatically.
//
// FOX_MODULE arguments:
//   slug         identifier used in code, e.g. `foo`        (must be a valid C identifier)
//   function     symbol to call: void run_foo(Context&)
//   flag         CLI flag, e.g. "--foo"
//   description  one-line description shown in --help
//   default_on   if true, module runs unless explicitly disabled with --no-<slug>

#include "context.hpp"

namespace fox_install {

using ModuleFn = void(*)(Context&);

struct Module {
    const char* slug;
    ModuleFn    fn;
    const char* flag;
    const char* description;
    bool        default_on;
};

// Defined in registry.cpp via X-macro expansion of modules.def.
extern const Module  MODULES[];
extern const std::size_t MODULES_COUNT;

}  // namespace fox_install

#endif
