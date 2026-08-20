#!/usr/bin/env bash

# OpenCode Setup Script
# This script pulls the latest skills/commands from third party
#
# Requirements:
#  • Git, curl, and a bash-compatible shell

# ---

# This line is often referred to as the "Bash Unofficial Strict Mode"
#
# -e (errexit): Tells the script to exit immediately if a command exits with a non-zero status
#               (indicates an error). Without this, Bash keeps running the next line even if the
#               previous command failed.
# -i (nounset): Causes the script to exit if you try to use a variable that hasn't been defined.
#               This prevents disasters like "rm -rf /$DIR" if $DIR happens to be empty.
# -o pipefail: Ensures that if any command in a pipeline fails (e.g., step1 | step2 | step3), the whole
#              pipeline returns a failure code. Normally, Bash only cares if the last command in the pipe worked.
set -euo pipefail

# Requires Bash 4.2+ for associative arrays and global declarations.
if (( BASH_VERSINFO[0] < 4 )) || { (( BASH_VERSINFO[0] == 4 )) && (( BASH_VERSINFO[1] < 2 )); }
then
    echo "Error: Requires Bash 4.2 or higher." >&2
    echo "Current version: $BASH_VERSION" >&2
    exit 1
fi

# Phase 1: Resolve project root
SCRIPT_SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." 2>/dev/null && pwd)" || true

if [[ -f "$SCRIPT_SRC/src/utils/_logger.sh" ]]
then
    ROOT_DIR="$SCRIPT_SRC"
else
    echo "Not running locally. Clone the repo and run locally."
    exit 1
fi

# Load helpers
source "$ROOT_DIR/src/utils/_logger.sh"


# ----------------------------------

function _update_grill_me_command
{
    log::info "Updating /grill-me command"
    mkdir -p "$ROOT_DIR/src/commands/"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/productivity/grill-me/SKILL.md" > "$ROOT_DIR/src/commands/grill-me.md"
    log::success "/grill-me updated"
    log::newline
}

function _update_handoff_command
{
    log::info "Updating /handoff command"
    mkdir -p "$ROOT_DIR/src/commands/"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/productivity/handoff/SKILL.md" > "$ROOT_DIR/src/commands/handoff.md"
    log::success "/handoff updated"
    log::newline
}

function _update_diagnosing_bugs_skill
{
    log::info "Updating diagnosing-bugs skill"
    mkdir -p "$ROOT_DIR/src/skills/diagnosing-bugs/scripts"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/diagnosing-bugs/SKILL.md" > "$ROOT_DIR/src/skills/diagnosing-bugs/SKILL.md"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/diagnosing-bugs/scripts/hitl-loop.template.sh" > "$ROOT_DIR/src/skills/diagnosing-bugs/scripts/hitl-loop.template.sh"
    log::success "diagnosing-bugs updated"
    log::newline
}

function _update_codebase_design_skill
{
    log::info "Updating codebase-design skill"
    mkdir -p "$ROOT_DIR/src/skills/codebase-design"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/codebase-design/SKILL.md" > "$ROOT_DIR/src/skills/codebase-design/SKILL.md"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/codebase-design/DEEPENING.md" > "$ROOT_DIR/src/skills/codebase-design/DEEPENING.md"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/codebase-design/DESIGN-IT-TWICE.md" > "$ROOT_DIR/src/skills/codebase-design/DESIGN-IT-TWICE.md"
    log::success "codebase-design updated"
    log::newline
}

function _update_domain_modeling_skill
{
    log::info "Updating domain-modeling skill"
    mkdir -p "$ROOT_DIR/src/skills/domain-modeling"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/domain-modeling/SKILL.md" > "$ROOT_DIR/src/skills/domain-modeling/SKILL.md"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/domain-modeling/ADR-FORMAT.md" > "$ROOT_DIR/src/skills/domain-modeling/ADR-FORMAT.md"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/domain-modeling/CONTEXT-FORMAT.md" > "$ROOT_DIR/src/skills/domain-modeling/CONTEXT-FORMAT.md"
    log::success "domain-modeling updated"
    log::newline
}

function _update_improve_codebase_architecture_skill
{
    log::info "Updating improve-codebase-architecture skill"
    mkdir -p "$ROOT_DIR/src/skills/improve-codebase-architecture"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/improve-codebase-architecture/SKILL.md" > "$ROOT_DIR/src/skills/improve-codebase-architecture/SKILL.md"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/engineering/improve-codebase-architecture/HTML-REPORT.md" > "$ROOT_DIR/src/skills/improve-codebase-architecture/HTML-REPORT.md"
    log::success "improve-codebase-architecture updated"
    log::newline
}

function _update_grilling_skill
{
    log::info "Updating grilling skill"
    mkdir -p "$ROOT_DIR/src/skills/grilling"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/productivity/grilling/SKILL.md" > "$ROOT_DIR/src/skills/grilling/SKILL.md"
    log::success "grilling updated"
    log::newline
}

function _update_using_git_worktrees_skill
{
    log::info "Updating using-git-worktrees skill"
    mkdir -p "$ROOT_DIR/src/skills/using-git-worktrees"
    curl -fsSL -# "https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/using-git-worktrees/SKILL.md" > "$ROOT_DIR/src/skills/using-git-worktrees/SKILL.md"
    log::success "using-git-worktrees updated"
    log::newline
}

function _update_verification_before_completion_skill
{
    log::info "Updating verification-before-completion skill"
    mkdir -p "$ROOT_DIR/src/skills/verification-before-completion"
    curl -fsSL -# "https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/skills/verification-before-completion/SKILL.md" > "$ROOT_DIR/src/skills/verification-before-completion/SKILL.md"
    log::success "verification-before-completion updated"
    log::newline
}

function _update_writing_for_agents_skill
{
    log::info "Updating writing-for-agents skill"
    mkdir -p "$ROOT_DIR/src/skills/writing-for-agents"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/productivity/writing-for-agents/SKILL.md" > "$ROOT_DIR/src/skills/writing-for-agents/SKILL.md"
    curl -fsSL -# "https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/productivity/writing-for-agents/SKILL-MECHANICS.md" > "$ROOT_DIR/src/skills/writing-for-agents/SKILL-MECHANICS.md"
    log::success "writing-for-agents updated"
    log::newline
}


# ----------------------------------


_update_grill_me_command
_update_handoff_command

_update_diagnosing_bugs_skill
_update_codebase_design_skill
_update_domain_modeling_skill
_update_improve_codebase_architecture_skill
_update_grilling_skill
_update_using_git_worktrees_skill
_update_verification_before_completion_skill
_update_writing_for_agents_skill
