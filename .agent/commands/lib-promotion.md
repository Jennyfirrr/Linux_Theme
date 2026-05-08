---
name: lib-promotion
description: Identify generic primitives in the current project that are candidates for promotion to a reusable library.
---

# /lib-promotion — Library Candidate Audit

Scan recent additions for generic logic that should be extracted into a shared library.

## Genericity Heuristics
A component is a strong candidate if:
1.  **No Project-Specific Includes**: Does not depend on domain-specific headers or internal project logic.
2.  **Generic API**: Uses naming conventions like `Math_*`, `String_*`, `Buffer_*` rather than `ProjectName_*`.
3.  **Self-Contained**: Can be tested in isolation without project state.
4.  **No Hardcoded Domain Constants**: Avoids project-specific limits (e.g., `MAX_THEMES`, `SERVER_PORT`).

## Instructions
1.  **Scope**: Identify files added or significantly modified since the last library sync.
2.  **Heuristic Scan**: Evaluate each file against the genericity heuristics above.
3.  **Deduplication**: Cross-check against the target library's existing headers to avoid duplication.
4.  **Back-porting**: Identify bug fixes or feature updates in the project that should be pulled back into the library.

## Output
Produce a Markdown report with:
*   [PROMOTE]: Strong candidates with suggested library paths.
*   [REFACTOR]: Partially generic components requiring extraction.
*   [SYNC]: Back-port suggestions for existing library features.
