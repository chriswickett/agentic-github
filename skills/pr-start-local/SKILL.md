---
name: pr-start-local
description: Implements a GitHub issue and opens a PR locally. Creates a branch, follows do-work to implement, commits, and opens a pull request linked to the issue.
---

# pr-start-local

## Trigger

`/pr-start-local`

## Process

### 1. Find the issue

Ask: "Which issue should I work on?"

The user should provide a GitHub issue number or URL. If they give a number, use `gh issue view <number>` to fetch it.

Wait for the user's response, unless they already specified an issue.

### 2. Configure bot identity

All git and gh commands in this skill must use `git-bot` (located at `bin/git-bot` in the skills repo). Use `git-bot git ...` instead of `git ...` and `git-bot gh ...` instead of `gh ...`.

### 3. Create a branch

Create a branch named `feat/concise-spinal-case` (or `fix/...`, `refactor/...`, etc.) derived from the issue title.

### 4. Execute the plan

Read `../do-work/SKILL.md` (from the skills repo) and follow its instructions to execute the issue.

### 5. Commit

Read `../commit/SKILL.md` and follow its process for committing. Ignore any steps that require user input — you are making decisions autonomously here. The first line of the commit body (after the subject line and blank line) must be `issue: #<issue-number>`.

### 6. Push and open PR

Push the branch and open a PR using `gh pr create`. The PR title should be a concise summary. The PR body should briefly describe what was implemented and include `Closes #<issue-number>` to link the issue.
