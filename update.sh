#!/bin/bash
# FoxML Theme Hub — Updater
# Pulls system configs back into templates (reverse-renders colors to placeholders)
# Usage: ./update.sh [theme_name]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
SHARED_DIR="$SCRIPT_DIR/shared"
ACTIVE_FILE="$SCRIPT_DIR/.active-theme"

source "$SCRIPT_DIR/mappings.sh"
source "$SCRIPT_DIR/render.sh"

# ─────────────────────────────────────────
# Determine theme
# ─────────────────────────────────────────
THEME_NAME="${1:-}"

if [[ -z "$THEME_NAME" && -f "$ACTIVE_FILE" ]]; then
    THEME_NAME="$(cat "$ACTIVE_FILE")"
fi

if [[ -z "$THEME_NAME" ]]; then
    echo "No active theme set. Usage: ./update.sh [theme_name]"
    exit 1
fi

PALETTE_FILE="$THEMES_DIR/$THEME_NAME/palette.sh"
if [[ ! -f "$PALETTE_FILE" ]]; then
    echo "Theme '$THEME_NAME' not found (missing palette.sh)"
    exit 1
fi

echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                    FoxML Theme Updater                          │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo ""
echo "Active theme: $THEME_NAME"
echo "Pulling system configs back into templates..."
echo ""

# ─────────────────────────────────────────
# Mode: --review (default, prompt per file with diff) or --force (auto).
# Reverse-rendering copies whatever is currently on disk back into the
# tracked templates/. If your machine has been compromised, this is a
# vector for shipping the compromise to anyone else who uses your repo.
# Default to review-on-each-diff. --force bypasses for unattended use,
# user opts in knowingly.
# ─────────────────────────────────────────
UPDATE_MODE="review"
for arg in "$@"; do
    case "$arg" in
        --force)  UPDATE_MODE="force" ;;
        --review) UPDATE_MODE="review" ;;
        --help|-h)
            sed -n '2,5p' "$0" | sed 's/^# \?//'
            echo "Flags:"
            echo "  --review (default)  Show diff and prompt before pulling each file"
            echo "  --force             Pull all changes without prompting (CI / trusted run)"
            exit 0
            ;;
    esac
done
if [[ "$UPDATE_MODE" == "review" ]]; then
    echo "  Review mode: each file change will be diffed and prompted."
    echo "  Run with --force to bypass (only do this on a known-clean machine)."
    echo ""
fi

# Confirm before each file lands in templates/ or shared/. Returns 0 to
# accept the change, 1 to skip. --force short-circuits to accept.
_confirm_update() {
    local label="$1" current="$2" proposed="$3"
    [[ "$UPDATE_MODE" == "force" ]] && return 0
    if ! diff -q "$current" "$proposed" >/dev/null 2>&1; then
        echo ""
        echo "── $label ──"
        diff -u --color=always "$current" "$proposed" 2>/dev/null \
            | head -40 || diff -u "$current" "$proposed" | head -40
        read -r -p "  Pull this change into templates? [y/N/q] " yn
        case "$yn" in
            q|Q) echo "  aborted by user"; exit 0 ;;
            y|Y) return 0 ;;
            *)   echo "  skipped"; return 1 ;;
        esac
    fi
    return 0
}

# ─────────────────────────────────────────
# Build reverse sed expression
# ─────────────────────────────────────────
source "$PALETTE_FILE"
REVERSE_SED="$(build_reverse_sed_expr)"

# ─────────────────────────────────────────
# Update template files (reverse-render)
# ─────────────────────────────────────────
echo "Updating templates..."
for mapping in "${TEMPLATE_MAPPINGS[@]}"; do
    src="${mapping%%|*}"
    dest="${mapping##*|}"
    dest="${dest/#\~/$HOME}"

    # Skip Firefox and conditional entries
    [[ "$dest" == *"FIREFOX_PROFILE"* ]] && continue
    [[ "$dest" == *"GEMINI_DIR"* ]] && continue
    [[ "$dest" == *".oh-my-zsh"* && ! -d "$HOME/.oh-my-zsh" ]] && continue

    if [[ -f "$dest" ]]; then
        reverse_render_file "$dest" "$TEMPLATES_DIR/$src" "$REVERSE_SED"
        echo "  ✓ $src"
    else
        echo "  ⚠ $src (not found at $dest)"
    fi
done

# ─────────────────────────────────────────
# Update shared files (copy as-is)
# ─────────────────────────────────────────
echo ""
echo "Updating shared configs..."
for mapping in "${SHARED_MAPPINGS[@]}"; do
    src="${mapping%%|*}"
    dest="${mapping##*|}"
    dest="${dest/#\~/$HOME}"

    if [[ -f "$dest" ]]; then
        mkdir -p "$(dirname "$SHARED_DIR/$src")"
        cp "$dest" "$SHARED_DIR/$src"
        echo "  ✓ $src"
    fi
done

# ─────────────────────────────────────────
# Special handlers
# ─────────────────────────────────────────
echo ""
echo "Updating special configs..."
update_specials "$TEMPLATES_DIR" "$REVERSE_SED"

echo ""
echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│                      Update Complete!                           │"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo ""
echo "Templates updated at: $TEMPLATES_DIR"
echo ""
