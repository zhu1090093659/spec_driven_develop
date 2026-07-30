# Review Output Format

Final review responses must be findings-first.

## With Findings

```markdown
## Findings

### Critical
- [C1] `path/to/file:line` Short problem title
  Impact: What breaks and why it matters.
  Evidence: Specific diff/context evidence.
  Trigger: Input, state, or execution path that exposes the bug.
  Suggested fix: Minimal fix direction.
  Test gap: Missing or weak test coverage, if relevant.

### High
- [H1] `path/to/file:line` Short problem title
  Impact: ...
  Evidence: ...
  Trigger: ...
  Suggested fix: ...
  Test gap: ...

### Medium
- [M1] `path/to/file:line` Short problem title
  Impact: ...
  Evidence: ...
  Trigger: ...
  Suggested fix: ...
  Test gap: ...

### Low
- [L1] `path/to/file:line` Short problem title
  Impact: ...
  Evidence: ...
  Trigger: ...
  Suggested fix: ...
  Test gap: ...

## Testing Gaps
- [Only gaps not already attached to individual findings]

## Questions
- [Only unresolved questions needed to complete the review]

## Residual Risks
- [What was not fully reviewable and why]

## Verification
- Context collected: [command]
- Additional checks run: [commands or "not run"]
```

Omit empty severity sections. Keep summaries brief and below findings.

## Without Findings

```markdown
## Findings

No findings.

## Testing Gaps
- [Any meaningful coverage gaps, or "None identified from the reviewed diff."]

## Residual Risks
- [What was not fully reviewable and why]

## Verification
- Context collected: [command]
- Additional checks run: [commands or "not run"]
```

## Quality Bar

- Every finding needs evidence.
- Every finding should describe impact, not just code shape.
- Do not include style-only comments.
- Do not include broad refactor suggestions unless they prevent a concrete defect.
- Prefer `No findings` over weak or speculative findings.

## Severity Rollup

- `critical` / `high`: always report — bugs, security, and data-loss risks.
- `medium`: performance, error-handling, maintainability — include context.
- `low`: minor correctness/clarity suggestions — only when clearly valuable. Do not proactively hunt for style issues; this stays consistent with the findings-first discipline that excludes style unless it causes a concrete bug risk.
- Suspected false positives: silently dropped, never counted.

## Structured JSON

Emit the following JSON block after the text report. It MUST stay consistent with the findings listed above (same items, same severities). This schema mirrors `open-code-review-delegate` so both skills produce downstream-compatible output.

Compatibility notes for downstream consumers:
- `mode` uses open-code-review-delegate-compatible values: `workspace` (review-spd uncommitted mode), `range` (review-spd commit-range **and** branch/PR mode — branch comparisons use `range` with explicit `from`/`to`), `commit` (single commit). No separate `branch` mode is emitted.
- `rules[]` carries a `rule` field but intentionally omits `path_pattern` (review-spd has no file-type rule matching); tolerate its absence.
- `category` intentionally covers only `bug | security | performance | test | other` (maintainability/style/documentation are excluded by the findings-first discipline); tolerate the narrower set.

```json
{
  "tool": "review-spd",
  "mode": "workspace | range | commit",
  "repository": "<repo path>",
  "target": { "type": "workspace | range | commit", "from": "<ref>", "to": "<ref>", "commit": "<hash>" },
  "files": [
    { "path": "src/foo.go", "status": "modified", "insertions": 2, "deletions": 0 }
  ],
  "rules": [
    { "rule": "review-spd is focus-driven; no rule.json engine" }
  ],
  "findings": [
    {
      "path": "src/foo.go",
      "start_line": 10,
      "end_line": 12,
      "category": "bug | security | performance | test | other",
      "severity": "critical | high | medium | low",
      "comment": "problem description",
      "suggestion": "fix suggestion (optional)"
    }
  ],
  "summary": { "files_reviewed": 1, "critical": 0, "high": 0, "medium": 0, "low": 0 }
}
```
