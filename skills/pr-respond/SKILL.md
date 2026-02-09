---
name: pr-respond
description: Entry point for PR review events. Checks for back-off signals, then delegates to pr-fix or pr-merge.
---

# pr-respond

## Trigger

Called by GitHub Actions when a `pull_request_review` event fires.

## Context

You are running in a GitHub Actions VM. The repo is checked out at the PR branch. You have access to `gh` CLI and the full repo including `./plans/`.

## Process

### 0. Configure bot identity

All git and gh commands in this skill must use `git-bot` (located at `bin/git-bot` in the skills repo). Use `git-bot git ...` instead of `git ...` and `git-bot gh ...` instead of `gh ...`.

### 1. Gather context

Use `gh` to get the review details:

- `gh pr view --json number,title,body,headRefName` for PR metadata
- `gh api repos/{owner}/{repo}/pulls/{pr}/reviews` for the review that triggered this run
- Extract the review state (`changes_requested` or `approved`) and the review body

### 2. Check for back-off signals

Read the review body. Use your judgement to determine if the reviewer is signaling that a human will take over. Examples:

- "I'll fix this myself"
- "Human will handle this"
- "No more AI"
- "Too complex for automation"
- Any natural language that clearly means "stop"

If a back-off signal is detected:

1. Append to `./plans/progress.txt`:
   ```
   ## Back-off - {timestamp}
   Reviewer signalled human takeover: "{quote from review}"
   ```
2. Commit and push progress.txt
3. Exit without further action

### 3. Delegate

Based on the review state, read the relevant skill file and follow its instructions.

- **`changes_requested`** → read `../pr-fix/SKILL.md` and follow it
- **`approved`** → read `../pr-merge/SKILL.md` and follow it
