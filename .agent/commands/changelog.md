---
name: changelog
description: Automatically update the project changelog based on git history.
---

# /changelog — Automated History Log

Generate a user-facing changelog entry for recent project changes.

## Instructions
1.  **History Scan**: Run `git log --format="%H %ad %s" --date=short` to identify all commits since the last changelog entry.
2.  **Diff Review**: For each new commit, read the diff with `git show --stat <hash>` to understand the technical impact.
3.  **Categorization**: Group changes into clear, project-appropriate categories (e.g., Features, Fixes, Documentation, Performance).
4.  **Formatting**: 
    *   Add the new entry at the TOP of the `CHANGELOG.md` file.
    *   Maintain the existing project style (e.g., `## Date — Version`, `### Category`).
    *   Use bullet points for specific changes.
5.  **Audit**: Ensure the entry is readable for users, focusing on "What changed" and "Why it matters" rather than just listing commit messages.

## Output
A staged update to the `CHANGELOG.md` file ready for review and commitment.
