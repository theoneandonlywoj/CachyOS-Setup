---
description: Implement the work described by a spec or set of tickets.
---

Implement the work described by the user. Use the spec, tickets, or current conversation as the source of truth.

## Process

1. Read the spec or tickets. If none, use the conversation context.
2. Read `CONTEXT.md` and relevant ADRs.
3. Drive the implementation using the `tdd` skill where seams are pre-agreed.
4. Run typechecking or equivalent validation regularly.
5. Run single test files regularly.
6. Run the full test suite once at the end.
7. Use the `code-review` skill to review the diff.
8. Commit the work to the current branch.

## Rules

- One vertical slice at a time.
- Do not scope creep.
- Keep commits small and meaningful.
- Do not run `git push` unless the user explicitly asks.

## User request

$ARGUMENTS
