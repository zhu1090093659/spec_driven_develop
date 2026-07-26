# Orchestrator-Centric Execution Model (v1.15.0) — Progress Tracker

> **Task**: Transform the SDD plugin: pure-orchestrator execution model with per-lane review-and-fix sub-agents; aggressive prompt single-sourcing + conciseness across all skills; delete the commands/ surface; ship as v1.15.0.
> **Started**: 2026-07-26
> **Last Updated**: 2026-07-26
> **Mode**: GITHUB_STANDARD
> **Repo**: zhu1090093659/spec_driven_develop

## GitHub Resources
- **All Issues**: `gh issue list -R zhu1090093659/spec_driven_develop --label "spec-driven" --state all`
- **Open Batch PRs**: `gh pr list -R zhu1090093659/spec_driven_develop --state open --search "in:title Batch"`
- **Project Board**: none (GITHUB_STANDARD — no `project` scope)

## References
- [Project Overview](../analysis/project-overview.md)
- [Module Inventory](../analysis/module-inventory.md)
- [Risk Assessment](../analysis/risk-assessment.md)
- [Task Breakdown](../plan/task-breakdown.md)
- [Dependency Graph](../plan/dependency-graph.md)
- [Milestones](../plan/milestones.md)

## Execution Telemetry

Per-task telemetry (actual effort, S.U.P.E.R score, unplanned dependencies) is recorded in **Issue comments** at batch integration (see adaptive-control.md "Telemetry Collection"). Cumulative drift state lives in **Milestone description YAML blocks**. Thresholds: annotate at 20%, replan at 40%, rescope at 60% of phase task count.

## Milestones

| Phase | Name | Milestone URL | Open | Closed | Total |
|:------|:-----|:-------------|-----:|-------:|------:|
| 1 | Foundation & Guard | https://github.com/zhu1090093659/spec_driven_develop/milestone/4 | 5 | 0 | 5 |
| 2 | Orchestrator-Centric Execution Model | https://github.com/zhu1090093659/spec_driven_develop/milestone/5 | 7 | 0 | 7 |
| 3 | Prompt Restructure & Single-Sourcing | https://github.com/zhu1090093659/spec_driven_develop/milestone/6 | 8 | 0 | 8 |
| 4 | Command Surface Removal & Distribution Paths | https://github.com/zhu1090093659/spec_driven_develop/milestone/7 | 2 | 0 | 2 |
| 5 | Documentation Consolidation & Release v1.15.0 | https://github.com/zhu1090093659/spec_driven_develop/milestone/8 | 3 | 0 | 3 |

## Issue Mapping

| Task ID | Issue | Title | Delivery Batch | PR | Status |
|:--------|:------|:------|:---------------|:---|:-------|
| T1.1 | #14 | Fix stale cross-surface references | P1-B1 | #40 | in review |
| T1.2 | #15 | Relocate 10-check S.U.P.E.R checklist to super-philosophy.md | P1-B1 | #40 | in review |
| T1.3 | #16 | Hygiene: delete junk artifacts and legacy installer entries | P1-B1 | #40 | in review |
| T1.4 | #17 | Create scripts/validate.sh + exporter smoke fixture | P1-B1 | #40 | in review |
| T1.5 | #18 | Repair AGENTS.md Truth Sources + Validation sections | P1-B1 | #40 | in review |
| T2.1 | #19 | Author agents/code-reviewer.md | P2-B1 | #41 | in review |
| T2.2 | #20 | Rewrite SKILL.md Phase 5 for the review loop | P2-B1 | #41 | in review |
| T2.3 | #21 | Insert review loop into parallel-protocol.md | P2-B1 | #41 | in review |
| T2.4 | #22 | Writer-model rules in behavioral-rules.md | P2-B1 | #41 | in review |
| T2.5 | #23 | Restate single-writer invariant in task-executor.md | P2-B1 | #41 | in review |
| T2.6 | #24 | Reviewer-ready planning in task-architect.md | P2-B1 | #41 | in review |
| T2.7 | #25 | Register code-reviewer on all adapter surfaces | P2-B1 | #41 | in review |
| T3.1 | #26 | Restructure SKILL.md to phase flow + one-line pointers | P3-B1 | #42 | in review |
| T3.2 | #27 | Slim github-integration.md; hedge worktree tool name | P3-B1 | #42 | in review |
| T3.3 | #28 | Slim adaptive-control.md; convert §-anchors to named headings | P3-B1 | #42 | in review |
| T3.4 | #29 | Hedge behavioral-rules.md rule 9 | P3-B1 | #42 | in review |
| T3.5 | #30 | Slim all four agent prompts, preserving contracts | P3-B1 | #42 | in review |
| T3.6 | #31 | Templates prose-slim + progress.md format freeze | P3-B1 | #42 | in review |
| T3.7 | #32 | Single-source audit gate (8 hotspots) | P3-B1 | #42 | in review |
| T3.8 | #33 | Conciseness pass on satellite skills (deep-discuss, review-spd) | P3-B1 | #42 | in review |
| T4.1 | #34 | Delete commands/ atomically (5 surfaces) | P4-B1 | #43 | in review |
| T4.2 | #35 | Create scripts/install-agents.sh + install-all.sh wiring | P4-B1 | #43 | in review |
| T5.1 | #36 | Full README reconciliation (both mirrors) | P5-B1 | #44 | in review |
| T5.2 | #37 | Finalize AGENTS.md + CLAUDE.md | P5-B1 | #44 | in review |
| T5.3 | #38 | Version bump ×4 → 1.15.0 + release commit | P5-B1 | #44 | in review |

