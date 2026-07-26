# GitHub Integration Protocol

This document defines how the Spec-Driven Develop workflow integrates with GitHub Issues, Milestones, Labels, Projects, and Pull Requests for task tracking and execution.

---

## Operating Modes

The workflow auto-detects the best available mode via a pre-flight check. The user can also force a specific mode.

| Mode | Requirements | Capabilities |
|:-----|:------------|:-------------|
| **GITHUB_FULL** | `gh` CLI + auth + `project` scope | Issues + Milestones + Labels + Project board + worktrees + batch PRs |
| **GITHUB_STANDARD** | `gh` CLI + auth + `repo` scope | Issues + Milestones + Labels + worktrees + batch PRs (no board) |
| **LOCAL_ONLY** | None | Original local-file workflow (no GitHub) |

---

## Pre-flight Check

Run this check at the end of Phase 1 (after analysis, before proceeding to Phase 2). Report the detected mode to the user.

```bash
# Step 1: gh CLI exists?
gh --version > /dev/null 2>&1 || { echo "LOCAL_ONLY"; exit; }

# Step 2: Authenticated?
gh auth status > /dev/null 2>&1 || { echo "LOCAL_ONLY"; exit; }

# Step 3: GitHub remote exists?
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null) || { echo "LOCAL_ONLY"; exit; }

# Step 4: Can access issues?
gh issue list --repo "$REPO" --limit 1 > /dev/null 2>&1 || { echo "LOCAL_ONLY"; exit; }

# Step 5: Can access projects?
gh project list --limit 1 > /dev/null 2>&1 && echo "GITHUB_FULL" || echo "GITHUB_STANDARD"
```

If the detected mode differs from the user's preference, inform them and explain what's missing (e.g., "Project board requires the `project` scope. Run `gh auth refresh -s project` to enable it.").

---

## Resource Mapping

```
Spec-Driven-Develop Run  →  GitHub Project (board)     [GITHUB_FULL only]
├── Phase N               →  Milestone "Phase N: <name>"
│   ├── Task N.1          →  Issue with structured body
│   │   ├── Priority P0   →  Label "priority:P0"
│   │   ├── Size M        →  Label "size:M"
│   │   └── Lane A        →  Label "lane:A"
│   └── Task N.2          →  Issue with structured body
└── Delivery Batch B1     →  integration branch + one PR
    ├── Lane work         →  isolated worktree/branch + commits (no PR)
    ├── Task Issues       →  atomic acceptance + telemetry records
    └── Batch PR          →  one `Closes #N` line per completed Issue
```

Issue and PR cardinality are intentionally different. Keep one Issue per task for planning and telemetry, then group related Issues into the smallest coherent set of phase-local delivery batches. Default to one reviewable batch PR per phase; do not create a PR merely because one Issue is implemented.

---

## Label Scheme

Create these labels before creating Issues. Use `--force` for idempotency.

```bash
REPO="owner/repo"

# Priority labels
gh label create "priority:P0" --color "d73a4a" --description "Critical — must do first" --repo "$REPO" --force
gh label create "priority:P1" --color "e4e669" --description "Important — do soon" --repo "$REPO" --force
gh label create "priority:P2" --color "0e8a16" --description "Nice to have" --repo "$REPO" --force

# Size labels
gh label create "size:S" --color "c5def5" --description "Small — hours" --repo "$REPO" --force
gh label create "size:M" --color "bfd4f2" --description "Medium — a day" --repo "$REPO" --force
gh label create "size:L" --color "d4c5f9" --description "Large — days" --repo "$REPO" --force
gh label create "size:XL" --color "f9d0c4" --description "Extra large — a week+" --repo "$REPO" --force

