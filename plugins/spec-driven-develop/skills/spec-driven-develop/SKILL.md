---
name: spec-driven-develop
description: >-
  Automates pre-development workflow for large-scale complex tasks. Use when the user
  mentions "rewrite", "migrate", "overhaul", "refactor entire project", "transform",
  "rebuild in [language]", "spec-driven", or describes any large-scale project transformation
  that requires planning before coding. Also triggers on Chinese keywords: "改造", "重写",
  "迁移", "重构", "大规模", "规范驱动". Performs full project analysis, task decomposition,
  documentation generation, progress tracking setup, and task-specific sub-SKILL creation
  before any development begins.
version: 1.2.0
---

# Spec-Driven Develop

You are executing the **Spec-Driven Development** workflow — a standardized pre-development pipeline for large-scale complex tasks. Your job is to complete all preparation phases before any actual coding begins, ensuring the project has full analysis, a clear plan, trackable progress documents, and a task-specific SKILL.

## Before You Begin: Cross-Conversation Continuity Check

**CRITICAL**: Before starting any phase, check if `docs/progress/MASTER.md` already exists in the project.

- If it **exists**: Read it immediately. Then perform the **Session Handshake Protocol** (see below). You are resuming an in-progress task. Identify which phase you are in, what has been completed, and continue from the exact point where the previous conversation left off. Do NOT restart from Phase 0.
- If it **does not exist**: This is a fresh start. Proceed to Phase 0.

### Session Handshake Protocol

When resuming from an existing MASTER.md, perform these checks before doing anything else:

1. **Integrity verification**: Read each `docs/progress/phase-N-*.md` file and count the actual `[x]` checkboxes. Compare with the completion counts in MASTER.md. If they differ, **the phase files are the source of truth** — update MASTER.md counts to match.

2. **State reconstruction**: Read the "Next Action" field in MASTER.md's "Current Status" section. This contains the exact operation to resume. If this field is missing or unclear, fall back to inferring state from checkbox progress.

3. **Staleness detection**: Check the "Last Updated" timestamp in MASTER.md. If it is more than 7 days old, present the user with a brief status summary and ask: "It's been a while since the last session. Want me to re-validate the current plan before continuing, or proceed as-is?"

4. **Report**: Tell the user in 2-3 sentences: what phase you're in, what was last completed, and what you're about to do next.

After loading your current state from MASTER.md, populate the platform's native task tracking tool (e.g. TodoWrite) with the active phase's pending tasks. For each task, set content to the task description, status to "in-progress" for the currently active task and "todo" for the rest, and priority mapped as P0=high, P1=medium, P2=low. This gives the user real-time visual progress in their IDE. If no native task tool is available, skip this step — MASTER.md alone is sufficient.

---

## Phase 0: Intent Recognition, Scope Assessment & Confirmation

**Goal**: Understand exactly what the user wants to accomplish, assess the scale, and determine the appropriate workflow intensity.

**Actions**:

1. Identify the user's core intent from their message. Extract:
   - The type of transformation (language migration, framework change, architecture overhaul, new feature development, etc.)
   - The target state (e.g., "rewrite in Rust", "migrate to microservices")
   - Any constraints or preferences mentioned

2. **Scale Assessment** — Before asking clarifying questions, quickly scan the project to determine scope:
   - Count the files and approximate lines of code in scope
   - Classify the task scale:
     - **Small** (<10 files or <1000 LOC): Use **Lite Mode** — skip Phase 1 full analysis and Phase 4 sub-SKILL generation. Produce a lightweight task list and progress tracker only.
     - **Medium** (10-100 files or 1000-20000 LOC): Use **Standard Mode** — execute all phases normally.
     - **Large** (>100 files or >20000 LOC): Use **Full Mode** — execute all phases, mandatory use of sub-agents for parallel analysis, and generate detailed risk mitigation plans.
   - Present the detected scale and recommended mode to the user. The user may override (e.g., force Full Mode on a medium project).

3. Ask the user structured clarifying questions. At minimum, confirm:
   - **Scope**: Which parts of the project are in scope? The entire codebase or specific modules?
   - **Target**: What is the target technology/architecture/state?
   - **Constraints**: Are there hard constraints (timeline, backward compatibility, specific libraries, deployment targets)?
   - **Priorities**: What matters most — performance, maintainability, feature parity, or something else?

4. Summarize your understanding back to the user (including the workflow mode) and get explicit confirmation before proceeding.

**Output**: A clear, confirmed task definition with an assigned workflow mode (Lite/Standard/Full).

