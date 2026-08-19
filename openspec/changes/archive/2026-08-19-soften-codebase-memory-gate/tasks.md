## 1. Rewrite plugin from gate to nudge

- [x] 1.1 Remove gate machinery: `deny()`, `GATE_MESSAGE`, `hasOverride`, `stripOverride`, `OVERRIDE_FLAG`
- [x] 1.2 Add per-session search counter (`Map<sessionID, number>`)
- [x] 1.3 Implement `tool.execute.after` hook that prepends the `[codebase-memory]` reminder to `output.output` for detected searches
- [x] 1.4 Keep native `grep`/`glob` detection (tool name check) and shell search detection (`isShellSearchCommand`) unchanged
- [x] 1.5 Apply throttle: emit reminder on search 1-2, then every 10th search (2, 12, 22, ...)
- [x] 1.6 Remove the `tool.execute.before` hook entirely

## 2. Verification

- [x] 2.1 Typecheck the plugin (`bun`/`tsc` as configured in this repo)
- [x] 2.2 Manually verify in a marked project: native `grep`, native `glob`, and `rg` all run to completion with the reminder prepended
- [x] 2.3 Verify throttle: 3rd-11th searches produce no reminder; 12th produces one
- [x] 2.4 Verify `--skip-graph` passes through to the command unmodified
- [x] 2.5 Verify a project without the AGENTS.md marker produces no reminders
