## 1. Root-resolution helper

- [x] 1.1 Add `_resolve_init_root <tool_name>` to `bin/setup`: inside a Git repo it echoes the `git rev-parse --show-toplevel` root; outside a Git repo it warns, prompts "Initialize <tool> in the current directory anyway? [y/N]" (default no) via `util::prompt_yes_no`, echoes the working directory on yes, and returns non-zero on skip. Normalize the resolved path with `cd "$root" && pwd -P`.
- [x] 1.2 Confirm the helper returns skip (non-zero) without prompting when no TTY is available.

## 2. Rewire init functions

- [x] 2.1 In `_init_openspec`, replace the git-check block (bin/setup:192-197) with a call to `_resolve_init_root "OpenSpec"`; run `openspec init --tools opencode` from the resolved root; return 0 (skip) when the helper reports skip.
- [x] 2.2 In `_init_codebase_memory_mcp`, replace the git-check block (bin/setup:267-272) with a call to `_resolve_init_root "codebase-memory-mcp"`; use the resolved root for the AGENTS.md, plugin, and MCP config writes; return 0 (skip) when the helper reports skip.
- [x] 2.3 Update the script header comment (bin/setup:4) to note non-git directories are prompted rather than rejected.

## 3. Verification

- [x] 3.1 Run `bash -n bin/setup` to confirm the script parses.
- [x] 3.2 In a throwaway non-git directory, run setup interactively and confirm: accepting init writes OpenSpec/AGENTS.md/.opencode into that directory; declining logs a skip and continues without error.
- [x] 3.3 Pipe setup with no TTY (`echo y | ... < /dev/null`) in a non-git directory and confirm both tools are skipped.
- [x] 3.4 In a real Git repo (this project), run the affected init functions and confirm no prompt appears and the Git top-level is still used.