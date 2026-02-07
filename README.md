# Agentic

Reusable Claude Code skills and GitHub Actions workflows for automated PR lifecycle management.

## Skills

- **pr-start** — executes a plan locally, commits, and opens a PR
- **pr-respond** — GitHub Actions entry point for PR review events
- **pr-fix** — fixes code based on reviewer feedback
- **pr-merge** — squash-merges approved PRs with clean commit messages
- **commit** — atomic git commit methodology

## Client repo setup

1. Add `.github/workflows/pr-respond.yml` calling the reusable workflow:

```yaml
on:
  pull_request_review:
    types: [submitted]

jobs:
  pr-respond:
    uses: chriswickett/agentic/.github/workflows/pr-respond.yml@main
    secrets: inherit
```

2. Add repo secrets: `ANTHROPIC_API_KEY`, `SKILLS_REPO_PAT`
3. Ensure a `plans/` directory exists

See `WORKFLOW.md` for the full system design.
