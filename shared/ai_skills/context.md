---
name: context
description: Generate a project code-map and audit the codebase against safety invariants.
---

# /context — Project Intelligence & Invariants

Provide the AI with an instant, project-wide understanding of file structure and foundational logic rules.

## 1. Code Mapping
*   **Generate Map**: Run `tree -L 3 -I ".git|.claude|rendered"` and `ls -R` to build a structural overview.
*   **Identify Core Files**: Locate and summarize the purpose of entry points (e.g., `install.sh`), config hubs (e.g., `mappings.sh`), and mandates (`GEMINI.md`).
*   **Update CODE_MAP.md**: If the file exists, update it with the latest structure. If not, propose creating it to reduce AI "crawling" time.

## 2. Invariants Audit
*   **Identify Invariants**: Read the project mandates (e.g., `GEMINI.md` or a dedicated `INVARIANTS.md`) to extract "Load-Bearing Assumptions."
*   **Audit Logic**: For each invariant, scan the codebase to verify it is being respected.
    *   Example: "Path Agnosticism" — Scan for hardcoded `/home` paths.
    *   Example: "Hyprland Standard" — Scan for `windowrulev2`.
*   **Gap Detection**: Identify any invariant that does not have a corresponding test or assertion in the code.

## Output
Produce a Markdown report summarizing:
1.  **Structure**: Current project hierarchy.
2.  **Health**: Status of core project files.
3.  **Invariants**: A [PASS/FAIL] list of safety rules with specific drift findings.
