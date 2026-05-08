---
name: plan-check
description: Cross-verify multiple plans in a sprint for consistency and dependencies.
---

# /plan-check — Sprint Integration Audit

Verify the cohesion of a multi-plan sprint, checking for dependency conflicts and architectural drift.

## Instructions
1.  **Map the Sprint**: Identify the "Master Plan" and all associated sub-plans.
2.  **Conflict Detection**:
    *   **Files**: Flag any file touched by multiple plans without clear coordination.
    *   **Fields**: Check for configuration name collisions or semantic mismatches across plans.
    *   **Invariants**: Ensure no plan violates an architectural invariant claimed by another.
3.  **Dependency Validation**:
    *   Verify that predecessor plans are scheduled before dependents.
    *   Confirm the deliverables of one plan satisfy the needs of the next.
    *   Detect circular dependencies (A -> B -> A).
4.  **Sanity Checks**:
    *   Cumulative effort check: Ensure the total estimated time is realistic.
    *   Test count check: Sum of planned tests should match the sprint goals.
5.  **Status Reporting**:
    *   Produce a report with [GREEN], [YELLOW], or [RED] status for the entire sprint.
    *   List specific "Must Fix" items before coding starts.

## Output
A unified Markdown report summarizing the sprint's architectural integrity.