---

## Phase 1: Deep Project Analysis

**Goal**: Build a comprehensive understanding of the current codebase.

> **Lite Mode**: Skip this phase. Instead, write a single `docs/analysis/quick-summary.md` containing: tech stack, key files in scope, and the top 3 risks in bullet points. Then proceed to Phase 2.

**Actions**:

1. Analyze the project systematically:
   - Project structure and directory layout
   - Technology stack (languages, frameworks, build tools, dependency managers)
   - Entry points and build/run commands
   - Module inventory: each module's responsibility, public API surface, and approximate size
   - Dependency graph: internal module dependencies and external library dependencies
   - Code patterns: architectural patterns, design patterns, coding conventions in use

2. Assess transformation-specific concerns:
   - Which modules will be most challenging to transform?
   - What are the key risks (complex algorithms, platform-specific code, tight coupling)?
   - Are there external integration points that constrain the approach?

3. **For Large projects (Full Mode)**: Apply a sampling strategy. Do not attempt to analyze every file. Instead:
   - Fully analyze entry points, public API surfaces, and configuration files
   - For internal modules, analyze the top-level structure and representative files (1-2 per module)
   - Flag modules that need deeper analysis with a `[NEEDS-DEEP-DIVE]` marker for later

4. Write analysis documents to `docs/analysis/`:
   - `project-overview.md` — Architecture, tech stack, entry points, build system
   - `module-inventory.md` — Every module with: responsibility, dependencies, size, complexity rating
   - `risk-assessment.md` — Technical risks, compatibility risks, complexity hotspots

**On Claude Code**: If available, launch `project-analyzer` sub-agents in parallel to speed up analysis across different areas of the codebase.

**Output**: Complete `docs/analysis/` directory with three documents (or one quick-summary in Lite Mode).

---

## Phase 2: Task Decomposition

**Goal**: Break down the transformation into manageable, trackable tasks organized in phases.

### Lookback Check (before starting)

Before decomposing tasks, review the Phase 1 outputs:
- Are there modules mentioned in the project structure that are missing from the module inventory?
- Are there dependencies or integration points that were not captured in the risk assessment?
- If you find gaps, **update the Phase 1 documents first**, and append a note to the Session Log in MASTER.md: `"Phase 1 补充更新: [what was added]"`.

> **Lite Mode**: Produce a single `docs/plan/task-list.md` with a flat numbered list of tasks (no phases, no Mermaid diagram). Each task needs: description, effort estimate, and acceptance criteria. Then proceed to Phase 3.

**Actions**:

1. Design a phased approach based on the analysis:
   - Identify natural phase boundaries (e.g., core libraries first, then application layer, then integrations)
   - Order phases by dependency: foundational components before dependent ones
   - Each phase should be independently testable/verifiable

2. For each phase, define concrete tasks. Each task must have:
   - A clear description of what to do
   - Priority level (P0/P1/P2)
   - Estimated effort (S/M/L/XL)
   - Dependencies on other tasks
   - Acceptance criteria: how to verify the task is done
   - **Associated risks**: Link to risks from `risk-assessment.md` that relate to this task (use risk ID if available, otherwise a short description)

3. **Risk-first ordering**: Within each phase, at the same priority level, order tasks by associated risk severity (highest risk first). This ensures the hardest problems surface early, not at the end.

4. Map dependencies between tasks and phases using a Mermaid diagram.

5. Define milestones: meaningful checkpoints where the project reaches a demonstrably better state.

6. Write planning documents to `docs/plan/`:
   - `task-breakdown.md` — All phases and tasks with full detail
   - `dependency-graph.md` — Mermaid diagram showing task/phase dependencies
   - `milestones.md` — Milestone definitions with target criteria

**On Claude Code**: If available, launch `task-architect` sub-agents to explore different decomposition strategies in parallel.

**Output**: Complete `docs/plan/` directory with three documents (or one task-list in Lite Mode).

---

## Phase 3: Progress Tracking Documentation

**Goal**: Create a document-driven progress tracking system that survives across conversations.

**Actions**:

1. Create the **master control file** `docs/progress/MASTER.md` with:
   - Task name and description (from Phase 0)
   - **Workflow mode** (Lite/Standard/Full)
   - Link to each analysis document
   - Link to each plan document
   - A summary table of all phases with completion percentage
   - Links to each phase's detailed progress file
   - A "Current Status" section indicating which phase/task is active, including a **"Next Action"** field with the exact operation to perform next
   - A "Next Steps" section for the agent to quickly orient itself
   - A **"Timeline"** section (append-only log of task completions with timestamps)
   - A **"Decisions"** section (or link to decisions in phase files)