# Spec-driven workflow label
gh label create "spec-driven" --color "1d76db" --description "Managed by Spec-Driven Develop workflow" --repo "$REPO" --force
```

Phase labels are created dynamically based on the actual phase names:
```bash
gh label create "phase:1" --color "ededed" --description "Phase 1: <name>" --repo "$REPO" --force
```

Lane labels are created dynamically based on parallel lane assignments:
```bash
gh label create "lane:A" --color "fef2c0" --description "Parallel lane A" --repo "$REPO" --force
```

---

## Milestone Creation

`gh` has no native `milestone create` subcommand. Use the REST API:

```bash
gh api repos/{owner}/{repo}/milestones \
  -f title="Phase 1: Foundation" \
  -f description="Phase 1 goal description" \
  -f state="open"
```

To list milestones: `gh api repos/{owner}/{repo}/milestones --jq '.[].title'`

---

## Issue Body Template

Every task Issue uses this structured body format:

```markdown
## Task: {task_id} — {task_name}

**Phase**: {phase_number} — {phase_name}
**Priority**: {priority} | **Size**: {size} | **Lane**: {lane}
**Delivery Batch**: {batch_id}
**S.U.P.E.R Drivers**: {principles}
**Test Expectation**: {required_tests_or_explicit_no_test_rationale}
**Memory/Governance Impact**: {memory_or_governance_update_expectation}

### Description
{task_description}

### Acceptance Criteria
- [ ] {criterion_1}
- [ ] {criterion_2}
- [ ] Passes S.U.P.E.R Quick Check for: {principles}
- [ ] Satisfies test expectation: {required_tests_or_explicit_no_test_rationale}
- [ ] Updates the resolved memory or instruction surfaces if durable project knowledge or agent instructions changed

### Affected Files
- `{file_path_1}`
- `{file_path_2}`

### Dependencies
- Depends on: {dependency_issue_refs or "None"}

