---
name: gen-cpp
description: Generate modern, high-performance C++ code following Data-Oriented Design.
---

# /gen-cpp — High-Performance C++ Architect

Generate C++ boilerplate and implementation logic following modern standards and performance patterns.

## Instructions
1.  **JSON Standard**: Use the requested JSON library (defaulting to `nlohmann/json`) for all parsing/serialization.
2.  **Data-Oriented Design (DOD)**:
    *   Prioritize Struct-of-Arrays (SoA) for cache-friendly memory access.
    *   Favor composition over complex inheritance hierarchies.
    *   Minimize branching and avoid virtual calls in performance-critical paths.
3.  **Modern Standards**: Adhere to C++20 or C++23 standards.
4.  **Surgical Extraction**:
    *   Provide clear, documented `.hpp` headers.
    *   Provide robust `.cpp` implementations.
    *   Include necessary JSON serializers/deserializers.
5.  **Path Safety**: Ensure all file handling is path-agnostic (using XDG standards or relative paths).

## Output
Produce the required C++ files with a summary of the architectural decisions made.
