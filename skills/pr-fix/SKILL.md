---
name: pr-fix
description: Fixes code based on PR review feedback. Called by pr-respond when changes are requested.
---

# pr-fix

## Context

You are called by pr-respond. The review comments, PR metadata, and repo are already available in context. You are sandboxed to file tools only (Read, Edit, Write, Glob, Grep). Do not attempt to use Bash, git, or gh.

## Output

Return structured JSON via pr-respond's schema:

```json
{
  "commit_message": "fix: Address review feedback\n\nplan: {plan-filename.md}",
  "pr_comment": "Fixed the requested changes: ...",
  "back_off": false
}
```

The first line of the commit message body (after the subject line and blank line) must be `plan: {plan-filename.md}`. Follow the atomic commit conventions from `../../commit/SKILL.md` for the message format.

## Process

### 1. Understand the feedback

Read the review comments - both the summary and any line-by-line comments. Understand what the reviewer is asking for.

### 2. Find the plan

Parse the commit history (provided in context) for `plan: {filename.md}` in a commit body. Read that plan from `./plans/`.

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

### 6. Return JSON

Set `commit_message` to a clean commit message describing the fix. Set `pr_comment` to a concise paragraph explaining what you fixed. Set `back_off` to `false`. The workflow handles committing, pushing, and commenting.
