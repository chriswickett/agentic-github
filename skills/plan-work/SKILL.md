---
name: plan-work
description: Plan work through structured conversation and create a GitHub issue.
---

# plan-work

## Trigger

`/plan-work`

## Process

### 1. Open question

Ask: "What do you want to work on?"

Wait for the user's response before proceeding.

### 2. Research

After the user describes what they want to build:

- Scan the codebase for related code, patterns, and existing implementations
- Look for files, components, or systems that might be affected
- Identify any existing similar functionality
- **Extract code examples** showing how similar patterns are already implemented (e.g., component structure, utility usage, styling patterns, registration patterns)

Do this silently — use findings to inform your questions.

### 3. Clarifying questions

Ask follow-up questions to build shared understanding. Questions should be:

- Context-dependent based on research findings
- One at a time
- Skipped if the answer is already obvious

Possible areas to clarify:
- Scope and boundaries
- Acceptance criteria (what does "done" look like?)
- Technical approach
- Dependencies or constraints
- For UI features: any reference images, inspiration, or flat designs? (Ask for file paths, e.g., "Save the image and let me know the path")

### 4. Summary and choice

Once you have enough context, summarise the plan briefly and ask:

"Want me to create a GitHub issue for this?"

### 5. Account selection

Before creating the issue, check for an `AGENTIC_BOT_TOKEN` variable in `.env` or `.env.local` in the client repo root (the current working directory, not the agentic-github repo). If the token is present, ask the user whether they want to create the issue as themselves or as the bot account. If no token is found, skip this step and use the default `gh` auth.

### 6. Create the GitHub issue

Use `gh issue create` to create the issue. The repo is determined from the current git remote (`gh` will pick it up automatically, or the user may specify).

If the user chose the bot account, pass the token per-command: `GITHUB_TOKEN=$AGENTIC_BOT_TOKEN gh issue create ...`. Do not export the variable or set it permanently.

The issue title should be a concise summary prefixed with a type label, e.g. `feat: Add signup button` or `fix: Header overflow on mobile`.

### Issue body structure

The issue will be executed by an intelligent agent that **cannot ask questions**. Structure the body in this order:

1. **Problem statement**: What needs to be built/fixed
2. **Visual references** (if applicable): For UI features, attach or link reference images
3. **Proposed changes**: What to implement (the plan steps)
4. **Current state**: Brief context about relevant existing code
5. **Code examples from the codebase**: Show how similar patterns are already implemented
   - Component structure patterns
   - How utilities/helpers are used
   - Styling patterns (SCSS modules, etc.)
   - Registration/export patterns
   - Similar feature implementations
6. **Usage** (if applicable): Example of how to use the new feature
7. **Acceptance criteria**: Clear definition of what "done" looks like. NOTE: this is not 'how to code the feature'. It is the OUTCOMES we want to see.

The goal: an intelligent agent should be able to implement without asking "how do we do X in this codebase?" because they can see examples of X already being done.

### 7. Output

After creating the issue, display the issue URL so the user can review it. Let them know they can trigger implementation by commenting `@claude /pr-start` on the issue.
