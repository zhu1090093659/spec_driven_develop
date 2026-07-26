# Module Inventory

~30 tracked text modules, ~4,300 lines. Score format: 🟢 compliant / 🟡 partial / 🔴 violation.

| Module | Responsibility | Files | Lines | Complexity | S.U.P.E.R Score |
|:-------|:---------------|------:|------:|:-----------|:----------------|
| spec-driven-develop SKILL.md | Orchestrator prompt: 7-phase pipeline, config, continuity | 1 | 398 | High | S🟡 U🟢 P🟢 E🟡 R🟡 |
| behavioral-rules.md | 17 non-negotiable rules for all agents/phases | 1 | 43 | Low | S🟢 U🟢 P🟡 E🔴 R🟡 |
| parallel-protocol.md | Lane/worktree execution, merge-risk, post-integration checks | 1 | 99 | Medium | S🟢 U🟢 P🟢 E🟢 R🟡 |
| github-integration.md | gh protocol: modes, labels, milestones, issues, board, batch PR | 1 | 386 | High | S🟢 U🟢 P🟢 E🟡 R🟡 |
| adaptive-control.md | Telemetry, drift_score, 20/40/60% thresholds, state storage | 1 | 290 | High | S🟢 U🟢 P🟢 E🟡 R🔴 |
| super-philosophy.md | 5 S.U.P.E.R principles + Quick Check | 1 | 128 | Low | S🟢 U🟢 P🟡 E🟢 R🟢 |
| templates/analysis.md | Schemas: project-overview, module-inventory, risk-assessment | 1 | 120 | Low | S🟢 U🟢 P🟢 E🟢 R🟢 |
| templates/plan.md | Schemas: task-breakdown, dependency-graph, milestones | 1 | 113 | Low-Med | S🟢 U🟢 P🟢 E🟢 R🟡 |
| templates/progress.md | Schemas: MASTER.md (2 modes), phase files | 1 | 197 | Medium | S🟡 U🟢 P🟢 E🟢 R🟡 |
| templates/governance.md | Schemas: AGENTS.md, CLAUDE.md, governance table, memory | 1 | 104 | Low | S🟡 U🟢 P🟢 E🟢 R🟢 |
| templates/archive.md | Schema: archive index + directory tree | 1 | 49 | Low | S🟢 U🟢 P🟢 E🟢 R🟡 |
| agents/project-analyzer.md | Phase 1 read-only analyst sub-agent | 1 | 95 | Medium | S🟢 U🟢 P🟢 E🟡 R🟡 |
| agents/task-architect.md | Phase 3 planner sub-agent | 1 | 146 | Medium | S🟢 U🟢 P🟢 E🟡 R🟡 |
| agents/task-executor.md | Coder sub-agent: implement+verify, no PRs | 1 | 162 | Medium | S🟢 U🟢 P🟢 E🟡 R🟢 |
| commands/spec-dev.md | `/spec-dev` launcher (deletion target) | 1 | 14 | Low/High coupling | S🟢 U🟢 P🟡 E🔴 R🔴 |
| commands/dp.md | `/dp` launcher (deletion target) | 1 | 14 | Low/High coupling | S🟢 U🟢 P🟡 E🔴 R🔴 |
| deep-discuss SKILL.md | Standalone Chinese discussion workflow | 1 | 173 | Low | all🟢 |
| review-spd skill | Findings-first review workflow + context script | 4 | ~600 | Medium | all🟢 |
| opencode-plugin.js | OpenCode loader: registers skills+commands+agents | 1 | 95 | High for size | S🟡 U🟢 P🟡 E🔴 R🔴 |
| install-codex.sh / install-cursor.sh | Skill-copy installers (~95% identical twins) | 2 | 203 | Medium | S🟢 U🟢 P🟢 E🟡 R🔴 |
| install-opencode.sh / install-all.sh | OpenCode installer + umbrella | 2 | 135 | Medium | S🟢 U🟢 P🟢 E🟢 R🟡 |
| export-progress.py | MASTER.md → JSON parser (LOCAL_ONLY format) | 1 | 158 | Low | S🟢 U🟢 P🟡 E🟢 R🟢 |
| review-context.py (×2) | Git context collector + repo wrapper | 2 | 334 | Low | all🟢 |
| Manifests (4 JSON) | Plugin/marketplace metadata, version pins | 4 | 126 | Low | S🟢 U🟢 P🟡 E🟡 R🟡 |
| AGENTS.md / CLAUDE.md | Repo governance surfaces | 2 | 43 | Low | all🟢 |
| README.md / README.zh-CN.md | Bilingual user docs (full mirrors) | 2 | 946 | Medium | S🟡 U🟢 P🟢 E🟢 R🟡 |
| docs/archives/ | One archived run (adaptive-control-layer) | 5 | 210 | Low (data) | n/a |

