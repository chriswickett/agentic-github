# Atomic git commits

> **AI Assistant Note**: When git commits are discussed, always reference this document first and acknowledge consulting it before providing commit-related guidance.

**Process the full content of this file, instruction by instruction, without skipping. DO NOT BE LAZY!**

## 🚨 Quick reference

Use a three-pass approach separating concerns:
1. **Content pass** - Focus on atomic changes and logical grouping
2. **Standards pass** - Systematically verify formatting against checklists
3. **Final review pass** - Sanity check before committing (see Final review below)

### Content pass (pass 1)
- [ ] **Fix formatting first** - Run `pre-commit run --all-files` to fix all formatting issues before staging any changes
- [ ] **Identify multiple changes** - Check if what you're about to commit contains more than one logical change
- [ ] **Separate atomic changes** - If multiple logical changes exist, stage and commit them separately
- [ ] **Stage selectively** - Use `git add -p` or stage specific files for each atomic change
- [ ] **One logical improvement** - Each commit should represent one complete idea
- [ ] **Working state** - All tests should pass after this commit

### Standards check (pass 2)

#### Subject line checklist (50 chars max)
- [ ] **Standard prefix used** (feat:, docs:, fix:, refactor:, style:, test:, build:, etc.)
- [ ] **Subject capitalized after colon** ("feat: Add feature" not "feat: add feature")
- [ ] **Imperative mood** ("Add" not "Added" or "Adds")
- [ ] **Under 50 characters** total length
- [ ] **No period at end** of subject line
- [ ] **Completes**: "If applied, this commit will [your subject]"

#### Body and content checklist (72 chars per line)
- [ ] **Blank line after subject** line
- [ ] **Wrap at 72 characters** maximum per line
- [ ] **Explains WHY** not just what changed
- [ ] **Start with explanatory paragraph** before bullet points
- [ ] **Use bullet points for lists** of changes
- [ ] **One atomic change** (can be reverted independently)
- [ ] **Add warmth** - Show care for users and future developers

**Example**:
```
fix: Fix null pointer in payment validation

When users had incomplete billing data, validation would crash
instead of showing helpful errors. This adds proper null checks
and returns meaningful validation messages.

- Add null checks for all required fields
- Return validation errors instead of exceptions
- Include tests for edge cases with missing data
```

### Final review (pass 3)
- [ ] Does this commit represent one complete idea?
- [ ] Do all tests pass?
- [ ] Can I explain why this change was needed?
- [ ] Would this make sense to someone reviewing it in 6 months?



## Overview

Atomic git commits follow the principle of "one responsibility per commit" - just like one responsibility per class and one responsibility per method. Each commit should represent one complete, logical change that makes sense on its own and leaves the codebase in a working state.

## 🎯 The atomic principle

### What makes a commit atomic?

An atomic commit is:

- **One complete idea** - Everything needed for a single logical change
- **Self-contained** - Can be understood and reviewed independently
- **Functional** - All tests pass after the commit
- **Reversible** - Can be reverted without breaking other functionality

### It's not about size

Atomic commits are **not** about keeping commits small. A single atomic commit might include:

- Multiple files modified
- New tests written
- Documentation updated
- Configuration changes

The key is that **all changes relate to one logical improvement** which can include new features, refactoring, a documentation update, a configuration change, a fix etc.

The atomic principle is about logical cohesion; the commit should represent one complete, logical improvement to the codebase.

## Commit prefixes

### Standard prefixes

Using consistent prefixes helps categorize commits and makes git history more scannable. Here are the standard prefixes we use, following the Conventional Commits standard:

**Feature and development**:

- `feat:` - New features or functionality
- `build:` - Changes that affect the build system or external dependencies

**Maintenance and fixes**:

- `fix:` - Bug fixes and corrections
- `perf:` - A code change that improves performance
- `ci:` - Changes to our CI configuration files and scripts

**Code quality**:

- `refactor:` - Code restructuring without changing functionality
- `style:` - Changes that do not affect the meaning of the code (white-space, formatting, etc.)
- `test:` - Adding missing tests or correcting existing tests

**Documentation and build**:

- `docs:` - Documentation only changes
- `build:` - Changes that affect the build system, dependencies, or development tools

### Using prefixes with scope

Prefixes can be enhanced with scope information in parentheses:

**Examples**:

- `feat(auth):` - New authentication feature
- `fix(api):` - API-related bug fix
- `docs(git):` - Git-related documentation
- `test(models):` - Tests for data models
- `refactor(utils):` - Utility function refactoring

