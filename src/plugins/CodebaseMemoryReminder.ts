import { readFileSync } from "fs"
import { join } from "path"
import type { Plugin } from "@opencode-ai/plugin"

const OVERRIDE_FLAG = "--skip-graph"
const GRAPH_MARKER = "<!-- codebase-memory-mcp:start -->"
const AGENTS_FILENAME = "AGENTS.md"

// Content-searching binaries on a shell line. Leading-token only.
const SEARCH_BINARIES = new Set([
  "grep",
  "egrep",
  "fgrep",
  "rg",
  "ag",
  "ack",
  "find",
  "fd",
])

// Shell reserved words tolerated before the actual command.
const PRESET_WORDS = new Set(["command", "builtin", "exec", "time", "env", "sudo"])

// Shell control chars and escapes that can precede the first command word.
const LEADING_SEPARATOR_RE = /^[;&|()\s!\\]+/

const GATE_MESSAGE = `Search rejected: a codebase knowledge graph is active for this project.

Use the graph tools for code discovery first:
- search_graph() — find functions/classes/routes/variables
- trace_path(...)   — who calls something / what it calls
- get_code_snippet() — read a specific symbol's source
- get_architecture() — project structure overview

If you genuinely need a raw string/error/config literal or must search
non-code files, re-run the search as a bash command and append the override,
e.g.:
    rg --skip-graph "foo"

For native grep/glob there is no override; switch to a bash command above.
`

export const CodebaseMemoryReminderPlugin: Plugin = async ({ directory, $ }) => {
  // Only arm the gate when the knowledge graph is actually configured.
  // Binary present...
  try {
    await $`which codebase-memory-mcp`.quiet()
  } catch {
    console.warn("[codebase-memory] binary not in PATH — plugin disabled")
    return {}
  }

  // ...and declared for this project.
  const workspaceRoot = directory || process.cwd()
  const agentsPath = join(workspaceRoot, AGENTS_FILENAME)
  let graphActive = false
  try {
    graphActive = readFileSync(agentsPath, "utf8").includes(GRAPH_MARKER)
  } catch {
    // No AGENTS.md in the workspace.
  }

  if (!graphActive) {
    console.warn("[codebase-memory] AGENTS.md lacks the codebase-memory-mcp marker — plugin disabled")
    return {}
  }

  const deny = () => {
    throw new Error(GATE_MESSAGE)
  }

  return {
    "tool.execute.before": async (input, output) => {
      const tool = String(input?.tool ?? "").toLowerCase()

      // Native search tools: no flag override exists; always direct to bash.
      if (tool === "grep" || tool === "glob") {
        deny()
      }

      if (tool !== "bash" && tool !== "shell") return

      const command = (output?.args as Record<string, unknown>)?.command
      if (typeof command !== "string" || command.length === 0) return

      if (!isShellSearchCommand(command)) return

      // The user/model explicitly bypassed the graph.
      if (hasOverride(command)) {
        output.args.command = stripOverride(command)
        return
      }

      deny()
    },
  }
}

function isShellSearchCommand(command: string): boolean {
  // Inspect each command segment split on operators, so chained forms like
  // `cd /tmp && rg foo` are caught too. Matching a leading token (not a
  // substring) avoids false positives such as `cp foo.rg bar`.
  return command
    .split(/\n|\|\||&&|[;|]/)
    .map(s => s.trim())
    .filter(s => s.length > 0)
    .some(segIsSearch)
}

function segIsSearch(segment: string): boolean {
  const { first, second } = firstToken(segment)
  if (!first) return false

  // git grep counts as search; git subcommands otherwise are not.
  if (first === "git") return second === "grep"

  return SEARCH_BINARIES.has(first)
}

function firstToken(s: string): { first: string; second: string } {
  let t = s
  for (let i = 0; i < 4; i++) {
    const prev = t
    t = LEADING_SEPARATOR_RE.test(t) ? t.replace(LEADING_SEPARATOR_RE, "") : t
    if (t === prev) break
  }

  // Walk leading non-command tokens: reserved words, env (VAR=value),
  // and flags (with one optional value token) — but never swallow a token
  // that is itself a search binary, so `sudo -E rg` still resolves to rg.
  const toks = t.split(/\s+/).filter(x => x.length > 0)
  let i = 0
  while (i < toks.length) {
    const tok = toks[i].toLowerCase()
    if (PRESET_WORDS.has(tok)) {
      i++
      if (tok === "command" && /^(-v|-V|--)$/.test(toks[i] ?? "")) i += 2
      continue
    }
    if (/^[a-z_][a-z0-9_]*=/i.test(tok)) {
      i++
      continue
    }
    if (/^--/.test(tok)) {
      i++
      continue
    }
    if (/^-/.test(tok)) {
      i++
      if (toks[i] && !/^-/.test(toks[i]) && !SEARCH_BINARIES.has(toks[i])) i++
      continue
    }
    break
  }

  return { first: toks[i]?.toLowerCase() ?? "", second: toks[i + 1]?.toLowerCase() ?? "" }
}

function hasOverride(command: string): boolean {
  return new RegExp(`(?<!\\S)${OVERRIDE_FLAG}(?=\\s|$)`, "g").test(command)
}

function stripOverride(command: string): string {
  return command.replace(/\s*--skip-graph\b/g, "").trim()
}