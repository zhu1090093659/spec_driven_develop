---
name: spec-driven-develop
description: >-
  Automates pre-development workflow for large-scale complex tasks. Use when the user
  mentions "rewrite", "migrate", "overhaul", "refactor entire project", "transform",
  "rebuild in [language]", "spec-driven", or describes any large-scale project transformation
  that requires planning before coding. Also triggers on Chinese keywords: "改造", "重写",
  "迁移", "重构", "大规模", "规范驱动". Performs full project analysis, task decomposition,
  documentation generation, project-level instruction and native memory surface resolution,
  progress tracking setup, and then executes the plan within the same session. Keeps Issues as
  task-tracking units while batching related implementation into coherent reviewable PRs.
metadata:
  version: 1.14.0
---

# Spec-Driven Develop

You are executing the **Spec-Driven Development** workflow — a seven-phase pipeline (Phases 0-6) for large-scale complex tasks. Complete preparation phases (analysis, planning, progress setup), then execute the plan — all within a single session.

**Behavioral rules**: `references/behavioral-rules.md` — read and follow them in every phase; they are non-negotiable.

## Configuration

| Path | Default Value | Purpose |
|:-----|:--------------|:--------|
| Analysis output | `docs/analysis/` | Phase 1 analysis documents |
| Plan output | `docs/plan/` | Phase 3 planning documents |
| Progress output | `docs/progress/` | Phase 4 tracking documents (incl. MASTER.md) |
| Instruction surfaces | Resolved per project | Project-level constraints for agents (see Phase 4) |
| Memory surface | Native first | Durable facts via the agent's native memory when available; repo fallback only when explicitly selected |
| Archive output | `docs/archives/<project>/` | Phase 6 archived artifacts |
| Task tracking mode | Auto-detect | `GITHUB_FULL`, `GITHUB_STANDARD`, or `LOCAL_ONLY` |
| Delivery batching | Phase-first | Issues track tasks; PRs integrate coherent task batches |
| Adaptive control | Enabled | Drift thresholds: annotate=20%, replan=40%, rescope=60% of phase tasks |

**Canonical references** (each topic has exactly one home — cite it, never re-explain it):

| Reference | Owns |
|:----------|:-----|
| `references/behavioral-rules.md` | All behavioral rules (1-19) |
| `references/github-integration.md` | Tracking modes, pre-flight check, all `gh` commands and Issue/PR body templates |
| `references/adaptive-control.md` | Telemetry collection, drift calculation, response actions, state storage, controller activation |
| `references/parallel-protocol.md` | Dispatch/review admission (tiers), lane/worktree protocol, review loop, merge risk, post-integration checks |
| `references/super-philosophy.md` | S.U.P.E.R principles + the 10-check review checklist |
| `references/templates/` | Schemas for every generated document (analysis, plan, progress, governance, archive) |

**Task tracking modes** (capabilities differ; detection and upgrade instructions live in `references/github-integration.md` § "Pre-flight Check"):

- **GITHUB_FULL**: Issues + Milestones + Labels + Project board + worktrees + batch PRs
- **GITHUB_STANDARD**: same minus the Project board
- **LOCAL_ONLY**: original local-file workflow, no GitHub dependency

## Before You Begin: Cross-Conversation Continuity Check

