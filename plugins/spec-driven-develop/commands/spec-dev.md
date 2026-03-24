---
description: Launch the Spec-Driven Development workflow for a large-scale project task
argument-hint: <task description, e.g. "rewrite this project in Rust">
allowed-tools: [Read, Glob, Grep, Bash, LS, Write, NotebookRead, WebFetch, TodoWrite, WebSearch, BashOutput]
---

# Spec-Driven Development

You are executing the **Spec-Driven Development** workflow. This is a standardized pre-development pipeline that prepares everything needed before actual coding begins on a large-scale complex task.

**Full workflow details are defined in the `spec-driven-develop` skill's `SKILL.md`**. This command provides the execution entry point with agent orchestration guidance.

## Task Input

The user's task description: $ARGUMENTS

## Cross-Conversation Continuity Check

**CRITICAL**: Before anything else, check if `docs/progress/MASTER.md` exists in the project.

- If it **exists**: Read it now. Run the **Session Handshake Protocol** as defined in SKILL.md (integrity verification → state reconstruction → staleness detection → status report). Do NOT restart.
- If it **does not exist**: This is a fresh start. Proceed with Phase 0 below.

---

## Workflow Phases

Execute these phases in order. Confirm with the user before advancing to each next phase. For full phase protocols (including Lite/Standard/Full mode behavior, lookback checks, and coverage verification), refer to SKILL.md.

### Phase 0: Intent Recognition, Scope Assessment & Confirmation

1. Parse the task description above.
2. **Scale Assessment**: Quickly scan the project to count files and LOC in scope. Classify as Lite (<10 files) / Standard (10-100 files) / Full (>100 files). Present the recommended mode; user may override.
3. Confirm scope, target, constraints, and priorities with the user. Get explicit confirmation including workflow mode.

### Phase 1: Deep Project Analysis

> **Lite Mode**: Write only `docs/analysis/quick-summary.md`. Skip to Phase 2.

Launch 2-3 `project-analyzer` agents in parallel:
- Agent 1: Overall architecture, tech stack, and entry points
- Agent 2: Module inventory with dependency mapping
- Agent 3: Transformation risks and complexity hotspots (assign Risk IDs: R1, R2...)

**Full Mode**: Instruct agents to use sampling strategy for 100+ file projects.

Consolidate findings into `docs/analysis/`: `project-overview.md`, `module-inventory.md`, `risk-assessment.md`.

### Phase 2: Task Decomposition

**Lookback Check**: Review Phase 1 outputs for gaps before starting. Update if needed.

> **Lite Mode**: Write only `docs/plan/task-list.md`. Skip to Phase 3.

Launch 1-2 `task-architect` agents:
- Provide the full analysis output and the confirmed task definition
- Request 2-3 viable strategies with a recommendation
- Request risk-first ordering within each phase

Write to `docs/plan/`: `task-breakdown.md`, `dependency-graph.md`, `milestones.md`.

### Phase 3: Progress Tracking Documentation

Create the progress tracking system using templates from `references/doc-templates.md`.

> **Lite Mode**: Create only a simplified MASTER.md with embedded task checklist.

**Standard/Full Mode**: Create `docs/progress/MASTER.md` (with Next Action, Timeline, Decisions sections) and `docs/progress/phase-N-<n>.md` per phase.

### Phase 4: Sub-SKILL Generation

> **Lite Mode**: Skip this phase entirely.

1. Ask the user: project-level or global-level installation?
2. Select a base template from `references/sub-skill-templates/` (language-migration / architecture-change / framework-migration / general).
3. Customize the template with project-specific standards.
4. Install: Use the platform's native `skill-creator` if available, otherwise create the SKILL.md directly.

### Phase 5: Handoff

**Coverage Verification**: Re-read Phase 0 requirements and verify every requirement maps to at least one task. Fix gaps if found.

Present all generated artifacts to the user. Include workflow mode, coverage verification result, and all file paths. Ask: "Ready to begin development?"

### Phase 6: Cleanup & Documentation Conversion (triggered when all tasks complete)

When all checkboxes in MASTER.md are done:
1. List all generated artifacts
2. For each, offer three options: **Delete** / **Keep as-is** / **Convert to project docs**
3. Execute user's choices

---

## Rules

Follow all behavioral rules defined in SKILL.md. Key reminders:
- Never skip phases (Lite Mode has pre-defined skips — follow those)
- Confirm at each phase boundary
- Update progress docs after every completed task (checkbox + MASTER.md count + Timeline + Next Action)
- New conversation = Session Handshake first
- Phase files are the source of truth for task completion
- Dual-write: update both native task tools and Markdown files
- Record significant decisions in ADR-lite format
