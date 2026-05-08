---
name: readiness
description: Verify a plan before coding starts. Walks the 17-item high-discipline pre-coding protocol.
---

## Instructions
*   **Research**: Use **`fask`** to research existing patterns or "Symmetry/Parity" logic across the codebase before evaluating the plan.
*   **Protocol**: Verify the plan file against the 17-item high-discipline protocol. Output a report with GREEN/YELLOW/RED verdicts.

## The 17-Item Protocol

### 1-10: Foundational Checklist
1.  **Hot Path Purity**: Does any item touch critical paths? Scrutinize for branches/allocation/float math.
2.  **Symmetry/Parity**: Check for train-serve, read-write, or local-remote drift in logic.
3.  **Surface Area**: Files touched count. Flag if > 8 files per phase; propose helper extraction.
4.  **Lifecycle Management**: New heap/state? Check _Init/_Free/NULL-init patterns.
5.  **Backward Compatibility**: Check for version constant bumps or breaking config changes.
6.  **Concurrency**: New threads/atomics? Verify single-writer rules.
7.  **Test Coverage**: Explicit test counts/assertions defined in the plan?
8.  **Docs + Invariants**: Load-bearing rules documented? Changelog entry planned?
9.  **Maintenance Logic**: If code repeats 3+ sites, suggest a helper/X-macro.
10. **Rollback Story**: Git tags/anchors defined for each phase?

### 11-14: Architectural Sprint Guards
11. **Sprint Detection**: If splitting/porting, verify WHERE every function is called post-sprint.
12. **Display Identity**: Verify UI/GUI reads the same field the execution path reads.
13. **Lifecycle Completeness**: Ensure all stages (Init, Adapt, Build, Exit, Adjust) are accounted for.
14. **Dispatch Correctness**: Verify X-macro/function-pointer table signature uniformity.

### 15-17: Logic Hardening
15. **Parity Regression**: Identify snapshot tests that will fail; specify intentional vs bug.
16. **Propagation Check**: Verify new fields propagate to example configs, docs, and recipes.
17. **Failure Paths**: Verify strict-mode behavior (refuse/warn/skip) for all new failure modes.

## Output
Produce a Markdown report. [GREEN] = Ready. [YELLOW] = Minor Fixes. [RED] = Revisit Plan.
