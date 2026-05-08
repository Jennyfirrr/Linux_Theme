---
name: fox-intel
description: Detailed reference for the Fox Intelligence Layer (fask, findex, fstatus).
---

# /fox-intel — Semantic RAG & System Awareness

Use this skill to understand or explain the native C++ Intelligence Layer built into the FoxML Workstation.

## Core Commands
1.  **`findex`**: (C++) Generates semantic embeddings for the current project. Must be run after significant code changes to refresh the RAG context.
2.  **`fask <query>`**: (C++) Performs a vector similarity search across the project index and provides an AI-driven answer based on the discovered context.
3.  **`fstatus`**: Audits the health of the AI stack, VRAM usage, and checks for "project drift" (divergence from INVARIANTS.md).
4.  **`fcommit`**: AI-augmented git commit. Analyzes staged diffs and writes high-discipline commit messages.

## Technical Context
- **Models**: Uses `nomic-embed-text` for indexing and `qwen2.5-coder` for chat/generation.
- **Project Awareness**: Detects `$FOXML_PROJECT_ROOT` automatically if `AGENT.md` is present.
- **RAG Engine**: Native C++ implementation using `libcurl` and `nlohmann/json` for maximum performance and low latency.

## When to suggest
- When the user is lost in a large codebase (`fask`).
- When the system feels slow or AI models are failing (`fstatus`).
- Before a major code change to ensure the index is fresh (`findex`).
- During the "Execution" phase to ensure high-quality git history (`fcommit`).
