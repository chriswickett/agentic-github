---
name: pr-merge
description: Writes a clean squash-merge commit message for an approved PR. Called by the pr-merge job in GitHub Actions.
---

# pr-merge

## Trigger

Called by the pr-merge job in GitHub Actions after pr-triage has returned CONTINUE.

## Context

You are running in a GitHub Actions VM. The repo is checked out at the PR branch. You have access to Read and Write tools only. Do not attempt to use Bash, git, or gh. The workflow handles the actual merge after you finish.

PR metadata, review comments, and commit history are provided in your prompt.

## Process

### 1. Gather context

Read `./plans/progress.txt` and review the commit history (provided in your prompt) to understand the full journey — initial implementation and any rejection cycles.

### 2. Find the plan

Parse the commit history for `plan: {filename.md}` in a commit body. Read that plan from `./plans/`.

### 3. Write the commit message

Write a clean commit message describing what was built. Follow the conventions in the commit skill at `../commit/SKILL.md`.

The message should read as if the work was done right the first time. No mention of rejections, fix cycles, or iterations. Just the final result.

The first line of the commit body (after the subject and blank line) must be `plan: {plan-filename.md}`.

## Output

Write this file:

- `/tmp/commit_msg.txt` — the clean squash-merge commit message.

The workflow will squash-merge the PR using this message.
