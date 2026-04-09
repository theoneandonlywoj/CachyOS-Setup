---
name: pr
description: Generate a pull request description from git diff and commit history against a target branch
argument-hint: <diff-target-branch>
allowed-tools: Bash(git *), Bash(gh *), Bash(mix *), Bash(rg *), Bash(cat *), Bash(printf *), Read, Glob, Write, Edit
---

# Generate Pull Request Description

## Context

- Current branch: !`git branch --show-current`
- Diff target: $ARGUMENTS (defaults to main if not provided)
- GitHub user: !`gh api /user --jq '.login'`
- Recent commits on current branch: !`git log $ARGUMENTS..HEAD --oneline 2>/dev/null || git log HEAD~10..HEAD --oneline`
- Changed files: !`git diff $ARGUMENTS..HEAD --stat 2>/dev/null || echo "(unable to compute diff)"`

## Instructions

### 1. Determine Target Branch
Use `$ARGUMENTS` as the diff target. If empty, use `main`.

### 2. Check for Existing PR
Run: `gh pr list --head $(git branch --show-current) --state open --json number,title,url --jq '.[]'`

- If PR exists → note the PR number for update
- If no PR exists → will create new

### 3. Generate PR Title from Branch Name
Convert branch name to title case:
- Replace `-` and `_` with spaces
- Strip common prefixes: `feat/`, `fix/`, `hotfix/`, `chore/`, `docs/`, `refactor/`
- Title case each word

Example: `feat/add-new-feature` → `Add New Feature`

### 4. Generate PR Body
Generate a pull request description following the template in `.github/PULL_REQUEST_TEMPLATE.md`.

Populate it as follows:

1. **Summary**: Derive from commit messages on the current branch. If none, use a concise description of the main purpose.

2. **Changes**: List key files changed and what they do, based on `git diff`. Group related changes.

3. **Testing**:
   - **User**: Describe manual testing steps for user-facing functionality, or note if UI/styling changed
   - **System**: Describe backend/system testing (API, database, background jobs), or note if tests were added/modified

4. **Related Issues**: Leave as `<!-- Related Issues -->` if none can be inferred

Do not include any footer, attribution, or timestamp. Do not add "Written by" or similar sections.

### 5. Create or Update PR

**If existing PR found:**
```bash
gh pr edit <PR_NUMBER> --title "<TITLE>" --body "<BODY>"
```

**If no existing PR:**
```bash
gh pr create --title "<TITLE>" --body "<BODY>" --draft
```

### 6. Output
After successful create/edit, output the PR URL so the user can click directly to it.
