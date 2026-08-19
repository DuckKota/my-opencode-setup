## Why

The `setup` script silently skips OpenSpec and codebase-memory-mcp initialization when the current directory is not a Git repository, even though both tools can operate in a plain directory. The blanket skip hides the capability and forces the user to re-run setup after `git init`.

## What Changes

- In `bin/setup`, replace the silent-skip branches in `_init_openspec` and `_init_codebase_memory_mcp` with a user prompt.
- When the working directory is not a Git repository, setup asks the user whether to initialize each tool in the current directory anyway or skip it.
- When the user opts in, setup initializes into the current working directory instead of a Git root.
- When no interactive TTY is available (headless `curl | bash`), setup falls back to skipping, preserving current behavior.

## Capabilities

### New Capabilities
- `setup-non-git-handling`: Defines how the setup script behaves when run outside a Git repository — prompting for OpenSpec and codebase-memory-mcp initialization instead of silently skipping.

### Modified Capabilities
<!-- No existing spec-level requirements change. -->

## Impact

- `bin/setup`: both `_init_openspec` and `_init_codebase_memory_mcp` gain prompt logic and a CWD fallback root.
- No changes to installed tool behavior, specs, or the OpenSpec CLI itself.