---
name: pr-merge
description: Writes a clean commit message and squash-merges an approved PR. Called by pr-respond when a PR is approved.
---

# pr-merge

## Context

You are called by pr-respond. The PR metadata and repo are already available in context.

## Process

### 0. Configure bot identity

All git and gh commands in this skill must use `git-bot` (located at `bin/git-bot` in the skills repo). Use `git-bot git ...` instead of `git ...` and `git-bot gh ...` instead of `gh ...`.

### 1. Gather context

Read `./plans/progress.txt` and all commit messages on this branch to understand the full journey - initial implementation and any rejection cycles.

### 2. Write the commit message

Write a clean commit message describing what was built. Follow the atomic commit principles in `../../commit/SKILL.md`.

The message should read as if the work was done right the first time. No mention of rejections, fix cycles, or iterations. Just the final result.

The first line of the commit body (after the subject line and blank line) must be `plan: {plan-filename.md}`.

### 3. Squash-merge

Merge the PR using:

```
gh pr merge --squash -m "{the clean message}"
```

The messy history of fix commits disappears. Main gets one clean commit.
