# Linux_Theme — Development Guide

Project-specific guidance for working on the FoxML Theme Hub / "Arch + Hyprland + AI" distro lite. Loaded automatically when `claude` runs from this directory.

## What this repo is

A theme + tools + installer for an opinionated Arch Linux + Hyprland + local-AI workstation. Currently mid-migration from a 2400-line `install.sh` to a modular C++ orchestrator (`fox-install`) plus a constellation of native tools under `src/fox-*/`.

## Native tool layout

Every C++ component lives in its own `src/<tool>/` directory with its own `Makefile` exposing `all`, `install`, `clean`, optional `test`. The root `Makefile` auto-discovers every subdir — adding a new tool requires zero root-Makefile edits.

Current tools:

| Tool              | Role                                                                |
| ----------------- | ------------------------------------------------------------------- |
| `fox-intel`       | Library (`libfox-intel.a`) — Ollama client, embeddings, helpers. The AI primitive every other tool links against. |
| `fox-render-fast` | Concurrent template engine. Drop-in for `render.sh`, byte-for-byte match. |
| `fox-pulse`       | Single-epoll daemon multiplexing Hyprland IPC + inotify + debouncers. Replaces `focus-pulse.sh` and `fox-monitor-watch.sh`. |
| `fox-vault`       | `mlock()`'d in-RAM secret store with Unix-socket CLI.               |
| `fox-install`     | C++ orchestrator with X-macro module registry. Mid-port; `install.sh` is still the active install path until wave 2 lands. |

## Adding a new tool

```
mkdir src/fox-foo
# write src/fox-foo/Makefile exposing: all / install / clean / (optional) test
# write src/fox-foo/*.cpp
make           # root Makefile auto-discovers it
make test      # auto-runs your test target if present
```

The Makefile contract is the only requirement. No central registration, no dependency declaration.

## Adding a new install module (fox-install)

```
# 1. Write src/fox-install/modules/foo.cpp:
#
#     #include "../core/context.hpp"
#     #include "../core/shell.hpp"
#     #include "../core/ui.hpp"
#     namespace fox_install {
#     void run_foo(Context& ctx) {
#         ui::section("Doing foo");
#         sh::pacman({"some-pkg"});
#         sh::systemctl_enable("some.service", /*user=*/false);
#     }
#     }
#
# 2. Add one line to src/fox-install/core/modules.def:
#
#     FOX_MODULE( foo, run_foo, "--foo", "What foo does", false )
#
# 3. Rebuild. --help, --foo/--no-foo parsing, dry-run plan, and the
#    dispatcher all pick it up automatically.
```

The X-macro registry in `modules.def` is the single source of truth. The args parser, `--help`, dry-run preview, dispatcher, and registry-validation test all derive from it.

## Reusable headers

Modules and tools share these by `#include`-ing them; never duplicate the functionality.

| Header                       | Provides                                                          |
| ---------------------------- | ----------------------------------------------------------------- |
| `src/fox-intel/fox_intel.hpp` | `FoxIntel.ask(prompt)`, embeddings, `cosine_similarity`, Ollama state mgmt. **Every AI-flavored command imports this — there is no separate "AI module" abstraction; AI is a library call.** |
| `src/fox-install/core/ui.hpp` | Pacman-style `section`/`substep`/`ok`/`warn`/`err`/`progress`/`summary_row`/`ask_yn`. |
| `src/fox-install/core/shell.hpp` | `sh::run`/`capture`/`pacman`/`systemctl_*`/`sudo_warmup` + `set_dry_run`. Never `system()`/`popen()` directly. |
| `src/fox-install/core/context.hpp` | Shared install state passed into every module. Hardware flags, paths, theme name, global flags. |

## When to port shell → C++

Port when **one or more** of these apply:

- **Frequently invoked** (>1/sec, or in a hot path like Hyprland event handling).
- **Long-running daemon.**
- **Security-critical** (handles secrets, kernel APIs, signing).
- **Needs registry-based extensibility** (more than a handful of modes/subcommands).
- **Complex parsing or data structures** (templates, palettes, graphs, JSON).

**Leave alone** when the script is mostly orchestration of 2–3 commands and runs once per user action — porting it buys verbosity, not perf. Examples that should stay in shell: small `fox-knock`-style wrappers that call one external binary and `notify-send`.

## AI integration recipe

A command goes from "no AI" to "AI-integrated" by adding three lines:

```cpp
#include "../../fox-intel/fox_intel.hpp"
// ...
FoxIntel ai;
std::string summary = ai.ask("Summarize these logs:\n" + logs);
```

There is no AI framework, no plugin system, no "AI module" class to derive from. `libfox-intel.a` is already linked into anything that wants it; instantiate `FoxIntel`, call `.ask()`, done. Embedding-based RAG is `ai.get_embedding(text)` + `FoxIntel::cosine_similarity(a, b)`.

## Testing discipline

`make test` runs every `src/<tool>/test` target.

