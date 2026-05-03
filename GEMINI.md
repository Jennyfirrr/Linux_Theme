# FoxML Theme Hub — Gemini Mandates

This file provides persistent instructions and architectural context for the Gemini CLI agent.

## Core Mandates

- **Path Agnosticism**: All configuration mappings and special handlers must be path-agnostic. Use environment variables (e.g., `GEMINI_CONFIG_HOME`, `XDG_CONFIG_HOME`) with appropriate fallbacks.
- **Mapping Patterns**: New application configurations should be added to `TEMPLATE_MAPPINGS` in `mappings.sh`. If an application requires special logic (like JSON merging or complex path resolution), use a placeholder in the mapping (e.g., `GEMINI_DIR`, `FIREFOX_PROFILE`) and implement the logic in `install_specials` and `update_specials`.
- **No Hardcoded Home Paths**: Avoid using hardcoded `/home/user` or `~` in logic when an environment variable or standard placeholder is available.

## Architecture

- **Templates**: All application-specific styles should live in `templates/` using `{{PLACEHOLDER}}` tokens.
- **Palettes**: Themes are defined as simple bash scripts in `themes/<name>/palette.sh`.
- **Special Handlers**: Reserve these for logic that `backup_and_copy` cannot handle (e.g., merging JSON sections, installing extensions, rebuilding caches).

## Future Refactor (C++)

The project is moving toward a compiled CLI tool (likely C++) to replace the aging Bash scripts.
- **Consolidation**: The tool will replace `render.sh`, `install.sh`, `update.sh`, and `swap.sh`.
- **JSON Handling**: Use `nlohmann/json` for native merging.
- **Performance**: Prioritize data-oriented design and branchless patterns for templating efficiency.