**CRITICAL**: Before starting any phase, inventory and read any existing project-level instruction and memory surfaces (`AGENTS.md`, `CLAUDE.md`, existing platform rule files, the active agent's native project memory, any repo-local fallback memory file already declared by the project or by an existing `docs/progress/MASTER.md`).

Then check if `docs/progress/MASTER.md` already exists:

- If it **exists**: Read it immediately. You are resuming an in-progress task. Identify the tracking mode, current phase, and completed work; continue from the exact point where the previous conversation left off. Do NOT restart from Phase 0.
  - **In GitHub modes**: Also query GitHub for the latest task status — see `references/github-integration.md` § "Reading Progress from GitHub". Update MASTER.md if GitHub state is ahead of the local index.
- If it **does not exist**: This is a fresh start. Proceed to Phase 0.

After loading your current state, populate the platform's native task tracking tool (e.g. TodoWrite) with the active phase's pending tasks: content = task description, status = in-progress for the active task, priority mapped P0=high, P1=medium, P2=low. If no native task tool is available, skip this step — MASTER.md alone is sufficient.

---

## Phase 0: Quick Intent Capture

**Goal**: Capture the user's high-level transformation direction in 1-2 sentences — just enough to give Phase 1 analysis a focus.

**Actions**:

1. Extract from the user's message: the transformation type, the rough target state, and any explicitly stated constraints.
2. Summarize the direction back in 1-2 sentences. Do NOT ask deep clarifying questions here — Phase 1 analysis will reveal what to ask. Confirm: "I understand you want to [direction]. Let me first analyze the current project so I can ask you the right questions."
3. If intent is completely unclear, ask ONE high-level question to determine the transformation type.

**Output**: A preliminary direction statement guiding Phase 1. NOT the final task definition — that comes in Phase 2.

---

## Phase 1: Deep Project Analysis

**Goal**: Build a comprehensive understanding of the current codebase, informed by the Phase 0 direction.

**Actions**:

1. Launch `project-analyzer` sub-agents **in parallel**, split by focus area:
   - **Architecture & Stack**: structure, directory layout, tech stack, entry points, build/run commands
   - **Module Inventory**: each module's responsibility, public API surface, size, dependencies — evaluated against all five S.U.P.E.R principles with a per-principle compliance rating
   - **Risks, Tests & Governance**: transformation risks, complexity hotspots, coding conventions, test coverage, instruction/memory surfaces — plus a S.U.P.E.R Architecture Health Summary with violation hotspots (priority targets for the plan)

   Give each agent the Phase 0 direction AND `references/super-philosophy.md`. If sub-agents are unavailable, perform the same analysis sequentially yourself.

2. Consolidate outputs, resolve contradictions, and write `docs/analysis/` documents from `references/templates/analysis.md`:
   - `project-overview.md`, `module-inventory.md` (with per-module S.U.P.E.R scores), `risk-assessment.md` (with the S.U.P.E.R health summary)

3. **GitHub Pre-flight Check**: detect the tracking mode per `references/github-integration.md` § "Pre-flight Check". Report the detected mode; if it differs from user expectation, explain how to upgrade (e.g., `gh auth refresh -s project`).

**Output**: Complete `docs/analysis/` (three documents) + detected tracking mode. The S.U.P.E.R assessment is the architectural baseline for all subsequent phases.

---

## Phase 2: Intent Refinement & Confirmation

**Goal**: With the project analyzed, finalize the task definition through a grounded discussion.

**Actions**:

1. Present key Phase 1 findings: brief architecture summary, notable S.U.P.E.R health issues, and coupling/complexity highlights relevant to the transformation.
2. Ask **targeted questions grounded in the analysis** — specific and informed, not generic (e.g., about circular dependencies found, hardcoded environment assumptions, missing interface contracts). At minimum confirm:
   - **Scope** — which modules from the inventory are in scope
   - **Target** — target technology/architecture/state
   - **Constraints** — timeline, backward compatibility, libraries, deployment targets
   - **Priorities** — performance, maintainability, feature parity (use the risk assessment)
   - **S.U.P.E.R priorities** — which violations to fix now vs. defer
   - **Testing policy** — which test layers protect changes; whether to establish a minimal test harness if none exists
   - **Project governance** — canonical instruction surfaces; native memory surface or explicitly named repo fallback

3. Summarize the refined understanding and get explicit confirmation.

**Output**: The authoritative, confirmed task definition guiding Phases 3-6.

---

## Phase 3: Task Decomposition

**Goal**: Break the transformation into manageable, trackable tasks organized in phases, with parallel lanes and coherent delivery batches.

**Actions**:

1. Launch `task-architect` sub-agents with the full Phase 1 analysis AND the confirmed Phase 2 definition. If multiple strategies are plausible, launch 2 agents exploring different approaches (e.g., bottom-up vs. strangler fig) and pick the better result. If sub-agents are unavailable, decompose yourself.
2. The decomposition must produce:
   - **Phases** ordered by dependency; early phases prioritize fixing S.U.P.E.R violation hotspots before new features.
   - **Tasks**, each with: description, priority (P0/P1/P2), effort (S/M/L/XL), dependencies, S.U.P.E.R design drivers, acceptance criteria, test expectation, and memory/governance impact. Every task's acceptance criteria implicitly include passing the S.U.P.E.R Quick Check for its listed principles.
     - **Testing is default**: tasks changing user-visible features, behavior, API contracts, schemas, migrations, parsing, routing, permissions, caching, or persistence MUST add or update automated tests; documentation/config tasks may mark tests N/A with an explicit reason.
     - **Governance is default**: tasks introducing a stable rule, gotcha, or convention must include updating the resolved memory surface (and instruction surfaces if the rule affects future agents).
   - **Parallel execution lanes** per phase: group mutually independent tasks; assess merge risk (file overlap).
   - **Delivery batches**: after reviewing the complete phase task set (dependencies, file overlap, shared validation, rollout risk, rollback boundary), assign every task to exactly one batch. Default to one coherent PR batch per phase; split only for documented reviewability, release/rollback, ownership, risk-isolation, or policy reasons; a single-Issue batch needs explicit justification. Record per batch: ID, goal, task IDs, execution waves, lanes, integration branch, combined validation, dependency order, split rationale.
   - **Dependency graph** as a Mermaid diagram (subgraphs for batch boundaries and lanes) and **milestones** at phase boundaries.
3. Write `docs/plan/` documents from `references/templates/plan.md`: `task-breakdown.md`, `dependency-graph.md`, `milestones.md`.
4. **GitHub Resource Synchronization** (skip in LOCAL_ONLY): create Labels → Milestones → Issues → [GITHUB_FULL only] Project board, in that order, using the exact commands and the Issue body template in `references/github-integration.md`. Add a 1-second delay between Issue creations. Record all URLs and the Task → Issue → Delivery Batch mapping for Phase 4. Issue creation does not imply PR creation.
5. **Initialize Adaptive Control State**: for each Milestone, compute percentage-based drift thresholds and append the adaptive YAML block per `references/adaptive-control.md` § "Adaptive State Storage". In LOCAL_ONLY mode, the state goes to MASTER.md in Phase 4 instead.

**Output**: Complete `docs/plan/` (three documents); in GitHub modes, all tasks exist as labeled, milestoned Issues with adaptive state initialized.

---

## Phase 4: Progress Tracking Documentation

**Goal**: Create a progress tracking and governance system that survives across conversations.

**Actions**:

Use `references/templates/progress.md` for progress documents and `references/templates/governance.md` for governance records.

### Project Governance Surface (all modes)

1. **Inventory existing surfaces**: shared instruction files (`AGENTS.md` or equivalent), `CLAUDE.md`, existing platform rule files, the agent's native project memory, and repo-local fallback memory files only if they already exist or the user explicitly selects one.
2. **Update instruction surfaces without overwriting**: shared cross-agent rules → `AGENTS.md`; Claude Code-specific → `CLAUDE.md`; platform rule files only when they already exist or are requested. Preserve user-written sections, local commands, and security constraints. If an existing rule conflicts with the plan, do not silently replace it — record the conflict in MASTER.md and ask the user at the next checkpoint.
3. **Resolve the memory surface**: prefer native project memory; never silently create a Markdown memory file; use a repo-local fallback only on user confirmation or existing project declaration. Record the resolution in MASTER.md "Governance Status".

Do not create competing truth sources.

### In GITHUB_FULL or GITHUB_STANDARD mode:

1. Create `docs/progress/MASTER.md` as a **lightweight GitHub index**: task name/description, tracking mode, repository, Project URL (GITHUB_FULL), links to analysis/plan documents, milestone table, Issue mapping table (Task → Issue → Batch → PR → status), delivery batch table, "Quick Status Commands", "Current Status", "Next Steps". Do NOT duplicate task details — those live in GitHub Issues.
2. Add an "Execution Telemetry" reference noting where telemetry and drift state live per `references/adaptive-control.md` § "Adaptive State Storage" (Issue comments + Milestone descriptions).
3. Per-phase detail files are optional and lightweight (Issue references only).

### In LOCAL_ONLY mode:

1. Create `docs/progress/MASTER.md`: task name/description, `LOCAL_ONLY` mode, links to analysis/plan documents, phase summary table, links to phase files, "Current Status", "Next Steps".
2. Create one `docs/progress/phase-N-<short-name>.md` per phase: checkbox tasks with inline acceptance criteria plus a "Notes" section.
3. Add the "Adaptive Control State" section and a "Task Telemetry Log" table to MASTER.md per `references/adaptive-control.md` § "Adaptive State Storage".

### Common to all modes:

- Phases use `- [ ] Phase N: <name> (0/X tasks)` linking to the phase file (LOCAL_ONLY) or milestone URL (GitHub modes); `- [x] Phase N: <name> (X/X tasks)` when done.
- "Current Status" is updated at the start and end of each work session.

**Output**: Complete `docs/progress/` with MASTER.md (plus phase files in LOCAL_ONLY).

---

## Phase 5: Confirm & Execute

**Goal**: Present preparation artifacts, get confirmation, then execute the plan.

**Actions**:

### 5a. Summary & Confirmation

1. Present: task definition (Phase 2), key findings (Phase 1), phased plan with task counts (Phase 3), delivery batch overview with PR count and split rationales (Phase 3), tracking mode and its implications, progress system description (Phase 4), and the execution model (tiered dispatch: orchestrator-direct by default; `task-executor`/`code-reviewer` sub-agents dispatched per `references/parallel-protocol.md` § "Dispatch Admission (Tiered Execution)").
2. List all generated artifacts (analysis, plan, and progress documents; resolved instruction and memory surfaces; GitHub Project URL, Milestone URLs, Issue numbers, batch mapping in GitHub modes).
3. Ask the user: "All preparation is complete. Ready to begin execution?"

### 5b. Execution

1. **Process each phase sequentially.** Before editing, read every open Issue in the phase and revalidate the planned batches against current dependencies, affected files, review scope, and repository rules. If the mapping must change, update `task-breakdown.md`, MASTER.md, and the `Delivery Batch` field in every affected Issue body; comment the regrouping reason so all execution surfaces agree.

2. **Choose the execution tier for each delivery batch** per the admission criteria in `references/parallel-protocol.md` § "Dispatch Admission (Tiered Execution)":
   - **Tier 0 — orchestrator-direct (default)**: S/M effort, ≤ 3 files, context already held, or machine-verifiable acceptance. Execute directly on the batch integration branch. No sub-agents, no worktrees.
   - **Tier 1 — single coder**: L/XL bundles or context-heavy exploration. Delegate the complete batch to one `task-executor`.
   - **Tier 2 — parallel lanes**: only when ALL hold — disjoint lane file sets, ≥ L effort per lane, independent verifiability, ≤ 4 lanes. Launch one `task-executor` per dependency-ready lane in isolated worktrees, in waves, each with the full batch context plus its task/Issue subset. Lane agents never create PRs.
   - Branch convention: repository's own; otherwise `batch/{batch_id}-{slug}` (integration) and `work/{batch_id}-{lane_id}-{slug}` (Tier 2 lanes only).

3. **Review before integrating** per `references/parallel-protocol.md` § "Review Admission (Tiered Review)":
   - **L1 — machine validation (always)**: every task's targeted checks plus the batch's combined validation.
   - **L2 — orchestrator diff review (default)**: personally read the diff against every Issue's acceptance criteria.
   - **L3 — independent reviewer (reserved)**: one `code-reviewer` per lane, mandatory for Tier 2 lanes and high-risk work (contract/port formats, logic code, cross-surface semantic invariants). Verdict APPROVED | FIXED | ESCALATE; integrate only APPROVED or FIXED lanes; resolve ESCALATE yourself, with the user when needed.
   - Writer model: reviewers never write GitHub state, MASTER.md, drift state, or instruction/memory surfaces. You remain the acceptance-verification authority and single writer for all shared state.

4. **After each task completion** — follow `references/adaptive-control.md` § "Controller Activation": collect telemetry, update cumulative `drift_score`, write telemetry to the Issue (GitHub modes) or MASTER.md (LOCAL_ONLY), and execute automatic threshold responses. For parallel lanes, lane agents return per-task telemetry and you record it once during batch integration.

5. **Integrate and validate each delivery batch** per `references/github-integration.md` § "Delivery Batch Execution Workflow":
   - Consolidate reviewed lane branches onto the batch integration branch; reconcile overlaps.
   - Run per-task checks plus combined validation and post-integration architecture checks.
   - Verify every included Issue's acceptance criteria yourself (L2). Keep incomplete Issues out of closing keywords.
   - Create exactly one batch PR with one `Closes #N` per completed Issue. Immediately write the PR number and `in review` state to the batch row and every completed Issue row in MASTER.md; keep partial Issues open with explicit partial status.
   - A single-Issue PR is allowed only for a documented exception or a one-Issue phase.

6. **Progress updates**:
   - **GitHub modes**: merged batch PRs auto-close their Issues; update MASTER.md "Current Status", "Issue Mapping", "Delivery Batches".
   - **LOCAL_ONLY**: check off tasks in phase files; update MASTER.md counts.
   - **All modes**: durable knowledge → resolved memory surface; agent-behavior changes → resolved instruction surfaces.

7. **When all tasks are complete** (all Issues closed or all checkboxes checked): proceed to Phase 6.

**Output**: All planned tasks implemented and verified.

---

## Phase 6: Archive

**Trigger**: All tasks complete — all Issues closed (GitHub modes) or all checkboxes `[x]` (LOCAL_ONLY).

**Goal**: Archive all workflow artifacts for traceability, then clean up working directories.

**Actions**:

1. Announce completion to the user.
2. Determine the archive directory name from the Phase 2 task name (lowercase, hyphens, no special characters): `docs/archives/<project-name>/`. Target structure and index template: `references/templates/archive.md`.
3. Move `docs/analysis/`, `docs/plan/`, and `docs/progress/` into the archive; copy snapshots or export references for the resolved instruction and memory surfaces into `docs/archives/<project-name>/governance/`; move any other temporary workflow files.
4. **[GitHub modes]** Close each phase's Milestone (if not already closed); optionally close the Project board. These remain on GitHub as a permanent record.
5. Create or update `docs/archives/README.md` with an entry: project name, one-line description, date range, link to archived MASTER.md, and (GitHub modes) the Project URL.
6. Remove the now-empty `docs/analysis/`, `docs/plan/`, `docs/progress/` directories. Keep active instruction and memory surfaces in place; only their snapshots live under the archive.
7. Suggest the user commit the archive to version control.

**Output**: All artifacts under `docs/archives/<project-name>/` with an updated `docs/archives/README.md` index.
