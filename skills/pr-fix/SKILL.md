---
name: pr-fix
description: Fixes code based on PR review feedback. Called by the pr-fix job in GitHub Actions.
---

# pr-fix

## Trigger

Called by the pr-fix job in GitHub Actions after pr-triage has returned CONTINUE.

## Context

You are running in a GitHub Actions VM. The repo is checked out at the PR branch. You have access to file tools only (Read, Edit, Write, Glob, Grep). Do not attempt to use Bash, git, or gh. The workflow handles all git and GitHub operations after you finish.

PR metadata, review comments, and commit history are provided in your prompt.

## Process

### 1. Understand the feedback

Read the review comments — both the summary and any line-by-line comments. Understand what the reviewer is asking for.

### 2. Find the plan

Parse the commit history (provided in context) for `plan: {filename.md}` in a commit body. Read that plan from `./plans/`.

### 3. Read progress.txt

Read `./plans/progress.txt` to see what's been tried before. Understand what was already attempted so you don't repeat failed approaches.

### 4. Fix

Address all requested changes in one pass, unless the reviewer explicitly asks for smaller commits.

### 5. Update progress.txt

Append to `./plans/progress.txt`:

```
## Rejection {n} - {timestamp}
Review feedback: "{summary of what was requested}"
Action taken: {what you did to fix it}
```

### 6. Output

Write these files:

- `/tmp/commit_msg.txt` — a single commit message for all your changes. Follow the conventions in the commit skill at `../commit/SKILL.md`. The first line of the commit body (after the subject and blank line) must be `plan: {plan-filename.md}`.
- `/tmp/pr_comment.txt` — a concise paragraph explaining what you fixed, for the PR comment thread.

The workflow will commit, push, and comment using these files.
