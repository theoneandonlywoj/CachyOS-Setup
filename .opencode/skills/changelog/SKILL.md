---
name: changelog
description: Generate a changelog from conventional commits. Use when you need to create or update a CHANGELOG.md from git commit history.
---

# changelog — Generate Changelog from Conventional Commits

Use this skill when you need to generate or update a changelog based on git commit history following conventional commit format.

## When to Use

- Releasing a new version
- Updating CHANGELOG.md
- Summarizing changes between releases
- Generating release notes

## Conventional Commit Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change that neither fixes nor adds |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependencies |
| `ci` | CI configuration |
| `chore` | Other changes |
| `revert` | Reverts a previous commit |

## Generate Changelog

### From all commits

```bash
git log --pretty=format:"%s" --reverse
```

### From a tag or commit range

```bash
git log v1.0.0..v2.0.0 --pretty=format:"%s"
```

### Group by type

```bash
git log --pretty=format:"%s" | grep -E "^(feat|fix|docs|refactor|perf|test|build|ci|chore|revert)"
```

## Changelog Format

Output as a grouped markdown list:

```markdown
# Changelog

## [Unreleased]

### Added
- New feature description (#123)

### Fixed
- Bug fix description (#456)

### Changed
- Existing feature update

### Deprecated
- Feature that will be removed

### Removed
- Removed feature

### Security
- Security improvement

### Infrastructure
- CI/CD changes
```

## Implementation

The AI will:
1. Run `git log` to fetch commit messages
2. Parse each commit for conventional format: `type(scope): message`
3. Group by type
4. Extract PR numbers from footers if present
5. Output as grouped markdown

## Tips

- Commits without conventional format appear under "Other changes"
- Include `(#issue)` or `(#pr)` in commits for automatic linking
- Use `BREAKING CHANGE:` in footer for breaking changes
- Squash merge commits to preserve meaningful messages

## Anti-patterns

- Do not include chore/merge commits in user-facing changelog
- Do not use vague messages like "update" or "fix stuff"
- Do not generate changelog without reviewing the output