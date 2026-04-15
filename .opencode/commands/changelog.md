# changelog — Generate changelog from git commits

Generate a changelog grouped by conventional commit types.

## Usage

```
/changelog [from_ref] [to_ref]
```

Arguments (optional):
- `from_ref` — Starting commit/tag (default: last tag or beginning of history)
- `to_ref` — Ending commit/tag (default: HEAD)

## Examples

```
/changelog                    # All commits
/changelog v1.0.0             # Commits since v1.0.0
/changelog v1.0.0 v2.0.0     # Commits from v1.0.0 to v2.0.0
/changelog HEAD~20..HEAD      # Last 20 commits
```

## Output

Generates a grouped markdown changelog:

```markdown
# Changelog

## [Unreleased] / [Version]

### Added
- Feature descriptions

### Fixed
- Bug fix descriptions

### Changed
- Existing feature updates
...
```

## Notes

- Uses conventional commit format: `type(scope): message`
- Extracts PR/issue references from commit footers
- Reviews output before committing to CHANGELOG.md

Use the `changelog` skill for detailed formatting guidance.