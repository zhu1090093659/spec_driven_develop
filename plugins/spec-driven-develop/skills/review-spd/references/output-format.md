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

Severity levels are defined **authoritatively** in `SKILL.md` → Phase 5 "Severity guide" (Critical / High / Medium / Low). Grade findings using those definitions; this section only adds rollup presentation rules.

- `critical` / `high`: always report — bugs, security, and data-loss risks.
- `medium` / `low`: report only when the finding meets the Phase 5 definitions; do not proactively hunt for style issues. This stays consistent with the findings-first discipline that excludes style unless it causes a concrete bug risk.
- Suspected false positives: silently dropped, never counted.

## Structured JSON

Emit the following JSON block after the text report. It MUST stay consistent with the findings listed above (same items, same severities). This schema mirrors `open-code-review-delegate` so both skills produce downstream-compatible output.

Compatibility notes for downstream consumers:
- `mode` uses open-code-review-delegate-compatible values: `workspace` (review-spd uncommitted mode), `range` (review-spd commit-range **and** branch/PR mode — branch comparisons use `range` with `from` = base and `to` = head, matching `review-context.py` `base`/`head`), `commit` (single commit). No separate `branch` mode is emitted.
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

**Text ↔ JSON consistency example.** The text finding below and the JSON object below MUST describe the same defect — same path, same line range, same severity, same category. This is the "same findings list" discipline from Phase 6.

Text finding:

```markdown
### Medium
- [M1] `src/parser.go:88` Nil dereference when input has zero length
  Impact: Panics on empty input because `input[0]` is read with no length guard.
  Evidence: `if input[0] == delimiter {` at line 88, no `len(input) == 0` check above.
  Suggested fix: return a clear error when `len(input) == 0`.
```

JSON object (same finding):

```json
{
  "path": "src/parser.go",
  "start_line": 88,
  "end_line": 91,
  "category": "bug",
  "severity": "medium",
  "comment": "Nil dereference when input has zero length: `input[0]` is read with no length guard, panicking on empty input.",
  "suggestion": "Return a clear error when len(input) == 0 before accessing input[0]."
}
```

If the text and JSON ever disagree (different severity, a finding present in one but not the other, or contradictory comment), the JSON is wrong — regenerate it from the text. Never let the two drift.
