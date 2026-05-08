---
name: review
description: Review changes against project mandates (e.g., Path Agnosticism, Coding Standards).
---

# /review — Mandate Compliance Audit

Review the current staged changes for compliance with project foundational mandates.

## Instructions
1.  **System Audit**: Run **`fstatus`** to verify system health and ensure no project drift has occurred before starting the review.
2.  **Identify Mandates**: Locate and read the project's primary instruction files (e.g., `AGENT.md`, `INVARIANTS.md`) or use **`fask`** to query the project architecture.
3.  **Diff Analysis**: Run `git diff --cached` to inspect the staged changes.
4.  **Mandate Mapping**: Compare the diff against the identified mandates:
    *   **Path Agnosticism**: Check for hardcoded absolute paths; ensure use of environment variables or relative paths.
    *   **Standards**: Verify that any domain-specific syntax or library usage follows the project's stated standards.
    *   **Patterns**: Ensure the code adheres to requested architectural patterns (e.g., Data-Oriented Design, lock-free logic).
4.  **Reporting**: 
    *   List any violations clearly with the file and line number.
    *   Explain which mandate was broken and why.
    *   Provide the corrected code snippet.
5.  **Final Verdict**: Give a [PASS] if compliant or [GAP] if fixes are required.
