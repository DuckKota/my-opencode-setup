# setup-non-git-handling Specification

## Purpose

Defines how the setup script handles non-git working directories: instead of silently skipping OpenSpec and codebase-memory-mcp initialization, setup prompts the user to opt in per tool, uses the working directory as the initialization root when they do, falls back to skipping in headless runs, and leaves git-repository behavior unchanged. (TBD — refine as the capability evolves.)

## Requirements

### Requirement: Non-git working directories prompt for initialization
When the setup script runs in a working directory that is not a Git repository, it SHALL NOT silently skip OpenSpec and codebase-memory-mcp initialization. Instead, it SHALL ask the user whether to initialize each tool in the current directory or skip it.

#### Scenario: Setup prompts when directory is not a Git repository
- **WHEN** setup runs in a directory that fails `util::is_git_project`
- **THEN** setup prompts the user to initialize OpenSpec in the current directory, accepting a yes or no answer
- **AND** setup separately prompts the user to initialize codebase-memory-mcp in the current directory, accepting a yes or no answer

#### Scenario: User declines initialization
- **WHEN** the user answers "no" to the OpenSpec or codebase-memory-mcp prompt
- **THEN** setup skips that tool's initialization with a clear message
- **AND** setup continues running the remaining steps without error

### Requirement: Opt-in initialization uses the working directory as root
When the user opts in to initialize OpenSpec or codebase-memory-mcp in a non-git working directory, setup SHALL treat the working directory as the initialization root. OpenSpec SHALL run `openspec init --tools opencode` in the working directory, and codebase-memory-mcp SHALL write its AGENTS.md instructions, plugin, and MCP config to the working directory.

#### Scenario: User accepts OpenSpec initialization in non-git directory
- **WHEN** the user answers "yes" to the OpenSpec prompt in a non-git directory
- **THEN** setup runs `openspec init --tools opencode` in the working directory
- **AND** setup reports OpenSpec initialized successfully

#### Scenario: User accepts codebase-memory-mcp initialization in non-git directory
- **WHEN** the user answers "yes" to the codebase-memory-mcp prompt in a non-git directory
- **THEN** setup writes the codebase-memory-mcp instructions into `AGENTS.md` in the working directory
- **AND** setup installs the CodebaseMemoryReminder plugin into `.opencode/plugins` in the working directory
- **AND** setup registers the codebase-memory-mcp MCP server in `.opencode/opencode.json` in the working directory
- **AND** setup enables the `auto_index` and `auto_watch` config flags

### Requirement: Headless runs fall back to skipping
When no interactive TTY is available, setup SHALL default to skipping OpenSpec and codebase-memory-mcp initialization in a non-git working directory, preserving the prior silent-skip behavior.

#### Scenario: Headless run in non-git directory skips initialization
- **WHEN** setup runs in a non-git directory with no TTY available for prompting
- **THEN** setup skips OpenSpec initialization
- **AND** setup skips codebase-memory-mcp initialization

### Requirement: Git repositories retain existing behavior
When the working directory is inside a Git repository, setup SHALL initialize OpenSpec and codebase-memory-mcp into the repository root exactly as before, without prompting.

#### Scenario: Setup in a Git repository skips the prompt
- **WHEN** setup runs inside a Git repository
- **THEN** setup resolves the Git top-level directory and initializes both tools there
- **AND** setup does not prompt the user about non-git initialization
