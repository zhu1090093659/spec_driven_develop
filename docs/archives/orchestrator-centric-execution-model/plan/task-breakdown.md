# Task Breakdown

## Overview
- **Total Phases**: 5
- **Total Tasks**: 25
- **Planned Delivery Batches / PRs**: 5 (one per phase)
- **Estimated Total Effort**: XL aggregate (~65 agent-hours; ~40 wall-clock hours with planned lanes)
- **Tracking Mode**: GITHUB_STANDARD (Issues + Milestones + Labels + batch PRs; no Project board)
- **Release**: v1.15.0

## Strategy

Foundation-first phased rewrite — one coherent batch PR per phase, sequential phases, maximal parallel lanes inside each phase.

- **P1 first**: fix stale refs + hygiene + `validate.sh`, so the guard exists before risky rewrites (mitigates R4, R8).
- **P2 (heart)**: the execution-model change lands as ONE coherent batch per AGENTS.md L18 (SKILL.md + references + agent prompts together).
- **P3 follows P2**: the model change rewrites the same files; restructuring after avoids double prose rewrites.
- **P4 (commands/ deletion) is sequenced AFTER P2, not merged**: independent rollback for the Critical-severity R1 (OpenCode load-time failure); one PR must not mix "delete a user-facing surface" with "add a review loop".
- **P5 last**: README structural reconciliation happens once, after the file inventory is final; version bump + release commit closes.

