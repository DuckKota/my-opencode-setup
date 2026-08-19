## Why

The `CodebaseMemoryReminder` plugin hard-blocks native `grep`/`glob` and shell search commands whenever a codebase knowledge graph is active, forcing the AI agent to use graph tools and re-run searches with an override flag. The block is too aggressive: it stops legitimate searches the project's own AGENTS.md explicitly permits (string literals, config values, non-code files), and it contradicts the plugin's "reminder" name. The AI agent gets blocked from doing work.

## What Changes

- Replace hard deny with a soft nudge: detected searches always run, and a short reminder line is prepended to the tool output.
- Add a per-session throttle: first 2 nudges fire, then 1 nudge every 10 detected searches. No timers.
- Remove the `--skip-graph` override flag and all gate/deny machinery (`deny()`, `GATE_MESSAGE`, `hasOverride`, `stripOverride`).
- Switch the plugin hook from `tool.execute.before` (deny) to `tool.execute.after` (annotate output).
- Keep detection logic unchanged: native `grep`/`glob` plus shell search binaries (including chained commands), armed only when the binary is in PATH and AGENTS.md carries the graph marker.

## Capabilities

### New Capabilities
- `codebase-memory-gate`: Governs how the codebase-memory-mcp reminder plugin steers AI agents toward graph tools without blocking search.

### Modified Capabilities

None. `openspec/specs/` is empty — this is the first spec.

## Impact

- `src/plugins/CodebaseMemoryReminder.ts` — primary edit; most of the file is rewritten.
- No changes to `AGENTS.md`, opencode config, or the codebase-memory-mcp server itself.
- No new dependencies; relies on the existing `tool.execute.after` plugin hook.
