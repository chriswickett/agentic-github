---
name: pr-fix
description: Fixes code based on PR review feedback. Called by pr-respond when changes are requested.
---

# pr-fix

## Context

You are called by pr-respond. The review comments, PR metadata, and repo are already available in context.

## Process

### 1. Understand the feedback

Read the review comments - both the summary and any line-by-line comments. Understand what the reviewer is asking for.

### 2. Find the plan

Parse the commit history for `plan: {filename.md}` in a commit body. Read that plan from `./plans/`.

### 3. Read progress.txt

Read `./plans/progress.txt` to see what's been tried before. Understand what was already attempted so you don't repeat failed approaches.

### 4. Fix

Read `../../do-work/SKILL.md` and follow its principles for executing work. Address all requested changes in one pass, unless the reviewer explicitly asks for smaller commits.

### 5. Update progress.txt

Append to `./plans/progress.txt`:

```
## Rejection {n} - {timestamp}
Review feedback: "{summary of what was requested}"
Action taken: {what you did to fix it}
```

### 6. Commit and push

Read `../../commit/SKILL.md` and follow its process for committing. Ignore any steps that require user input. The first line of the commit body (after the subject line and blank line) must be `plan: {plan-filename.md}`.

Push the commit.

### 7. Comment on the PR

Use `gh pr comment` to post a concise paragraph on the PR explaining what you fixed. Keep it short - the reviewer can look at the diff for details.