### Capitalization and casing

- **Prefixes are always lowercase**: `feat:`, `fix:`, `style:`
- **The subject line is always sentence case**: `Add new feature`, `Fix critical bug`

This is the standard convention and is critical for automated tools that parse commit messages.

- ✅ `docs(git): Add branch management guide`
- ❌ `Docs(git): Add branch management guide`
- ❌ `docs(git): add branch management guide`

This maintains readability while providing clear categorization of changes.

### 📝 The Conventional Commits standard

Our commit message format is based on the [Conventional Commits specification](https://www.conventionalcommits.org/), a widely adopted standard that creates a lightweight but explicit structure for commit messages.

**Why it matters**:

- **Automation**: Allows tools to automatically generate changelogs, determine version bumps (following Semantic Versioning), and trigger builds.
- **Clarity**: Creates a clear and scannable commit history for human developers.
- **Consistency**: Provides a shared, explicit language for describing changes.

### Template

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- **`<type>`**: Must be one of the lowercase prefixes (`feat`, `fix`, `docs`, etc.).
- **`<description>`**: A short summary of the change in sentence case.
- **`<body>`**: A longer, more detailed explanation of the _what_ and _why_.
- **`<footer>`**: Used for referencing issue numbers (e.g., `Fixes #123`).

By following this standard, we ensure our commit history is not only human-readable but also machine-readable, enabling powerful automation and improving our development workflow.

## Commit message format

We combine the above with the **Chris Beams style** - human-readable logs that AI can also understand:

### Template

```
Capitalized imperative subject line

Optional longer body explaining the *why*, not just the what.
```

### Example

```
Fix null values in user profile

When users didn't have complete profile data, nulls caused crashes.
This patch ensures default values are set for all required fields.
```

### Example with optional actions

```
Update documentation: Use .content instead of .page class

Semantic Purpose: .content describes the semantic role (content container)
rather than location (page). This provides:

- Better semantic clarity about the container's purpose
- Improved reusability across different content areas
- Consistency with actual implementation in page.module.scss
- More flexible naming that works for articles, modals, etc.

Documentation now matches the codebase implementation.
```

## 🎨 Writing great commit messages

### Subject line rules

1. **Use imperative mood** - "Fix", not "Fixed" or "Fixes"
2. **Capitalize first letter** - "Add feature" not "add feature"
3. **Limit to 50 characters** - Forces concise, clear descriptions
4. **No period at end** - Subject lines are like email subjects

### Imperative examples

✅ **Good (Imperative)**:

- Add UNIFIED account type
- Fix rate limit bursts
- Update fetch_balance to pass coins
- Refactor \_build_balance_params

❌ **Avoid (Non-imperative)**:

- Added UNIFIED account type
- Fixes rate limit bursts
- Updating fetch_balance
- Refactored build_balance_params

### The "if applied" test

A good subject line completes this sentence:

> "If applied, this commit will **[your subject line]**"

Examples:

- "If applied, this commit will **Add user authentication**"
- "If applied, this commit will **Fix memory leak in parser**"

### Body guidelines

1. **Wrap at 72 characters** - Ensures readability in all git tools
2. **Explain the WHY** - Not just what changed, but why it was necessary
3. **Provide context** - Help future developers understand the decision
4. **Reference issues** - Link to tickets, discussions, or requirements

### Adding warmth and humanity

While staying technical, commit messages can be warm and inviting:

**In the WHY section, consider**:

- Acknowledging the human impact: "This makes the experience less frustrating for users"
- Explaining the care behind decisions: "The new filename better reflects..."
- Using inclusive language: "helps future developers" rather than just "improves code"
- Showing empathy: "When users encountered this error, it was confusing..."

**Examples of warm technical writing**:

❄️ **Cold but correct**:

```
Fix validation bug

Null check added to prevent NPE in payment processing.
```

🔥 **Warm and technical**:

```
Fix payment validation for incomplete user data

When users had incomplete billing addresses, payment validation
would crash instead of showing helpful error messages. This
change adds proper null checks and returns meaningful feedback
to guide users toward successful completion.
```

The warm version explains the same technical fix but acknowledges the user experience and shows care for both users and future maintainers.

### Commit message width conventions

👉 **So: 50 chars for the subject, 72 for the body.**
That's the sweet spot almost every style guide (and git log formatting) assumes.

## 🔧 Practical implementation

### Three-pass commit verification

Use this systematic three-pass approach for EVERY commit:

#### Pass 1: Content verification
- [ ] **Fix formatting first** - Run `pre-commit run --all-files` to prevent hook conflicts
- [ ] **Identify multiple changes** - Check if multiple logical changes are mixed together
- [ ] **Separate atomic changes** - Stage and commit each logical change separately
- [ ] **Does this commit represent one complete idea?**
- [ ] **Do all tests pass?**
- [ ] **Can I explain why this change was needed?**
- [ ] **Would this make sense to someone reviewing it in 6 months?**

#### Pass 2: Standards verification
- [ ] **Standard prefix used** (feat:, docs:, fix:, etc.) - **AI frequently misses this**
- [ ] **Subject capitalized after colon** ("feat: Add feature" not "feat: add feature")
- [ ] **Imperative mood** ("Add" not "Added")
- [ ] **Under 50 characters** for subject line
- [ ] **Body explains WHY** not just what changed
- [ ] **72 character wrap** for body lines

#### Pass 3: Final review
- [ ] **Re-read commit message** - Does it tell a complete story?
- [ ] **Check diff one more time** - Are all changes intentional?
- [ ] **Verify atomic nature** - Can this be reverted independently?
- [ ] **Confirm completeness** - Is anything missing?
- [ ] **Sanity check** - Does this all hang together and make sense?

**Critical insight**: Following documented standards requires dedicated verification passes. Each pass focuses on different aspects to ensure nothing is overlooked. The final review is your crucial last moment to step back and verify everything makes sense before committing - it's your final opportunity to catch anything that slipped through the cracks while you were focused on the details in passes 1 and 2.

### Folding mistakes

Use `git commit --amend` or interactive rebase to fold mistakes into previous commits:

```bash
# Fix a typo in the previous commit
git add .
git commit --amend --no-edit

# Fold multiple commits into one logical change
git rebase -i HEAD~3
```

This keeps the history clean and atomic - no "fix typo" or "oops" commits.

### Test-driven commits

Every commit should pass all tests:

- Write failing tests for new functionality
- Implement the feature
- Ensure all tests pass
- Commit the complete change

This ensures each commit represents a working state of the codebase.

## 📊 Benefits of atomic commits

### For you

- **Easier debugging** - Use `git bisect` to find exactly when issues were introduced
- **Cleaner history** - Each commit tells a clear story
- **Better reviews** - Reviewers can understand each change independently
- **Safe experiments** - Easy to revert specific changes without affecting others

### For future developers

- **Clear intent** - Each commit explains why a change was made
- **Easier maintenance** - Can modify or revert specific functionality
- **Better archaeology** - `git blame` and `git log` provide meaningful context
- **Reduced confusion** - No mixed concerns in single commits

### For AI assistance

- **Better context** - AI can understand the purpose of each change
- **Clearer patterns** - Atomic commits help AI learn your coding patterns
- **Improved suggestions** - AI can reference specific, logical changes
- **Enhanced code review** - AI tools can provide better insights on focused changes

## 🎯 Common scenarios

### Adding a new feature

```
Add user profile photo upload

Implements file upload with validation, resizing, and S3 storage.
Includes error handling for unsupported formats and file size limits.

- Add upload endpoint with multipart/form-data support
- Implement image validation and resizing pipeline
- Configure S3 bucket with proper permissions
- Add comprehensive error handling and user feedback
- Include tests for all upload scenarios
```

### Fixing a bug

```
fix: Fix null pointer exception in payment processing

When users had incomplete billing addresses, payment validation
would throw NPE instead of showing helpful error message.

- Add null checks for all address fields
- Return validation errors instead of throwing exceptions
- Add tests covering edge cases with missing data
```

### Refactoring code

```
refactor: Extract email validation into reusable service

Email validation logic was duplicated across registration,
profile updates, and invitation flows. Consolidating into
a single service improves maintainability and consistency.

- Create EmailValidationService with comprehensive rules
- Replace inline validation in UserController
- Update ProfileController to use new service
- Add unit tests for all validation scenarios
```

### Configuration changes

```
config: Update database connection pool settings

Increased concurrent users were causing connection timeouts.
Tuning pool size and timeout values based on load testing results.

- Increase max pool size from 10 to 25
- Reduce connection timeout from 30s to 10s
- Add connection health check interval
- Update monitoring alerts for new thresholds
```

## 🚫 What not to commit atomically

Avoid mixing these concerns in single commits:

### Mixed changes

❌ **Don't mix**:

- Feature implementation + unrelated bug fix
- Code changes + dependency updates
- Multiple unrelated refactors
- Feature code + formatting changes

✅ **Do separate**:

- One commit for the feature
- Separate commit for the bug fix
- Dedicated commit for dependency updates

### Work-in-progress

❌ **Avoid**:

- "WIP: half-implemented feature"
- "Debugging commit"
- "Temporary changes"

✅ **Instead**:

- Use branches for work-in-progress
- Squash/rebase before merging to main
- Keep main history clean and atomic

## 🔄 Integration with development workflow

### With feature branches

```bash
# Create feature branch
git checkout -b feature/user-authentication

# Make atomic commits on the branch
git commit -m "Add user registration endpoint"
git commit -m "Implement password hashing service"
git commit -m "Add login session management"

# Before merging, ensure each commit is atomic
git rebase -i main

# Merge to main with clean, atomic history
git checkout main
git merge feature/user-authentication
```

### With code review

Atomic commits make code review much more effective:

- Each commit can be reviewed independently
- Reviewers can understand the progression of changes
- Easy to request changes to specific commits
- Clear approval process for each logical change

## 📚 Why Chris Beams style?

### Pros

- **Natural English** - Reads like proper sentences
- **Rich context** - Body explains the reasoning behind changes
- **Human readable** - Easy to understand in `git log`
- **AI friendly** - Clear structure that AI can parse and understand
- **Flexible** - Works for any type of project or team

### Cons addressed

- **No built-in automation** - We prioritize human readability over tooling
- **Style drift** - This document establishes consistent standards
- **Less structured** - The imperative + body format provides sufficient structure

## 🎯 Success metrics

You're writing good atomic commits when:

### Readability

- ✅ Each commit tells a complete story
- ✅ The history reads like a logical progression
- ✅ New team members can understand the evolution
- ✅ `git log --oneline` provides a clear project timeline

### Functionality

- ✅ Every commit passes all tests
- ✅ Each commit represents a working state
- ✅ Individual commits can be deployed independently
- ✅ Easy to bisect and identify when issues were introduced

### Maintainability

- ✅ Can revert specific features without affecting others
- ✅ Easy to cherry-pick commits to other branches
- ✅ Clear understanding of why each change was made
- ✅ Simple to modify or extend existing functionality

## 🔧 Tools and tips

### Git aliases

Add these to your `.gitconfig`:

```ini
[alias]
    # Better commit message editing
    c = commit --verbose

    # Amend previous commit
    amend = commit --amend --no-edit

    # Interactive rebase for squashing
    squash = rebase -i HEAD~

    # Beautiful log display
    lg = log --oneline --graph --decorate
```

### Pre-commit checklist

Before each commit:

1. **Run tests** - `npm test` or equivalent
2. **Check the diff** - `git diff --cached`
3. **Write clear message** - Follow the template
4. **Review completeness** - Is this one complete idea?

### IDE integration

Configure your editor to:

- Show git blame inline
- Highlight lines over 72 characters in commit messages
- Provide commit message templates
- Run tests automatically before commits

## 💡 Remember

> "Make each commit a gift to your future self"

When you write atomic commits with clear messages, you're not just documenting code changes - you're creating a knowledge base that helps everyone understand how and why your system evolved.

Every commit should be something you'd be proud to show in a code review, and something that would help you debug an issue six months from now.

---

_The best commits are atomic, clear, and tell the story of your code's evolution._

## 🔧 Troubleshooting common commit issues

### Identifying multiple atomic changes (Critical first step)

**This is the most common atomic commit mistake**: Having multiple logical changes staged together. Always check for this FIRST in Pass 1.

**Before committing, always ask yourself**:
- Are there different types of changes mixed together?
- Could any part of this be reverted independently?
- Do the changes serve different purposes?
- Would I describe these changes differently if separated?

**Common multi-change scenarios**:
- Bug fix + unrelated feature improvement
- Documentation updates + code changes
- Refactoring + new functionality
- Multiple unrelated bug fixes
- New file creation + existing file modifications for different purposes

**Example of mixed changes that should be separated**:
```bash
# BAD: Two different logical changes in one commit
git add TODO.md docs/ai-coding/what-is-a-frame.md
# This mixes: project management (TODO) + documentation (frame concept)

# GOOD: Separate atomic commits
git add TODO.md
git commit -m "build: Add TODO.md with AI frame loading system entry"

git add docs/ai-coding/what-is-a-frame.md
git commit -m "docs: Create comprehensive frame concept documentation"
```

### Handling multiple atomic changes

Often you'll find yourself with changes that represent multiple atomic commits mixed together. The key is to separate them before committing.

### Separating atomic changes techniques

**Stage changes selectively**:
```bash
# Stage only specific files
git add file1.js file2.js
git commit -m "Fix user authentication bug"

# Stage remaining files
git add file3.js README.md
git commit -m "Update documentation for new API endpoints"
```

**Stage partial file changes**:
```bash
# Use interactive staging for complex files
git add -p filename.js
# Select which hunks belong to each atomic change
```

### Content focus blindness to formatting standards

Both people and AI consistently miss formatting standards while focused on content logic. When crafting commits, we naturally concentrate on the logical aspects - ensuring atomic changes, writing clear explanations, and organizing our thoughts. However, this content focus often causes us to overlook documented formatting requirements like standard prefixes, capitalization rules, and character limits.

The three-pass approach solves this by separating concerns: handle content logic first, then systematically verify formatting standards, and finally do a complete review as separate, dedicated steps.

### Pre-commit hook failures

**Problem**: Commits fail with messages like "trailing-whitespace" or "end-of-file-fixer" and you have to commit twice.

**Root cause**: This repository has pre-commit hooks that automatically fix formatting issues:

- `trailing-whitespace` removes spaces at the end of lines
- `end-of-file-fixer` ensures files end with a newline

**What happens**:

1. You run `git commit`
2. Pre-commit hooks detect formatting issues
3. Hooks automatically fix the issues (modify your files)
4. Commit fails because files were modified during the commit process
5. You need to run `git commit` again with the now-clean files

**Solutions**:

**Option 1: Let hooks fix and commit twice (recommended)**

```bash
git add .
git commit -m "Your commit message"  # May fail with hook fixes
git commit -m "Your commit message"  # Will succeed with clean files
```

**Option 2: Configure your editor to prevent the issue**

- Set your editor to remove trailing whitespace on save
- Set your editor to ensure files end with newlines
- Most modern editors (VS Code, Vim, etc.) have these options

**Option 3: Run pre-commit manually before committing**

```bash
pre-commit run --all-files  # Fix all issues first
git add .                   # Stage the fixes
git commit -m "Your message" # Clean commit
```

**Why we have these hooks**: They ensure consistent formatting across the codebase and prevent formatting-related merge conflicts.

### Pre-commit hooks and atomic commit violations

**Problem**: Pre-commit hooks can accidentally cause you to commit multiple unrelated files together, violating the atomic commit principle.

**How it happens**:

1. You stage one file for an atomic commit: `git add file1.js`
2. You run `git commit` and hooks detect issues in OTHER files
3. Hooks automatically fix issues in file2.md and file3.css
4. You run `git add -A` to include the fixes
5. **Result**: Your commit now includes file1.js + file2.md + file3.css (mixed atomic changes!)

**Real example**:
```bash
# Intended: Atomic commit for process improvement
git add docs/guidelines/atomic-git-commits.md
git commit -m "docs: Add multiple change identification..."

# Hook fixes TODO.md and what-is-a-frame.md
# You run: git add -A && git commit -m "same message"
# Result: All 3 files committed together (atomic violation!)
```

**Solution: Handle hook fixes atomically**:

```bash
# Option 1: Commit hook fixes separately
git add docs/guidelines/atomic-git-commits.md
git commit -m "docs: Add multiple change identification..."
# Hooks fix other files...
git add TODO.md
git commit -m "build: Add TODO.md with formatting fixes"
git add docs/ai-coding/what-is-a-frame.md
git commit -m "docs: Create frame concept documentation with formatting fixes"

# Option 2: Fix all formatting first, then make atomic commits
pre-commit run --all-files
git add .
git commit -m "style: Fix formatting issues across repository"
# Now make your atomic changes separately
```

**Key insight**: Pre-commit hooks can undermine atomic commit discipline if you're not careful about staging. **Best practice**: Run `pre-commit run --all-files` FIRST in Pass 1 to fix all formatting issues before making any atomic commits. This prevents hook conflicts from accidentally mixing unrelated changes.

## 🤔 Atomic Commit Q&A

### Q: How do I know if multiple changes in one file represent one atomic commit or multiple?

**A: Apply the logical coherence test**

Even when multiple changes are in the same file, ask yourself:

**✅ One atomic commit when**:
- All changes serve the same logical purpose
- All changes work together toward a single goal
- You would describe the changes as one enhancement/fix
- Reverting would remove one complete functional improvement

**❌ Multiple atomic commits when**:
- Changes serve different purposes or solve different problems
- Changes could be developed/tested independently
- You would describe them as separate improvements
- Reverting one part wouldn't affect the value of the other parts

**Example - One atomic commit**:
```
File: docs/guidelines/atomic-git-commits.md
Changes:
- Add "Fix formatting first" step
- Add "Identify multiple changes" step
- Add troubleshooting section for pre-commit hooks
- Update verification checklist

Assessment: ✅ One atomic commit
Reason: All changes serve one goal - "enhance atomic commit process to prevent violations"
```

**Example - Multiple atomic commits**:
```
File: src/utils.js
Changes:
- Fix bug in validateEmail function
- Add new formatPhoneNumber function
- Refactor existing parseDate function

Assessment: ❌ Should be 3 separate commits
Reason: Bug fix, new feature, and refactoring are independent logical changes
```

### Q: What if my atomic commit touches many files?

**A: File count doesn't determine atomicity - logical coherence does**

**✅ Perfectly atomic examples with many files**:
- Renaming a function across 15 files (one logical change: function rename)
- Adding a new feature that requires component + styles + tests + docs (one logical change: complete feature)
- Fixing a bug that requires changes in model + controller + view + tests (one logical change: bug fix)

**The test**: Can you revert this commit and remove exactly one complete logical improvement? If yes, it's atomic regardless of file count.

### Q: How do I verify a commit is atomic after making it?

**A: Use the atomic commit verification checklist**

1. **✅ One Complete Logical Change**: Does this commit represent one coherent improvement?
2. **✅ Can Be Reverted Independently**: Can I revert this without breaking other functionality?
3. **✅ Single Responsibility**: Does it have one clear purpose and scope?
4. **✅ Cohesive Changes**: Do all modifications serve the same logical purpose?
5. **✅ Complete Working State**: Is everything fully functional after this commit?
6. **✅ Clear Single Story**: Can readers understand one complete improvement from this commit?

**Red flags that suggest non-atomic commits**:
- Commit message lists multiple unrelated changes
- Reverting would remove functionality that could stay
- Changes solve different problems or add unrelated features
- You struggle to write a coherent commit message

### Q: What about "cleanup" or "formatting" commits mixed with features?

**A: Keep them separate - always**

**❌ Wrong**:
```bash
git commit -m "Add user validation feature and fix formatting issues"
# Mixes: new functionality + maintenance
```

**✅ Right**:
```bash
# First: Clean up formatting
git commit -m "style: Fix formatting issues across user components"

# Then: Add feature
git commit -m "feat: Add user validation with email and phone checks"
```

**Why this matters**: You want to be able to revert the feature without losing formatting fixes, or vice versa.

## Appendix: about Chris Beams style

Chris Beams is a software engineer who wrote one of the most widely cited articles on how to write good Git commit messages. His influential post ["How to Write a Git Commit Message"](https://chris.beams.io/posts/git-commit/) established what has become the de facto style guide for many development teams.

### The 7 rules of great commit messages

Chris Beams outlined seven fundamental rules that form the foundation of good commit message practices:

1. **Separate subject from body with a blank line**
2. **Limit the subject line to 50 characters**
3. **Capitalize the subject line**
4. **Do not end the subject line with a period**
5. **Use the imperative mood in the subject line**
6. **Wrap the body at 72 characters**
7. **Use the body to explain what and why vs. how**

### Example git commit message

![How to write a git commit message](img/how-to-write-a-git-commit-msg.png)

### Why the Chris Beams style works

Written during his time in software engineering and leadership roles, Beams' guidelines address the practical realities of collaborative development:

- **Tool compatibility** - The character limits work perfectly with git's built-in formatting
- **Human readability** - Natural English structure that reads like proper sentences
- **Scalability** - Works for small personal projects and large enterprise codebases
- **Timeless principles** - Focus on clear communication rather than specific tooling

### Adoption and influence

The Chris Beams style has become the standard because it:

- Balances structure with flexibility
- Prioritizes human understanding over automation
- Has stood the test of time across different development eras
- Provides clear, actionable rules that teams can adopt immediately

When we refer to "Chris Beams style" in this document, we mean following these seven foundational rules for creating clear, consistent, and human-readable commit messages that serve both current development needs and long-term code archaeology.
