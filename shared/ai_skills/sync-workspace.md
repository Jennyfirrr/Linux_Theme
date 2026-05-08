---
name: sync-workspace
description: Synchronize project-private files (plans, skills, local configs) with a private remote repository.
---

# /sync-workspace — Private Data Backup

Back up sensitive or local-only project data to an off-machine repository.

## Instructions
1.  **Identify Targets**: Identify files ignored by the main repository but requiring backup (e.g., `plans/`, .agent-skills/`, `.env` files, local memory overlays).
2.  **Verify Remote**: Ensure the "Workspace" repository is initialized and has a valid private remote.
3.  **Grouping**: Group changes by category (e.g., "plans", "skills", "configs").
4.  **Verification**: 
    *   Ensure no secrets are being accidentally pushed to public remotes.
    *   Confirm all symlinks are resolving correctly.
5.  **Commit**: Generate a smart commit message based on the grouped changes.
6.  **Push**: Push to the private remote branch.

## Output
Report the synchronization status, commit SHA, and target remote.
