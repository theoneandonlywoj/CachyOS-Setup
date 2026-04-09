---
name: pr
description: Generate a pull request description from git diff and commit history against a target branch
---

# Generate Pull Request Description

Generate a PR description based on:
- Current branch vs target branch (argument)
- Commit messages on current branch
- Changed files and their purpose

## Context

- Current branch: `!git branch --show-current`
- Diff target: `$ARGUMENTS` (defaults to main if not provided)
- GitHub user: `!gh api /user --jq '.login'`
- Recent commits: `!git log $ARGUMENTS..HEAD --oneline 2>/dev/null || git log HEAD~10..HEAD --oneline`

## Template

Use `.github/PULL_REQUEST_TEMPLATE.md` structure:
- Summary (from commits)
- Changes (from diff)
- Testing: User + System sections
- Related Issues

No attribution footer.
