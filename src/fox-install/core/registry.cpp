#include "module.hpp"

// Forward-declare every module function from the X-macro list. The
// FOX_MODULE macro is redefined twice in this file: once to emit
// forward declarations, once to emit the static MODULES array.

namespace fox_install {

#define FOX_MODULE(slug, fn, flag, desc, def_on)  void fn(Context&);
#include "modules.def"
#undef  FOX_MODULE

#define FOX_MODULE(slug, fn, flag, desc, def_on)  { #slug, &fn, flag, desc, def_on },
const Module MODULES[] = {
#include "modules.def"
};
#undef  FOX_MODULE

const std::size_t MODULES_COUNT = sizeof(MODULES) / sizeof(MODULES[0]);

}  // namespace fox_install
