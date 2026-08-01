---
name: resolving-merge-conflicts
description: Resolve an in-progress git merge or rebase conflict hunk by hunk, tracing each side's intent to its primary source. Use when the user is in a merge conflict.
---

# Resolving Merge Conflicts

Work through an in-progress git merge or rebase conflict hunk by hunk. Resolve by intent traced to each side's primary source.

## Process

1. Confirm the operation: `git status`.
2. For each conflicted file:
   - Read the file and identify the conflict markers.
   - Determine what each side was trying to do.
   - Trace each side to its primary source: commit message, PR description, issue, spec.
   - Pick the side that matches the intended outcome, or synthesize both if both are partially correct.
3. Remove conflict markers.
4. Run the relevant tests or validation.
5. Continue the merge or rebase.

## Rules

- **Never `--abort`** unless the user explicitly asks.
- **No silent resolution.** State the rationale for each hunk.
- **Prefer the side with the clearer intent.** If both are unclear, ask the user.
- **Run tests after each file or batch.** Don't wait until the end.
- If a conflict is large, process it in small batches.

## When to ask

Ask the user when:
- Both sides conflict on a fundamental design decision
- The intended outcome is not documented
- Resolving the conflict would require significant refactoring
