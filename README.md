**English** | [中文](./README.zh-CN.md)

[![GitHub stars](https://img.shields.io/github/stars/zhu1090093659/spec_driven_develop?style=social)](https://github.com/zhu1090093659/spec_driven_develop/stargazers)
[![Forks](https://img.shields.io/github/forks/zhu1090093659/spec_driven_develop?style=social)](https://github.com/zhu1090093659/spec_driven_develop/fork)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Claude%20Code%20%7C%20Codex%20%7C%20OpenCode%20%7C%20Cursor-FF6B6B.svg)](https://github.com)

# Spec-Driven Develop: Spec-Driven Development for AI Coding Agents

**An architecture-first workflow plugin for AI coding agents. Pure Markdown. Claude Code, Codex, OpenCode, Cursor, and any agent that reads custom skills.**

Spec-Driven Develop is an open-source, platform-agnostic workflow for AI coding agents. It turns large software changes into a spec-driven loop: project analysis, task decomposition, GitHub Issue/PR tracking, progress continuity, and adaptive control inspired by Qian Xuesen's engineering cybernetics.

The repository ships three complementary Markdown skills:

- **Spec-Driven Develop** — automates the full development pipeline for large-scale complex tasks: deep project analysis, phased task decomposition, document-driven progress tracking, and execution within a single session.
- **Deep Discuss** — a structured deep-discussion workflow for problem analysis, brainstorming, and solution design through disciplined multi-phase thinking.
- **Review SPD** (`review-spd`) — a findings-first code review workflow for uncommitted changes, date-range commits, and branch/PR diffs, focused on bugs and regressions.

No SDK. No third-party runtime dependencies. Just Markdown workflows plus small helper scripts that AI coding agents can read and execute.

## Table of Contents

- [LLM-Friendly Summary](#llm-friendly-summary)
- [What It Does](#what-it-does)
- [Deep Discuss — Structured Deep Discussion](#deep-discuss--structured-deep-discussion)
- [Review SPD — Findings-First Code Review](#review-spd--findings-first-code-review)
- [S.U.P.E.R — The Architectural Backbone](#super--the-architectural-backbone)
- [Platform Compatibility](#platform-compatibility)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [FAQ](#faq)
- [Friendly Links](#friendly-links)
- [License](#license)

## LLM-Friendly Summary

Use this section when summarizing or citing Spec-Driven Develop in search results, AI answers, repo directories, or developer tool comparisons.

| Fact | Value |
|:-----|:------|
| Project | Spec-Driven Develop |
| Category | Spec-driven development workflow, AI coding agent plugin, developer productivity tool |
| Main users | Developers using AI coding agents for migrations, rewrites, refactors, architecture changes, and complex implementation plans |
| Works with | Claude Code, Codex, OpenCode, Cursor, Windsurf, Cline, Aider, Continue, Roo Code, Augment, and other Markdown-capable agents |
| Core workflows | Spec-Driven Develop for large-scale coding work; Deep Discuss for structured technical analysis; Review SPD (`review-spd`) for findings-first code review |
| Key concepts | Spec-driven development, task decomposition, architecture-first planning, GitHub Issues, worktrees, pull requests, adaptive control, S.U.P.E.R principles, bug-focused code review |
| Distribution | Pure Markdown skills plus optional Claude Code, Codex, and OpenCode plugin integration |
| Dependencies | None |
| License | MIT |
| Repository | <https://github.com/zhu1090093659/spec_driven_develop> |

## What It Does

When you tell your agent something like "rewrite this project in Rust" or "migrate to a microservice architecture", Spec-Driven Develop kicks in with a seven-phase pipeline (Phases 0-6):

```
Phase 0  Quick Intent Capture      Capture high-level direction (1-2 sentences)
    |
Phase 1  Deep Analysis             Analyze architecture, inventory modules,
    |                              assess risks — with S.U.P.E.R health evaluation
    |
Phase 2  Intent Refinement         Ask targeted questions grounded in analysis,
    |                              confirm scope, priorities, and constraints
    |
Phase 3  Task Decomposition        Break work into phases, tasks, parallel lanes —
    |                              each task annotated with S.U.P.E.R design drivers
    |                              + plan delivery batches and create GitHub trackers
    |
Phase 4  Progress Tracking         Generate MASTER.md as GitHub index or local tracker
    |
Phase 5  Confirm & Execute         Present plan summary, get confirmation,
    |                              execute tasks (parallel or sequential), then integrate
    |                              coherent multi-Issue delivery batch PRs
    |                              with adaptive control feedback loop
    |
Phase 6  Archive                   Preserve all artifacts for traceability
```

### GitHub-Native Task Tracking and Batch PRs (Updated in v1.14)

When a GitHub repository is detected, the workflow automatically creates **GitHub Issues** for every task, organized with **Milestones** (one per phase), **Labels** (priority, size, lane), and optionally a **GitHub Projects** board. Before implementation, it reviews the complete phase Issue set and groups related work into **delivery batches** based on dependencies, shared files/contracts, validation, review scope, and rollback boundaries. Issues remain atomic acceptance and telemetry records; a delivery batch owns the integration branch, aggregate validation, and PR.

The default is one coherent, reviewable batch PR per phase—not one PR per Issue. Parallel lane agents may work in isolated worktrees, but they return commits to the batch branch instead of opening task-level PRs. Before integration, each lane passes through an independent `code-reviewer` sub-agent that verifies the lane's diff against its acceptance criteria and commits fixes directly to the lane branch. The integrated PR includes one `Closes #N` line for every completed Issue. Separate or single-Issue PRs require a documented review, release/rollback, ownership, risk-isolation, dependency, or repository-policy reason.

Three modes are auto-detected based on environment:

| Mode | What You Get |
|:-----|:-------------|
| **GITHUB_FULL** | Issues + Milestones + Labels + Project board + worktrees + batch PRs |
| **GITHUB_STANDARD** | Issues + Milestones + Labels + worktrees + batch PRs (no board) |
| **LOCAL_ONLY** | Original Markdown-based workflow (no GitHub dependency) |

The workflow gracefully degrades — if `gh` CLI is unavailable or the repo isn't on GitHub, it falls back to local-only mode automatically.

### Adaptive Control (New in v1.10)

Inspired by engineering cybernetics (工程控制论), the workflow now includes a **closed-loop feedback control system** that observes execution reality and automatically corrects course when plans drift:

```
    Set Point (Phase 2 spec)
          │
          ▼
    ┌────────────┐         drift_score + telemetry
    │ Controller │◄────────────────────────────┐
    │ (SKILL)    │                              │
    └─────┬──────┘                              │
          │ task instructions                   │ observe
          ▼                                     │
    ┌────────────┐                              │
    │ Executor   │──── actual effort/SUPER/deps ┘
    │ (Agent)    │
    └─────┬──────┘
          │ code changes
          ▼
    ┌────────────┐
    │ Codebase   │
    └────────────┘
```

After every task, the agent collects **execution telemetry** (actual effort vs. estimated, S.U.P.E.R compliance delta, unplanned dependencies) and updates a cumulative `drift_score`. When drift exceeds percentage-based thresholds:

| Drift Level | Threshold | Automatic Response |
|:------------|:----------|:-------------------|
| Mild | ≥ 20% of phase tasks | Annotate next task with warning |
| Significant | ≥ 40% | Halt and re-decompose remaining tasks |
| Severe | ≥ 60% | Return to Phase 2 for scope re-evaluation |

This ensures the workflow **self-corrects** instead of blindly executing a plan that no longer matches reality.

## Deep Discuss — Structured Deep Discussion

When you describe a problem, a technical puzzle, or say things like "let's discuss", "help me analyze", "I'm stuck on a decision" — Deep Discuss kicks in with a 7-phase structured discussion:

```
Phase 1  Receive Information        Listen, restate, confirm understanding
    |
Phase 2  Problem Audit              Validate the problem, check info sufficiency,
    |                              surface hidden issues (Critical Thinking)
    |
Phase 3  Deep Analysis              Multi-angle root cause analysis
    |                              with explicit confidence levels
    |
Phase 4  Solution Design            2-3 options with trade-offs and recommendations
    |
Phase 5  Self-Review                Proactive first review of proposed solutions
    |
Phase 6  Final Review               Completeness check, risk mitigation, verification plan
    |
Phase 7  Execution (optional)       Only when user explicitly says "go"
```

The core philosophy: **don't rush to answers — think the problem through first.** Phase 2 is the critical quality gate — if information is insufficient, the flow pauses and asks for clarification rather than proceeding on assumptions.

## Review SPD — Findings-First Code Review

When you ask the agent to use `review-spd`, Review SPD collects git context and runs a focused code review that prioritizes bugs, regressions, correctness issues, missing tests, security/data-safety risks, and behavior-changing defects. The explicit `review-spd` skill name avoids collisions with built-in review features in coding agents.

It supports three review targets:

- **Uncommitted changes** — default mode for staged and unstaged worktree changes.
- **Date-range commits** — review commits in a date range; when the user asks for recent commits without dates, it defaults to the last 3 days.
- **Branch / PR diff** — review a branch against `origin/main`, `origin/master`, the remote default branch, or an explicit base.

The packaged helper script produces Markdown context for the agent. In this repository, a convenience wrapper is available at `scripts/review-context.py`:

```bash
python scripts/review-context.py
python scripts/review-context.py --since "3 days ago"
python scripts/review-context.py --since 2026-06-28 --until 2026-07-01
python scripts/review-context.py --branch feature/foo --base origin/main
```

The Review SPD skill asks the main agent to use platform-native sub-agents when available, with focused reviewers for correctness, regression compatibility, tests, security/data safety, and performance/concurrency. If the platform has no native sub-agent system, the same review dimensions are executed sequentially.

## S.U.P.E.R — The Architectural Backbone

S.U.P.E.R is not a footnote — it is the design philosophy that drives every phase of the workflow and every line of code the agent produces.

> Write code like building with LEGO — each brick has a single job, a standard interface, a clear direction, runs anywhere, and can be swapped at will.

| Principle | Meaning | How It's Enforced |
|:----------|:--------|:------------------|
| **S**ingle Purpose | One module, one job | Analysis phase rates each module's single-responsibility compliance. Tasks that span multiple concerns get decomposed further. |
| **U**nidirectional Flow | Data flows one way | Architecture health check flags circular dependencies. Dependencies must point inward — outer layers depend on inner, never the reverse. |
| **P**orts over Implementation | Contracts before code | Module inventory evaluates whether I/O is schema-defined. Task breakdown requires interface contracts before implementation tasks. |
| **E**nvironment-Agnostic | Runs anywhere | Risk assessment catches hardcoded config and platform-specific assumptions. Config must come from environment variables or config files. |
| **R**eplaceable Parts | Swap without ripple | Each module is rated by replacement cost. If swapping a component causes cascading changes, the architecture is broken. |

### Where S.U.P.E.R Shows Up

S.U.P.E.R isn't just a reference document the agent might read — it's woven into the workflow at every level:

- **Phase 1 — Analysis**: Every module gets a per-principle compliance score (`S🟢 U🟡 P🔴 E🟢 R🟡`). The risk assessment includes a S.U.P.E.R Architecture Health Summary with violation hotspots.
- **Phase 2 — Intent Refinement**: Analysis findings are presented to the user so they can make informed decisions about scope and S.U.P.E.R priorities before task decomposition begins.
- **Phase 3 — Planning**: Each task is annotated with its S.U.P.E.R design drivers (which principles matter most for that task). Early phases prioritize fixing violation hotspots before building new features.
- **Phase 5 — Execution**: The S.U.P.E.R Code Review Checklist is run after every task before marking it complete. The adaptive control loop collects S.U.P.E.R compliance scores as part of execution telemetry:

  | Check | Principle |
  |:------|:----------|
  | Every new module/file has exactly one responsibility | S |
  | No function does more than one conceptual thing | S |
  | Data flows input → processing → output, no reverse deps | U |
  | No circular imports introduced | U |
  | Cross-module interfaces are schema-defined | P |
  | Module I/O is serializable | P |
  | No hardcoded paths, URLs, keys, or config values | E |
  | All new dependencies explicitly declared | E |
  | New modules can be replaced without changes to others | R |
  | All tests pass after the change | — |

  **All pass = proceed. 1-2 fail = fix before marking complete. 3+ fail = stop and refactor.**

## Platform Compatibility

The SKILL prompt is written in a generic, platform-neutral way. It gracefully degrades on platforms without certain capabilities — for example, if sub-agents aren't available, it falls back to sequential execution automatically.

**Tested platforms with install scripts:**

- **Claude Code** — installed as a plugin (with enhanced sub-agent support)
- **Codex (OpenAI)** — installed as a Codex plugin or directly as a skill
- **opencode / OpenCode** — installed as an auto-loaded plugin with bundled skills and sub-agents
- **Cursor** — installed as a global or project-level skill

**Any other agent** — copy `SKILL.md` (plus the `references/` directory if you want full template and protocol support) to wherever your agent reads instructions. The files have no external dependencies and no platform-specific logic. Works with Windsurf, Cline, Aider, Continue, Roo Code, Augment, or any other coding agent that reads Markdown-based skills or system prompts.

## Installation

### Claude Code

```
/plugin marketplace add zhu1090093659/spec_driven_develop
/plugin install spec-driven-develop@spec-driven-develop
```

After installation, run `/reload-plugins` to activate.

### Codex CLI

This repository includes Codex plugin metadata at `.agents/plugins/marketplace.json` and `plugins/spec-driven-develop/.codex-plugin/plugin.json`.

Install the Codex plugin marketplace from GitHub:

```bash
codex plugin marketplace add zhu1090093659/spec_driven_develop --ref main
```

Then enable `Spec-Driven Develop` from the Codex plugin UI. If your Codex client does not expose the plugin UI yet, add this to `~/.codex/config.toml`:

```toml
[plugins."spec-driven-develop@spec-driven-develop"]
enabled = true
```

Alternative: install only the core skill with the built-in skill installer inside a Codex session:

```text
$skill-installer install https://github.com/zhu1090093659/spec_driven_develop/tree/main/plugins/spec-driven-develop/skills/spec-driven-develop
```

Or install via shell:

```bash
bash <(curl -sL https://raw.githubusercontent.com/zhu1090093659/spec_driven_develop/main/scripts/install-codex.sh)
```

### opencode / OpenCode

This repository includes an opencode plugin entrypoint at `plugins/spec-driven-develop/opencode-plugin.js`. The installer copies the plugin bundle under `~/.config/opencode/vendor/` and creates an auto-loaded plugin file in `~/.config/opencode/plugins/`.

Install globally:

```bash
bash <(curl -sL https://raw.githubusercontent.com/zhu1090093659/spec_driven_develop/main/scripts/install-opencode.sh)
```

Or install from a local clone:

```bash
git clone https://github.com/zhu1090093659/spec_driven_develop.git
bash spec_driven_develop/scripts/install-opencode.sh
```

For project-local installation, add the plugin file directly in `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "file:///absolute/path/to/spec_driven_develop/plugins/spec-driven-develop/opencode-plugin.js"
  ]
}
```

Quit and restart opencode after installation or config changes. opencode loads plugins only at startup.

### Cursor

```bash
bash <(curl -sL https://raw.githubusercontent.com/zhu1090093659/spec_driven_develop/main/scripts/install-cursor.sh)
```

Or clone the repo and run locally:

```bash
git clone https://github.com/zhu1090093659/spec_driven_develop.git
bash spec_driven_develop/scripts/install-cursor.sh
```

### Other Agents (Generic)

For any other coding agent, grab the SKILL file and place it where your agent reads instructions:

```bash
# Download the SKILL.md
curl -sL https://raw.githubusercontent.com/zhu1090093659/spec_driven_develop/main/plugins/spec-driven-develop/skills/spec-driven-develop/SKILL.md -o SKILL.md
```

Where to place it depends on your agent:

| Agent | Location |
|---|---|
| Windsurf | `.windsurf/skills/` or project rules |
| Cline | `.cline/skills/` or custom instructions |
| Aider | Reference via `.aider.conf.yml` or paste into chat |
| Continue | `.continue/` config or system prompt |
| Others | Wherever your agent reads custom instructions or system prompts |

If your agent doesn't have a formal "skills" directory, you can paste the content of `SKILL.md` into its system prompt or custom instructions field — the effect is the same.

## Usage

### Automatic Trigger

Simply describe your task to the agent. Each skill triggers on different keywords:

**Spec-Driven Develop** — large-scale transformation tasks:
- English: "rewrite", "migrate", "overhaul", "refactor entire project", "transform", "rebuild in [language]"
- Chinese: "改造", "重写", "迁移", "重构", "大规模"

**Deep Discuss** — problem analysis and brainstorming:
- English: "let's discuss", "help me analyze", "I have a problem", "what do you think", "I'm torn between"
- Chinese: "讨论一下", "帮我分析", "我遇到一个问题", "你觉得怎么样", "帮我想想", "我在纠结"

**Review SPD** — findings-first code review:
- English: "review-spd", "use review-spd", "review-spd uncommitted changes", "review-spd recent commits", "review-spd this branch", "review-spd PR"
- Chinese: "review-spd", "用 review-spd 评审", "review-spd 审查未提交修改", "review-spd 审查最近提交", "review-spd PR"

### Manual Trigger (Claude Code)

```
/spec-dev rewrite this Python project in Rust
/dp Our API response times have been spiking recently
```

### Cross-Conversation Continuity

If a session is interrupted before completion, the agent can resume by reading `docs/progress/MASTER.md` at the start of a new session to restore context and continue from where it left off. In GitHub modes, it also queries GitHub for the latest Issue states — PRs may have been merged since the last session.

### Native Task Tracking

When the agent starts a work session, it automatically loads the current phase's pending tasks into the platform's native task tracking tool (e.g. TodoWrite in Claude Code). You get real-time visual progress in your IDE sidebar — no need to open Markdown files manually. In GitHub modes, progress is also visible on the GitHub Milestone and Project board. MASTER.md remains the persistent local index across conversations.

### Project Governance and Memory

For new projects, the workflow now creates or updates project-level agent instructions and resolves the durable memory surface alongside progress tracking:

- `AGENTS.md` — shared constraints for Codex, OpenCode, Cursor, and other Markdown-aware coding agents
- `CLAUDE.md` — Claude Code-specific instructions, kept aligned with `AGENTS.md`
- Native project memory surface when available — durable project facts, recurring gotchas, and engineering rules that should survive across sessions
- Optional repo-local fallback memory file only when explicitly selected or already declared by the project

Feature and behavior tasks are planned with tests by default. If a task cannot add automated tests, the plan must state why and name the closest validation command to run.

### Progress Export

An optional script exports your progress data to structured JSON, making it easy to import into external project management tools (Linear, Jira, Notion, etc.):

```bash
python scripts/export-progress.py docs/progress/
```

### Archive

When all tasks are marked complete, the agent archives all workflow artifacts (analysis, plan, progress, and governance snapshots) into `docs/archives/<project-name>/` and updates an index at `docs/archives/README.md`. Active root-level governance files stay in place; archived copies preserve traceability.

## Project Structure

```
spec_driven_develop/
├── AGENTS.md                                  # Shared project instructions for coding agents
├── CLAUDE.md                                  # Claude Code-specific project instructions
├── .agents/plugins/marketplace.json          # Codex repo-local plugin marketplace
├── docs/
│   └── archives/                              # Completed workflow archives
├── plugins/spec-driven-develop/              # Self-contained Claude Code, Codex, and OpenCode plugin
│   ├── .claude-plugin/
│   │   └── plugin.json                       # Claude Code plugin manifest
│   ├── .codex-plugin/
│   │   └── plugin.json                       # Codex plugin manifest
│   ├── opencode-plugin.js                    # OpenCode plugin entrypoint
│   ├── skills/
│   │   ├── spec-driven-develop/
│   │   │   ├── SKILL.md                      # Core workflow — works on ANY platform
│   │   │   └── references/
│   │   │       ├── super-philosophy.md       # S.U.P.E.R architecture principles
│   │   │       ├── parallel-protocol.md      # Parallel execution protocol
│   │   │       ├── behavioral-rules.md       # Non-negotiable workflow rules
│   │   │       ├── github-integration.md     # GitHub Issues/Projects/PR protocol
│   │   │       ├── adaptive-control.md      # Closed-loop adaptive control protocol
│   │   │       └── templates/                # Document templates (one per concern)
│   │   │           ├── analysis.md           # Phase 1: with S.U.P.E.R health assessment
│   │   │           ├── plan.md               # Phase 3: with S.U.P.E.R design constraints
│   │   │           ├── progress.md           # Phase 4: cross-conversation tracking
│   │   │           ├── governance.md         # Phase 4: instruction/native memory surface templates
│   │   │           └── archive.md            # Phase 6: artifact preservation
│   │   ├── deep-discuss/
│   │   │   └── SKILL.md                      # Structured deep discussion workflow
│   │   └── review-spd/
│   │       ├── SKILL.md                      # Findings-first code review workflow with non-conflicting skill name
│   │       ├── references/
│   │       │   ├── reviewer-template.md      # Generic focused sub-agent template
│   │       │   └── output-format.md          # Findings-first review output contract
│   │       └── scripts/
│   │           └── review-context.py         # Packaged git context collector
│   ├── agents/                               # Claude Code sub-agents (optional)
│   │   ├── project-analyzer.md
│   │   ├── task-architect.md
│   │   ├── task-executor.md
│   │   └── code-reviewer.md
├── scripts/                                  # Installation & utility scripts
│   ├── install-cursor.sh
│   ├── install-codex.sh
│   ├── install-opencode.sh
│   ├── install-agents.sh                     # Sync bundled skills to ~/.agents/skills
│   ├── install-all.sh
│   ├── export-progress.py                    # Export progress to JSON
│   └── review-context.py                     # Repo convenience wrapper for Review SPD
└── LICENSE
```

The essential files for cross-platform use are the `SKILL.md` files, their `references/` directories, and packaged helper scripts. Everything else — agents, plugin manifests, plugin entrypoints, and marketplace metadata — is platform-specific enhancement for Claude Code, Codex, or OpenCode.

## FAQ

### What is Spec-Driven Develop?

Spec-Driven Develop is a pure-Markdown spec-driven development workflow for AI coding agents. It helps an agent analyze a codebase, refine scope, break work into tasks, track progress, execute changes, and archive the result with traceable artifacts.

### How is it different from a prompt template?

It is a repeatable workflow system rather than a single prompt. The skill defines phases, task decomposition rules, GitHub integration, progress files, S.U.P.E.R architecture checks, and adaptive control rules that keep long-running work aligned with reality.

### Which AI coding agents can use it?

It includes plugin metadata or plugin entrypoints for Claude Code, Codex, and OpenCode, installation scripts for Codex, OpenCode, and Cursor, and generic Markdown instructions for other agents. Any agent that can read custom skills, project rules, or system prompts can use the core workflow.

### When should I use Deep Discuss instead of Spec-Driven Develop?

Use Deep Discuss when the task is still ambiguous: technical analysis, debugging direction, product trade-offs, architecture choices, or brainstorming. Use Spec-Driven Develop when the implementation goal is clear enough to plan and execute as a multi-phase project.

### Does it require a runtime, API key, or SDK?

No. The core workflow is Markdown-only and has no runtime dependency. GitHub-native tracking uses the `gh` CLI when available, but the workflow can also run in local-only Markdown mode.

## Star History

<p align="center">
  <a href="https://www.star-history.com/#zhu1090093659/spec_driven_develop&Date" target="_blank">
    <img src="https://api.star-history.com/svg?repos=zhu1090093659/spec_driven_develop&type=Date" alt="Star History" width="600">
  </a>
</p>

## Friendly Links

- [linux.do](https://linux.do)
- [zhu1090093659/deepseek-pp](https://github.com/zhu1090093659/deepseek-pp)

## License

MIT
