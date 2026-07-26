import { readFile } from "node:fs/promises"
import { dirname, join } from "node:path"
import { fileURLToPath } from "node:url"

const pluginRoot = dirname(fileURLToPath(import.meta.url))
const skillsPath = join(pluginRoot, "skills")

const stripFrontmatter = (content) =>
  content.replace(/^---\r?\n[\s\S]*?\r?\n---\r?\n?/, "")

const readPrompt = async (relativePath) => {
  const content = await readFile(join(pluginRoot, relativePath), "utf8")
  return stripFrontmatter(content).trim()
}

const unique = (items) => [...new Set(items)]

let assetsPromise

const loadAssets = async () => {
  if (!assetsPromise) {
    assetsPromise = Promise.all([
      readPrompt("commands/spec-dev.md"),
      readPrompt("commands/dp.md"),
      readPrompt("agents/project-analyzer.md"),
      readPrompt("agents/task-architect.md"),
      readPrompt("agents/task-executor.md"),
      readPrompt("agents/code-reviewer.md"),
    ]).then(
      ([specDevCommand, deepDiscussCommand, projectAnalyzer, taskArchitect, taskExecutor, codeReviewer]) => ({
        commands: {
          "spec-dev": {
            description: "Launch the Spec-Driven Development workflow for a large-scale project task",
            template: specDevCommand,
          },
          dp: {
            description: "Launch structured deep discussion for problem analysis, solution design, and brainstorming",
            template: deepDiscussCommand,
          },
        },
        agents: {
          "project-analyzer": {
            description:
              "Performs deep codebase analysis for the Spec-Driven Develop workflow. Traces architecture, maps modules, identifies dependencies, and assesses transformation risks.",
            mode: "subagent",
            prompt: projectAnalyzer,
            permission: { edit: "deny" },
          },
          "task-architect": {
            description:
              "Designs phased task decomposition for large-scale project transformations and produces dependency-aware implementation plans.",
            mode: "subagent",
            prompt: taskArchitect,
            permission: { edit: "deny" },
          },
          "task-executor": {
            description:
              "Executes a coherent delivery batch or one assigned lane from a phased plan. Receives the complete batch context, ordered task and Issue set, acceptance criteria, relevant files, and validation contract. Implements and commits the work, but leaves integration state, cumulative telemetry, and the single batch PR to the orchestrator.",
            mode: "subagent",
            prompt: taskExecutor,
          },
          "code-reviewer": {
            description:
              "Reviews one execution lane's diff against its per-task acceptance criteria, commits fixes directly to the lane branch, and returns a structured verdict to the orchestrator. Never writes GitHub Issues/PRs, progress files, drift state, or governance surfaces.",
            mode: "subagent",
            prompt: codeReviewer,
          },
        },
      }),
    )
  }

  return assetsPromise
}

export const SpecDrivenDevelopPlugin = async () => {
  const assets = await loadAssets()

  return {
    config: (cfg) => {
      cfg.skills ??= {}
      cfg.skills.paths = unique([...(cfg.skills.paths ?? []), skillsPath])

      cfg.command ??= {}
      for (const [name, command] of Object.entries(assets.commands)) {
        if (!cfg.command[name]) {
          cfg.command[name] = command
        }
      }

      cfg.agent ??= {}
      for (const [name, agent] of Object.entries(assets.agents)) {
        if (!cfg.agent[name]) {
          cfg.agent[name] = agent
        }
      }
    },
  }
}

export default SpecDrivenDevelopPlugin
