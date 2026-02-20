# Agentic

Reusable Claude Code skills and GitHub Actions composite actions for automated PR lifecycle management.

## ⚠️ Security

- Claude runs with `--dangerously-skip-permissions`, meaning it can execute any tool without approval
- All GitHub Actions secrets and variables are injected as environment variables, so Claude has access to every secret and variable configured on the repo
- The bot account's PAT is currently a classic token, which grants access to all repos the account can access

Make sure you are comfortable with all three of these before using.

## Skills

- **plan-work** — creates GitHub issues through structured conversation
- **do-work** — implements work from a GitHub issue
- **pr-start** — implements a GitHub issue in CI, writes output files for the workflow to commit and open a PR
- **pr-start-local** — implements a GitHub issue locally, creates branch, commits, and opens a PR
- **pr-fix** — fixes code based on reviewer feedback
- **gh-respond** — answers questions and responds to PR or issue comments
- **pr-merge** — writes clean commit message for squash-merging approved PRs
- **commit** — atomic git commit conventions

## PR Workflow

A system where an AI agent handles the full PR lifecycle. All interactions require addressing the bot with `@claude` at the start of a review or comment. When a reviewer requests changes, the AI reads the feedback, fixes the code, and pushes for re-review. When approved, the AI writes a clean commit message and merges.

## The Players

- **You** (human): Create issues, trigger work, review PRs, approve or reject
- **Claude** (local): Runs on your machine. Helps plan issues, executes work, opens PRs
- **GClaude** (GitHub Actions): Runs in GitHub's cloud on issue and PR events. Implements, fixes, responds, or merges

## The Loop

```
You create a GitHub issue (or /plan-work helps you)
       ↓
@claude /pr-start on the issue (or /pr-start-local)
       ↓
Claude implements and opens a PR (Closes #issue)
       ↓
You review the PR
       ↓
@claude + request changes?
       ↓
GClaude fixes, writes commit msg + PR comment
       ↓
Workflow commits, pushes, and posts comment
       ↓
Back to review
```

## Step by Step

### 1. Planning (local, you + Claude)

You run `/plan-work`. Claude asks what you want to build, researches the codebase, asks clarifying questions, then creates a GitHub issue with the plan.

### 2. Execution (GitHub Actions or local)

Comment `@claude /pr-start` on the issue. GClaude implements the plan, commits with `issue: #N` in the body, and opens a PR with `Closes #N`.

Alternatively, run `/pr-start-local` to do this on your machine.

(`/do-work` can also be used standalone if you just want to implement an issue without the PR lifecycle.)

### 3. Review (GitHub, human)

A human reviews the PR. To trigger the bot, start a review or comment with `@claude`. Without `@claude`, nothing happens — the bot only responds when addressed directly.

### 4. pr-fix (GitHub Actions, GClaude)

Runs when a review with `changes_requested` starts with `@claude`:

1. Checks out the repo at the PR branch
2. Runs `gather-pr-context` to collect PR data, reviews, comments, commit history, and the linked issue into `context.txt`
3. Runs Claude with the pr-fix skill
4. Claude reads the review comments, finds the linked issue for original context
5. Claude fixes all requested changes in one pass
6. Claude writes commit message + PR comment to files
7. The workflow commits, pushes, and posts the comment

The loop returns to the review step.

### 5. gh-respond (GitHub Actions, GClaude)

Runs when a PR or issue comment starts with `@claude`:

1. Checks out the repo (PR branch for PRs, main for issues)
2. Gathers context (PR context or issue context depending on source)
3. Runs Claude with the gh-respond skill
4. Claude reads the comment, explores the codebase as needed, and writes a response
5. The workflow posts the response as a comment

### 6. pr-merge (GitHub Actions, GClaude)

Runs when a review with `approved` starts with `@claude`:

1. Checks out the repo at the PR branch
2. Runs `gather-pr-context` to collect PR data, reviews, comments, commit history, and the linked issue into `context.txt`
3. Runs Claude with the pr-merge skill
4. Claude reads the commit history and linked issue, writes a clean commit message
5. The workflow squash-merges the PR with that message

The messy history of fix commits disappears. Main gets one clean commit.

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

## Composite Actions

This repo provides a reusable workflow and a set of composite actions.

### Reusable Workflow

**`agentic.yml`** — A single reusable workflow that handles all four event types (issue comments, new issues, PR reviews with changes requested, PR reviews with approval). It routes to the correct composite action based on the event payload.

### High-level Actions

Called by the reusable workflow. Each one calls `run-skill` then handles the post-skill steps (commit, comment, merge, etc.):

- **pr-fix** — Fixes code based on reviewer feedback, commits, pushes, and posts a comment
- **pr-start** — Implements an issue, commits to a new branch, and opens a PR
- **pr-merge** — Writes a clean commit message and squash merges
- **gh-respond** — Responds to issue or PR comments

### Core Action

- **run-skill** — The shared core. Injects env vars, determines the correct checkout ref, checks out the repo, sets up Claude CLI + Chrome DevTools + mkcert, gathers context, and runs Claude with the specified skill.

### Building Block Actions

- **inject-env** — Injects all secrets and vars into `GITHUB_ENV`
- **git-commit-push** — Commits and pushes changes, optionally creating a new branch
- **post-comment** — Posts a comment to an issue or PR
- **create-pr** — Creates a PR with optional issue linking
- **squash-merge** — Squash merges a PR with custom commit message

## Repo Setup

Before using these workflows with a client repo:

1. **Disable auto-merge**: Settings → General → Pull Requests. Make sure "Allow auto-merge" is OFF. GClaude controls when merges happen.

2. **Allow squash merging**: Same section, make sure "Allow squash merging" is ON.

3. **Add a workflow file**: Create a single file at `.github/workflows/agentic.yml`:

   ```yaml
   on:
     issue_comment:
       types: [created]
     issues:
       types: [opened]
     pull_request_review:
       types: [submitted]

   jobs:
     agentic:
       uses: chriswickett/agentic/.github/workflows/agentic.yml@main
       secrets: inherit
   ```

   All routing, filtering, checkout, setup, and env var handling is done by the reusable workflow. Secrets are passed through via `secrets: inherit`. Variables from the `vars` context are available automatically. Any secrets or variables you add in the GitHub UI are injected as env vars at runtime.

4. **Add secrets**: At repo level (Settings → Secrets and variables → Actions) or org level:
   - `CLAUDE_CODE_OAUTH_TOKEN`: OAuth token from `claude setup-token` (uses your Claude Pro/Max subscription)
   - `AGENTIC_BOT_TOKEN`: The bot account's PAT
   - Any app-specific secrets are automatically injected as env vars

5. **Add variables**: At repo level (Settings → Secrets and variables → Actions → Variables) or org level:
   - `AGENTIC_BOT_NAME`: The bot's GitHub username
   - `AGENTIC_BOT_EMAIL`: The bot's noreply email
   - Any app-specific variables are automatically injected as env vars

