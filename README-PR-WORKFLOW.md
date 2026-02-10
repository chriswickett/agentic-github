# Agentic

Reusable Claude Code skills and GitHub Actions workflows for automated PR lifecycle management.

## Skills

- **plan-work** — creates plans through structured conversation
- **do-work** — executes plans
- **pr-start** — creates branch, executes plan, commits, and opens a PR
- **pr-triage** — classifies PR review intent as STOP or CONTINUE
- **pr-fix** — fixes code based on reviewer feedback
- **pr-merge** — writes clean commit message for squash-merging approved PRs
- **commit** — atomic git commit conventions

## PR Workflow

A system where an AI agent handles the full PR lifecycle. When a reviewer requests changes, the AI reads the feedback, fixes the code, and pushes for re-review. When approved, the AI writes a clean commit message and merges. At any point, a reviewer can tell the AI to back off and it will step away.

## The Players

- **You** (human): Write plans, trigger initial work, review PRs, approve or reject
- **Claude** (local): Runs on your machine. Creates plans, executes work, opens PRs
- **GClaude** (GitHub Actions): Runs in GitHub's cloud on PR events. Triages, fixes, or merges

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
GClaude triages the review
       ↓
Back-off signal detected?
    GClaude comments "stepping back" and stops
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

## Step by Step

### 1. Planning (local, you + Claude)

You run `/plan-work`. Claude asks what you want to build, researches the codebase, asks clarifying questions, then writes a plan to `./plans/something.md`.

### 2. Execution (local, Claude)

You run `/pr-start`. Claude asks which plan to execute, creates a branch, then delegates to do-work to implement the changes. When done, Claude:

- Creates `progress.txt` with initial context (what was implemented)
- Commits with the plan name in the commit body: `plan: something.md`
- Pushes and opens a pull request

(`/do-work` can also be used standalone if you just want to execute a plan without the PR lifecycle.)

### 3. Review (GitHub, human)

A human reviews the PR. The reviewer can either:

- Request changes (with specific feedback)
- Approve
- Tell the AI to stop (e.g. "I'll fix this myself", "no more AI", "@someone can you pick this up")

### 4. pr-triage (GitHub Actions, GClaude)

Any review event triggers the reusable workflow. The first job is triage:

1. Checks out the repo at the PR branch
2. Clones the skills repo
3. Runs `gather-pr-context` to collect PR data, reviews, comments, and commit history into a single `context.txt`
4. Runs Claude with the pr-triage skill to classify intent as STOP or CONTINUE
5. If STOP: comments "Understood — stepping back from this PR." and no further jobs run
6. If CONTINUE: uploads `context.txt` as an artefact for downstream jobs

### 5. pr-fix (GitHub Actions, GClaude)

Runs when `changes_requested` and triage returned CONTINUE:

1. Downloads the context artefact from triage
2. Runs Claude with the pr-fix skill
3. Claude reads the review comments, finds the plan, reads progress.txt
4. Claude fixes all requested changes in one pass
5. Claude updates progress.txt and writes commit message + PR comment to files
6. The workflow commits, pushes, and comments on the PR

The loop returns to the review step.

### 6. pr-merge (GitHub Actions, GClaude)

Runs when `approved` and triage returned CONTINUE:

1. Downloads the context artefact from triage
2. Runs Claude with the pr-merge skill
3. Claude reads progress.txt and commit history, writes a clean commit message
4. The workflow squash-merges the PR with that message

The messy history of fix commits disappears. Main gets one clean commit.

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

## Bot Identity

In GitHub Actions, the workflow sets git identity directly using `AGENTIC_BOT_NAME` and `AGENTIC_BOT_EMAIL` variables, and authenticates with `AGENTIC_BOT_TOKEN`. Claude never runs git or gh commands — the workflow handles all git and GitHub operations.

For local use, `bin/git-bot` is a wrapper script that sets the bot's identity via environment variables. This ensures commits, PRs, and comments are attributed to your machine account, not your personal GitHub account.

### Setting up a GitHub machine account

1. Create a new GitHub account for your bot (e.g. `yourname-bot`)
2. Add the bot account as a collaborator on your repos (with write access)
3. On the bot account, generate a fine-grained Personal Access Token (PAT):
   - Settings → Developer settings → Personal access tokens → Fine-grained tokens
   - Repository access: **All repositories** (covers any repo the bot is added to in the future)
   - Permissions:
     - **Contents**: Read and write (for git push)
     - **Pull requests**: Read and write (for creating/commenting/merging PRs)
     - **Metadata**: Read (auto-selected)
4. Note the bot's noreply email from https://github.com/settings/emails — it looks like `ID+username@users.noreply.github.com`

### Environment variables

`git-bot` requires three env vars:

| Variable | Value |
|---|---|
| `AGENTIC_BOT_NAME` | The bot's GitHub username (e.g. `yourname-bot`) |
| `AGENTIC_BOT_EMAIL` | The bot's noreply email (e.g. `ID+yourname-bot@users.noreply.github.com`) |
| `GH_TOKEN` | The bot's PAT |

**Locally**, set these in your shell profile or a `.env` file:

```bash
export AGENTIC_BOT_NAME="yourname-bot"
export AGENTIC_BOT_EMAIL="123456+yourname-bot@users.noreply.github.com"
export GH_TOKEN="ghp_..."
```

**In GitHub Actions**, add `AGENTIC_BOT_TOKEN` as a repo/org secret, and `AGENTIC_BOT_NAME` / `AGENTIC_BOT_EMAIL` as repo/org variables (Settings → Secrets and variables → Actions).

## Repo Setup

Before using this workflow with a client repo:

1. **Disable auto-merge**: Settings → General → Pull Requests. Make sure "Allow auto-merge" is OFF. GClaude controls when merges happen.

2. **Allow squash merging**: Same section, make sure "Allow squash merging" is ON.

3. **Add the workflow file**: Create `.github/workflows/pr-respond.yml` that calls the reusable workflow:

   ```yaml
   on:
     pull_request_review:
       types: [submitted]

   jobs:
     pr-respond:
       uses: chriswickett/agentic/.github/workflows/pr-respond.yml@main
       secrets:
         ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
         AGENTIC_BOT_TOKEN: ${{ secrets.AGENTIC_BOT_TOKEN }}
   ```

4. **Add secrets**: At repo level (Settings → Secrets and variables → Actions) or org level:
   - `ANTHROPIC_API_KEY`: For Claude CLI
   - `AGENTIC_BOT_TOKEN`: The bot account's PAT

5. **Add variables**: At repo level (Settings → Secrets and variables → Actions → Variables) or org level:
   - `AGENTIC_BOT_NAME`: The bot's GitHub username
   - `AGENTIC_BOT_EMAIL`: The bot's noreply email

6. **Create plans directory**: Create an empty `./plans/` directory.

