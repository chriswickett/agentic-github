# Agentic GitHub

This is a system for getting Claude to do work for you in GitHub, all on the cloud. Comment `@claude` on issues and PRs to trigger Claude Code in GitHub Actions.

## Security notes

- Claude runs with `--dangerously-skip-permissions`, meaning it can execute any tool without approval
- All GitHub Actions secrets and variables are injected as environment variables, so Claude has access to every secret and variable configured on the repo
- The bot account's PAT is currently a classic token, which grants access to all repos the account can access

Make sure you are comfortable with all three of these before using.

## Usage

All interactions must start with `@claude` at the beginning of a comment or review.

| Action | Trigger |
|---|---|
| Implement an issue | Comment `@claude /pr-start` on an issue |
| Ask a question | Comment `@claude <question>` on an issue or PR |
| Request fixes | Submit a PR review with "Request changes" starting with `@claude` |
| Merge a PR | Submit a PR review with "Approve" starting with `@claude` |

## Setup

### 1. Create a bot account

Create a GitHub account for your bot (e.g. `yourname-bot`). Generate a Personal Access Token with Contents, Pull requests, and Issues read/write permissions. Note the account's noreply email from the account's email settings.

### 2. Configure the client repo

Add these as repo or org-level secrets (Settings > Secrets and variables > Actions) to the repo you want to use Agentic GitHub with.

| Secret | Value |
|---|---|
| `AGENTIC_BOT_TOKEN` | The bot's PAT |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth token from `claude setup-token` |

Add these as repo or org-level variables:

| Variable | Value |
|---|---|
| `AGENTIC_BOT_USERNAME` | The bot's GitHub username |
| `AGENTIC_BOT_NAME` | Display name for git commits |
| `AGENTIC_BOT_EMAIL` | The bot's noreply email |

Add the bot account as a collaborator with write access.

### 3. Add the workflow

Create `.github/workflows/agentic.yml`:

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
    if: github.actor != vars.AGENTIC_BOT_USERNAME
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
        with:
          repository: chriswickett/agentic

      - uses: ./.github/actions/dispatch
        with:
          secrets-json: ${{ toJSON(secrets) }}
          vars-json: ${{ toJSON(vars) }}
```

### 4. Repo settings

- Disable auto-merge (Settings > General > Pull Requests)
- Enable squash merging