**Ratified design decisions** (orchestrator, from architect's open questions):
1. code-reviewer frontmatter: `model: sonnet`, `color: red`, tools mirror task-executor (Write/Edit/Bash required for fix commits). ✓
2. Verdict taxonomy: APPROVED / FIXED / ESCALATE (coder-rework folds into ESCALATE with orchestrator routing). ✓
3. README.md keeps its 10-check table (user-facing); `super-philosophy.md` becomes the agent-canonical copy. ✓
4. `.gitignore` addition (`__pycache__/`, `*.pyc`, `.DS_Store`) included in T1.3. ✓
5. OpenCode empty-command tolerance: T4.1 runs a node stub-cfg smoke; fallback is `cfg.command ??= {}` no-op with documentation. ✓
6. **No renames/splits/merges** in `references/` or `templates/` during P3 — all de-dup in place via canonical homes + one-line pointers. ✓
7. PR bodies cite the real usage problems per `.github/PULL_REQUEST_TEMPLATE.md` (slow serial execution without review loop, prompt bloat from duplication, redundant command surface). ✓

## Binding Global Constraints

### Style Rule (all phases, all prompt surfaces)

**Every sentence in a prompt file has exactly three legal identities: a rule, a contract, or a pointer. Delete anything that is none of the three.** Prompts must be concise, clear, and unambiguous — one precise rule beats three verbose sentences; no decorative framing, no redundant restatement, no ambiguous hedging. This applies to ALL skills (spec-driven-develop, deep-discuss, review-spd), all references, and all agent prompts.

### Dispatch Economics (binding for all execution AND for the workflow text written in P2)

Adopted 2026-07-26 (user decision 方案 A) after measuring ~7.1M sub-agent tokens for preparation + one batch: **sub-agent dispatch is an economic decision, not a default.** Dispatch pays off only when `parallelism gain + context-isolation value > cold-start tax + duplicated verification + orchestration overhead`.

**Tiered dispatch:**
- **Tier 0 (default) — orchestrator-direct**: S/M effort, ≤3 files, orchestrator already has context, or acceptance is machine-verifiable. No sub-agent, no worktree; work directly on the batch branch.
- **Tier 1 — single coder sub-agent**: L/XL task bundles, heavy exploratory reading, or long outputs that would pollute orchestrator context.
- **Tier 2 — parallel coder lanes**: only when ALL hold — disjoint file sets AND each lane ≥ L effort AND independently verifiable AND ≤4 lanes. Worktrees exist only for parallel sub-agent lanes.

**Tiered review:**
- **L1 (default)**: deterministic acceptance commands (validate.sh, rg sweeps) — near-zero cost.
- **L2 (default)**: orchestrator personally reviews the diff — cheap because the orchestrator holds context.
- **L3 (reserved)**: independent reviewer sub-agent — only for high-risk changes: contract/port formats (executor handoff, document schemas), logic code (validate.sh, opencode-plugin.js), cross-surface writer-model semantics (P2-B1 qualifies).

P2 must encode this model into the workflow itself (see amended acceptance criteria in #20/#21/#22): SKILL.md Phase 5, parallel-protocol.md, and behavioral-rules.md must state tiered dispatch + tiered review as the standing execution policy for all future users of the plugin.

### Canonical-Home Assignments (binding for all P3 lanes)

| Content | Canonical home | Everywhere else |
|:--|:--|:--|
| Behavioral rules (tests-by-default, Issue/PR cardinality, governance/memory resolution, telemetry mandates, writer model) | `references/behavioral-rules.md` | one-line pointer ("See behavioral-rules.md rule N") |
| gh command schemas, mode table, pre-flight check, Issue/PR body templates | `references/github-integration.md` | one-line pointer |
| Telemetry signals, drift formula, thresholds, adaptive-state YAML, telemetry comment format | `references/adaptive-control.md` | one-line pointer |
| Document schemas (MASTER.md, phase files, analysis/plan/governance/archive docs) | `references/templates/*.md` | one-line pointer |
| Phase flow, configuration table | `SKILL.md` | — |
| S.U.P.E.R principles + 10-check Code Review Checklist | `references/super-philosophy.md` | one-line pointer |
| Lane/worktree/review-loop execution protocol | `references/parallel-protocol.md` | one-line pointer |

**Named anchors** (replace brittle §-numbers): adaptive-control.md → "Telemetry Collection", "Drift Score Calculation", "Automatic Response Actions", "Adaptive State Storage", "Controller Activation"; github-integration.md → "Pre-flight Check", "Issue Body Template", "Delivery Batch Execution Workflow", "Reading Progress from GitHub".

### Writer-Model Invariants (binding for all P2 lanes — must survive consistently into SKILL.md Phase 5, parallel-protocol.md, behavioral-rules.md, task-executor.md, code-reviewer.md)

1. Each lane gets exactly one `task-executor` (coder), then exactly one `code-reviewer`, operating in the same worktree on the same lane branch.
2. The reviewer verifies the lane's diff against the per-task acceptance criteria and lane-level checks, and commits fixes **directly to the lane branch**, append-only (never rewrites the coder's commits), using `fix:` commits that reference but never close Issues.
3. The reviewer NEVER writes GitHub Issues/PRs/comments, MASTER.md, drift/adaptive state, or instruction/memory surfaces. It returns a structured Review Report to the orchestrator.
4. The orchestrator integrates only lanes whose verdict is APPROVED or FIXED; ESCALATE is resolved by the orchestrator (with the user when needed).
5. The orchestrator remains the acceptance-verification authority (reviewers assist; the orchestrator decides) and the single writer for all shared state.
6. Reviewer telemetry (review effort, findings, fix commits) flows back through the orchestrator and is recorded once at batch integration.

## S.U.P.E.R Design Constraints

> All tasks must conform to S.U.P.E.R principles. Every task's acceptance criteria implicitly includes: "Passes the S.U.P.E.R Quick Check for the listed principles."

- **S**: Each change solves exactly one problem per batch; the reviewer is a single-purpose role.
- **U**: Truth flows canonical-home → pointer; writer model flows lane → orchestrator. No bidirectional rule definitions.
- **P**: Contracts (executor handoff, reviewer report, document schemas, progress-file format) are load-bearing ports — preserved byte-identical unless parser + fixture change in the same commit.
- **E**: Shared files name no platform-specific tools unhedged; installers honor env overrides.
- **R**: Any duplicated rule must collapse to canonical + pointer so future changes touch one file.

## Testing and Governance Constraints

- **Tests by default**: no automated suite exists in this Markdown-first repo; the test surface is `scripts/validate.sh` (created in T1.4) + static checks per AGENTS.md. Every batch's combined validation runs it. Per-task N/A rationales name the closest validation command.
- **Agent instruction updates**: workflow behavior changes update SKILL.md + affected references/templates + affected agent prompts TOGETHER (AGENTS.md L18); AGENTS.md/CLAUDE.md updates are called out per task.
- **Memory updates**: no native memory surface in this environment; per AGENTS.md policy no repo fallback file is created. Recorded in MASTER.md.
- **Issue/PR separation**: Issues are atomic task/telemetry records; batches are PR units. One batch PR per phase; splits require recorded rationale.

---

## Phase 1: Foundation & Guard
**Goal**: Eliminate all pre-existing stale references and junk; install `scripts/validate.sh` as the standing consistency guard BEFORE any risky rewrite. Mitigates R4, R8, R10, R2(partial).
**Prerequisite**: None.
**S.U.P.E.R Focus**: U (single-source the phase model), P (validation contracts), R (remove propagating junk).

| # | Task | Priority | Effort | Depends On | Lane | Delivery Batch | S.U.P.E.R | Test Expectation | Memory Impact |
|:--|:-----|:---------|:-------|:-----------|:-----|:---------------|:----------|:-----------------|:--------------|
| T1.1 | Fix stale cross-surface references | P0 | M | — | B | P1-B1 | U, R | N/A (docs); validate.sh + rg | None |
| T1.2 | Relocate 10-check S.U.P.E.R checklist to super-philosophy.md | P0 | M | — | B | P1-B1 | U, P, R | N/A (docs); rg dangling-phrase check | None |
| T1.3 | Hygiene: orphan/pycache/.DS_Store + BUNDLED_SKILLS + .gitignore | P0 | S | — | C | P1-B1 | S, R | N/A (deletions); bash -n installers | None |
| T1.4 | Create scripts/validate.sh + exporter smoke fixture | P0 | L | — | A | P1-B1 | P, E | Self-test (negative path) + 7 checks green | None |
| T1.5 | Repair AGENTS.md Truth Sources + Validation | P0 | S | T1.4 | A | P1-B1 | P, U | N/A (governance); run validate.sh | Updates AGENTS.md |

### T1.1 — Fix stale cross-surface references
Single-source the workflow shape as "Phases 0-6" (seven phases) everywhere; remove sub-SKILL leftovers.
- Edits: (a) `SKILL.md` L140 "(Phase 3-7)" → "(Phases 3-6)"; (b) `adaptive-control.md` L15 "Phases 0-7" → "Phases 0-6"; (c) `.codex-plugin/plugin.json` L29 "six-phase development pipeline" → "seven-phase development pipeline (Phases 0-6)"; (d) `README.md` L56 "6-phase pipeline" → "seven-phase pipeline (Phases 0-6)" + zh-CN mirror (verify via rg); (e) `parallel-protocol.md` L3 "the generated sub-SKILL (and the agent using it)" → "the agent", L30 "Coding standards from the sub-SKILL" → "Coding standards from the orchestrator's dispatch input"; (f) `templates/archive.md` L12 drop "and task-specific skill", L44-45 remove `skill/SKILL.md` tree entry; (g) `project-analyzer.md` L82-94: delete the divergent inline pre-flight one-liner (missing `--repo`), replace with one-line pointer to `references/github-integration.md` § "Pre-flight Check", keep the "append detected mode under `## GitHub Integration Mode`" instruction.

**Acceptance Criteria**:
- [ ] `rg -n "sub-SKILL|sub-skill|Sub-SKILL" plugins/ scripts/` → zero hits (archives intentionally untouched)
- [ ] `rg -n "Phase 3-7|Phases 0-7|six-phase|6-phase" plugins/ README.md README.zh-CN.md` → zero hits
- [ ] Both READMEs state the identical phase count (lockstep)
- [ ] `project-analyzer.md` contains no inline `gh` pre-flight pipeline; points at github-integration.md
- [ ] `bash scripts/validate.sh` exits 0 (re-run at batch integration)
- [ ] Passes S.U.P.E.R Quick Check for U, R

**Affected files**: SKILL.md, adaptive-control.md, parallel-protocol.md, templates/archive.md, agents/project-analyzer.md, .codex-plugin/plugin.json, README.md, README.zh-CN.md.

### T1.2 — Relocate the 10-check S.U.P.E.R Code Review Checklist into super-philosophy.md
Fix the dangling contract: `adaptive-control.md` L44 invokes a checklist defined only in README.md L200-211 (not agent-readable). Add section "S.U.P.E.R Code Review Checklist (10 checks)" to `references/super-philosophy.md` with the 10 checks (adapt README table verbatim: 2×S, 2×U, 2×P, 2×E, 1×R, 1×tests) + scoring rule ("All pass = proceed; 1-2 fail = fix before marking complete; 3+ fail = stop and refactor"). Update adaptive-control.md L44 to point at super-philosophy.md § "S.U.P.E.R Code Review Checklist". README table stays (user-facing).

**Acceptance Criteria**:
- [ ] super-philosophy.md contains the 10-item checklist + scoring rule
- [ ] `rg -n "Code Review Checklist" plugins/` shows adaptive-control.md pointing at super-philosophy.md
- [ ] Content matches README.md L200-211 semantically (no third variant)
- [ ] Passes S.U.P.E.R Quick Check for U, P, R

**Affected files**: super-philosophy.md, adaptive-control.md.

### T1.3 — Hygiene: delete junk artifacts and legacy installer entries
Delete: `plugins/spec-driven-develop/skills/review/` (orphan pycache remnant; installers ship it via `cp -R`), `plugins/spec-driven-develop/skills/review-spd/scripts/__pycache__/`, root `.DS_Store`, any other `.pyc`/`__pycache__` found. Remove legacy `"review"` from `BUNDLED_SKILLS` in `scripts/install-codex.sh` L12 and `scripts/install-cursor.sh` L11. Create root `.gitignore` with `__pycache__/`, `*.pyc`, `.DS_Store`.

**Acceptance Criteria**:
- [ ] `plugins/spec-driven-develop/skills/` contains exactly `spec-driven-develop/`, `deep-discuss/`, `review-spd/`
- [ ] Glob `**/*.pyc`, `**/__pycache__/**`, `**/.DS_Store` → zero tracked files; `.gitignore` covers all three patterns
- [ ] `rg -n '"review"' scripts/install-codex.sh scripts/install-cursor.sh` → zero hits; `bash -n` passes on both
- [ ] Passes S.U.P.E.R Quick Check for S, R

**Affected files**: deletions above; `scripts/install-codex.sh`, `scripts/install-cursor.sh`; NEW `.gitignore`.

### T1.4 — Create `scripts/validate.sh` + exporter smoke fixture
New validation script, bash + python3 stdlib only, no new dependencies:
- **(a) Reference existence**: extract backtick-quoted relative paths matching `plugins/...`, `scripts/...`, or containing `references/`, `agents/`, `templates/` segments from all tracked `.md`/`.json`/`.js`; verify existence. MUST skip candidates containing `<`, `>`, `{`, `}`, `*` (template placeholders).
- **(b) Manifest↔filesystem parity**: every path in `.claude-plugin/plugin.json`'s `agents` (and `commands` while present) exists; no unlisted files in `agents/` (or `commands/`); every `readPrompt("...")` literal in `opencode-plugin.js` exists. MUST tolerate an absent `commands` array (P4 needs no validate.sh edit).
- **(c) Version parity**: SKILL.md frontmatter `version:`, `.claude-plugin/plugin.json` `.version`, `.codex-plugin/plugin.json` `.version`, root `.claude-plugin/marketplace.json` `.plugins[0].version` — all equal.
- **(d) JSON validity**: all 4 manifests + `.agents/plugins/marketplace.json` (exclude `.claude/settings.local.json`).
- **(e) ESM syntax**: `node --check --input-type=module < plugins/spec-driven-develop/opencode-plugin.js` (plain `node --check` parses as CJS and fails on `import`). FAIL loudly if node missing.
- **(f) py_compile**: all 3 Python files (`scripts/export-progress.py`, `scripts/review-context.py`, `plugins/spec-driven-develop/skills/review-spd/scripts/review-context.py`).
- **(g) Exporter smoke test**: fixture `scripts/test-fixtures/progress/MASTER.md` + `phase-1-foundation.md` following templates/progress.md LOCAL_ONLY format exactly; run `python3 scripts/export-progress.py scripts/test-fixtures/progress/`; assert via python3 heredoc that JSON contains expected task name, 1 phase with `total_tasks == 2`, 2 parsed tasks with non-empty priority/acceptance.
- Print per-check PASS/FAIL; exit non-zero on any failure.

**Acceptance Criteria**:
- [ ] `bash scripts/validate.sh` exits 0 on merged P1 repo state; prints all 7 checks
- [ ] Negative path verified in a throwaway copy: removing a referenced file fails (a); desyncing one version site fails (c)
- [ ] Check (b) passes with `commands/` present AND with `commands` key absent (simulated)
- [ ] Fixture parses: exporter JSON assertions pass
- [ ] No new dependencies (bash + python3 stdlib + node + rg; if rg absent, python3 fallback — document choice in script header)
- [ ] Passes S.U.P.E.R Quick Check for P, E

**Affected files**: NEW `scripts/validate.sh`, NEW `scripts/test-fixtures/progress/MASTER.md`, NEW `scripts/test-fixtures/progress/phase-1-foundation.md`.

### T1.5 — Repair AGENTS.md Truth Sources + Validation
Truth Sources gains: `plugins/spec-driven-develop/opencode-plugin.js`, the plugin manifests (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, root `.claude-plugin/marketplace.json`), `scripts/`. Do NOT add `commands/` (slated for P4 deletion; record decision in PR body). Validation: add `bash scripts/validate.sh` as primary check (subsumes py_compile; keep `bash -n`, rg checks, `git diff --check`).

**Acceptance Criteria**:
- [ ] Truth Sources lists opencode-plugin.js, all manifests, scripts/
- [ ] Validation's first command is `bash scripts/validate.sh`
- [ ] AGENTS.md contains no `commands/` reference
- [ ] `bash scripts/validate.sh` exits 0
- [ ] Passes S.U.P.E.R Quick Check for P, U

**Affected files**: `AGENTS.md`. **Memory/governance impact**: updates instruction surface.

### Phase 1 Parallel Lanes
| Lane | Tasks | Combined Effort | Merge Risk | Key Files |
|:-----|:------|:----------------|:-----------|:----------|
| A | T1.4 → T1.5 | L+S | Low | scripts/validate.sh (new), scripts/test-fixtures/ (new), AGENTS.md |
| B | T1.1, T1.2 | M+M | Low | SKILL.md, 4 reference files, project-analyzer.md, .codex-plugin/plugin.json, both READMEs |
| C | T1.3 | S | Low | deletions + install-codex.sh, install-cursor.sh, .gitignore |

### Phase 1 Delivery Batches
| Batch | Tasks / Issues | Execution Waves | Goal and Grouping Rationale | Integration Branch | Combined Validation | Depends On | Split Rationale |
|:------|:---------------|:----------------|:----------------------------|:-------------------|:--------------------|:-----------|:----------------|
| P1-B1 | T1.1-T1.5 | W1: Lanes A+B+C parallel | One coherent "stop the drift + install the guard" unit; every later phase depends on it | `batch/p1-b1-foundation-guard` | validate.sh (a-g) green; bash -n all installers; rg post-checks clean; git diff --check | — | Default phase-level batch |

---

## Phase 2: Orchestrator-Centric Execution Model
**Goal**: Pure-orchestrator model with per-lane independent review-and-fix loop. New agent `agents/code-reviewer.md` created and registered on all 5 surfaces. Mitigates R6, R6b, stale-ref #4.
**Prerequisite**: P1-B1 merged.
**S.U.P.E.R Focus**: S (reviewer single-purpose role), U (writer model flows one way to orchestrator), P (reviewer I/O contracts as ports).

| # | Task | Priority | Effort | Depends On | Lane | Delivery Batch | S.U.P.E.R | Test Expectation | Memory Impact |
|:--|:-----|:---------|:-------|:-----------|:-----|:---------------|:----------|:-----------------|:--------------|
| T2.1 | Author agents/code-reviewer.md | P0 | L | — | A (W1) | P2-B1 | S, P, U | N/A (prompt); validate.sh asset check | None |
| T2.2 | Rewrite SKILL.md Phase 5 for the review loop | P0 | L | T2.1 | A1 (W2) | P2-B1 | S, U, P | N/A; rg joint-surface check | Joint-update L18 |
| T2.3 | Insert review loop into parallel-protocol.md | P0 | M | T2.1 | A1 (W2) | P2-B1 | U, P | N/A; rg check | Joint-update L18 |
| T2.4 | Writer-model rules in behavioral-rules.md | P0 | M | T2.1 | A2 (W2) | P2-B1 | U, S | N/A; rg check | Joint-update L18 |
| T2.5 | Restate single-writer invariant in task-executor.md | P0 | M | T2.1 | A2 (W2) | P2-B1 | P, U | N/A; handoff format preserved | Joint-update L18 |
| T2.6 | Reviewer-ready planning in task-architect.md | P1 | S | T2.1 | A2 (W2) | P2-B1 | P | N/A | Joint-update L18 |
| T2.7 | Register code-reviewer on all adapter surfaces | P0 | M | T2.1-T2.6 | B1+B2 (W3) | P2-B1 | P, R | N/A; validate.sh (b) + rg audit | Updates CLAUDE.md |

### T2.1 — Author `plugins/spec-driven-develop/agents/code-reviewer.md`
New sub-agent prompt reusing the contract style of `skills/review-spd/references/reviewer-template.md`, adapted from "return candidate findings" to "review, fix forward, and report". Style Rule applies (rule/contract/pointer sentences only).
- **Frontmatter**: `name: code-reviewer`; description: "Reviews one execution lane's diff against its per-task acceptance criteria, commits fixes directly to the lane branch, and returns a structured verdict to the orchestrator. Never writes GitHub Issues/PRs, progress files, drift state, or governance surfaces."; tools mirror task-executor (Write/Edit/Bash — NOT edit-denied); `model: sonnet`; `color: red`.
- **Mission**: per-lane independent reviewer in the SDD execution loop; reuses review-spd's reviewer-template contract; review-spd remains the separate user-invoked standalone skill (R6b positioning, one sentence).
- **Input Contract**: batch ID + goal; lane ID + assigned task/Issue subset; tracking mode; per-task acceptance criteria (the review checklist); coder's handoff report; lane branch + worktree path; lane-level validation commands; relevant source files; resolved instruction surfaces.
- **Review Protocol**: read coder handoff + every assigned Issue's acceptance criteria; diff lane branch vs. integration base; verify each criterion with evidence; run lane-level checks; fix forward via `fix: {description} (refs #N)` commits, append-only; never amend/rebase coder commits; large design disputes → ESCALATE, don't re-implement.
- **Prohibitions**: writer-model invariants 2, 3, 5 verbatim.
- **Output Contract**:
```markdown
## Lane Review Report: {batch_id} / {lane_id}
### Verdict: APPROVED | FIXED | ESCALATE
### Scope Reviewed
- Tasks / Issues: ... | Commits reviewed: <sha..sha>
### Acceptance Verification
| Task / Issue | Criterion | Result | Evidence |
### Findings
### [Severity] path:line — title (Impact / Evidence / Fix applied or Escalated)
### Fix Commits
- <sha> — description (refs #N)
### Validation Run
- command → result
### Residual Risks / Questions
### Telemetry Inputs
- Review effort: S/M/L/XL | Findings: N | Fix commits: N
```

**Acceptance Criteria**:
- [ ] File exists with frontmatter + all five sections; output contract matches schema
- [ ] Prohibitions state invariants 2, 3, 5 verbatim
- [ ] R6b positioning sentence present
- [ ] validate.sh check (b) passes once T2.7 registers it (verify at integration)
- [ ] Passes S.U.P.E.R Quick Check for S, P, U

**Affected files**: NEW `plugins/spec-driven-develop/agents/code-reviewer.md`.

### T2.2 — Rewrite SKILL.md Phase 5 (§ 5b Execution) for the review loop
Rewrite Phase 5 steps 2-4 to: dispatch one `task-executor` per dependency-ready lane in isolated worktrees (unchanged) → **dispatch one `code-reviewer` per lane in the same worktree, handed the coder's report + per-task acceptance criteria; reviewer commits fixes to the lane branch and returns a Review Report** → orchestrator integrates ONLY lanes with verdict APPROVED or FIXED (ESCALATE → resolve before integration) → consolidate, validate, verify every Issue's acceptance criteria itself (orchestrator remains acceptance authority), one batch PR. Update dispatch wording to include reviewer hand-off; add one line to 5a listing `agents/code-reviewer.md` among execution resources. Preserve batch/telemetry/PR cardinality semantics. Do NOT slim/de-dup here (that is T3.1).

**Acceptance Criteria**:
- [ ] Phase 5 describes coder → reviewer → integrate-only-reviewed-lanes → batch PR
- [ ] Writer-model invariants 1, 4, 5 appear in Phase 5 prose
- [ ] No contradiction with T2.3 text (same sequence, same verdict names)
- [ ] `rg -n "code-reviewer" .../SKILL.md` ≥ 2 hits
- [ ] Passes S.U.P.E.R Quick Check for S, U, P

**Affected files**: SKILL.md (Phase 5 only).

### T2.3 — Insert the review loop into parallel-protocol.md
In the consolidation step, insert the reviewer stage BEFORE consolidation: per lane, dispatch one `code-reviewer` with coder handoff + acceptance criteria; only APPROVED/FIXED lanes proceed; ESCALATE handling. Add reviewer inputs to the per-lane dispatch checklist (acceptance criteria as reviewer checklist, coder handoff, lane validation commands). Restate single-writer: reviewers write fix commits to the lane branch only; orchestrator remains sole writer for integration, drift, MASTER.md, Milestones, PRs. Merge-risk/telemetry sections unchanged in substance.

**Acceptance Criteria**:
- [ ] Protocol order: launch coders → per-lane review → integrate reviewed lanes → combined validation → batch PR
- [ ] Verdict names match code-reviewer.md (APPROVED/FIXED/ESCALATE)
- [ ] Single-writer restatement names reviewer fix-commit ownership explicitly
- [ ] Passes S.U.P.E.R Quick Check for U, P

**Affected files**: parallel-protocol.md.

### T2.4 — Writer-model rules in behavioral-rules.md
Add rule 18: "**Reviewer commit-ownership and authority boundaries.** In the execution review loop, the per-lane code-reviewer may commit fixes only to its lane's branch (append-only, `fix:` commits referencing but never closing Issues). Reviewers never create or comment on GitHub Issues/PRs, never edit MASTER.md or drift/adaptive state, and never write instruction or memory surfaces — their Review Reports return to the orchestrator. The orchestrator remains the acceptance-verification authority and the single writer for all shared state." Terse style, no examples.

**Acceptance Criteria**:
- [ ] New rule present, ≤ 6 lines, matching invariants 2, 3, 5
- [ ] No existing rule contradicted (rules 4, 8, 17 remain consistent)
- [ ] Passes S.U.P.E.R Quick Check for U, S

**Affected files**: behavioral-rules.md.

### T2.5 — Restate single-writer invariant in task-executor.md relative to reviewer fix commits
Surgical edits only — preserve Input Contract and Handoff Format verbatim (load-bearing ports, R5): (a) Commit-and-Handoff section: handoff now feeds a per-lane `code-reviewer`; executor does not continue editing the lane branch post-handoff unless the orchestrator returns it with reviewer findings; (b) Isolation Rules: "Reviewer-authored fix commits on your lane branch are expected and do not violate the single-writer rule — reviewers own fix commits; the orchestrator owns integration state"; (c) Handoff `### Notes` field: add "flag anything the reviewer should double-check".

**Acceptance Criteria**:
- [ ] Input Contract and Handoff Format byte-identical except the one Notes addition
- [ ] Reviewer hand-off and fix-commit ownership stated; no contradiction with rule 18
- [ ] Passes S.U.P.E.R Quick Check for P, U

**Affected files**: agents/task-executor.md.

### T2.6 — Reviewer-ready planning in task-architect.md
Amend acceptance-criteria guidance: criteria must be checkbox-style, independently verifiable, specific enough for an independent reviewer to check without re-deriving intent (exact files, commands, expected outcomes). Amend lane guidance: each lane lists key files so a reviewer can scope its diff. One sentence noting reviewer agents consume per-task acceptance criteria.

**Acceptance Criteria**:
- [ ] Acceptance-criteria definition requires reviewer-verifiable specificity
- [ ] Lane definition requires key-file listing
- [ ] Passes S.U.P.E.R Quick Check for P

**Affected files**: agents/task-architect.md.

### T2.7 — Register code-reviewer on all adapter surfaces
(a) `.claude-plugin/plugin.json`: append `"./agents/code-reviewer.md"` to `agents`. (b) `opencode-plugin.js`: add `readPrompt("agents/code-reviewer.md")` + agents-map entry (`mode: "subagent"`, NO `edit: "deny"` — reviewer commits fixes); fix stale task-executor description to match its frontmatter. Do not otherwise restructure the loader (command removal is P4). (c) `CLAUDE.md`: note `agents/` includes `code-reviewer.md`. (d) `README.md` + `README.zh-CN.md` lockstep: add `code-reviewer.md` to structure tree agents/ section + one bullet stating lanes pass through an independent reviewer before integration.

**Acceptance Criteria**:
- [ ] `rg -l "code-reviewer"` hits all 5 surfaces: plugin.json, opencode-plugin.js, CLAUDE.md, README.md, README.zh-CN.md
- [ ] validate.sh (b) + (e) pass
- [ ] README mirrors are section-equivalent
- [ ] task-executor description in opencode-plugin.js matches its frontmatter
- [ ] Passes S.U.P.E.R Quick Check for P, R

**Affected files**: plugin.json, opencode-plugin.js, CLAUDE.md, README.md, README.zh-CN.md. **Memory/governance impact**: updates CLAUDE.md + user-facing READMEs.

### Phase 2 Parallel Lanes
| Lane | Tasks | Combined Effort | Merge Risk | Key Files |
|:-----|:------|:----------------|:-----------|:----------|
| A (W1) | T2.1 | L | — | agents/code-reviewer.md (new) |
| A1 (W2) | T2.2, T2.3 | L+M | Medium (semantic, not git) | SKILL.md, parallel-protocol.md |
| A2 (W2) | T2.4, T2.5, T2.6 | M+M+S | Medium (semantic, not git) | behavioral-rules.md, task-executor.md, task-architect.md |
| B1 (W3) | T2.7 (manifests+loader+CLAUDE) | M (shared) | Low | plugin.json, opencode-plugin.js, CLAUDE.md |
| B2 (W3) | T2.7 (README mirrors) | M (shared) | Low | README.md, README.zh-CN.md |

> A1‖A2 have zero file overlap but high semantic coupling — made safe by the six binding writer-model invariants; orchestrator diff-reviews both lanes' wording at integration. B1‖B2 are file-disjoint. T2.7 executes as two sub-lanes merging to the same batch branch.

### Phase 2 Delivery Batches
| Batch | Tasks / Issues | Execution Waves | Goal and Grouping Rationale | Integration Branch | Combined Validation | Depends On | Split Rationale |
|:------|:---------------|:----------------|:----------------------------|:-------------------|:--------------------|:-----------|:----------------|
| P2-B1 | T2.1-T2.7 | W1: A; W2: A1‖A2; W3: B1‖B2 | The heart: review-loop model + all joint surfaces + registration, one coherent reviewable unit per AGENTS.md L18 | `batch/p2-b1-orchestrator-review-loop` | validate.sh green (incl. (b) with 4 agents); `rg -c "code-reviewer"` ≥1 on all 5 registration surfaces + SKILL.md + parallel-protocol.md + behavioral-rules.md + task-executor.md; writer-model invariant wording consistency check | P1-B1 | Default phase-level batch (combining with commands/ deletion explicitly rejected — risk isolation per Strategy) |

---

## Phase 3: Prompt Restructure & Single-Sourcing
**Goal**: Every rule in its canonical home; all other sites become one-line references; examples removed; platform names hedged; **all skills' prompts concise/clear/unambiguous per the Style Rule**. Mitigates R5, R11, all 8 duplication hotspots.
**Prerequisite**: P2-B1 merged.
**S.U.P.E.R Focus**: R (de-dup), U (single direction of truth), E (environment-agnostic shared files).

| # | Task | Priority | Effort | Depends On | Lane | Delivery Batch | S.U.P.E.R | Test Expectation | Memory Impact |
|:--|:-----|:---------|:-------|:-----------|:-----|:---------------|:----------|:-----------------|:--------------|
| T3.1 | Restructure SKILL.md to phase flow + pointers | P0 | L | P2-B1 | A | P3-B1 | S, R, U | N/A; validate.sh + line delta | None |
| T3.2 | Slim github-integration.md (keep schemas, hedge worktree) | P0 | M | — | B1 | P3-B1 | P, R, E | N/A; rg dup audit | None |
| T3.3 | Slim adaptive-control.md + named anchors | P0 | M | — | B2 | P3-B1 | P, R | N/A; rg anchor audit | None |
| T3.4 | Hedge behavioral-rules.md rule 9 | P0 | S | — | C | P3-B1 | E | N/A; rg platform-name audit | None |
| T3.5 | Slim all 4 agent prompts (preserve contracts) | P1 | M | T2.5/T2.6 merged | C | P3-B1 | S, R, P | N/A; contract-preservation diff | None |
| T3.6 | Templates prose-slim + progress.md format freeze | P1 | M | T1.4 | D | P3-B1 | P, R | Exporter smoke (g) green | None |
| T3.7 | Single-source audit gate (8 hotspots) | P0 | M | T3.1-T3.6, T3.8 | E (W2) | P3-B1 | R, U | Audit rg suite + validate.sh | None |
| T3.8 | Conciseness pass on satellite skills (deep-discuss, review-spd) | P1 | M | — | F | P3-B1 | S, R | N/A; schema-preservation diff | None |

### T3.1 — Restructure SKILL.md to phase flow + one-line pointers
Slim ~398 → ≤280 lines without behavior change: (a) tracking-mode table → pointer to github-integration.md "Operating Modes"; (b) adaptive thresholds config row → pointer to adaptive-control.md; (c) delete embedded adaptive-state YAML (near-verbatim dup) → pointer to "Adaptive State Storage"; (d) Phase 4 governance inventory → pointers to behavioral-rules.md rules 13-14 + templates/governance.md; (e) tests-by-default/governance-by-default paragraphs → pointers to rules 15-16; (f) remove illustrative Phase 2 example questions, keep the "At minimum, confirm" rule list; (g) verify platform tool names hedged; (h) replace §-number references with named anchors; (i) Phase 5: pointer-de-dup ONLY (functionally rewritten in T2.2). Config table (paths) and phase flow remain SKILL-owned.

**Acceptance Criteria**:
- [ ] ≤ 280 lines with zero behavioral loss (every removed rule has a live pointer)
- [ ] No YAML schema blocks remain in SKILL.md; mode table appears exactly once repo-wide
- [ ] `rg -n "§ [0-9]" .../SKILL.md` → zero hits
- [ ] All outbound `references/...` links resolve — validate.sh (a) green
- [ ] Passes S.U.P.E.R Quick Check for S, R, U

**Affected files**: SKILL.md.

### T3.2 — Slim github-integration.md; hedge worktree tool name
~386 → ~250-280 lines: keep ALL bash schemas + Issue/PR body templates verbatim (ports); cut prose restating behavioral-rules (cardinality → pointer to rule 17; batching rules → pointer, keep gh commands); dedup "Reading Progress from GitHub" vs templates/progress.md quick-status (canonical here; one comment line notes the relationship); hedge "`EnterWorktree`" → "the platform's native worktree mechanism (e.g., Claude Code's `EnterWorktree`)". Section headings stable (named anchors).

**Acceptance Criteria**:
- [ ] Every original ```bash block present and syntactically identical (diff-review)
- [ ] `rg -n "EnterWorktree"` shows hedged form only
- [ ] Cardinality policy stated once (rule 17), referenced here
- [ ] Passes S.U.P.E.R Quick Check for P, R, E

**Affected files**: github-integration.md.

### T3.3 — Slim adaptive-control.md; convert §-anchors to named headings
Keep all YAML/comment schemas verbatim (ports); slim control-theory framing (~290 → ~200); headings exactly match binding anchor names ("Telemetry Collection", "Drift Score Calculation", "Automatic Response Actions", "Adaptive State Storage", "Controller Activation"); internal §-refs → named form. Also fix parallel-protocol.md's L98 §-reference (this lane owns it; no other edit — review loop landed in P2).

**Acceptance Criteria**:
- [ ] YAML/comment schemas byte-identical (diff-review)
- [ ] Headings match anchor table; `rg -n "§ [0-9]" plugins/` → zero hits at batch gate
- [ ] Threshold formulas + drift math unchanged
- [ ] Passes S.U.P.E.R Quick Check for P, R

**Affected files**: adaptive-control.md, parallel-protocol.md (L98 only).

### T3.4 — Hedge behavioral-rules.md rule 9
Rule 9 → "Use the platform's structured question mechanism for all user interactions (e.g., `AskUserQuestionTool` in Claude Code)". Rule numbering stable (inbound refs point at rule numbers). Update this file's §-refs to adaptive-control named anchors (rules 10, 11, 12).

**Acceptance Criteria**:
- [ ] `rg -n "AskUserQuestionTool" plugins/` shows only hedged parenthetical form
- [ ] Rule count/numbering unchanged; no §-number references remain
- [ ] Passes S.U.P.E.R Quick Check for E

**Affected files**: behavioral-rules.md.

### T3.5 — Slim all four agent prompts, preserving contracts
For `project-analyzer.md`, `task-architect.md`, `task-executor.md`, `code-reviewer.md`: remove examples; convert restated rules (tests-by-default, telemetry, single-writer, governance) to one-line pointers to behavioral-rules.md; PRESERVE all Input/Output/Handoff/Review-Report contracts byte-identical (ports, R5). Target ~320 total lines for the 4 files. Style Rule applies throughout.

**Acceptance Criteria**:
- [ ] All contract blocks byte-identical to post-P2 state (diff-review)
- [ ] No rule restated that behavioral-rules.md owns — pointers only
- [ ] Passes S.U.P.E.R Quick Check for S, R, P

**Affected files**: all 4 files under `plugins/spec-driven-develop/agents/`.

### T3.6 — Templates prose-slim + progress.md format freeze
templates/*.md are schemas by design: slim ONLY surrounding prose/comments. **Format freeze (R5): DO NOT change** progress.md's LOCAL_ONLY structures parsed by export-progress.py — title `# <Name> — Progress Tracker`, blockquote `> **Started**:`, phase checklist lines `- [ ] Phase N: <name> (X/Y tasks)`, task blocks `- [ ] **Task N.M**: <title>`, `- Field: value` patterns. Any desired format change requires parser + fixture change in the same commit (recommend: none). plan.md: restated tests-by-default (L32-33) and cardinality prose (L36, L64-68) → pointers to rules 15/17. governance.md/analysis.md/archive.md: comment-level slim only.

**Acceptance Criteria**:
- [ ] validate.sh (g) exporter smoke green — regex contract intact
- [ ] plan.md contains pointers, not restatements, for rules 15/17
- [ ] Passes S.U.P.E.R Quick Check for P, R

**Affected files**: templates/plan.md, progress.md (prose only), governance.md, analysis.md, archive.md (prose only).

### T3.7 — Single-source audit gate
Phase-gate: run the audit suite proving all 8 duplication hotspots collapsed to canonical+pointers: rg counts for (1) cardinality phrasing, (2) governance inventory lists, (3) tests-by-default phrasing, (4) adaptive threshold YAML, (5) mode tables, (6) `batch/{`/`work/{` conventions, (7) telemetry/single-writer + pre-flight + quick-status, (8) version strings (exactly 4, equal — validate.sh (c)). Verify Style Rule application: no unhedged platform tool names in shared files. Produce line-count delta report for PR body. Re-run full validate.sh.

**Acceptance Criteria**:
- [ ] Each hotspot phrase occurs at canonical site + one-line pointers only (audit output in PR body)
- [ ] `bash scripts/validate.sh` exits 0
- [ ] No unhedged platform tool name in shared (non-agent-specific) files
- [ ] Passes S.U.P.E.R Quick Check for R, U

**Affected files**: none (audit); may issue follow-up fixes within the batch.

### T3.8 — Conciseness pass on satellite skills (deep-discuss, review-spd)
Apply the Style Rule to the satellite skills: `skills/deep-discuss/SKILL.md` (~173 lines) and `skills/review-spd/` (`SKILL.md` ~140, `references/reviewer-template.md` ~60, `references/output-format.md` ~83). Remove illustrative examples and verbose framing; every rule stated once, declaratively, unambiguously; phases/behavior unchanged. PRESERVE output schemas in reviewer-template.md and output-format.md byte-identical (ports — code-reviewer.md reuses the reviewer-template contract style; review-spd SKILL references both). Target ≥25% line reduction on the two SKILL.md files.

**Acceptance Criteria**:
- [ ] Both SKILL.md files reduced ≥25% with zero behavioral loss (same phases, same workflow steps)
- [ ] reviewer-template.md + output-format.md output schemas byte-identical (diff-review)
- [ ] No examples remain in either satellite skill; rules are declarative and unambiguous
- [ ] validate.sh (a) green (all internal references resolve)
- [ ] Passes S.U.P.E.R Quick Check for S, R

**Affected files**: `plugins/spec-driven-develop/skills/deep-discuss/SKILL.md`, `plugins/spec-driven-develop/skills/review-spd/SKILL.md`, `plugins/spec-driven-develop/skills/review-spd/references/reviewer-template.md`, `plugins/spec-driven-develop/skills/review-spd/references/output-format.md`.

### Phase 3 Parallel Lanes (exclusive file ownership — zero overlap)
| Lane | Tasks | Combined Effort | Merge Risk | Key Files |
|:-----|:------|:----------------|:-----------|:----------|
| A | T3.1 | L | Low | SKILL.md |
| B1 | T3.2 | M | Low | github-integration.md |
| B2 | T3.3 | M | Low | adaptive-control.md, parallel-protocol.md |
| C | T3.4, T3.5 | S+M | Low | behavioral-rules.md, agents/*.md (4) |
| D | T3.6 | M | Low | templates/*.md (5) |
| F | T3.8 | M | Low | deep-discuss/, review-spd/ (skill files only) |
| E (W2) | T3.7 | M | — | audit only |

### Phase 3 Delivery Batches
| Batch | Tasks / Issues | Execution Waves | Goal and Grouping Rationale | Integration Branch | Combined Validation | Depends On | Split Rationale |
|:------|:---------------|:----------------|:----------------------------|:-------------------|:--------------------|:-----------|:----------------|
| P3-B1 | T3.1-T3.8 | W1: A‖B1‖B2‖C‖D‖F; W2: E | One coherent de-dup unit: single-sourcing only converges if all files move to pointers in the same merge | `batch/p3-b1-prompt-single-sourcing` | validate.sh (a-g) green; exporter smoke green; hotspot rg audit clean; line-delta report attached | P2-B1 | Default phase-level batch |

---

## Phase 4: Command Surface Removal & Distribution Paths
**Goal**: Delete `commands/` atomically across all 5 inbound surfaces (R1); add the `~/.agents` sync path. Mitigates R1, R7, R3 (script half).
**Prerequisite**: P3-B1 merged.
**S.U.P.E.R Focus**: S (skills-only surface), R (removable parts without load-time failure), E (env-overridable installer).

| # | Task | Priority | Effort | Depends On | Lane | Delivery Batch | S.U.P.E.R | Test Expectation | Memory Impact |
|:--|:-----|:---------|:-------|:-----------|:-----|:---------------|:----------|:-----------------|:--------------|
| T4.1 | Delete commands/ atomically (5 surfaces) | P0 | M | P3-B1 | A | P4-B1 | S, R | Load smoke + rg post-check | Updates CLAUDE.md, READMEs |
| T4.2 | Create scripts/install-agents.sh + install-all.sh wiring | P1 | M | T1.3 | B | P4-B1 | E, R | N/A; bash -n + structural diff | None |

### T4.1 — Delete `plugins/spec-driven-develop/commands/` atomically
One logical unit touching every inbound surface: (a) `git rm -r plugins/spec-driven-develop/commands/`; (b) `.claude-plugin/plugin.json`: remove `commands` array; (c) `opencode-plugin.js`: remove command `readPrompt` calls, `commands:` map, and `cfg.command` registration block; KEEP `cfg.skills` + `cfg.agent` intact; document in PR body that validate.sh (b) is the standing R7 mitigation; (d) `CLAUDE.md` L8: remove slash-command line; (e) `README.md`: remove "Manual Trigger (Claude Code)" subsection + `commands/` tree lines; (f) `README.zh-CN.md`: mirror removals. **Verify OpenCode tolerance**: node smoke — import edited opencode-plugin.js, invoke `config` hook with stub `cfg = {}`, assert `cfg.skills.paths` contains skills dir, `cfg.agent` has 4 entries, no `cfg.command` assignment (fallback if evidence shows the key must exist: `cfg.command ??= {}` no-op + documentation).

**Acceptance Criteria**:
- [ ] `rg -n "commands/|/spec-dev|/dp" --type md --type js --type json` → only intentional historical hits under docs/archives/
- [ ] plugin.json has no `commands` key; JSON valid (validate.sh d)
- [ ] Node smoke: plugin loads with zero commands; skills path + 4 agents register on stub cfg
- [ ] `bash scripts/validate.sh` exits 0 in post-deletion state
- [ ] Both READMEs edited in lockstep
- [ ] Passes S.U.P.E.R Quick Check for S, R

**Affected files**: commands/ (deleted), plugin.json, opencode-plugin.js, CLAUDE.md, README.md, README.zh-CN.md. **Memory/governance impact**: CLAUDE.md + user-facing READMEs (`/spec-dev`, `/dp` disappear; skill auto-trigger remains).

### T4.2 — Create `scripts/install-agents.sh` and wire install-all.sh
Mirror `install-codex.sh`'s structure exactly: `TARGET_SKILLS_DIR="${AGENTS_HOME:-$HOME/.agents}/skills"`, `BUNDLED_SKILLS=("spec-driven-develop" "deep-discuss" "review-spd")`, same REPO_URL/RAW_URL/SKILLS_SUBPATH constants, same functions, final echo naming the agents skills dir. Update `scripts/install-all.sh`: add `[4/4] Installing to ~/.agents skills...` step; adjust numbering. Do NOT touch READMEs here (docs land in T5.1 — keeps lanes file-disjoint).

**Acceptance Criteria**:
- [ ] `bash -n scripts/install-agents.sh scripts/install-all.sh` passes
- [ ] Structural-mirror diff vs install-codex.sh shows only expected differences (target dir, bundled list, messages)
- [ ] install-all.sh runs all four installers in order
- [ ] Passes S.U.P.E.R Quick Check for E, R

**Affected files**: NEW `scripts/install-agents.sh`, `scripts/install-all.sh`.

### Phase 4 Parallel Lanes
| Lane | Tasks | Combined Effort | Merge Risk | Key Files |
|:-----|:------|:----------------|:-----------|:----------|
| A | T4.1 | M | Low | commands/ (del), plugin.json, opencode-plugin.js, CLAUDE.md, both READMEs |
| B | T4.2 | M | Low | scripts/install-agents.sh (new), scripts/install-all.sh |

### Phase 4 Delivery Batches
| Batch | Tasks / Issues | Execution Waves | Goal and Grouping Rationale | Integration Branch | Combined Validation | Depends On | Split Rationale |
|:------|:---------------|:----------------|:----------------------------|:-------------------|:--------------------|:-----------|:----------------|
| P4-B1 | T4.1, T4.2 | W1: A‖B | One "distribution surface" unit: what the plugin ships and how it installs | `batch/p4-b1-command-surface-removal` | validate.sh green; node load smoke (stub cfg, 4 agents, no commands); rg commands/spec-dev/dp post-check clean; bash -n all 5 installers | P3-B1 | Default phase-level batch |

---

## Phase 5: Documentation Consolidation & Release v1.15.0
**Goal**: Reconcile both README mirrors against the final file inventory exactly once; finalize governance surfaces; bump 4 version sites; cut the release. Mitigates R9, R2, R3 (docs half).
**Prerequisite**: P4-B1 merged.
**S.U.P.E.R Focus**: U (docs point at final truth), R (one version fact per site, parity-checked).

| # | Task | Priority | Effort | Depends On | Lane | Delivery Batch | S.U.P.E.R | Test Expectation | Memory Impact |
|:--|:-----|:---------|:-------|:-----------|:-----|:---------------|:----------|:-----------------|:--------------|
| T5.1 | Full README reconciliation (both mirrors) | P0 | L | P4-B1, T2.7, T4.2 | A | P5-B1 | S, U | N/A; mirror-consistency diff | Updates user docs |
| T5.2 | Finalize AGENTS.md + CLAUDE.md | P0 | S | T4.1 | B | P5-B1 | P, U | N/A; rg governance audit | Updates instruction surfaces |
| T5.3 | Version bump ×4 → 1.15.0 + release commit | P0 | S | T5.1, T5.2 | A (W2) | P5-B1 | R | validate.sh (c) parity green | None |

### T5.1 — Full README reconciliation (both mirrors, lockstep)
One pass over both READMEs against the FINAL inventory: (a) structure tree — verify no `commands/`, `agents/` shows 4 files incl. code-reviewer.md, `scripts/` gains install-agents.sh + validate.sh + test-fixtures/, no review/ orphan; (b) Installation section — add `~/.agents` sync path (install-agents.sh, `${AGENTS_HOME:-$HOME/.agents}/skills`) with curl + local-clone variants mirroring Codex/Cursor blocks; mention in install-all.sh coverage (R3: sync path now documented and owned); (c) prose sweep for command-era leftovers ("bundled skills, commands, and sub-agents" → "bundled skills and sub-agents", etc., zh-CN equivalents); (d) ensure reviewer-loop bullet reads consistently; add "(Updated in v1.15)" note covering orchestrator-centric model + review loop + commands removal + all-skills conciseness pass; (e) verify no `/spec-dev`, `/dp`, `commands/` references remain. Grep checklist: `rg -n "spec-dev|/dp|commands|code-reviewer|install-agents|validate\.sh|1\.15" README.md README.zh-CN.md` reviewed line by line.

**Acceptance Criteria**:
- [ ] Structure trees in both mirrors identical modulo translation, matching on-disk reality
- [ ] install-agents.sh documented in both mirrors
- [ ] v1.15 update note present in both; every edit mirrored (section-by-section diff review)
- [ ] Passes S.U.P.E.R Quick Check for S, U

**Affected files**: README.md, README.zh-CN.md.

### T5.2 — Finalize AGENTS.md + CLAUDE.md
Verify/finish: AGENTS.md Truth Sources lists SKILL.md, references/, agents/, opencode-plugin.js, all manifests, scripts/ — and must NOT reference `commands/`; Validation current (validate.sh primary — from T1.5); CLAUDE.md contains no `commands/` reference and mentions code-reviewer (T2.7). Fix residue.

**Acceptance Criteria**:
- [ ] `rg -n "commands" AGENTS.md CLAUDE.md` → zero hits
- [ ] `rg -n "code-reviewer" CLAUDE.md` → ≥1 hit
- [ ] Passes S.U.P.E.R Quick Check for P, U

**Affected files**: AGENTS.md, CLAUDE.md (residue fixes only, if any).

### T5.3 — Version bump ×4 → 1.15.0 + release commit
Bump `1.14.0` → `1.15.0` in exactly 4 sites: SKILL.md frontmatter, `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, root `.claude-plugin/marketplace.json`. (`.agents/plugins/marketplace.json` has no version field; satellite skills keep own versions.) Commit per convention: `release: 1.15.0`.

**Acceptance Criteria**:
- [ ] `rg -n "1\.14\.0"` → zero hits outside docs/archives/
- [ ] validate.sh (c) version-parity green at 1.15.0
- [ ] Commit `release: 1.15.0` merged to main
- [ ] Passes S.U.P.E.R Quick Check for R

**Affected files**: the 4 version sites.

### Phase 5 Parallel Lanes
| Lane | Tasks | Combined Effort | Merge Risk | Key Files |
|:-----|:------|:----------------|:-----------|:----------|
| A | T5.1 → (W2) T5.3 | L+S | Low | README.md, README.zh-CN.md → 4 version sites |
| B | T5.2 | S | Low | AGENTS.md, CLAUDE.md |

### Phase 5 Delivery Batches
| Batch | Tasks / Issues | Execution Waves | Goal and Grouping Rationale | Integration Branch | Combined Validation | Depends On | Split Rationale |
|:------|:---------------|:----------------|:----------------------------|:-------------------|:--------------------|:-----------|:----------------|
| P5-B1 | T5.1-T5.3 | W1: A‖B; W2: T5.3 | The release unit: docs final + versions bumped together so the published state is atomically consistent | `batch/p5-b1-release-1-15-0` | validate.sh full suite green at 1.15.0; README mirror diff review; rg no-stale sweep (commands/, 1.14.0, spec-dev/dp outside archives) | P4-B1 | Default phase-level batch |

---

## Effort Summary

| Phase | Tasks | Aggregate | Wall-clock (lanes) |
|:------|------:|----------:|-------------------:|
| P1 Foundation & Guard | 5 | ~12h | ~7h (3 lanes) |
| P2 Execution Model | 7 | ~22.5h | ~16h (serial heart, 3 waves) |
| P3 Single-Sourcing | 8 | ~20.5h | ~9h (6 lanes + gate) |
| P4 Command Removal | 2 | ~5h | ~2.5h (2 lanes) |
| P5 Release | 3 | ~7h | ~6.5h |
| **Total** | **25** | **~67h** | **~41h** |

**Critical path**: T1.4 → T2.1 → T2.2 → T2.3/T2.6 → T2.7 → T3.1 → T3.7 → T4.1 → T5.1 → T5.3.