- **Do** unit-test pure functions: palette parsing, substitution, vault crypto roundtrip, registry invariants.
- **Don't** unit-test modules that call `pacman` / `systemctl`. For those, write integration tests that flip `sh::set_dry_run(true)` and assert the planned command sequence. Real system tests belong in CI under a container.
- Tests live in `src/<tool>/tests/` and are compiled by the tool's own Makefile under a `test` target. The umbrella `make test` skips silently for tools with no test target.

## Conventions

- **C++17**, `-Wall -Wextra`, no exceptions in hot paths (use return codes / `std::optional`).
- **No `system()` / `popen()`** outside `shell.cpp`. Subprocess goes through `sh::` so dry-run + logging stay centralized.
- **Atomic file writes**: `tmp + rename`, never write-in-place.
- **No `mkdir -p` in C++ — use `std::filesystem::create_directories`** (it's already atomic and handles races).
- **Comments**: only when the *why* isn't obvious. Don't narrate what the code does — the names already do that.
- **Memory hygiene** for anything secret: `mlock()` the page, XOR-obfuscate at rest, `explicit_bzero` on destruction. Pattern is in `src/fox-vault/vault_store.cpp`.

## install.sh migration status

**Migration complete.** `install.sh` is a 90-line wrapper (self-update + sudo keepalive + build + exec). All 21 install modules are native C++ — there is no longer any `bridge::call()` site in the fox-install codebase. The bridge infrastructure (`core/mappings_bridge.*`) has been deleted.

**Native module index (all 21):**

| Phase           | Modules                                                                                  |
| --------------- | ---------------------------------------------------------------------------------------- |
| 0 — discovery   | detect, preflight, theme                                                                 |
| 1 — system      | deps, privacy, perf, security (UFW + sysctls + USBGuard + AppArmor + polkit + fail2ban + auditd + waybar-sudoers) |
| 2 — render      | render, symlinks                                                                         |
| 3 — opt-in      | vault, ai, models, github                                                                |
| 4 — GPU         | amd_gpu, intel_gpu, nvidia                                                               |
| 5 — hardware    | fprint                                                                                   |
| 6 — build       | xgboost                                                                                  |
| 7 — per-machine | monitors, personalize                                                                    |
| 8 — report      | summary                                                                                  |

**`install.sh.legacy` is gone.** Every install step has a native module, including the SSH hardening wizard (`--ssh-harden`). Git history retains the legacy bash forever: `git show <pre-cutover-sha>:install.sh`.

**Why `mappings.sh` is still on disk**
- `shared/hyprland_scripts/{fox-monitor-watch.sh, fox-unlock-hook.sh, rotate_wallpaper.sh}` source `mappings.sh` at runtime — they're deployed to `~/.config/hypr/scripts/` by the symlinks module and run as systemd user services. `mappings.sh` is a runtime helper library for them, not an install-time dependency anymore.
- `update.sh` (separate tool) sources `mappings.sh` for its template-capture logic.

**Don't add new install steps to `install.sh` or `mappings.sh`** — write a `fox-install` module instead. The X-macro registry is the single source of truth.

## AI integration (worked example)

The pattern documented in "Reusable headers" / "AI integration recipe" is now live in `src/fox-ai-doctor/`. It gathers system context (failed systemd units, `journalctl -p err`, kernel ring buffer), shapes a prompt, and streams the local Ollama model's response:

```cpp
#include "../fox-intel/fox_intel.hpp"

FoxIntel ai;
if (!ai.ensure_ollama_running()) return 1;

std::string prompt = "Diagnose: ...";
ai.ask(prompt, /*stream=*/true);
```

That's the whole integration. Any future `fox-ai-*` tool follows this shape:

1. Capture context via short-lived `execvp` calls (`systemctl`, `journalctl`, `ufw`, `lspci`, …).
2. Build a focused prompt with the captured state.
3. `FoxIntel.ask(prompt, /*stream=*/true)` and let the response flow to stdout.

Embedding-backed RAG is `ai.get_embedding(text)` + `FoxIntel::cosine_similarity(a, b)`; see `src/fox-intel/fask.cpp` for a reference implementation. **There is no AI framework or plugin abstraction** — `libfox-intel.a` is the dependency, the constructor + `.ask()` are the API.

## What NOT to do

- Don't reintroduce centralized helper bash files. Bash that survives the migration should be small, scoped to one tool, and called from a `fox-install` module.
- Don't add AI integration as a separate "framework." It's `#include "fox_intel.hpp"` + `ai.ask()`. Same pattern everywhere.
- Don't write multi-paragraph docstrings on functions. Headers explain why the file exists; functions get a 1-line comment if anything.
- Don't add a feature flag system for in-development C++ code. Compile it in, gate it behind a CLI flag if needed, delete the flag when stable.
- Don't pre-fork registries or plugin loaders for features that don't have at least three concrete callers yet.

## Useful one-liners

```bash
# Full clean rebuild + test
make clean && make && make test

# Just the orchestrator
make -C src/fox-install && ./src/fox-install/fox-install --help

# Render with the native engine
./src/fox-render/fox-render-fast themes/FoxML_Classic/palette.sh templates /tmp/out

# Dry-run an install plan
./src/fox-install/fox-install --dry-run --full
```
