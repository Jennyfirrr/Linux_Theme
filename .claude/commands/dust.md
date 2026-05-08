---
name: dust
description: Audit the codebase for cleanup candidates — rotting comments, dead code, copy-paste patterns. Non-destructive report.
---

# /dust — Codebase Audit

Run a non-destructive audit pass to identify cleanup candidates.

## Scans

1.  **Rotting Comments**: Find TODO/FIXME markers and stale version/phase references.
2.  **Oversized Functions**: Find bodies > 100 lines or nesting depth > 4.
3.  **Copy-Paste Signatures**: Identify logic blocks of 8+ lines repeating in 3+ sites.
4.  **Dead Code**: Find functions/enums/constants defined but never referenced/emitted.
5.  **Abstraction Leaks**: Detect modes or architecture flags proliferating across logic (e.g., > 8 sites for a single mode flag).
6.  **Symmetry Mismatch**: Cross-reference stateful structs against their serialization/snapshot sites to find missing fields.
7.  **Assumption Check**: Identify load-bearing invariants with no direct test/assertion.
8.  **Doc Drift**: Check for documentation referencing non-existent features or old versions.

## Output
Produce a ranked punch list. User decides which items to address.
