---
name: init
description: Perform an architectural interview to bootstrap a new project with mandates and invariants.
---

# /init — The Architect's Interview

Bootstrap a high-discipline workspace by answering a series of strategic questions.

## The Interview Process
The AI will ask the user for:
1.  **Project Goal**: What is the core mission of this codebase?
2.  **Tech Stack**: Primary languages and libraries (e.g., C++23, nlohmann/json).
3.  **Hardware Constraints**: VRAM/RAM limits or specialized targets.
4.  **Safety Rules**: What are the 3-5 rules that must NEVER be broken? (e.g., Path Agnosticism).
5.  **Lifecycle Strategy**: How is state managed? (Init/Exit/Adapt).

## Automatic Generation
Based on the answers, the AI will:
1.  **Generate `AGENT.md`**: Core mandates and architectural style.
2.  **Generate `INVARIANTS.md`**: Safety rules and enforcement grep patterns.
3.  **Generate `CODE_MAP.md`**: Initial project structure overview.
4.  **Setup `.agent/commands/`**: Symlink the universal skills vault.

## Output
A "Workspace Ready" report with the generated architectural documents.
