# Risk Assessment

## S.U.P.E.R Architecture Health Summary

| Principle | Status | Key Findings | Transformation Priority |
|:----------|:-------|:-------------|:------------------------|
| **S** Single Purpose | 🟡 | Good file-per-concern split overall; `opencode-plugin.js` does 3 jobs; READMEs are marketing+install+manual+spec at once | Medium |
| **U** Unidirectional Flow | 🔴 | Workflow *shape* defined bidirectionally across surfaces: SKILL.md "Phase 3-7", adaptive-control "Phases 0-7", codex plugin.json "six-phase" — no single source for phase count | **High** |
| **P** Ports over Implementation | 🔴 | No validation for Markdown cross-references; export-progress.py↔progress.md is an implicit untested regex contract; manifest↔filesystem bindings unchecked | **High** |
| **E** Environment-Agnostic | 🟡 | `AskUserQuestionTool`/`TodoWrite`/`EnterWorktree` named in shared files; `install-cursor.sh` lacks env override siblings have; hardcoded GitHub URLs | Medium |
| **R** Replaceable Parts | 🔴 | Duplication: rules restated 3-6×, installer twins ~95% identical, README pair full mirror, version ×4. Any workflow change = coordinated edits in 8-12 files | **High** |

**Overall Health**: _0/5 fully healthy (2🟡 3🔴)_ — Technical Debt Alert by the repo's own Quick Check.

### S.U.P.E.R Violation Hotspots

1. Cross-surface workflow-shape duplication (U) — single-source the phase model.
2. Missing consistency validation (P) — add a repo-local check for references/manifests/versions.
3. Rule duplication across 6 sites (R) — canonical owner per rule + one-line references.
4. Platform tool names in shared rules (E) — hedge or relocate to platform surfaces.

## Risk Matrix

| Risk | Impact | Likelihood | Severity | Mitigation |
|:-----|:-------|:-----------|:---------|:-----------|
| R1 commands/ deletion ripple (5 inbound refs; OpenCode fails at **load time**, taking skills+agents down too) | High | Certain | **Critical** | One commit touching plugin.json, opencode-plugin.js, CLAUDE.md, both READMEs; verify no `rg` hits remain |
| R6 Reviewer-agent insertion touches ≥8 behavioral surfaces at once; collides with orchestrator-single-writer invariant | High | High | **High** | Reviewer returns reports/fix-commits to orchestrator; never writes GitHub/MASTER; reuse reviewer-template.md contract; joint-update all surfaces per AGENTS.md L18 |
| R6b New built-in reviewer overlaps user-facing review-spd skill (competing truth sources) | Medium | Medium | Medium | Explicit positioning decision: execution-loop reviewer reuses review-spd contract; review-spd remains the user-invoked standalone skill |
| R5 Slimming destroys load-bearing contracts (executor handoff format, progress.md↔export-progress.py regexes, templates) | High | Medium | **High** | Treat templates/handoff formats as ports; run exporter smoke test after edits; preserve schemas verbatim |
| R4 Pre-existing stale refs (sub-SKILL, Phases 0-7, dangling 10-check) get re-encoded by the rewrite | Medium | Certain (present today) | **High** | Fix stale refs as an early phase before the rewrite |
| R8 No CI / no cross-file consistency checker — every prior restructure (v1.10, v1.11) left drift | Medium-High | Certain | **High** | Add `scripts/validate.sh`: reference-existence, manifest↔filesystem, version-parity, JSON validity, node --check, py_compile all Python |
| R2 Version pinned in 4 surfaces (already desynced once at v1.10); release bump burden | Medium | High | Medium | Version-parity check in validate.sh; single release checklist |
| R3 Installed-copy drift: `~/.agents/skills` sync path undocumented; ZCode cache holds stale 1.13.1 | Medium | Certain | Medium | Document/own the `~/.agents` sync path; version bump refreshes caches |
| R9 README bilingual full duplication — every change written twice | Medium | High | Medium | Mandatory paired edits (AGENTS.md L19); consider trimming structure-tree detail |
| R11 Platform-specific names in shared "environment-agnostic" files | Low-Medium | Certain | Medium | Hedge to "the platform's question/worktree mechanism (e.g., …)" |
| R10 Junk propagation: orphan `skills/review/` pycache dir ships to user installs via `cp -R` | Low | Medium | Low | Delete orphan + .pyc files; verify installers' source side clean |
| R7 opencode-plugin.js zero error handling on hardcoded asset reads | High | Medium | **High** | Covered by R1 fix; add graceful handling or generated manifest while editing |

