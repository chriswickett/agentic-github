# Agentic GitHub

This is a system for getting Claude to do work for you in GitHub, all on the cloud. Comment `@claude` on issues and PRs to trigger Claude Code in GitHub Actions.

## Security notes

- Claude runs with `--dangerously-skip-permissions`, meaning it can execute any tool without approval
- All GitHub Actions secrets and variables are injected as environment variables, so Claude has access to every secret and variable configured on the repo
- The bot account's PAT is currently a classic token, which grants access to all repos the account can access

- Fork PRs are blocked: if a PR originates from a fork, the workflow refuses to run. Without this, a forked repo could inject malicious code (e.g. in `CLAUDE.md` hooks or any script) that executes with access to your secrets
- Any code in the checked-out repo can read environment variables, including secrets. This applies to `CLAUDE.md` hooks, pre-commit hooks, scripts Claude is asked to run, and any process spawned on the runner

Make sure you are comfortable with all of these before using.

## Usage

All interactions must start with `@claude` at the beginning of a comment or review.

| Action | Trigger |
|---|---|
| Implement an issue | Comment `@claude /pr-start` on an issue |
| Ask a question | Comment `@claude <question>` on an issue or PR |
| Request fixes | Submit a PR review with "Request changes" starting with `@claude` |
| Merge a PR | Submit a PR review with "Approve" starting with `@claude` |

You can also use /plan-work locally to have Claude plan a piece of work interactively and then create a GitHub issue.

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
| `AGENTIC_SKILLS_REPO` | (Optional) Override skills from a repo, e.g. `org/repo` or `org/repo/path/to/skills` |

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
          repository: chriswickett/agentic-github

      - uses: ./.github/actions/dispatch
        with:
          secrets-json: ${{ toJSON(secrets) }}
          vars-json: ${{ toJSON(vars) }}
```

### 4. Repo settings

- Disable auto-merge (Settings > General > Pull Requests)
- Enable squash merging

### 5. Local skills (optional)

To use skills like `/plan-work` locally in Claude Code, symlink the skills directory:

```bash
ln -s /path/to/agentic/skills/* ~/.claude/skills/
```

## Custom skills

The built-in skills (`gh-respond`, `pr-start`, `pr-fix`, `pr-merge`) define how Claude behaves during each workflow step. You can override any of them to change that behaviour — for example, to enforce your team's commit message conventions, add project-specific validation steps, or change how PRs are structured.

To override a skill, create a `SKILL.md` file with the same name in a separate GitHub repo. Set the `AGENTIC_SKILLS_REPO` variable on the client repo to point to it:

- `org/my-skills` — looks for skills in the `skills/` directory at the repo root
- `org/my-skills/path/to/skills` — looks in a subdirectory

The repo can be private — it's cloned using the bot account's PAT.

The directory structure should mirror agentic-github's `skills/` layout:

```
skills/
  pr-start/
    SKILL.md    # overrides the default pr-start skill
  gh-respond/
    SKILL.md    # overrides the default gh-respond skill
```

You can override any built-in skill (including `/commit`) or add entirely new skills of your own. Only skills with matching names are overridden — anything without a match uses the default.