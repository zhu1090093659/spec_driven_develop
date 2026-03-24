---
name: <source>-to-<target>-framework-dev
description: >-
  Development skill for framework migration (e.g., React to Vue, Express to Fastify).
  Triggers on keywords related to the ongoing framework migration task.
  Reads docs/progress/MASTER.md at the start of every conversation for cross-conversation continuity.
version: 1.0.0
---

# Framework Migration Dev — <SOURCE> → <TARGET>

You are executing development tasks for a framework migration project. Before doing anything, follow the continuity protocol below.

## Cross-Conversation Continuity

1. Read `docs/progress/MASTER.md` immediately.
2. Run the **Session Handshake Protocol**: verify phase file checkbox counts match MASTER.md counts. Phase files are the source of truth. Fix any discrepancies.
3. Check staleness: if Last Updated > 7 days ago, ask the user before proceeding.
4. Report your current position to the user in 2-3 sentences.

## Framework-Specific Standards

<!-- CUSTOMIZE: Replace the placeholders below with project-specific conventions -->

### Source Framework (<SOURCE>)
- **Version**: [Current version in use]
- **Key patterns**: [e.g., class components, HOCs, middleware chains]
- **State management**: [e.g., Redux, Vuex, built-in]
- **Routing**: [Router library and pattern]

### Target Framework (<TARGET>)
- **Version**: [Target version]
- **Equivalent patterns**: [How source patterns map to target patterns]
- **State management**: [Chosen state management approach]
- **Routing**: [Router library and pattern]
- **Style guide**: [Component naming, file structure, coding conventions]

### Migration Patterns
- **Component-by-component**: Migrate one component at a time, keeping both frameworks running
- **Page-by-page**: Migrate entire pages/routes, using a router-level switch
- **Shared utilities**: Identify framework-agnostic code that can be reused directly
- Document every non-obvious mapping choice as ADR-lite in the phase file's Decisions section

### Testing During Migration
- Each migrated component must have equivalent test coverage before marking the task complete
- Integration tests should cover the boundary between old and new framework code

## Progress Update Protocol

After completing each task:
1. Check off the task in the corresponding `docs/progress/phase-N-*.md` file
2. Update the completion count in `docs/progress/MASTER.md`
3. Append to the Timeline: `- YYYY-MM-DD HH:MM — [Phase X Task Y.Z] completed: brief description`
4. Update the "Next Action" field in Current Status
5. If you made a significant decision, record it in ADR-lite format

## Cleanup Trigger

When ALL checkboxes in MASTER.md are marked `[x]`, announce completion and initiate Phase 6 (Cleanup & Documentation Conversion) as defined in the main spec-driven-develop SKILL.