## High-Severity Risks (detail)

**R1 — commands/ deletion is wider than it looks.** `opencode-plugin.js` L22-28 reads `commands/spec-dev.md` and `commands/dp.md` at plugin load via `Promise.all`; a missing file rejects the promise and the *entire* config hook fails — skills-path registration and all 3 agent registrations die with it, at runtime, not install time. The deletion commit must simultaneously edit: `.claude-plugin/plugin.json` (commands array), `opencode-plugin.js` (remove command loading/registration), `CLAUDE.md` L8, `README.md` L350-355+L431-433, `README.zh-CN.md` L331-333+L410-412. Post-check: `rg -n "commands/|/spec-dev|/dp" --type md --type js --type json` returns only intentional hits.

**R6 — Reviewer sub-agent changes the writer model.** Today the orchestrator is the single writer for drift state, MASTER.md, and PRs (parallel-protocol.md L44), and executors produce all code commits. A review-and-fix reviewer introduces a second code-writer post-handoff. The protocol must define: reviewer commits fixes to the lane/batch branch (commit-ownership rule), reviewer telemetry flows back through the orchestrator (reviewers never comment on Issues or edit MASTER.md), and acceptance verification remains the orchestrator's job via clear per-task acceptance criteria.

**R5 — Templates are ports.** `export-progress.py` L26-70 parses MASTER.md/phase files with regexes coupled to `templates/progress.md`'s exact text. Executor Handoff Format (task-executor.md L95-136) is the orchestrator's parse contract. Slimming must preserve these schemas or update the parser in the same commit, with a smoke fixture.

**R4 — Drift is the norm.** v1.11 removed Sub-SKILL generation but left refs in parallel-protocol.md and archive.md; phase count is stated 3 different ways across surfaces. The rewrite must fix these first or it re-encodes them.

## Technical Debt

- Rule duplication hotspots (ranked in module-inventory.md) — the actual "prompt bloat".
- Installer twins ~95% identical; legacy `"review"` entry in BUNDLED_SKILLS.
- 4-way version sync; no CHANGELOG/tags; deep-discuss/review-spd versions unread by installers (no update prompts for satellite-skill-only changes).
- Orphan `skills/review/` dir + tracked/untracked `.pyc` artifacts; `.DS_Store`.
- Archived run uses stale vocabulary (sub-skill, Phase 7).
- AGENTS.md Truth Sources omits commands/, opencode-plugin.js, manifests; Validation omits 2 Python files.

## Testing Risks

No test harness or CI exists. The transformation touches ~all files, so regression protection must come from the new `scripts/validate.sh` (cross-reference existence, manifest↔filesystem, version parity, JSON validity, `node --check`, `py_compile` on all 3 Python files, exporter smoke fixture) plus the existing static checks. Highest-value guard: reference-existence + manifest checks (catches R1/R4/R7 class bugs).

## Project Governance Risks

- CLAUDE.md L8 goes stale on commands/ deletion (only AGENTS↔CLAUDE conflict).
- AGENTS.md L18 joint-update rule has been violated in practice (R4 drift) — the plan must batch surface updates per task.
- `.github/PULL_REQUEST_TEMPLATE.md` enforces "problem-driven change only" — the transformation PR should cite the real usage problem (slow serial execution, prompt bloat, command surface redundancy).
- No native memory surface in this environment beyond conversation; per AGENTS.md policy, no repo fallback file will be created.

## Compatibility Concerns

- **User-facing behavior change**: `/spec-dev` and `/dp` disappear; users must rely on skill auto-trigger (keywords already documented). Both READMEs' usage sections need rewriting, and install docs lose the command references.
- **OpenCode**: plugin loads with zero commands registered — verify OpenCode tolerates an empty/absent `cfg.command` block.
- **Installers**: no change needed for commands/ deletion (they copy skill dirs / whole plugin dir), but the orphan `skills/review/` cleanup affects what they ship.
- **MASTER.md/progress format**: unchanged if templates are preserved → export-progress.py keeps working.
- **ZCode plugin cache**: stale 1.13.1 coexists; a version bump (1.15.0) is required so downstream caches refresh.
