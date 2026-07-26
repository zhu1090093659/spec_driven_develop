# Claude Code Instructions

Read `AGENTS.md` first. It is the shared project-level instruction source for Codex, OpenCode, Cursor, Claude Code, and other Markdown-aware coding agents.

Claude Code-specific reminders:

- The optional Claude Code sub-agent prompts live in `plugins/spec-driven-develop/agents/`, including `code-reviewer.md`, the per-lane review-and-fix sub-agent used in the execution loop.
- Slash command entrypoints live in `plugins/spec-driven-develop/commands/`.
- When the shared workflow rules change, update Claude Code-specific prompts only where their execution contract also changes.
- Do not duplicate shared policy here. Put durable cross-agent rules in `AGENTS.md`; use Claude Code's native project memory surface for stable project facts when available.