## Module Details (transformation-critical only)

### spec-driven-develop/SKILL.md
- **Path**: `plugins/spec-driven-develop/skills/spec-driven-develop/SKILL.md`
- **Responsibility**: Orchestrator prompt — 7 phases, configuration, cross-session continuity, pointers to all references.
- **Dependencies**: 20 outbound references to `references/*`; dispatches `project-analyzer` (L93), `task-architect` (L150), `task-executor` (L331-332). Inbound: AGENTS.md, both READMEs, install scripts (version extraction), opencode-plugin.js.
- **Complexity**: High.
- **Transformation Notes**: The file the orchestrator redesign rewrites most. Verbosity is **duplication, not examples** (~7% examples, ~15-20% restated rules). Embeds config tables, adaptive-state YAML schema, and GitHub sync detail that belong to references. Stale: L140 says "Phase 3-7" (workflow is 0-6).
- **S.U.P.E.R**: S🟡 (embeds reference-owned detail) · U🟢 · P🟢 · E🟡 (names `TodoWrite`) · R🟡 (13 hard path refs).

### agents/task-executor.md
- **Responsibility**: The coder sub-agent — executes a batch/lane: orient, worktree, implement with tests, verify, commit without PR, return structured handoff + telemetry.
- **Transformation Notes**: Best contract in the repo (Input Contract L11-25, Handoff Format L95-136) — **load-bearing ports, preserve while slimming**. Currently self-verifies only (§4); the orchestrator re-verifies acceptance criteria itself (SKILL.md L345). The reviewer sub-agent slots in after this agent's handoff. Single-writer invariant (L83) must be restated relative to reviewer-authored fix commits.

### references/parallel-protocol.md
- **Transformation Notes**: Leanest reference (97% rules). The review loop's natural home: between "consolidate lanes" and batch PR creation. Stale: L3/L30 reference removed "sub-SKILL" feature.

### references/adaptive-control.md
- **Transformation Notes**: Three defects: (a) L15 "Phases 0-7" (stale); (b) L44 invokes a "S.U.P.E.R Code Review Checklist (10 checks)" **defined nowhere agent-readable** — it exists only in README.md L200-211 (dangling contract; natural home: super-philosophy.md); (c) §-number anchors referenced from 4 files (brittle). ~31% template content (load-bearing YAML schemas).

### references/github-integration.md
- **Transformation Notes**: Largest file (386 lines, ~59% executable templates). Templates are load-bearing ports (Issue/PR body schemas) — slim prose, keep schemas. Mode table duplicates SKILL.md L40-44; quick-status commands duplicate templates/progress.md.

### opencode-plugin.js
- **Transformation Notes**: Hardcoded 5-file asset list (`commands/*`, `agents/*`) read via `Promise.all` — **any deletion rejects the whole config hook** (takes down skills + agents too, not just commands). Re-declares descriptions duplicated from frontmatter; task-executor description is stale (predates batch/lane contract). Must be rewritten when commands/ is deleted and when the reviewer agent is added.