Status values: `open`, `in progress`, `awaiting batch PR`, `in review`, `partial`, `closed`.

## Delivery Batches

| Batch | Phase | Issues | Integration Branch | PR | Status |
|:------|:------|:-------|:-------------------|:---|:-------|
| P1-B1 | 1 | #14-#18 | `batch/p1-b1-foundation-guard` | #40 | in review |
| P2-B1 | 2 | #19-#25 | `batch/p2-b1-orchestrator-review-loop` | #41 | in review |
| P3-B1 | 3 | #26-#33 | `batch/p3-b1-prompt-single-sourcing` | #42 | in review |
| P4-B1 | 4 | #34, #35 | `batch/p4-b1-command-surface-removal` | — | planned |
| P5-B1 | 5 | #36-#38 | `batch/p5-b1-release-1-15-0` | #44 | in review |

## Quick Status Commands

```bash
REPO="zhu1090093659/spec_driven_develop"

# Phase progress (all milestones)
gh api repos/$REPO/milestones --jq '.[] | "\(.title): \(.open_issues) open, \(.closed_issues) closed"'

# Open tasks for a phase
gh issue list -R $REPO --milestone "Phase 1: Foundation & Guard" --state open --json number,title

# All spec-driven Issues
gh issue list -R $REPO --label "spec-driven" --state all --json number,title,state,milestone

# Open delivery batch PRs
gh pr list -R $REPO --state open --search "in:title Batch" --json number,title,headRefName,url
```

