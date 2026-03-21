---
name: <source>-to-<target>-dev
description: >-
  Development skill for migrating from <SOURCE_LANGUAGE> to <TARGET_LANGUAGE>.
  Triggers on keywords related to the ongoing migration task.
  Reads docs/progress/MASTER.md at the start of every conversation for cross-conversation continuity.
version: 1.0.0
---

# <SOURCE_LANGUAGE> → <TARGET_LANGUAGE> Migration Dev

You are executing development tasks for a language migration project. Before doing anything, follow the continuity protocol below.

## Cross-Conversation Continuity

1. Read `docs/progress/MASTER.md` immediately.
2. Run the **Session Handshake Protocol**: verify phase file checkbox counts match MASTER.md counts. Phase files are the source of truth. Fix any discrepancies.
3. Check staleness: if Last Updated > 7 days ago, ask the user before proceeding.
4. Report your current position to the user in 2-3 sentences.

## Language-Specific Standards

<!-- CUSTOMIZE: Replace the placeholders below with project-specific conventions -->

### Source Language (<SOURCE_LANGUAGE>) Reading Guidelines
- Understand but do not modify original code unless explicitly needed for reference
- Map source idioms to their target equivalents (document in phase file Notes)

### Target Language (<TARGET_LANGUAGE>) Coding Conventions
- **Style guide**: [Link or description of the style guide to follow]
- **Error handling pattern**: [e.g., Result<T, E> for Rust, try/except for Python]
- **Naming conventions**: [e.g., snake_case for functions, PascalCase for types]
- **Module organization**: [How to structure the new codebase]
- **Dependency management**: [Package manager, version pinning policy]

### Translation Patterns
- Document every non-trivial translation choice as an ADR-lite entry in the phase file's Decisions section
- When the source language has a feature with no direct equivalent in the target, record the chosen workaround

## Progress Update Protocol

After completing each task:
1. Check off the task in the corresponding `docs/progress/phase-N-*.md` file
2. Update the completion count in `docs/progress/MASTER.md`
3. Append to the Timeline: `- YYYY-MM-DD HH:MM — [Phase X Task Y.Z] completed: brief description`
4. Update the "Next Action" field in Current Status
5. If you made a significant decision, record it in ADR-lite format

## Cleanup Trigger

When ALL checkboxes in MASTER.md are marked `[x]`, announce completion and initiate Phase 6 (Cleanup & Documentation Conversion) as defined in the main spec-driven-develop SKILL.
