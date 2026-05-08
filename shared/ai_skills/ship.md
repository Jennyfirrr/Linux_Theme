---
name: ship
description: Run the post-coding ship ritual — build verify, version bump, commit with structured message, tag, and push.
---

# /ship — Post-Coding Ship Ritual

Execute the high-discipline gate sequence for committing and pushing code.

## Ritual Sequence

1.  **Build Verification**: Run appropriate build commands for the project (tests, gui, suite).
2.  **Test Count**: Capture and compare before/after test/assertion counts.
3.  **Orphan Check**: Run static analysis to detect orphaned functions or broken dispatches.
4.  **Version Bump**: Update version strings/constants in the central version file.
5.  **Map Regen**: Regenerate code maps or documentation if new symbols were added.
6.  **Commit**: Use **`fcommit`** to generate a structured message with Theme, Context, Summary, and Verification Gates based on AI analysis of the staged changes.
7.  **Tag**: Create a git tag matching the new version.
8.  **Push**: Push branch first, then tags (for SSH passphrase safety).

## Output
Report the Shipped version, SHA, Build status, and suggest the Next ship.