## Phase Checklist
- [ ] Phase 1: Foundation & Guard (0/5 tasks) — [milestone](https://github.com/zhu1090093659/spec_driven_develop/milestone/4)
- [ ] Phase 2: Orchestrator-Centric Execution Model (7/7 tasks, pending PR merge) — [milestone](https://github.com/zhu1090093659/spec_driven_develop/milestone/5)
- [ ] Phase 3: Prompt Restructure & Single-Sourcing (8/8 tasks, pending PR merge) — [milestone](https://github.com/zhu1090093659/spec_driven_develop/milestone/6)
- [ ] Phase 4: Command Surface Removal & Distribution Paths (2/2 tasks, pending PR merge) — [milestone](https://github.com/zhu1090093659/spec_driven_develop/milestone/7)
- [ ] Phase 5: Documentation Consolidation & Release v1.15.0 (3/3 tasks, pending PR merge) — [milestone](https://github.com/zhu1090093659/spec_driven_develop/milestone/8)

## Current Status
**Active Phase**: All 5 phases complete pending merges; ready for Phase 6 (Archive)
**Active Delivery Batch**: P5-B1 — PR #44 in review (stacked on #43)
**Active Issues**: #14-#38 (in review)
**Blockers**: None
**Cost model**: Tiered dispatch + tiered review adopted 2026-07-26 (user decision 方案 A) — see task-breakdown.md "Dispatch Economics".

## Governance Status
**Shared instruction surface**: `AGENTS.md` (canonical; repair planned in T1.5, finalize in T5.2)
**Claude Code instruction surface**: `CLAUDE.md` (defers to AGENTS.md; T2.7 applied in P2-B1, T4.1 planned)
**Other platform rule surfaces**: none present (`.cursor/rules/`, `.windsurf/`, `.clinerules*`, `.codex/` absent)
**Memory surface**: unavailable (no native memory surface in this environment)
**Memory fallback path**: none — per AGENTS.md policy, no repo fallback file is created

## Next Steps
1. Merge PRs #40, #41, #42, #43, #44 in order (user action), then clean up P1–P5 worktrees/branches.
2. After all merges: Phase 6 (Archive) — move docs/{analysis,plan,progress} to docs/archives/orchestrator-centric-execution-model/, update archives index, suggest commit.

## Session Log
| Date | Session | Summary |
|:-----|:--------|:--------|
| 2026-07-26 | sess (preparation) | Phases 0-4 complete: 3 analysis docs, 3 plan docs (25 tasks, 5 batches), 25 GitHub Issues (#14-#38), 5 Milestones (#4-#8) with adaptive state, labels created. User decisions: per-lane review; aggressive restructure; GitHub tracking; validate.sh + hygiene + ~/.agents sync in scope; Style Rule (rule/contract/pointer) binding for all prompts. |
| 2026-07-26 | sess (P1-B1 + cost pivot) | P1-B1 executed: 3 coder lanes + reviews; octopus-merged clean; validate.sh 7/7 green; telemetry posted; PR #40 created. User flagged sub-agent cost/latency problem (~7.1M tokens for prep+P1); deep-discuss analysis → tiered dispatch + tiered review model adopted (方案 A); dispatch economics added to plan + P2 issue criteria. |
| 2026-07-26 | sess (P2-B1) | P2-B1 executed orchestrator-direct per tiered model: code-reviewer.md authored; SKILL 5b + parallel-protocol + rules 18/19 encode tiered dispatch/review + writer model; executor/architect updated (ports preserved); registered on 5 surfaces. validate.sh 7/7. L3 reviewer verdict FIXED (2 findings fixed forward: 3d1009d, 5f22549). Telemetry posted; milestone 5 → 7/7; PR #41 created (stacked on #40). Total sub-agent spend this batch: ~1 L3 reviewer. |
| 2026-07-26 | sess (P3-B1) | P3-B1 executed orchestrator-direct (Tier 0): SKILL.md 405→249 with canonical-reference table + named anchors; adaptive-control renamed to named sections; rule 9 hedged; github-integration EnterWorktree hedged; task-architect slimmed (contracts byte-identical); progress.md FORMAT FREEZE; deep-discuss −61%, review-spd slimmed; single-source audit 8/8. validate.sh 7/7. L3 reviewer verdict FIXED (1 Medium: progress template em-dash → `--`, 8d44b6d). Telemetry posted; PR #42 created (stacked on #41). Sub-agent spend: 1 L3 reviewer. |
| 2026-07-26 | sess (P4-B1) | P4-B1 executed orchestrator-direct (Tier 0): commands/ deleted atomically across 5 surfaces (plugin.json, opencode-plugin.js, CLAUDE.md, both READMEs); install-agents.sh created (AGENTS_HOME-aware) + wired into install-all.sh [4/4]; stale untracked review/ dir (v1.13.x leftover) removed from main working dir. validate.sh 7/7. L2 review only (no L3 per tiered criteria — mechanical deletion + additive installer). Telemetry posted; milestone 7 → 2/2; PR #43 created (stacked on #42). |
| 2026-07-26 | sess (P5-B1) | P5-B1 executed orchestrator-direct (Tier 0): v1.15 section added to both README mirrors (orchestrator-centric model, code-reviewer loop, skills-only, single-sourcing, install-agents.sh); AGENTS.md validation list finalized; version 1.14.0 → 1.15.0 across 4 parity sites. validate.sh 7/7. L2 review only (docs+metadata). Telemetry posted; milestone 8 → 3/3; PR #44 created (stacked on #43). All 25 tasks now in review across PRs #40-#44. |
