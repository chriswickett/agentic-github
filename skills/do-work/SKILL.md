---
name: do-work
description: Executes a plan created by plan-work skill
---

# do-work

## Trigger

`/do-work`

## Process

### 1. Find the plan

Ask: "Which plan should I execute?" 

If there's a `./plans/` directory, list available `.md` files for the user to choose from.

Wait for the user's response before proceeding, unless they have already told you or the md name was piped in.

### 2. Read and understand the plan

- Read the entire plan file
- Review code examples, acceptance criteria, and visual references
- Check the code references and be aggressive with reading as many files in the repo as you need to understand how things are currently done
- Understand the scope and approach

### 3. Create TODO list

Based on the plan's proposed changes, create a TODO list with discrete implementation steps.

### 4. Execute

Work through the TODO list:
- Follow patterns shown in the code examples
- Reference visual designs if provided
- Implement changes systematically
- Mark each TODO as done when complete

### 5. Validate

- Test the implementation (run tests if specified in the plan)
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

Provide a brief summary of what was implemented, focused on the changes made rather than restating code.

## Key principles

- **No questions**: The plan should contain everything needed. If critical information is missing, note it but proceed with best judgment based on codebase patterns.
- **Follow examples**: Use the code examples in the plan as the primary guide for implementation patterns.
- **Acceptance criteria**: These define "done" - ensure all criteria are met.
- **Test thoroughly**: Validate the work actually works before considering it complete.
