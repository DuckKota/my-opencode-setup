## Context

The `CodebaseMemoryReminder` plugin in `src/plugins/CodebaseMemoryReminder.ts` intercepts search tools to steer agents toward the codebase-memory-mcp knowledge graph. Its current implementation is a hard gate: native `grep`/`glob` are denied outright (no override exists), and shell search commands (`rg`, `find`, `git grep`, etc.) are denied unless the agent manually appends `--skip-graph`. This blocks legitimate searches that AGENTS.md itself permits (string literals, config values, non-code files) and stalled the agent during real work.

Goal: keep the steering behavior but remove the blocking. Search always runs; a short reminder is attached to the output instead.

## Goals / Non-Goals

**Goals:**
- Every detected search executes normally and returns its real results.
- The agent sees a brief, throttle-limited reminder that graph tools exist.
- Minimal code churn: reuse the existing, battle-tested search detection.
- No new dependencies; use hooks already present in the plugin SDK.

**Non-Goals:**
- Auto-rewriting searches into graph calls (surprising result differences).
- Checking graph freshness/index state (a wrong nudge costs nothing now).
- Any timers or wall-clock logic in the throttle (count-based only).

## Decisions

### 1. Soft nudge via `tool.execute.after`, not deny via `tool.execute.before`
The plugin SDK exposes `tool.execute.after` with a mutable `output.output` string. The plugin prepends the reminder there. Alternatives: rewriting the search into a graph call in `before` (rejected — silent behavior change, graph results can differ from raw grep), or injecting context periodically (rejected — doesn't land at the moment of the search).

### 2. Keep existing detection logic verbatim
`isShellSearchCommand`, `firstToken`, `SEARCH_BINARIES`, `PRESET_WORDS`, and `LEADING_SEPARATOR_RE` already cover native `grep`/`glob` plus shell searches including chained forms (`cd /tmp && rg foo`). Reuse as-is; only the *response* to a match changes from deny to annotate. For native tools, `tool.execute.after` fires with the tool name, so detection is a simple `tool === "grep" || tool === "glob"` check; for shell tools the command must be parsed from `input.args.command`.

### 3. Count-based throttle, session-scoped
A per-session search counter (`Map<sessionID, number>`). Emit reminder when `count <= 2` or `count % 10 === 0`. No timestamps, no wall clock. The throttle makes the nudge a gentle habit-former instead of noise on every search.

### 4. Remove override and gate machinery
`--skip-graph`, `hasOverride`, `stripOverride`, `deny()`, and `GATE_MESSAGE` are deleted. With no blocking, an override is dead weight, and the user explicitly preferred simplicity over keeping it as a "mute" flag.

### 5. Keep marker-based arming
Arm only when the `codebase-memory-mcp` binary is in PATH and the workspace AGENTS.md contains the graph marker. A freshness check against the MCP server was considered and rejected: the marginal cost of a stale-graph nudge is one wasted graph call, not worth plugin-startup MCP traffic.

## Risks / Trade-offs

- [Prepending to long bash output may push content past truncation] → The reminder is short (1-2 lines); prepending (not appending) keeps it above the truncation cut for tail-heavy outputs. Raw command output is preserved verbatim after the reminder.
- [Reminder noise if throttle state is lost (e.g. server restart mid-session)] → State is in-memory per `sessionID`; a restart resets counts, which merely re-fires up to 2 nudges. Acceptable.
- [Agents may ignore the nudge entirely] → Acceptable: the plugin's job is to steer, not enforce; AGENTS.md still carries the priority guidance.
- [Memory growth of the counter map across many sessions] → Tiny (one int per session); unbounded sessions are already a runtime reality. No action needed.

## Migration Plan

Single-file change. Rollback: revert `src/plugins/CodebaseMemoryReminder.ts` to the deny-based version (previous commit). No data, config, or AGENTS.md changes; no coordinated deploy.

## Open Questions

None.
