# Issue tracker

Issues for this repo are tracked in **GitHub Issues**.

- Repository: detected from `git remote -v`.
- CLI tool: `gh` (GitHub CLI).
- External pull requests are **not** treated as a request surface for triage. Flip the flag below if you want that.

## Reading an issue

```bash
gh issue view <number> --json number,title,body,state,labels,author,createdAt,updatedAt,comments
```

## Reading a PR

```bash
gh pr view <number> --json number,title,body,state,labels,author,createdAt,updatedAt,comments
```

```bash
gh pr diff <number>
```

## Listing issues

```bash
# Open issues
gh issue list --state open

# By label
gh issue list --label "needs-triage"
```

## Creating issues

```bash
gh issue create --title "..." --body "..." --label "ready-for-agent"
```

## Comments

```bash
gh issue comment <number> --body "..."
gh pr comment <number> --body "..."
```

## Labels

Use the canonical label vocabulary from `docs/agents/triage-labels.md`.

```bash
gh issue edit <number> --add-label "ready-for-agent" --remove-label "needs-triage"
```

## Blocking edges

GitHub supports `gh issue edit --add-linked-issue <number>` or sub-issues natively in the UI. Use the project's existing convention for blocking relationships.

## Flags

- **PRs as request surface:** `false`
