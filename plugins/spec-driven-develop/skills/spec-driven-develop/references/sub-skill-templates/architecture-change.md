---
name: <architecture-type>-overhaul-dev
description: >-
  Development skill for architecture transformation (e.g., monolith to microservices,
  layered to hexagonal). Triggers on keywords related to the ongoing architecture task.
  Reads docs/progress/MASTER.md at the start of every conversation for cross-conversation continuity.
version: 1.0.0
---

# Architecture Overhaul Dev — <DESCRIPTION>

You are executing development tasks for an architecture transformation project. Before doing anything, follow the continuity protocol below.

## Cross-Conversation Continuity

1. Read `docs/progress/MASTER.md` immediately.
2. Run the **Session Handshake Protocol**: verify phase file checkbox counts match MASTER.md counts. Phase files are the source of truth. Fix any discrepancies.
3. Check staleness: if Last Updated > 7 days ago, ask the user before proceeding.
4. Report your current position to the user in 2-3 sentences.

## Architecture-Specific Standards

<!-- CUSTOMIZE: Replace the placeholders below with project-specific conventions -->

### Source Architecture
- **Pattern**: [e.g., Monolith, Layered MVC]
- **Key boundaries**: [Where the current modules are coupled]

### Target Architecture
- **Pattern**: [e.g., Microservices, Hexagonal, Event-Driven]
- **Service boundaries**: [How to define service/module boundaries]
- **Communication patterns**: [REST, gRPC, message queues, events]
- **Data ownership**: [Each service owns its data vs shared database]
- **Deployment model**: [Containers, serverless, VMs]

### Migration Strategy
- **Approach**: [Strangler fig / Big bang / Parallel run]
- **Feature flags**: [Whether to use feature flags during migration]
- **Backward compatibility**: [API versioning, data format compatibility requirements]

### Architecture Decision Records
- Every boundary decision (what goes into which service) must be recorded as ADR-lite in the phase file's Decisions section
- Every communication pattern choice must be recorded with justification

## Progress Update Protocol

After completing each task:
1. Check off the task in the corresponding `docs/progress/phase-N-*.md` file
2. Update the completion count in `docs/progress/MASTER.md`
3. Append to the Timeline: `- YYYY-MM-DD HH:MM — [Phase X Task Y.Z] completed: brief description`
4. Update the "Next Action" field in Current Status
5. If you made a significant decision, record it in ADR-lite format

## Cleanup Trigger

When ALL checkboxes in MASTER.md are marked `[x]`, announce completion and initiate Phase 6 (Cleanup & Documentation Conversion) as defined in the main spec-driven-develop SKILL.
