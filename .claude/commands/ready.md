---
name: readiness
description: Verify a plan before coding starts. Walks the 17-item FoxML Pre-Flight protocol.
---

# /readiness — FoxML Plan Verification

## 17-Point Pre-Flight Protocol

1.  **AI Stack Verification**: Are 7B, 14B, and 32B models pulled and ready?
2.  **Ollama Service**: Is the local backend active and reachable?
3.  **Path Agnosticism**: Does the plan use standard environment variables (XDG_CONFIG_HOME, etc.) instead of hardcoded `/home` paths?
4.  **Hyprland Syntax**: Does the plan strictly use `windowrule` and `col.active_border`? (windowrulev2 is prohibited).
5.  **Template Integrity**: If modifying core logic, is the `templates/` directory updated alongside?
6.  **Mapping Sync**: Is `mappings.sh` updated to reflect any new files or changed destinations?
7.  **VRAM Budgeting**: For any AI features, does the plan respect the **4GB VRAM** hard limit?
8.  **Render Engine Compatibility**: Does the plan integrate with `render.sh` for color substitution?
9.  **Installer Flags**: Does the plan account for interactions with `--deps`, `--secure`, or `--ai`?
10. **Data-Oriented C++**: If refactoring, does the design follow SoA (Struct-of-Arrays) and branchless principles?
11. **JSON Standard**: Is `nlohmann/json` specified for all configuration parsing/merging?
12. **Bash to C++ Parity**: Does the new C++ logic match the validated Bash source behavior 1:1?
13. **Security Mandates**: No hardcoded secrets or insecure file permissions planned?
14. **Test Coverage**: Does the plan mention verification via `./install.sh --render-only`?
15. **Changelog Compliance**: Does the plan include a versioned entry for `CHANGELOG.md`?
16. **Backup Policy**: Does the plan use the `backup_and_copy` helper for all system writes?
17. **Rollback Strategy**: Is there a clear git tag or manual rollback step defined for each phase?

## Output
Produce a detailed Markdown report with [GREEN], [YELLOW], or [RED] verdicts per category.
