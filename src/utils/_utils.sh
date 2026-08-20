#!/usr/bin/env bash

function util::is_git_project
{
    local target_dir="$1"

    if command -v git >/dev/null 2>&1
    then
        git -C "$target_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1
        return $?
    fi

    return 1
}

function util::command_exists
{
    command -v "$1" >/dev/null 2>&1
}

function util::get_python_exe
{
    if command -v python3 >/dev/null 2>&1 && python3 -c "import json" 2>/dev/null
    then
        echo "python3"
    elif command -v python >/dev/null 2>&1 && python -c "import json" 2>/dev/null
    then
        echo "python"
    fi
}

function util::_read_from_tty
{
    local prompt="$1"
    local var="$2"

    # stdin is a terminal: prompt normally.
    if [[ -t 0 ]]
    then
        printf "%s" "$prompt" >&2
        read -r "$var" || true
        return 0
    fi

    # stdin is piped (e.g. curl | bash) but a controlling terminal exists:
    # reopen /dev/tty so the user still gets prompted.
    # Use explicit printf for prompt — read -p is suppressed when shell's
    # own fd 0 is a pipe, even with < /dev/tty redirect.
    if (exec 0< /dev/tty) 2>/dev/null
    then
        printf "%s" "$prompt" >&2
        read -r "$var" < /dev/tty || true
        return 0
    fi

    # Truly headless (no TTY at all): nothing to prompt against.
    return 1
}

function util::prompt_enter
{
    local prompt="${1:-Press Enter to continue...}"
    local _unused
    util::_read_from_tty "$prompt" _unused || true
}

function util::prompt_yes_no
{
    local prompt="$1"
    local default="${2:-yes}"

    local suffix
    if [[ "$default" == "yes" ]]
    then
        suffix="[Y/n]"
    else
        suffix="[y/N]"
    fi

    local answer
    if ! util::_read_from_tty "$prompt $suffix " answer
    then
        # No TTY available; fall back to the default answer.
        [[ "$default" == "yes" ]]
        return $?
    fi

    case "${answer,,}" in
        y|yes) return 0 ;;
        n|no) return 1 ;;
        *) [[ "$default" == "yes" ]] ;;
    esac
}