---
_Managed by [Spec-Driven Develop](https://github.com/zhu1090093659/spec-driven-develop) workflow_
```

Create an Issue with:
```bash
gh issue create \
  --repo "$REPO" \
  --title "[T{task_id}] {task_name}" \
  --body "$ISSUE_BODY" \
  --label "spec-driven,priority:{p},size:{s},phase:{n},lane:{lane}" \
  --milestone "Phase {n}: {phase_name}"
```

Add a 1-second delay between Issue creations to avoid secondary rate limits.

---

## Project Board Setup (GITHUB_FULL only)

### Create Project and Link to Repo

```bash
# Create project (returns project number)
PROJECT_NUM=$(gh project create --owner "@me" --title "Spec: {project_name}" --format json | jq -r '.number')

# Link to repository
gh project link "$PROJECT_NUM" --owner "@me" --repo "$REPO"
```

### Create Custom Fields

```bash
OWNER="@me"

# Priority field (mirrors labels but enables board filtering)
gh project field-create "$PROJECT_NUM" --owner "$OWNER" --name "Priority" --data-type "SINGLE_SELECT" --single-select-options "P0,P1,P2"

# Size field
gh project field-create "$PROJECT_NUM" --owner "$OWNER" --name "Size" --data-type "SINGLE_SELECT" --single-select-options "S,M,L,XL"

# Phase field
gh project field-create "$PROJECT_NUM" --owner "$OWNER" --name "Phase" --data-type "SINGLE_SELECT" --single-select-options "Phase 1,Phase 2,Phase 3"
```

### Add Issues to Project

```bash
# For each created Issue URL:
gh project item-add "$PROJECT_NUM" --owner "$OWNER" --url "$ISSUE_URL"
```

Setting custom field values on items requires GraphQL node IDs. Retrieve them with:
```bash
# Get project ID
PROJECT_ID=$(gh project view "$PROJECT_NUM" --owner "$OWNER" --format json | jq -r '.id')

# Get field IDs
gh project field-list "$PROJECT_NUM" --owner "$OWNER" --format json | jq '.fields[] | {name: .name, id: .id}'

# Get item IDs
gh project item-list "$PROJECT_NUM" --owner "$OWNER" --format json | jq '.items[] | {title: .title, id: .id}'
```

Then set field values:
```bash
gh project item-edit \
  --id "$ITEM_ID" \
  --field-id "$FIELD_ID" \
  --project-id "$PROJECT_ID" \
  --single-select-option-id "$OPTION_ID"
```

If setting custom field values fails, this is non-critical — the Issue Labels already carry the same information (priority, size, phase). Log a warning and continue.

---

## Delivery Batch Execution Workflow (worktree + PR)

The orchestrator owns batch boundaries, integration state, cumulative drift, and PR creation. Task executors implement complete batches or assigned lanes; they do not create task-level PRs.

### 1. Review the Complete Phase Issue Set

Before editing, list all open Issues in the active phase, then read each Issue's body and comments. Compare dependencies, affected files, shared contracts/tests, release target, review ownership, and rollback risk.

```bash
gh issue list --repo "$REPO" --milestone "Phase {n}: {phase_name}" --state open --json number,title,labels
gh issue view {issue_number} --repo "$REPO" --json number,title,body,comments,labels,milestone
```

Use these rules to confirm or revise delivery batches:

1. Keep batches within one Phase/Milestone by default.
2. Prefer one coherent batch for Issues that share an architecture invariant, API/data contract, file hotspot, test fixture, or release target.
3. Keep dependency order executable inside the batch; serialize batches when one depends on another.
4. Default to one reviewable batch PR per phase. Split only for a documented reviewability, independent release/rollback, ownership, high-risk isolation, hard dependency, or repository/user policy boundary.
5. Do not split mechanically by Issue count. A single-Issue batch requires an explicit rationale unless it is the only Issue in the phase.

Record every confirmed or revised Task → Issue → Delivery Batch mapping in `docs/plan/task-breakdown.md` and MASTER.md before implementation. If regrouping changes a previously created Issue, update its structured `**Delivery Batch**` field with `gh issue edit --body-file <updated-body-file>` while preserving the rest of the body, then comment with the reason. The Issue body, plan, and MASTER.md must never disagree about the active batch.

### 2. Create the Batch Integration Branch and Worktrees

Follow the repository's branch convention. If none exists, use:

- Integration branch: `batch/{batch_id}-{slug}`
- Optional lane branch: `work/{batch_id}-{lane_id}-{slug}`

For a one-lane batch, work directly in one isolated worktree on the integration branch. For a genuinely parallel batch, execute dependency-ready lanes in waves. Create each wave's lane worktrees from the current integration base; integrate prerequisite commits before branching downstream waves. Every lane receives the complete batch context and its assigned Issue subset.

If the platform provides a native worktree tool, use it according to that platform's documentation instead of manual worktree management.

### 3. Implement and Commit Without Creating PRs

Follow each Issue's acceptance criteria, test expectation, and memory/governance impact. Read the resolved instruction and memory surfaces before editing. Keep commits reviewable and reference the relevant Issues without closing them:

```bash
git add -A
git commit -m "feat: {batch_or_lane_description} (refs #{issue_1}, refs #{issue_2})"
```

Lane agents return branch and commit references to the orchestrator. They must not run `gh pr create`, add `Closes #N`, update cumulative adaptive state, or race to edit MASTER.md.

### 4. Integrate and Validate the Complete Batch

The orchestrator consolidates lane commits onto the batch integration branch, resolves overlaps, and runs:

- Every included Issue's targeted tests and acceptance checks
- The batch's combined build/test/smoke validation
- The post-integration S.U.P.E.R architecture checks from `parallel-protocol.md`
- Per-Issue telemetry collection, followed by one cumulative drift update

If an Issue is only partially covered, leave it open and use `Refs #N`; do not include a closing keyword until all acceptance criteria pass.

### 5. Push and Create One Batch PR

Push only the integrated batch branch, then create one PR for all completed Issues in the batch:

```bash
BATCH_BRANCH="{resolved_batch_branch}"
git push -u origin "$BATCH_BRANCH"

gh pr create \
  --repo "$REPO" \
  --title "[Batch {batch_id}] {batch_name}" \
  --body "$(cat <<'EOF'
## Batch Rationale
{why_these_issues_are_one_coherent_review_and_rollback_unit}

## Included Issues
Closes #{issue_1}
Closes #{issue_2}
Refs #{partially_covered_issue_if_any}

| Issue | Task | Acceptance | Targeted Validation |
|:------|:-----|:-----------|:--------------------|
| #{issue_1} | {task_1} | complete | {tests_1} |
| #{issue_2} | {task_2} | complete | {tests_2} |

## Changes
- {change_1}
- {change_2}

## Aggregate Validation
- {combined_test_commands_and_results}

## S.U.P.E.R Review
- [x] Batch passes the post-integration S.U.P.E.R checks for: {principles}

## Risk and Rollback
- Risk: {risk_summary}
- Rollback: {rollback_plan}

## Project Governance
- Instruction surfaces: updated / unchanged (list paths or native surfaces)
- Memory surface: updated / unchanged / unavailable / fallback used

---
_Part of [Spec-Driven Develop](https://github.com/zhu1090093659/spec-driven-develop) workflow_
EOF
)"
```

Add one standalone `Closes #N` line for every fully completed Issue. This lets one merged PR close the whole delivery batch while preserving Issue-level history.

### 6. Synchronize In-Review State and Comment on Issues

Immediately after the PR is created:

1. Update the delivery batch row in MASTER.md with the PR number and `in review`.
2. Update every fully completed Issue row with the PR number and `in review`.
3. Keep each partially covered Issue open with the PR number, `partial`, and its remaining acceptance work.
4. Comment on every included Issue using completion-accurate language:

```bash
# Fully completed and awaiting merge
gh issue comment {completed_issue} --repo "$REPO" --body "Fully implemented in delivery batch {batch_id}; integration PR: #{pr_number}. Pending merge."

# Referenced but not complete
gh issue comment {partial_issue} --repo "$REPO" --body "Partially covered by delivery batch {batch_id}; integration PR: #{pr_number}. This Issue remains open. Outstanding: {remaining_acceptance_work}."
```

This synchronization is required before yielding the session so resume logic cannot mistake an open batch PR for unstarted work or create a duplicate PR.

### 7. Cleanup

After the batch PR is merged, remove its integration and lane worktrees/branches according to repository policy. Do not clean a lane before the orchestrator has integrated its commits.

---

## Reading Progress from GitHub

New-session continuity protocol (when MASTER.md indicates a GitHub mode):

```bash
REPO="owner/repo"

# Get all milestones with completion stats
gh api repos/{owner}/{repo}/milestones --jq '.[] | "\(.title): \(.open_issues) open, \(.closed_issues) closed"'

# Get open tasks for a specific phase
gh issue list --repo "$REPO" --milestone "Phase 1: Foundation" --state open --json number,title

# Get closed tasks for a specific phase
gh issue list --repo "$REPO" --milestone "Phase 1: Foundation" --state closed --json number,title

# Get all spec-driven Issues
gh issue list --repo "$REPO" --label "spec-driven" --state all --json number,title,state,milestone

# Get open batch PRs
gh pr list --repo "$REPO" --state open --search "in:title Batch" --json number,title,headRefName,url
```

---

## Closing Issues

Issues are closed automatically when their delivery batch PR is merged. The PR body contains one `Closes #N` line per fully completed Issue, so one PR may close several Issues. Do not create single-Issue PRs by default, and do NOT close Issues manually unless the task is cancelled or deferred. Partial coverage uses `Refs #N` and leaves the Issue open.

To defer a task:
```bash
gh issue close {issue_number} --repo "$REPO" --reason "not planned" --comment "Deferred: {reason}"
```
