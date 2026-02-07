# Automated PR Workflow

## Overview

A system where an AI agent handles the full PR lifecycle. When a reviewer requests changes, the AI reads the feedback, fixes the code, and pushes for re-review. When approved, the AI writes a clean commit message and merges.

## The Players

- **You** (human): Write plans, trigger initial work, review PRs, approve or reject
- **Claude** (local): Runs on your machine. Creates plans, executes work, opens PRs
- **GClaude** (GitHub Actions): Runs in GitHub's cloud on PR events. Fixes rejected PRs, merges approved ones

## The Loop

```
You write a plan
       ↓
Claude executes it locally
       ↓
Claude commits and opens a PR
       ↓
You (or a reviewer) review the PR
       ↓
Changes requested?
    GClaude fixes the code
    GClaude commits and pushes
    Back to review
       ↓
Approved?
    GClaude writes clean commit message
    GClaude squash-merges the PR
       ↓
Done
```

## File Structure

### Your Personal Skills Repo (private, on GitHub)

This repo contains reusable skills and the workflow that client repos call.

```
skills-repo/
├── skills/
│   ├── plan-work/
│   │   └── SKILL.md        # Creates plans through conversation
│   ├── do-work/
│   │   └── SKILL.md        # Executes plans
│   ├── pr-respond/
│   │   └── SKILL.md        # Entry point for PR events, decides fix or merge
│   ├── pr-fix/
│   │   └── SKILL.md        # Fixes rejected PRs
│   └── pr-merge/
│       └── SKILL.md        # Writes clean commit and merges approved PRs
└── .github/
    └── workflows/
        └── pr-respond.yml  # The reusable workflow
```

### Each Client Repo

```
client-repo/
├── .github/
│   └── workflows/
│       └── pr-respond.yml  # Tiny file that calls the reusable workflow
└── plans/
    ├── feature-name.md     # Plans created by plan-work
    └── progress.txt        # Tracks what GClaude has tried across rejection cycles
```

## Step by Step

### 1. Planning (local, you + Claude)

You run `/plan-work`. Claude asks what you want to build, researches the codebase, asks clarifying questions, then writes a plan to `./plans/something.md`.

### 2. Execution (local, Claude)

You run `/do-work`. Claude asks which plan to execute, reads it, creates a task list, implements the changes. When done (and if you invoke the PR mode), Claude:

- Creates `progress.txt` with initial context (what was implemented)
- Commits with the plan name in the commit body: `plan: something.md`
- Opens a pull request

### 3. Review (GitHub, human)

A human reviews the PR. The user can either

- Request changes
- Approve
- Tell AI to stop with a comment (eg, "I'll fix this myself", "no more AI", etc).

### 4. pr-respond (GitHub Actions, GClaude)

Any review event triggers a workflow that:

1. Checks out the repo at the PR branch
2. Clones your private skills repo
3. Installs Claude CLI
4. Runs Claude with pr-respond

pr-respond checks for back-off signals first. If a comment such as "I'll fix this myself" is found, it logs to progress.txt and exits. Otherwise, delegates based on review state:

- **Changes requested** → step 5 (pr-fix)
- **Approved** → step 6 (pr-merge)

### 5. pr-fix

1. Reads the review comments (summary and line-by-line)
2. Reads progress.txt to see what's been tried before
3. Finds the plan by parsing the commit body for `plan: filename.md`
4. Reads the plan from `./plans/`
5. Fixes all requested changes in one pass (unless instructed to break into smaller commits)
6. Updates progress.txt with what it did
7. Creates a new commit and pushes
8. Comments on the PR with a concise paragraph of what it did

(We then return to the review step, and the loop begins again.)

### 6. pr-merge

1. Reads progress.txt and all the commit messages to understand the full journey
2. Writes a clean commit message describing what was built - as if done right the first time, no mention of rejections
3. Squash-merges the PR using `gh pr merge --squash`

The messy history of fix commits disappears. Main gets one clean commit

## progress.txt

A simple log in plans/progress.txt that persists across rejection cycles. Claude (local) creates it when first committing, with initial context about what was implemented. GClaude reads it at the start of each cycle to understand history, appends what it tried before committing.

Example:

```
## Initial Implementation - 2024-02-06T09:00:00Z
Plan: add-signup-button.md
Summary: Added signup button to header with click handler that navigates to /signup

## Rejection 1 - 2024-02-06T10:30:00Z
Review feedback: "Button color should be blue, not red"
Action taken: Changed button color from red to blue

## Rejection 2 - 2024-02-06T14:15:00Z
Review feedback: "Actually make it match the brand color variable"
Action taken: Updated button to use var(--brand-primary) instead of hardcoded blue
```

## UI Testing (Conditional)

For frontend work, GClaude can spin up a dev server and use Chrome DevTools to:

- Take screenshots
- Check console for errors
- Verify the UI matches expectations

This only happens when the plan involves UI work. The GitHub Actions runner has Chrome pre-installed. GClaude starts it in headless mode and connects via the Chrome DevTools MCP.

## Repo Setup

Before using this workflow with a client repo:

1. **Disable auto-merge**: Settings → General → Pull Requests. Make sure "Allow auto-merge" is OFF. GClaude controls when merges happen.

2. **Allow squash merging**: Same section, make sure "Allow squash merging" is ON.

3. **Add the workflow file**: Copy the tiny workflow YAML to `.github/workflows/pr-respond.yml`.

4. **Add secrets**: At repo level (Settings → Secrets and variables → Actions) or org level:
   - `ANTHROPIC_API_KEY`: For Claude CLI
   - `SKILLS_REPO_PAT`: Personal access token to clone your private skills repo

5. **Create plans directory**: Create an empty `./plans/` directory.

## The Reusable Workflow

Lives in your skills repo. Client repos call it with a tiny file:

```yaml
# .github/workflows/pr-respond.yml (in client repo)
on:
  pull_request_review:
    types: [submitted]

jobs:
  pr-respond:
    uses: your-username/skills-repo/.github/workflows/pr-respond.yml@main
    secrets: inherit
```


