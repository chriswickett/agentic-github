# Commit workflow

<mark>**Follow these steps in order. Do not skip any step.**</mark>

---

## Execution sequence

| Pass | Action | Goal |
|:-----|:-------|:-----|
| 0 | **Pre-flight** | Fix formatting, identify atomic changes |
| 1 | **Content** | Stage selectively, verify one logical change |
| 2 | **Standards** | Verify message format against checklists |
| 3 | **Final review** | Sanity check before committing |
| 4 | **Post-commit** | Verify atomicity after committing |

---

## Before you start

Read [SKILL.md](SKILL.md) first — it contains the coherence test, AI atomicity mistakes, commit format reference, and the pre-commit atomicity trap.

---

## Pass 0: Pre-flight

**Goal**: Clean slate before staging.

1. Run `pre-commit run --all-files` to fix formatting issues
2. Stage any formatting fixes: `git add .` then commit as `style: Fix formatting issues`
3. Run `git status` to see all changed files
4. Run `git diff` to understand the changes
5. Identify how many **logical changes** exist

### Multiple logical changes?

Ask: could any subset of these changes be reverted independently and still make sense?

| Signal | Action |
|:-------|:-------|
| All changes serve one purpose | Proceed as one commit |
| Changes serve different purposes | Separate into multiple commits |
| Bug fix + unrelated feature | Two commits |
| Code change + unrelated formatting | Two commits |

Check the [common AI atomicity mistakes](SKILL.md#common-ai-atomicity-mistakes) — do not group changes just because they were made in the same session, share a prefix, or touch the same area.

**Common multi-change scenarios**:

- Bug fix + unrelated feature improvement
- Documentation updates + code changes
- Refactoring + new functionality
- Multiple unrelated bug fixes
- New file creation + existing file modifications for different purposes

---

## Pass 1: Content

**Goal**: Stage the right files for one atomic change.

1. **Stage selectively** — `git add` specific files, not `git add -A`
2. **Review staged changes** — `git diff --cached`
3. **Verify completeness** — are all files needed for this change staged?
4. **Apply the [coherence test](SKILL.md#the-coherence-test)** — does removing any file leave a hole?

### Staging techniques

**Stage specific files**:

```bash
git add file1.js file2.js
```

**Stage partial file changes** (when one file contains changes for multiple commits):

```bash
git add -p filename.js
# Select which hunks belong to each atomic change
```

---

## Pass 2: Standards

**Goal**: Draft the commit message and verify formatting against [SKILL.md](SKILL.md#commit-message-format).

This is a dedicated pass because of [content focus blindness](SKILL.md#content-focus-blindness) — both people and AI miss formatting rules while focused on content logic.

### Subject line checklist (50 chars max)

- [ ] **Standard prefix used** (feat:, docs:, fix:, refactor:, style:, test:, build:, etc.) — **AI frequently misses this**
- [ ] **Subject capitalized after colon** ("feat: Add feature" not "feat: add feature")
- [ ] **Imperative mood** ("Add" not "Added" or "Adds")
- [ ] **Under 50 characters** total length
- [ ] **No period at end** of subject line
- [ ] **Completes**: "If applied, this commit will [your subject]"

### Body and content checklist (72 chars per line)

- [ ] **Blank line after subject** line
- [ ] **Wrap at 72 characters** maximum per line
- [ ] **Explains WHY** not just what changed
- [ ] **Start with explanatory paragraph** before bullet points
- [ ] **Use bullet points for lists** of changes
- [ ] **One atomic change** (can be reverted independently)
- [ ] **Add warmth** — show care for users and future developers

### Commit execution

Use multiple `-m` flags to avoid heredoc issues with special characters:

```bash
git commit -m "type: Subject line here" -m "Explanatory paragraph about
why this change was needed. Keep lines under
72 characters.

- Specific change one
- Specific change two"
```

### Pre-commit hook failures

If the commit fails because hooks fix files:

1. Review what the hooks changed
2. Stage the hook-fixed files **only if they belong to this atomic change**
3. If hooks fixed unrelated files, commit your atomic change first, then handle hook fixes separately (see [the pre-commit atomicity trap](SKILL.md#the-pre-commit-atomicity-trap))
4. Re-run the commit

---

## Pass 3: Final review

**Goal**: Last sanity check before the commit lands.

- [ ] Does this commit represent one complete idea?
- [ ] Do all tests pass?
- [ ] Re-read the commit message — does it tell a complete story?
- [ ] Check the diff one more time — are all changes intentional?
- [ ] Can this be reverted independently?
- [ ] Is anything missing?
- [ ] Would this make sense to someone reviewing it in 6 months?

This is the crucial last moment to catch anything that slipped through while focused on content (Pass 1) and formatting (Pass 2).

If any check fails, go back to Pass 1 or Pass 2 as needed.

---

## Pass 4: Post-commit verification

**Goal**: Verify the commit is truly atomic after it lands.

```bash
git diff --stat HEAD~1 HEAD
git log -1
```

- [ ] All files serve the single purpose described in the commit message
- [ ] No hitchhikers — could any file be removed and still leave a coherent change?
- [ ] No stowaways — are there files that serve a different purpose?
- [ ] Clean revert — if reverted, would it remove exactly one logical improvement?

### If verification fails

```bash
# Undo the commit but keep all changes staged
git reset --soft HEAD~1

# Unstage everything
git reset HEAD .

# Now re-stage and commit each logical change separately
git add <files-for-change-1>
git commit -m "prefix: First logical change"

git add <files-for-change-2>
git commit -m "prefix: Second logical change"
```

### Folding mistakes

If a commit has a small error (typo, missed file) that belongs to the same logical change:

```bash
git add .
git commit --amend --no-edit
```

Only use `--amend` for unpushed commits.

---

## Output

After a successful commit, display the result:

```bash
git log -1 --format="%h %s%n%n%b"
```

Format:

```text
Committed:

<hash> <subject-line>

<full-commit-body>
```

---

## Verification gate

<mark>**All four passes must complete before the commit is final.**</mark>

- [ ] Pre-flight: formatting fixed, atomic changes identified
- [ ] Content: files staged selectively, coherence test passed
- [ ] Standards: message format verified against checklists
- [ ] Final review: sanity check passed
- [ ] Post-commit: atomicity verified, output displayed
