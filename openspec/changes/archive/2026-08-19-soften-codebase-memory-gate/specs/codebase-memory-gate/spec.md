## ADDED Requirements

### Requirement: Search is never blocked
When the codebase-memory graph is active, the plugin SHALL NOT block, deny, or error on any search tool invocation. Native `grep`, native `glob`, and shell search commands SHALL always execute normally.

#### Scenario: Native grep executes when graph is active
- **WHEN** the agent invokes the native `grep` tool while the graph is active
- **THEN** the search runs and returns its normal results without any error

#### Scenario: Shell search executes when graph is active
- **WHEN** the agent runs a shell search command (e.g. `rg foo`, `find . -name "*.go"`, `git grep bar`) while the graph is active
- **THEN** the command executes normally and its output is returned without any error

### Requirement: Reminder annotates search output
For detected searches, the plugin SHALL prepend a short reminder line to the tool output telling the agent that graph tools (e.g. `search_graph`, `trace_path`) may be faster, while explicitly noting the search result is valid and execution continues.

#### Scenario: Reminder prepended to bash search output
- **WHEN** a shell search command completes while the graph is active
- **THEN** the returned output begins with a `[codebase-memory]` reminder line referencing graph tools
- **AND** the original command output follows the reminder unchanged

#### Scenario: Reminder prepended to native grep/glob output
- **WHEN** the native `grep` or `glob` tool completes while the graph is active
- **THEN** the returned output includes a `[codebase-memory]` reminder line
- **AND** the original search results remain present and usable

### Requirement: Nudge is throttled per session
The plugin SHALL track detected searches per session and only emit the reminder on the first 2 searches, then on every 10th search after that (2nd, 12th, 22nd, ...). The counter SHALL be scoped to a session and reset when the session ends.

#### Scenario: First two searches are nudged
- **WHEN** the agent performs the 1st and 2nd detected searches in a session
- **THEN** both outputs carry the reminder

#### Scenario: Throttle suppresses reminders between nudges
- **WHEN** the agent performs searches 3 through 11 in the same session
- **THEN** searches 3-11 produce no reminder

#### Scenario: Reminder resumes every tenth search
- **WHEN** the agent performs the 12th detected search in the same session
- **THEN** its output carries the reminder again

### Requirement: Override flag removed
The plugin SHALL NOT recognize any `--skip-graph` override flag. Search commands run normally and are never rewritten or conditionally handled based on such a flag.

#### Scenario: Override flag has no effect
- **WHEN** the agent runs a shell search command containing `--skip-graph`
- **THEN** the command executes normally without special handling, and the flag is passed through to the underlying command as-is

### Requirement: Plugin arms only on marker
The reminder SHALL only be active when the `codebase-memory-mcp` binary is in PATH and the workspace `AGENTS.md` contains the codebase-memory graph marker. Otherwise the plugin SHALL be inert.

#### Scenario: Marker absent disables plugin
- **WHEN** a project's AGENTS.md lacks the graph marker
- **THEN** searches produce no reminder and the plugin has no effect

#### Scenario: Binary missing disables plugin
- **WHEN** the `codebase-memory-mcp` binary is not in PATH
- **THEN** the plugin logs a warning and produces no reminders
