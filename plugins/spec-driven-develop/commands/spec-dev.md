---
description: Launch the Spec-Driven Development workflow for a large-scale project task
argument-hint: <task description, e.g. "rewrite this project in Rust">
allowed-tools: [Read, Glob, Grep, Bash, LS, Write, NotebookRead, WebFetch, TodoWrite, WebSearch, BashOutput]
---

# Spec-Driven Development

You are executing the **Spec-Driven Development** workflow. This is a standardized pre-development pipeline that prepares everything needed before actual coding begins on a large-scale complex task.

## Task Input

The user's task description: $ARGUMENTS

## Cross-Conversation Continuity Check

**CRITICAL**: Before anything else, check if `docs/progress/MASTER.md` exists in the project.

- If it **exists**: Read it now. Run the **Session Handshake Protocol**:
  1. Verify phase file checkbox counts match MASTER.md counts (phase files are source of truth)
  2. Read the "Next Action" field for exact resume point
  3. Check staleness (>7 days → ask user)
  4. Report status in 2-3 sentences
  Do NOT restart. Continue from the exact point where work left off.
- If it **does not exist**: This is a fresh start. Proceed with Phase 0 below.

---

## Workflow Phases

Execute these phases in order. Confirm with the user before advancing to each next phase.

### Phase 0: Intent Recognition, Scope Assessment & Confirmation

1. Parse the task description above.
2. **Scale Assessment**: Quickly scan the project to count files and LOC in scope. Classify:
   - **Small** (<10 files / <1000 LOC) → **Lite Mode**
   - **Medium** (10-100 files / 1000-20000 LOC) → **Standard Mode**
   - **Large** (>100 files / >20000 LOC) → **Full Mode**
   Present the recommended mode. User may override.
3. Confirm with the user:
   - **Scope**: Which parts of the project are included?
   - **Target**: What is the desired end state?
   - **Constraints**: Timeline, compatibility, library preferences?
   - **Priorities**: Performance, maintainability, feature parity?
4. Get explicit confirmation (including workflow mode) before proceeding.

### Phase 1: Deep Project Analysis

> **Lite Mode**: Write only `docs/analysis/quick-summary.md` (tech stack, key files, top 3 risks). Skip to Phase 2.

Launch 2-3 `project-analyzer` agents in parallel, each focusing on a different aspect:
- Agent 1: Overall architecture, tech stack, and entry points
- Agent 2: Module inventory with dependency mapping
- Agent 3: Transformation risks and complexity hotspots (assign Risk IDs: R1, R2...)

**Full Mode**: Instruct agents to use sampling strategy for 100+ file projects.

Consolidate findings into `docs/analysis/`:
- `project-overview.md`
- `module-inventory.md`
- `risk-assessment.md`

### Phase 2: Task Decomposition

**Lookback Check**: Before starting, review Phase 1 outputs for gaps. In Standard/Full Mode, check module inventory and risk assessment; in Lite Mode, re-check quick-summary. If gaps found, update Phase 1 docs.

> **Lite Mode**: Write only `docs/plan/task-list.md` (flat numbered list with effort estimates and acceptance criteria). Skip to Phase 3.

Launch 1-2 `task-architect` agents with the analysis results:
- Provide the full analysis output and the confirmed task definition
- Request 2-3 viable strategies with a recommendation (not just one)
- Request risk-first ordering within each phase

Write to `docs/plan/`:
- `task-breakdown.md` (with Risk column referencing Risk IDs)
- `dependency-graph.md`
- `milestones.md`

### Phase 3: Progress Tracking Documentation

Create the progress tracking system using the templates defined in the skill's `references/doc-templates.md` (located alongside SKILL.md):

> **Lite Mode**: Create only a simplified MASTER.md with embedded task checklist (no per-phase files).

**Standard/Full Mode**:
- `docs/progress/MASTER.md` — master control file with phase summary, links, current status, **Next Action** field, **Timeline** section, **Decisions** section
- `docs/progress/phase-N-<n>.md` — one per phase with task checkboxes, acceptance criteria, **Decisions** section

### Phase 4: Sub-SKILL Generation

> **Lite Mode**: Skip this phase entirely.

1. Ask the user: project-level or global-level installation?
2. Select a base template from `references/sub-skill-templates/`:
   - `language-migration.md` — For language rewrites
   - `architecture-change.md` — For architecture overhauls
   - `framework-migration.md` — For framework changes
   - `general.md` — For everything else
3. Customize the template with project-specific standards.
4. Install: Use the platform's native `skill-creator` if available, otherwise create the SKILL.md directly.

### Phase 5: Handoff

**Coverage Verification**: Before presenting, re-read Phase 0 requirements and verify every requirement maps to at least one task. Fix gaps if found.

Present all generated artifacts to the user in a summary. Include:
- Workflow mode and rationale
- Coverage verification result
- All generated file paths

Ask: "Ready to begin development?"

### Phase 6: Cleanup & Documentation Conversion (triggered when all tasks complete)

When all checkboxes in MASTER.md are done:
1. List all generated artifacts
2. For each, offer three options: **Delete** / **Keep as-is** / **Convert to project docs**
   - Conversion: strip transformation language, update to reflect final state, suggest renaming (e.g., `project-overview.md` → `ARCHITECTURE.md`)
3. Execute user's choices

---

## Rules

- Never skip phases. Lite Mode has pre-defined skips — follow those. Confirm at each boundary.
- Update progress docs after every completed task (checkbox + MASTER.md count + Timeline + Next Action).
- New conversation = Session Handshake first, always.
- Phase files are the source of truth for task completion status.
- Record significant decisions in ADR-lite format.
- Lookback is allowed at the start of Phase 2 and Phase 5.