### commands/ (deletion target)
- **Inbound ripple list (5 surfaces)**: `.claude-plugin/plugin.json` L27-30; `opencode-plugin.js` L23-39 (runtime read — fails at load); `CLAUDE.md` L8; `README.md` L350-355 + L431-433; `README.zh-CN.md` L331-333 + L410-412. Also present in stale ZCode cache (1.13.1) — downstream, read-only.

### review-spd/references/reviewer-template.md
- **Transformation Notes**: The repo's existing independent-reviewer contract (5 focus areas, output schema, 60 lines). Ready-made basis for the new execution-loop reviewer agent.

## Duplication Hotspots (slimming targets, ranked)

1. **Issue/PR cardinality + batching policy — 6 copies** (behavioral-rules #17; github-integration L60+L234-242; SKILL L160-164+L348; task-architect L85-106; plan.md L36+L64-68).
2. **Governance/memory surface inventory — 5 copies** (SKILL L50-56+L216-238; behavioral-rules #13-14; governance.md; project-analyzer L23; AGENTS.md).
3. **Tests-by-default rule — 6 copies** (SKILL L157; behavioral-rules #15; task-architect L59; task-executor L64; plan.md L32-33; AGENTS.md L21).
4. **Adaptive thresholds + YAML state schema — 3 copies** (SKILL L32+L187-199 near-verbatim dup of adaptive-control L171-184; behavioral-rules #11).
5. **Tracking-mode table — 4 copies** (SKILL L40-44; github-integration L11-15; both READMEs).
6. **Branch conventions `batch/…`/`work/…` — 6 copies** across SKILL, parallel-protocol, github-integration, task-executor, task-architect, plan.md.
7. **Telemetry/single-writer — 5 copies**; **gh pre-flight — 2 divergent copies** (project-analyzer's one-liner missing `--repo`); **quick-status gh commands — 2 copies**.
8. **Version string ×4**; **install-codex.sh ≈ install-cursor.sh (~95% identical)**; README pair = full duplication.

## Example-to-Rule Ratios (key files)

| File | Lines | Example/template % | Rules % | Slimming guidance |
|:-----|------:|:------------------:|:-------:|:------------------|
| SKILL.md | 398 | ~7% | ~93% | Cut duplication, not examples |
| github-integration.md | 386 | ~59% | ~41% | Keep schemas, cut prose |
| adaptive-control.md | 290 | ~31% | ~69% | Keep YAML schemas |
| parallel-protocol.md | 99 | ~3% | ~97% | Already lean |
| behavioral-rules.md | 43 | 0% | 100% | Canonical rules owner |
| super-philosophy.md | 128 | ~45% | ~55% | Home for missing 10-check checklist |
| agents/*.md | 403 | ~25% | ~75% | Contracts are ports — preserve |
| templates/*.md | 584 | ~95-100% | — | Schemas by design (export-progress.py regex-coupled) |

## Stale / Dangling References (fix before rewrite re-encodes them)

1. `adaptive-control.md` L44: 10-check checklist dangling (defined only in READMEs).
2. `adaptive-control.md` L15 + `SKILL.md` L140: "Phases 0-7" / "Phase 3-7" vs actual 0-6; `.codex-plugin/plugin.json` L29 says "six-phase" — three different phase counts across surfaces.
3. `parallel-protocol.md` L3/L30 + `templates/archive.md` L12/L44-45: removed "sub-SKILL" feature references.
4. `opencode-plugin.js` L57: stale task-executor description.
5. `behavioral-rules.md` rule 9: platform-specific `AskUserQuestionTool` in a shared cross-platform file; `github-integration.md` L253 names `EnterWorktree`.
6. Orphan `plugins/spec-driven-develop/skills/review/` dir (pycache remnant of renamed skill) + 3 untracked `.pyc` files — installers would ship the orphan to users.
7. `project-analyzer.md` pre-flight one-liner diverges from canonical (missing `--repo`).
8. Archived docs use stale vocabulary (historical, low priority).
