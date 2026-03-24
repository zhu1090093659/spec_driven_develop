---
name: <task-name>-dev
description: >-
  Development skill for <TASK_DESCRIPTION>.
  Triggers on keywords related to the ongoing task.
  Reads docs/progress/MASTER.md at the start of every conversation for cross-conversation continuity.
version: 1.0.0
---

# <Task Name> Dev

You are executing development tasks for a project transformation. Before doing anything, follow the continuity protocol below.

## Cross-Conversation Continuity

1. Read `docs/progress/MASTER.md` immediately.
2. Run the **Session Handshake Protocol**: verify phase file checkbox counts match MASTER.md counts. Phase files are the source of truth. Fix any discrepancies.
3. Check staleness: if Last Updated > 7 days ago, ask the user before proceeding.
4. Report your current position to the user in 2-3 sentences.

## Project-Specific Standards

<!-- CUSTOMIZE: Replace the sections below with project-specific conventions -->

### Coding Conventions
- **Style guide**: [Link or description]
- **Naming conventions**: [Functions, variables, files]
- **Error handling**: [Pattern to follow]
- **Logging**: [What and how to log]

### Development Guidelines
- **Testing requirements**: [Unit test coverage, integration tests]
- **Documentation requirements**: [Inline comments, docstrings, README updates]
- **Review checklist**: [What to verify before marking a task complete]

### Decision Recording
- Record every significant choice using ADR-lite format in the phase file's Decisions section
- "Significant" means: any choice where an alternative existed and the alternative would have led to different downstream work

## Progress Update Protocol

After completing each task:
1. Check off the task in the corresponding `docs/progress/phase-N-*.md` file
2. Update the completion count in `docs/progress/MASTER.md`
3. Append to the Timeline: `- YYYY-MM-DD HH:MM — [Phase X Task Y.Z] completed: brief description`
4. Update the "Next Action" field in Current Status
5. If you made a significant decision, record it in ADR-lite format

## Cleanup Trigger

When ALL checkboxes in MASTER.md are marked `[x]`, announce completion and initiate Phase 6 (Cleanup & Documentation Conversion) as defined in the main spec-driven-develop SKILL.
