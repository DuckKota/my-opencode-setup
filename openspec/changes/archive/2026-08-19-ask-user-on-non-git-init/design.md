## Context

`bin/setup` is a bash bootstrap script that installs and initializes OpenSpec and codebase-memory-mcp. Both `_init_openspec` (bin/setup:186) and `_init_codebase_memory_mcp` (bin/setup:261) begin by checking `util::is_git_project` on the current working directory; when the check fails they log a warning and `return 0` — silently skipping initialization. `util::prompt_yes_no` (src/utils/_utils.sh:63) already supports interactive prompting with a configurable default and a headless fallback.

## Goals / Non-Goals

**Goals:**
- Replace the silent non-git skip in both init functions with a per-tool user prompt.
- On opt-in, initialize into the current working directory instead of a Git root.
- Preserve current behavior for Git repositories and headless runs.

**Non-Goals:**
- Re-enabling `_ensure_git_project` (commented out at bin/setup:636) as a hard gate.
- Changing how OpenSpec or codebase-memory-mcp work inside a Git repository.
- Adding a combined single prompt for both tools.

## Decisions

**Decision: Shared root-resolution helper, called per tool.**
Extract the "resolve root or skip" logic into one helper, e.g. `_resolve_init_root <tool_name>`, used by both `_init_openspec` and `_init_codebase_memory_mcp`. It echoes the resolved root on success and returns non-zero when the tool should be skipped.
- Inside a Git repo: returns the `git rev-parse --show-toplevel` root (unchanged behavior, no prompt).
- Outside a Git repo: warns, prompts "Initialize <tool> in the current directory anyway? [y/N]", and returns the working directory on yes or skip on no.
Rationale: the two init functions duplicate an identical git-check block today (bin/setup:192-197 and bin/setup:267-272); a shared helper keeps the prompt semantics consistent and avoids a third copy.
Alternative considered: prompting inline in each function — rejected as duplication. Alternative considered: re-enabling `_ensure_git_project` with a prompt — rejected because it gates the whole script, but the user may want one tool and not the other.

**Decision: Headless default is "no" (skip).**
Call `util::prompt_yes_no "<prompt>" "no"`. When no TTY is available the helper falls back to the default (src/utils/_utils.sh:76-82), which now means skip — identical to today's behavior.
Rationale: keeps `curl | bash` in a non-git directory exactly as safe as it is today; the prompt only changes behavior for interactive runs.

**Decision: Non-git opt-in initializes into the working directory.**
`_init_openspec` runs `openspec init --tools opencode` from the working directory. `_init_codebase_memory_mcp` writes `AGENTS.md`, `.opencode/plugins`, and `.opencode/opencode.json` under the working directory and enables `auto_index`/`auto_watch` (global config flags, repo-independent).
Rationale: the working directory is the only sensible root when no Git root exists; it matches the user's explicit choice to initialize "here".

**Decision: Normalization preserved.**
Both Git-root and CWD paths pass through the existing `cd "$root" && pwd -P` normalization so downstream logic sees canonical absolute paths.

## Risks / Trade-offs

- Writing AGENTS.md and `.opencode/` into an arbitrary non-git directory could surprise the user → mitigation: explicit opt-in prompt makes the write visible before it happens; the prompt defaults to skip.
- `openspec init --tools opencode` behavior outside a Git repository is unverified (it may warn or fail) → mitigation: existing failure handling already reports initialization failure and continues; a failure in a non-git dir is non-fatal.
- `auto_watch` registers a background git watcher; in a non-git directory it is inert until a repo exists → mitigation: acceptable; it is a global config flag and harmless.

## Migration Plan

Update `bin/setup` with the shared helper and rewrite the two git-check blocks to use it. Manually verify in a throwaway non-git directory (init accepted, init declined, headless) and in a real Git repo (no prompt, unchanged output). No rollback concerns — the script is the only artifact.