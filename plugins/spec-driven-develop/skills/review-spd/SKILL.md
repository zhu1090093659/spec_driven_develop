---
name: review-spd
description: >-
  Findings-first code review workflow for AI coding agents. Use when the user asks
  to review uncommitted changes, commits in a date range, or a branch compared to
  the main branch / PR-style diff. Focuses on bugs, regressions, correctness risks,
  missing tests, security/data-safety issues, and other behavior-changing defects.
version: 1.0.1
---

# Review SPD

You are executing the **Review SPD** workflow: a findings-first review of changed code. Identify bugs, regressions, and behavior risks introduced by the changes. Do not turn this into a style review or a broad summary.

## Configuration

| Item | Default | Purpose |
|:-----|:--------|:--------|
| Context script | `scripts/review-context.py` relative to this Review SPD skill directory | Collect stable git context |
| Default target | Uncommitted changes | Working tree + staged changes |
| Commit range default | Last 3 days | Only when the user requests commit/date review without dates |
| PR base | Auto-detect `origin/main`, `origin/master`, then remote default branch | Base for branch-vs-main review |
| Output style | Findings first | Findings by severity before summaries |

References: reviewer sub-agent template `references/reviewer-template.md`; final output format `references/output-format.md`.

## Target Modes

Three mutually exclusive targets:

1. **Uncommitted mode** (default)
2. **Commit-range mode** — no explicit range → last 3 days
3. **Branch / PR mode** — branch vs. main or explicit `base`

Conflict priority: `branch` specified → branch mode; else `since`/`until` → commit-range mode; else uncommitted. `base` applies only to branch mode. Vague requests ("review this") → uncommitted mode; "recent commits" without dates → `--since "3 days ago"`.

## Phase 1: Target Resolution

Resolve the context script from the installed Review SPD skill directory, not from the repository being reviewed:

```bash
python <review-spd-skill-dir>/scripts/review-context.py
python <review-spd-skill-dir>/scripts/review-context.py --since "3 days ago"
python <review-spd-skill-dir>/scripts/review-context.py --since 2026-06-28 --until 2026-07-01
python <review-spd-skill-dir>/scripts/review-context.py --branch feature/foo
python <review-spd-skill-dir>/scripts/review-context.py --branch feature/foo --base origin/main
```

When reviewing this repository itself, the convenience wrapper `scripts/review-context.py` is also available.

## Phase 2: Context Collection

Run the script with cwd = the repository under review (it cd's to the git root itself). The script only collects git context; it does not judge correctness. From its output identify: review mode and base/head, commit list (if any), changed files and diff stats, added/deleted/renamed files, and the unified diff hunks needing semantic review.

If the script reports no changes, stop and say there is nothing to review. Do not invent findings.

## Phase 3: Review Planning

Classify review size:

- **Small** (≤3 files, localized diff): cover Correctness + Tests.
- **Medium** (multiple files / behavior-affecting): add Regression/Compatibility.
- **Large or high-risk** (broad changes, auth/permissions, persistence, migrations, concurrency, caching, money, security, public APIs, generated code, config/deployment): add Security/Data Safety + Performance/Concurrency.

Prioritize behavior code, public contracts, data handling, error paths, configuration, persistence, tests. Deprioritize docs, formatting-only changes, generated files, lockfile churn unless they affect runtime behavior.

## Phase 4: Sub-Agent Review

If the platform supports sub-agents, spawn focused reviewers using `references/reviewer-template.md`; otherwise perform the same focused reviews sequentially yourself. Coverage must not shrink without sub-agents.

Reviewer focuses:

- **Correctness / Bug Risk**: logic errors, edge cases, state consistency, exception paths, invalid assumptions.
- **Regression / Compatibility**: changed API contracts, config behavior, data formats, migrations, CLI behavior, backward compatibility.
- **Tests / Verification**: missing tests for changed behavior, weak assertions, stale tests, untested failure modes.
- **Security / Data Safety**: authorization, validation, injection, secrets, destructive operations, data loss, privacy.
- **Performance / Concurrency**: async races, caching errors, resource leaks, excessive work, ordering bugs.

Each reviewer returns only evidence-backed candidate findings for its own focus.

## Phase 5: Finding Consolidation

Merge reviewer outputs into one findings list:

- Every finding must be supported by the diff or directly relevant context, with a file:line reference when possible.
- No style preferences, speculative rewrites, or generic best practices unless they create a concrete bug risk.
- Incomplete evidence → move to `Questions` or `Residual Risks`, not `Findings`.
- Deduplicate overlaps; keep the clearest impact statement.
- Order by severity: Critical, High, Medium, Low.

Severity guide:

- **Critical**: data loss, security bypass, production outage, irreversible corruption, severe user impact likely.
- **High**: clear bug/regression in a common or important path.
- **Medium**: edge-path bug, compatibility break, missing validation, or test gap likely to hide regressions.
- **Low**: minor bug risk, confusing behavior, narrow edge case, maintainability issue with direct defect potential.

## Phase 6: Final Response

Use `references/output-format.md`. Findings are the primary focus: present them first, keep summaries brief, never bury a bug below a summary. No findings → explicitly state `No findings` and include residual risks or testing gaps.

### Dual output: human-readable text + structured JSON

After the findings-first text, also emit a structured JSON block (see `references/output-format.md` → "## Structured JSON") so the result can be consumed by an Agent or downstream tooling. The two outputs MUST be derived from the same findings list; never let the JSON disagree with the text.

Map each reviewer focus to a JSON `category`:

| Reviewer focus | JSON `category` |
|:---------------|:---------------|
| Correctness / Bug Risk | `bug` |
| Regression / Compatibility | `bug` (or `other`) |
| Tests / Verification | `test` |
| Security / Data Safety | `security` |
| Performance / Concurrency | `performance` |

Severity maps directly: `critical` / `high` / `medium` / `low`. `files[]` and their `insertions`/`deletions` come from the Phase 2 context script output. Review SPD has no rule engine, so `rules[]` is either empty or a note that review is focus-driven (no `rule.json`). This JSON shape is intentionally compatible with the `open-code-review-delegate` report schema so both skills can feed the same downstream consumers.

## Review Discipline

- Think like a code reviewer, not a feature planner: does the change introduce new bugs?
- Verify claims against code context before reporting.
- Prefer one strong finding over many weak suggestions.
- Do not modify files unless the user explicitly asks you to fix the findings.
- If tests/builds are needed to validate a suspected issue, name the exact command or missing coverage.
