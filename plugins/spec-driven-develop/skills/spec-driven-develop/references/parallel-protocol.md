# Parallel Execution Protocol

This protocol defines how the agent should leverage sub-agents during actual development work. Issues are task units; delivery batches are integration and PR units. It applies throughout the implementation, not to a specific phase.

---

## When to Parallelize

At the start of each development phase, read every open Issue in that phase and consult `docs/plan/task-breakdown.md` for delivery batches and parallel lane assignments. Revalidate the planned grouping against current dependencies, file overlap, shared tests, review scope, and rollback boundaries before editing.

- Process delivery batches in dependency order; do not open a PR as soon as one Issue is implemented.
- If a batch has **multiple parallel lanes**, derive dependency-ready execution waves. Launch one `task-executor` per ready lane simultaneously, integrate that wave, then branch the next wave from the updated integration base. Each lane receives the complete batch context plus its assigned task/Issue subset.
- If a batch has **only one lane**, execute the whole batch together — do not force parallelism or split it into task-level PRs.
- If the platform does not support sub-agents, execute all tasks sequentially yourself

---

## How to Launch Parallel Task Executors

For each parallel lane in the current dependency-ready wave:

1. Prepare the input for each `task-executor` agent:
   - Delivery Batch ID, batch goal, rationale, combined validation, and complete ordered task/Issue set
   - Assigned lane ID plus its task IDs and descriptions from the plan
   - **Tracking mode** (`GITHUB_FULL`, `GITHUB_STANDARD`, or `LOCAL_ONLY`)
   - **GitHub Issue numbers** (GitHub modes) or inline task descriptions (LOCAL_ONLY)
   - Per-task acceptance criteria, test expectations, and explicit no-test rationales, if any
   - Per-task memory/governance impact and expected surface updates, if any
   - Relevant source file paths (from `docs/analysis/module-inventory.md`)
   - Coding standards from the orchestrator's dispatch input
   - Current project governance context from the resolved instruction and memory surfaces
   - Summary of completed prerequisite tasks and their outputs

2. Launch all ready lane agents **in a single message** (this is how platforms achieve true parallelism). Each agent works in an isolated worktree to prevent file conflicts. Do not launch a downstream lane until its prerequisite commits are integrated.
   - **In GitHub modes**: Follow the repository branch convention; otherwise each lane uses `work/{batch_id}-{lane_id}-{slug}`. Lane agents commit their work and return branch/commit references, but do not create PRs or use closing keywords.
   - **In LOCAL_ONLY mode**: Use worktree isolation if available; otherwise work sequentially

3. When all agents return, consolidate their results:
   - Verify each agent reported DONE (not BLOCKED)
   - If any agent is BLOCKED, resolve the blocker and re-launch only that agent
   - **In GitHub modes**: Consolidate lane commits onto the batch integration branch (`batch/{batch_id}-{slug}` unless the repository requires another convention). Resolve conflicts there; there is exactly one integration PR for the batch.
   - **In LOCAL_ONLY mode**: If agents worked in worktrees, merge their changes sequentially, resolving any conflicts
   - Run every task's targeted checks plus the batch's combined validation to verify the integrated changes are coherent
   - Verify each completed Issue's acceptance criteria and post its per-task telemetry. In parallel runs, the orchestrator is the single writer for cumulative drift, MASTER.md, and Milestone state.
   - Create the batch PR only after integration passes. Include one `Closes #N` line per fully completed Issue and use `Refs #N` for partial coverage.
   - Verify any reported instruction or memory surface updates are consistent and do not create competing sources of truth

---

## Progress Synchronization

After the orchestrator consolidates a delivery batch:

**In GitHub modes**:
- Verify the batch PR is merged and every Issue named by a `Closes #N` line is closed
- Query GitHub Milestones for updated open/closed counts
- Update MASTER.md's "Issue Mapping", "Delivery Batches", and "Milestones" tables with current states
- Update the platform's native task tool to reflect all completed tasks

**In LOCAL_ONLY mode**:
- Apply lane completion reports to the phase progress file once; lane agents do not write shared progress state
- Update MASTER.md with the final accurate completion counts
- Update the platform's native task tool to reflect all completed tasks

**In all modes**:
- Reconcile memory surface updates from parallel agents before moving on
- Keep resolved instruction surfaces aligned if any lane changed project-level agent instructions

---

## Merge Risk Mitigation

The `task-breakdown.md` includes merge risk ratings for parallel lanes. Apply these safeguards:
- **Low risk**: Merge freely — lanes touch different files
- **Medium risk**: Merge sequentially, run tests between each merge
- **High risk**: Consider running these tasks sequentially instead of in parallel, or use worktree isolation with careful conflict resolution

---

## Post-Integration Architecture Validation

After the test suite passes on integrated parallel results, perform these architecture-level checks. These go beyond functional correctness to verify structural integrity across lane boundaries.

### Cross-Lane S.U.P.E.R Compliance

Verify that parallel execution did not introduce cross-lane violations:
- **S (Single Purpose)**: No module gained responsibilities from multiple lanes
- **U (Unidirectional Flow)**: No circular dependencies introduced between code touched by different lanes
- **P (Ports)**: Interface contracts at lane boundaries remain intact — if Lane A changed a module's API, Lane B's usage still conforms
- **R (Replaceable)**: No lane created implicit coupling that makes another lane's modules harder to replace

### Aggregate Telemetry

After consolidating a delivery batch's parallel results, aggregate the adaptive control telemetry:
1. Sum only the `task_drift` contributions returned by lane agents and not already recorded
2. Add that sum to cumulative `drift_score` once in the Milestone description (GitHub modes) or MASTER.md (LOCAL_ONLY)
3. Evaluate thresholds against the new cumulative score
4. If any threshold is exceeded → trigger the appropriate response (see `references/adaptive-control.md` § 3) BEFORE starting the next delivery batch
