#!/bin/bash
# FoxML Theme Hub — Template Renderer
# Sources a palette and renders templates with {{PLACEHOLDER}} substitution
#
# Usage: ./render.sh <palette.sh> <template_dir> <output_dir>
# Or source this file and call render_all / render_file directly.

set -e

# ─────────────────────────────────────────
# Compute RGB components from hex
# ─────────────────────────────────────────
hex_to_rgb() {
    local hex="$1"
    printf "%d %d %d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# ─────────────────────────────────────────
# Build sed expression from palette variables
# ─────────────────────────────────────────
build_sed_expr() {
    local sed_expr=""

    # All palette variables that hold hex colors (6-char hex without #)
    local hex_vars=(
        BG BG_DARK BG_ALT BG_HIGHLIGHT SELECTION
        FG FG_PASTEL FG_DIM COMMENT
        PRIMARY SECONDARY ACCENT SURFACE
        RED RED_BRIGHT GREEN GREEN_BRIGHT
        YELLOW YELLOW_BRIGHT BLUE BLUE_BRIGHT
        CYAN CYAN_BRIGHT WHITE OK WARN
        BG_DUNST BG_SPICETIFY BG_VENCORD_ALT BG_VENCORD_DEEP CARD_HOVER
        FZF_ACCENT1 FZF_ACCENT2 ZSH_SUGGEST ZSH_CMD
        TMUX_INACTIVE_FG TMUX_ACTIVE_FG TMUX_ACTIVE_BG
        DIFF_ADD DIFF_CHANGE DIFF_DELETE DIFF_TEXT TREESITTER_CTX
        WARM SAND WHEAT CLAY NVIM_BG_HL NVIM_SEL
    )

    # Non-hex variables (strings/numbers)
    local str_vars=(
        THEME_TYPE NVIM_STYLE NVIM_BG KITTY_BG_OPACITY SHOW_WELCOME SHOW_BANNER WALLPAPER
        MAKO_ICON_THEME VSCODE_UI_THEME FONT_FAMILY
        ANSI_ACCENT1 ANSI_ACCENT2 ANSI_ACCENT3 ANSI_ACCENT4 ANSI_ACCENT5
        ANSI_TEXT ANSI_MUTED ANSI_ERROR ANSI_OK ANSI_STANDOUT_BG
        ANSI_PROMPT ANSI_PROMPT2 ANSI_LOAD
        GRAD1 GRAD2 GRAD3 GRAD4 GRAD5
        TMUX_ACTIVE TMUX_INACTIVE
    )

    # Hex variables: substitute {{VAR}} and also {{VAR_R}}, {{VAR_G}}, {{VAR_B}}
    for var in "${hex_vars[@]}"; do
        local val="${!var}"
        [[ -z "$val" ]] && continue
        sed_expr+="s/{{${var}}}/${val}/g;"

        # Compute RGB
        local r g b
        read r g b <<< "$(hex_to_rgb "$val")"
        sed_expr+="s/{{${var}_R}}/${r}/g;"
        sed_expr+="s/{{${var}_G}}/${g}/g;"
        sed_expr+="s/{{${var}_B}}/${b}/g;"
    done

    # String/number variables: just {{VAR}} → value
    for var in "${str_vars[@]}"; do
        local val="${!var}"
        [[ -z "$val" ]] && continue
        # Escape slashes in value for sed
        local escaped="${val//\//\\/}"
        sed_expr+="s/{{${var}}}/${escaped}/g;"
    done

    # PALETTE_LABELS is special (array) — skip, handled by swap.sh directly

    echo "$sed_expr"
}

# ─────────────────────────────────────────
# Render a single template file
# ─────────────────────────────────────────
render_file() {
    local template="$1"
    local output="$2"
    local sed_expr="$3"

    mkdir -p "$(dirname "$output")"
    sed "$sed_expr" "$template" > "$output"
}

# ─────────────────────────────────────────
# Progress bar helper (pacman-style)
# ─────────────────────────────────────────
foxml_progress() {
    local current="$1"
    local total="$2"
    local label="$3"
    
    local width=30
    local percent=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    
    local bar=""
    [[ $filled -gt 0 ]] && bar+=$(printf "%${filled}s" "" | tr ' ' '#')
    [[ $empty -gt 0 ]] && bar+=$(printf "%${empty}s" "" | tr ' ' '-')
    
    printf "\r:: %-25s [%s] %3d%% (%d/%d)" "$label" "$bar" "$percent" "$current" "$total"
}

# ─────────────────────────────────────────
# Render all templates
# ─────────────────────────────────────────
render_all() {
    local palette_file="$1"
    local template_dir="$2"
    local output_dir="$3"

    # Source the palette
    source "$palette_file"

    # Build sed expression
    local sed_expr
    sed_expr="$(build_sed_expr)"

    # Gather files
    local template_files=()
    while IFS= read -r -d '' template; do
        template_files+=("$template")
    done < <(find "$template_dir" -type f -print0)

    local total=${#template_files[@]}
    local current=0

    # Process all template files
    for template in "${template_files[@]}"; do
        current=$((current + 1))
        local rel="${template#$template_dir/}"
        local output="$output_dir/$rel"
        foxml_progress "$current" "$total" "Rendering templates"
        render_file "$template" "$output" "$sed_expr"
    done
    echo "" # newline after progress bar
}

# ─────────────────────────────────────────
# Reverse render: replace actual colors with {{PLACEHOLDER}}s
# Used by update.sh to convert system files back to templates
# ─────────────────────────────────────────
build_reverse_sed_expr() {
    local sed_expr=""

    local hex_vars=(
        BG BG_DARK BG_ALT BG_HIGHLIGHT SELECTION
        FG FG_PASTEL FG_DIM COMMENT
        PRIMARY SECONDARY ACCENT SURFACE
        RED RED_BRIGHT GREEN GREEN_BRIGHT
        YELLOW YELLOW_BRIGHT BLUE BLUE_BRIGHT
        CYAN CYAN_BRIGHT WHITE OK WARN
        BG_DUNST BG_SPICETIFY BG_VENCORD_ALT BG_VENCORD_DEEP CARD_HOVER
        FZF_ACCENT1 FZF_ACCENT2 ZSH_SUGGEST ZSH_CMD
        TMUX_INACTIVE_FG TMUX_ACTIVE_FG TMUX_ACTIVE_BG
        DIFF_ADD DIFF_CHANGE DIFF_DELETE DIFF_TEXT TREESITTER_CTX
        WARM SAND WHEAT CLAY NVIM_BG_HL NVIM_SEL
    )

    local str_vars=(
        THEME_TYPE NVIM_STYLE NVIM_BG KITTY_BG_OPACITY SHOW_WELCOME SHOW_BANNER WALLPAPER
        MAKO_ICON_THEME VSCODE_UI_THEME FONT_FAMILY
        ANSI_ACCENT1 ANSI_ACCENT2 ANSI_ACCENT3 ANSI_ACCENT4 ANSI_ACCENT5
        ANSI_TEXT ANSI_MUTED ANSI_ERROR ANSI_OK ANSI_STANDOUT_BG
        ANSI_PROMPT ANSI_PROMPT2 ANSI_LOAD
        GRAD1 GRAD2 GRAD3 GRAD4 GRAD5
        TMUX_ACTIVE TMUX_INACTIVE
    )

    # Reverse: replace RGB triples first (longer patterns), then hex values
    for var in "${hex_vars[@]}"; do
        local val="${!var}"
        [[ -z "$val" ]] && continue
        local r g b
        read r g b <<< "$(hex_to_rgb "$val")"
        # Replace RGB triple (e.g., "244,181,138" or "244, 181, 138")
        sed_expr+="s/${r}, *${g}, *${b}/{{${var}_R}},{{${var}_G}},{{${var}_B}}/g;"
    done

    # Then replace hex values (case-insensitive)
    for var in "${hex_vars[@]}"; do
        local val="${!var}"
        [[ -z "$val" ]] && continue
        # Match both upper and lowercase hex
        local upper="${val^^}"
        local lower="${val,,}"
        if [[ "$upper" != "$lower" ]]; then
            sed_expr+="s/${lower}/{{${var}}}/g;s/${upper}/{{${var}}}/g;"
        else
            sed_expr+="s/${val}/{{${var}}}/g;"
        fi
    done

    for var in "${str_vars[@]}"; do
        local val="${!var}"
        [[ -z "$val" ]] && continue
        # Escape sed special chars: / . * [ ] ^
        local escaped="${val//\//\\/}"
        escaped="${escaped//./\\.}"
        escaped="${escaped//\*/\\*}"
        sed_expr+="s/${escaped}/{{${var}}}/g;"
    done

    echo "$sed_expr"
}

reverse_render_file() {
    local src="$1"
    local output="$2"
    local sed_expr="$3"

    mkdir -p "$(dirname "$output")"
    sed "$sed_expr" "$src" > "$output"
}

# ─────────────────────────────────────────
# CLI mode
# ─────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 3 ]]; then
        echo "Usage: ./render.sh <palette.sh> <template_dir> <output_dir>"
        exit 1
    fi
    render_all "$1" "$2" "$3"
    echo "Rendered templates to: $3"
fi
