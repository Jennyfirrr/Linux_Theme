#!/usr/bin/env bash
# FoxML Theme Hub — installer entry point.
#
# As of the C++ orchestrator migration, install.sh is a thin wrapper:
#
#   1. (Optionally) self-update from origin/main.
#   2. Cache sudo + keep the credential alive across the long-running
#      module sequence.
#   3. Build fox-install if it isn't already on disk.
#   4. exec fox-install with the same argv. Every install step lives in
#      src/fox-install/modules/ now — adding new functionality means
#      writing one .cpp and adding one line to core/modules.def.
#
# The previous 2400-line bash implementation is preserved as
# install.sh.legacy for one-version-rollback safety; mappings.sh stays
# as the source of truth for modules still bridged to bash (security,
# personalize, monitors, github — see CLAUDE.md "install.sh migration
# status").

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOX_INSTALL_BIN="$SCRIPT_DIR/src/fox-install/fox-install"

# ─────────────────────────────────────────
# Self-update — pull latest installer from origin/main and re-exec.
# Skip with FOXML_NO_UPDATE=1 or when not in a clean git work tree.
# Stays in shell because re-execing native after a code refresh would
# need a second build step anyway.
# ─────────────────────────────────────────
if [[ "${FOXML_NO_UPDATE:-0}" != "1" && "${FOXML_UPDATED:-0}" != "1" ]] \
    && git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch="$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo)"
    dirty="$(git -C "$SCRIPT_DIR" status --porcelain 2>/dev/null | head -c 1 || echo)"
    if [[ "$branch" == "main" && -z "$dirty" ]]; then
        if timeout 15 git -C "$SCRIPT_DIR" fetch --quiet origin main 2>/dev/null; then
            local_sha="$(git -C "$SCRIPT_DIR" rev-parse HEAD)"
            remote_sha="$(git -C "$SCRIPT_DIR" rev-parse origin/main)"
            if [[ "$local_sha" != "$remote_sha" ]]; then
                if git -C "$SCRIPT_DIR" merge-base --is-ancestor HEAD origin/main 2>/dev/null; then
                    echo ":: Self-update: pulling origin/main (fast-forward only)"
                    git -C "$SCRIPT_DIR" pull --ff-only --quiet
                    export FOXML_UPDATED=1
                    exec "$SCRIPT_DIR/install.sh" "$@"
                fi
            fi
        fi
    fi
fi

# ─────────────────────────────────────────
# Sudo cache + keepalive. Long installs (--full with --models pulling
# multi-GB Ollama models) easily exceed sudo's 5-minute default TTL.
# Background loop refreshes the cache every 50s; trap kills it on exit.
# ─────────────────────────────────────────
if [[ -t 0 ]] || [[ "${1:-}" == *"--yes"* ]] || [[ "${ASSUME_YES:-0}" == "1" ]]; then
    if sudo -v 2>/dev/null; then
        ( while true; do sudo -n true 2>/dev/null || exit; sleep 50; done ) &
        SUDO_KEEPALIVE_PID=$!
        trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
    else
        echo "warning: sudo cache cold — privileged steps will prompt or fail." >&2
    fi
fi

# ─────────────────────────────────────────
# Build the native orchestrator if it isn't on disk already.
# `make` recurses through every src/<tool>/ and is idempotent under
# `--needed`-style re-runs (it just no-ops if everything is up to date).
# ─────────────────────────────────────────
if [[ ! -x "$FOX_INSTALL_BIN" ]]; then
    echo ":: Building native orchestrator (fox-install + libfox-intel)..."
    # nlohmann json.hpp is a fox-intel build dep.
    if [[ ! -f "$SCRIPT_DIR/src/fox-intel/json.hpp" ]]; then
        curl -fsSL \
            https://github.com/nlohmann/json/releases/latest/download/json.hpp \
            -o "$SCRIPT_DIR/src/fox-intel/json.hpp"
    fi
    if ! make -C "$SCRIPT_DIR" >/dev/null 2>&1; then
        # Rerun loudly so the user sees the actual compile error.
        make -C "$SCRIPT_DIR"
        echo "error: native orchestrator build failed; see output above." >&2
        exit 1
    fi
fi

# ─────────────────────────────────────────
# Hand control to the native orchestrator.
# ─────────────────────────────────────────
exec "$FOX_INSTALL_BIN" "$@"
