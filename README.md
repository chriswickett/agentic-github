# Agentic

**Ship features by talking to GitHub.**

Run Claude Code on GitHub, not just your laptop. Work on multiple features at the same time. Every change goes through a pull request, so the whole team can see and review what the AI builds. Comment `@claude` on an issue — it writes the code, opens a PR, fixes review feedback, and merges. Everything tracked in git.

## Repo Setup

Run the install script to set up a client repo:

```bash
bin/install
```

This interactively:
1. Checks prerequisites (bot account + PAT, Claude OAuth token)
2. Creates or connects to a repo
3. Configures repo settings (squash merge, delete branch on merge, no auto-merge)
4. Copies 4 thin workflow files from `templates/workflows/` into the client repo's `.github/workflows/`
5. Optionally sets secrets and variables
6. Adds the bot as a collaborator
7. Creates a CLAUDE.md template
8. Commits and pushes

For non-interactive use (CI or re-runs), pass `--repo` and `--path` to skip the prompts:

```bash
bin/install --repo acme/my-app --path ./my-app
```

The workflow files are thin callers that reference this repo's composite actions via `uses:`. When the agentic repo's actions are updated, all client repos pick up the changes automatically on the next workflow run.

### Workflow templates

The templates live in `templates/workflows/` and use a `__AGENTIC_REPO__` placeholder that the install script replaces with this repo's `owner/repo` path:

| Template | Trigger | What it does |
|----------|---------|-------------|
| `gh-commented.yml` | Issue comment or new issue starting with `@claude` | Responds to questions |
| `gh-start-work.yml` | Issue comment with `@claude /pr-start` | Implements issue, opens PR |
| `pr-changes-requested.yml` | PR review with changes requested starting with `@claude` | Fixes code, pushes |
| `pr-approved.yml` | PR review approved starting with `@claude` | Squash merges |

### Required secrets and variables

**Secrets** (Settings → Secrets and variables → Actions):
- `CLAUDE_CODE_OAUTH_TOKEN`: OAuth token from `claude setup-token`
- `AGENTIC_BOT_TOKEN`: The bot account's fine-grained PAT

**Variables** (Settings → Secrets and variables → Actions → Variables):
- `AGENTIC_BOT_NAME`: The bot's GitHub username
- `AGENTIC_BOT_EMAIL`: The bot's noreply email

### Diagnostics

To verify a client repo is set up correctly:

```bash
bin/diagnostics owner/repo
```

### Custom environment variables

To pass project-specific env vars (e.g. for a dev server proxy), add an `env` block at the job level in the client workflow. Composite actions inherit job-level env vars automatically:

```yaml
jobs:
  pr-fix:
    env:
      VITE_PROXY_TARGET: ${{ secrets.VITE_PROXY_TARGET }}
      VITE_HOST: localhost
    steps:
      - uses: <owner>/<agentic-repo>/.github/actions/run-claude-skill@main
        # VITE_PROXY_TARGET and VITE_HOST are automatically available
```

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

A GitHub machine account (e.g. `yourname-bot`) is used for all git and GitHub operations. Commits, PRs, and comments are attributed to the bot, not your personal account. Claude never runs git or gh commands directly — the workflows handle that.

`bin/install` walks you through setting up the bot account and its PAT. For local use, `bin/git-bot` is a wrapper that sets the bot's identity via `AGENTIC_BOT_NAME`, `AGENTIC_BOT_EMAIL`, and `GH_TOKEN` environment variables.

## Composite Actions

This repo provides 6 composite actions that can be composed into workflows:

- **setup-claude-agent** — Sets up Claude CLI, skills repo, dependencies, mkcert, and Chrome DevTools MCP
- **run-claude-skill** — Runs Claude with a specified skill and context (issue or PR). Inherits env vars from job.
- **git-commit-push** — Commits and pushes changes, optionally creating a new branch
- **post-comment** — Posts a comment to an issue or PR from `/tmp/comment.txt`
- **create-pr** — Creates a PR with optional issue linking from `/tmp/commit_msg.txt` and `/tmp/comment.txt`
- **squash-merge** — Squash merges a PR with custom commit message from `/tmp/commit_msg.txt`

## TODO

- Harden and expand the allowed commands list in `bin/bg`
