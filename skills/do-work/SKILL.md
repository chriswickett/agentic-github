---
name: do-work
description: Executes a plan from a GitHub issue
---

# do-work

## Trigger

`/do-work`

## Process

### 1. Find the issue

Ask: "Which issue should I work on?"

The user should provide a GitHub issue number or URL. If they give a number, use `gh issue view <number>` to fetch it.

Wait for the user's response before proceeding, unless they have already specified the issue.

### 2. Read and understand the plan

- Read the issue body and comments using `gh issue view <number>`
- Check any AI.md, CLAUDE.md, WARP.md files in the repo to learn about project-specific AI practices
- Review code examples, acceptance criteria, and visual references from the issue
- Check code references in the repo. Gather an understanding how things are currently done
- Understand the scope and approach

### 3. Create TODO list

Based on the issue's proposed changes, create a TODO list with discrete implementation steps.

### 4. Execute

Work through the TODO list:
- Follow patterns shown in the code examples
- Reference visual designs if provided
- Implement changes systematically
- Mark each TODO as done when complete
- Leave any test code/pages/examples you create in place for user to review

### 5. Validate

- Test the implementation (run tests if specified in the issue)
- Verify against acceptance criteria
- Run linting/typechecking if the project uses it
- **For frontend/UI features**: Use Chrome DevTools MCP to validate:
  - Take screenshots to compare against reference designs. Bear in mind reference images are inspiration only - the style should match the existing style
  - **CRITICAL**: When reviewing screenshots, look extremely carefully at what is ACTUALLY shown in the screenshot, not what you EXPECT to see. Describe what you observe, don't assume it matches the plan.
  - Check console for errors/warnings (`list_console_messages`)
  - Take snapshots to verify accessibility tree structure
  - Test interactivity with `evaluate_script` if needed
- Fix any issues found

### 6. Summary

Provide a brief summary of what was implemented, focused on the changes made rather than restating code. The summary should include which page/url/code the user should review (as an entry point)

## Key principles

- **No questions**: The issue should contain everything needed. If critical information is missing, note it but proceed with best judgment based on codebase patterns.
- **Follow examples**: Use the code examples in the issue as the primary guide for implementation patterns.
- **Acceptance criteria**: These define "done" - ensure all criteria are met.
- **Test thoroughly**: Validate the work actually works before considering it complete.
