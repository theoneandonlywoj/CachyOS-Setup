---
name: review
description: Run code review on changed files. Use when reviewing unstaged changes or preparing a PR.
---

# review — Code Review

Use when you need to review code changes for quality, correctness, and style.

## When to Use

- Before committing changes
- Before creating a pull request
- When reviewing another developer's changes
- During code handoff

## What It Does

This skill uses the `reviewer` subagent to analyze unstaged changes and provide feedback on:

- **Correctness** — Bugs, logic errors, edge cases
- **Style** — Following project conventions
- **Security** — Potential vulnerabilities
- **Performance** — Inefficiencies or N+1 queries
- **Readability** — Clear naming, appropriate comments

## Usage

/review

## Review Focus Areas

1. **Business Logic** — Are the changes doing what they should?
2. **Edge Cases** — What happens with empty input, nil values, concurrent access?
3. **Test Coverage** — Are new paths covered by tests?
4. **Documentation** — Are public APIs documented?

## Anti-patterns

- Do not approve code without understanding it
- Do not focus only on style — correctness first
- Do not skip security-sensitive code paths