2. Create **one detailed progress file per phase**: `docs/progress/phase-N-<short-name>.md`
   - Each file contains the phase's tasks as checkbox items: `- [ ] Task description`
   - Include acceptance criteria inline for each task
   - Include a "Notes" section for recording decisions, blockers, and context
   - Include a **"Decisions"** section using the ADR-lite format (see Behavioral Rules)

3. The MASTER.md format must follow this convention:
   - Phases use the format: `- [ ] Phase N: <n> (0/X tasks) [details](./phase-N-<n>.md)`
   - When a phase is fully done: `- [x] Phase N: <n> (X/X tasks) [details](./phase-N-<n>.md)`
   - The "Current Status" section is updated by the agent at the start and end of each work session

> **Lite Mode**: Create only MASTER.md with a simplified format (no per-phase files; embed the task checklist directly in MASTER.md).

**Output**: Complete `docs/progress/` directory with MASTER.md and per-phase detail files.

---

## Phase 4: Task-Specific Sub-SKILL Generation

**Goal**: Create a SKILL tailored to this specific task, encoding the interaction patterns and development standards needed for the actual implementation work.

> **Lite Mode**: Skip this phase entirely. The main SKILL provides sufficient guidance for small tasks.

**Actions**:

1. Ask the user where to install the sub-SKILL:
   - **Project-level** (e.g., `.cursor/skills/` or project-local) — tied to this project, discarded when done
   - **Global-level** (e.g., `~/.cursor/skills/` or `~/.codex/skills/`) — persists across projects

2. **Select a base template** from `references/sub-skill-templates/` based on the transformation type:
   - `language-migration.md` — For language rewrites (Python→Rust, JS→TS, etc.)
   - `architecture-change.md` — For architecture overhauls (monolith→microservices, etc.)
   - `framework-migration.md` — For framework changes (React→Vue, Express→Fastify, etc.)
   - `general.md` — For tasks that don't fit the above categories
   - If no template fits, create from scratch.

3. Customize the selected template with:
   - Task-specific coding standards and conventions for the target technology
   - The cross-conversation continuity protocol (read MASTER.md first, run Session Handshake)
   - Guidance on how to update progress documents after completing each task
   - Phase-specific instructions relevant to the transformation type
   - The cleanup trigger: when all tasks are done, initiate Phase 6

4. **Install the sub-SKILL**:
   - On **Claude Code** or **Codex**: Invoke the platform's built-in `skill-creator` skill if available. Otherwise, create the SKILL.md directly following the standard frontmatter + markdown format.
   - On **Cursor**: If a skill-creator skill is available, use it. Otherwise, create the SKILL.md directly following the standard frontmatter + markdown format and place it in the chosen directory.

5. The generated sub-SKILL should instruct the agent to:
   - Always read `docs/progress/MASTER.md` at the start of every conversation
   - Run the Session Handshake Protocol to verify integrity
   - Update the checkbox status in the relevant phase file after completing each task
   - Update the completion count and "Current Status" in MASTER.md
   - Record decisions using ADR-lite format in the phase file's "Decisions" section
   - Append a timestamped entry to the "Timeline" section in MASTER.md after each task completion
   - When all checkboxes are checked, trigger Phase 6 (Cleanup)

**Output**: A task-specific SKILL installed at the user's chosen location.

---

## Phase 5: Handoff & Summary

**Goal**: Present all preparation artifacts to the user and confirm readiness to begin development.

### Coverage Verification (before presenting)

Before handing off, perform a final coverage check:
- Re-read the confirmed task definition from Phase 0
- For each user requirement/constraint, verify that at least one task in the task breakdown addresses it
- If any requirement is not covered, add the missing tasks and update all affected documents
- Present any gaps found and fixes applied to the user

**Actions**:

1. Present a structured summary to the user:
   - Task definition (from Phase 0)
   - Workflow mode and rationale (from Phase 0)
   - Key findings from analysis (high-level, from Phase 1)
   - Phased plan overview with task counts (from Phase 2)
   - Progress tracking system description (from Phase 3)
   - Sub-SKILL name and installation location (from Phase 4, if applicable)
   - Coverage verification result

