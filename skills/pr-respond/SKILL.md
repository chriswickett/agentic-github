---
name: pr-respond
description: Entry point for PR review events. Checks for back-off signals, then delegates to pr-fix or pr-merge.
---

# pr-respond

## Trigger

Called by GitHub Actions when a `pull_request_review` event fires.

## Context

You are running sandboxed in a GitHub Actions VM. The repo is checked out at the PR branch. You only have access to file tools (Read, Edit, Write, Glob, Grep). The workflow provides PR metadata, review details, and review state in your prompt. The workflow handles all git and gh operations after you finish.

## Output

You must return structured JSON. The schema depends on the review state:

**For `changes_requested`:**
```json
{
  "commit_message": "feat: ...",
  "pr_comment": "Fixed the ...",
  "back_off": false
}
```

**For back-off:**
```json
{
  "back_off": true,
  "back_off_reason": "Reviewer said they will fix it themselves"
}
```

When `back_off` is false, `commit_message` and `pr_comment` are required.

## Process

### 1. Check for back-off signals

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
2. Return JSON with `back_off: true` and `back_off_reason` explaining the signal

### 2. Delegate

Based on the review state, read the relevant skill file and follow its instructions.

- **`changes_requested`** → read `../pr-fix/SKILL.md` and follow it
- **`approved`** → read `../pr-merge/SKILL.md` and follow it
