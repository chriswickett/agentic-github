---
name: pr-start
description: Executes a plan and opens a PR. Creates a branch, follows do-work to implement, creates progress.txt, commits, and opens a pull request.
---

# pr-start

## Trigger

`/pr-start`

## Process

### 1. Find the plan

Ask: "Which plan should I execute?"

If there's a `./plans/` directory, list available `.md` files for the user to choose from.

Wait for the user's response, unless they already specified a plan.

### 2. Configure bot identity

All git and gh commands in this skill must use `git-bot` (located at `bin/git-bot` in the skills repo). Use `git-bot git ...` instead of `git ...` and `git-bot gh ...` instead of `gh ...`.

### 3. Create a branch

Create a branch named after the plan file, e.g. `plans/add-signup-button` for `add-signup-button.md`.

### 4. Execute the plan

Read `../do-work/SKILL.md` (from the skills repo) and follow its instructions to execute the chosen plan.

### 5. Create progress.txt

Create `./plans/progress.txt` with:

```
## Initial Implementation - {timestamp}
Plan: {plan-filename.md}
Summary: {brief description of what was implemented}
```

### 6. Commit

Read `../commit/SKILL.md` and follow its process for committing. Ignore any steps that require user input - you are making decisions autonomously here. The first line of the commit body (after the subject line and blank line) must be `plan: {plan-filename.md}`.

### 7. Push and open PR

Push the branch and open a PR using `gh pr create`. The PR title should be a concise summary of the plan. The PR body should briefly describe what was implemented.