2. List all generated artifacts:
   - `docs/analysis/project-overview.md` (or `quick-summary.md` in Lite Mode)
   - `docs/analysis/module-inventory.md` (Standard/Full only)
   - `docs/analysis/risk-assessment.md` (Standard/Full only)
   - `docs/plan/task-breakdown.md` (or `task-list.md` in Lite Mode)
   - `docs/plan/dependency-graph.md` (Standard/Full only)
   - `docs/plan/milestones.md` (Standard/Full only)
   - `docs/progress/MASTER.md`
   - `docs/progress/phase-N-*.md` (one per phase, Standard/Full only)
   - The generated sub-SKILL (Standard/Full only)

3. Ask the user: "All preparation is complete. Ready to begin Phase 1 development?"

**Output**: User confirmation to proceed with actual implementation.

---

## Phase 6: Cleanup & Documentation Conversion

**Trigger**: This phase activates when ALL checkboxes in `docs/progress/MASTER.md` are marked complete (`[x]`).

**Goal**: Clean up temporary artifacts while optionally converting valuable outputs into permanent project documentation.

**Actions**:

1. Announce to the user that all tasks have been completed. Congratulate them.

2. List all artifacts that were generated during this workflow:
   - The entire `docs/` directory tree
   - The task-specific sub-SKILL (name and location)
   - Any other temporary files created during development

3. For each artifact, present **three options** (not just keep/delete):
   - **Delete**: Remove the file entirely
   - **Keep as-is**: Preserve the file in its current location
   - **Convert to project docs**: Transform the file into permanent project documentation:
     - Strip transformation-specific language (e.g., "migrate from X to Y" becomes "current architecture")
     - Update content to reflect the final state (not the pre-transformation state)
     - Move to the project's standard documentation directory (e.g., `docs/`, `wiki/`, or as configured)
     - Suggest renaming where appropriate (e.g., `project-overview.md` → `ARCHITECTURE.md`)

   Common conversion suggestions:
   - `project-overview.md` → `ARCHITECTURE.md` (updated to reflect new architecture)
   - `module-inventory.md` → `MODULES.md` (updated with new module structure)
   - `risk-assessment.md` → Usually delete (transformation-specific)
   - `task-breakdown.md` → Usually delete (transformation-specific)
   - `MASTER.md` → Usually delete, but the Timeline section can be preserved as a changelog entry

4. Execute the user's choices:
   - Delete unchecked artifacts
   - For "convert" choices, transform and relocate the files
   - Uninstall/delete the sub-SKILL if not kept
   - If the user keeps nothing, remove the entire `docs/` directory

5. If any artifacts were preserved or converted, suggest committing them to version control.

**Output**: A clean project with only the artifacts the user chose to keep or convert.

---

## Important Behavioral Rules

1. **Never skip phases**. Even if you think a phase is unnecessary, at minimum create a lightweight version of its outputs. Exception: Lite Mode has pre-defined phase skips — follow those.

2. **Always confirm with the user** before proceeding to the next phase. Each phase boundary is a checkpoint.

3. **Document everything**. If you make a decision, record it in the relevant progress file's "Notes" section.

4. **Record decisions using ADR-lite format**. When making a significant choice (strategy, tool selection, ordering, trade-off), record it in the phase file's "Decisions" section:
   ```
   **Decision**: [What was decided]
   **Context**: [Why this decision was needed, what alternatives existed]
   **Consequence**: [What this means for subsequent work]
   ```

5. **Progress updates are mandatory**. After completing any task:
   - Update the checkbox in the phase file
   - Update the completion count in MASTER.md
   - Append a timestamped line to the Timeline section in MASTER.md:
     `- YYYY-MM-DD HH:MM — [Phase X Task Y.Z] completed: [brief description]`
   - Update the "Next Action" field in the Current Status section

6. **New conversation = Session Handshake first**. This is non-negotiable. Read MASTER.md, verify integrity against phase files, detect staleness, and report status to the user.

7. **Respect the user's time**. Keep summaries concise. Use bullet points and tables, not walls of text.

8. **Cleanup is not optional**. When all tasks are done, always enter Phase 6. Don't leave temporary artifacts behind.

9. **Dual-write progress updates**. When completing a task, update both the platform's native task tool (mark as completed) AND the Markdown progress files (check the box, update counts). The native tool provides real-time visibility; the Markdown files provide cross-conversation persistence. Neither replaces the other.

10. **Phase files are the source of truth** for task completion. If MASTER.md counts disagree with phase file checkboxes, the phase files win.

11. **Lookback is allowed at phase boundaries**. At the start of Phase 2 and Phase 5, review prior phase outputs for gaps. If gaps are found, update the earlier documents and log the update. This is not "going back" — it's ensuring quality before moving forward.
