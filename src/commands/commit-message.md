---
description: Generate Conventional Commit Message
---

# Task

Generate a Conventional Commit message from the staged Git changes.

You must:

1. Analyze only staged changes.
2. Generate exactly one Conventional Commit message.
3. Validate the generated commit message using the repository's commit validation script.
4. Provide the exact `git commit` command for the user.

You must never:

- execute `git commit`
- execute `git push`
- modify repository files
- inspect unstaged changes as a substitute for staged changes

---

# Execution Workflow

Follow these steps in order.

## Step 1: Verify staged changes

Run:

```bash
git diff --cached
```

If no staged changes exist:

STOP.

Tell the user:

- no staged changes were found
- they should stage changes first (example: `git add .`)

Do not continue.

---

## Step 2: Determine issue number

Run:

```bash
git branch --show-current
```

Extract the issue number from the branch name.

Recognize common formats:

- `123-description`
- `issue-123-description`
- `feature/123-description`
- `fix/123-description`
- `#123`

The issue number is mandatory.

If an issue number cannot be found:

STOP.

Ask the user for the issue number.

Never:

- guess an issue number
- invent an issue number
- omit the issue footer

---

## Step 3: Analyze the change

Determine:

1. Commit type
2. Scope
3. Summary
4. Body
5. Footer

### Commit Type

Choose exactly one:

- build
- chore
- ci
- dep
- docs
- feat
- fix
- perf
- refactor
- revert
- style
- test

Select the type that best represents the primary purpose of the change.

When multiple types appear applicable, choose the type representing the
primary externally observable outcome rather than the implementation
mechanics.

Examples:

- New feature + tests → feat
- Bug fix + docs → fix
- Refactor + tests → refactor
- Documentation only → docs
- Formatting only → style
- Dependency updates only → dep

---

### Scope

Include a scope only when the changes belong to one clear, high-level
component.

Rules:

- lowercase
- kebab-case
- omit for global or cross-cutting changes
- never invent a scope merely because a directory exists

Examples:

- parser
- installer
- pipeline
- docs
- api-client

---

### Summary

Requirements:

- imperative mood
- present tense
- starts with a lowercase letter
- no trailing period
- describes the primary change
- maximum 72 characters

---

### Body

The body is required.

Focus on explaining:

- why the change exists
- what changed
- notable implementation decisions
- impact on users or developers

Avoid simply restating the summary or describing obvious code edits that
are already visible in the diff.

Wrap lines at 72 characters.

---

### Footer

The footer is required.

The footer must contain:

```
<GitLab keyword> #<issue>
```

Choose the keyword based on commit type:

- fix → Fixes
- feat → Implements
- all others → Closes

Examples:

```
Fixes #123
```

```
Implements #456
```

```
Closes #789
```

---

## Step 4: Validate the commit message

Validate the generated commit message by executing the commit
validation script located at:

<VALIDATE_COMMIT_SCRIPT>

Pass the complete generated commit message to the script via standard input.

Expected invocation pattern:

printf '%s\n' "<complete commit message>" | <VALIDATE_COMMIT_SCRIPT>

Treat the validator as the source of truth.

If validation succeeds:

Continue.

If validation fails:

- use the validator's error message to determine what must be corrected
- revise the commit message
- run the validator again

Repeat until validation succeeds.

Never ignore validator errors.

Do not return an invalid commit message.

---

## Step 5: Quality Gate

Before responding, ask:

> Would this commit make sense six months from now when viewed in
> `git log` without any additional context?

If not:

Improve the summary and body.

Then run the validation script again before continuing.

---

# Output Format

Return only:

## 1. Commit message

Inside a fenced code block:

With scope:

```text
<type>(<scope>): <summary>

<body>

<footer>
```

Without scope:

```text
<type>: <summary>

<body>

<footer>
```

## 2. Git command

Provide the exact command:

```bash
git commit -m "<subject>" -m "<body>" -m "<footer>"
```

Use multiple `-m` flags for shell compatibility.

Do not execute the command.

Return no explanation, analysis, or additional commentary outside the
required commit message and git command.