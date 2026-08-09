---
description: Review changes since a fixed point along two axes — Standards and Spec — in parallel.
---

Use the `code-review` skill for this request. Read
`.claude/skills/code-review/SKILL.md` and follow its workflow exactly: pin
the fixed point the user names (commit, branch, tag, or merge-base), find
the originating spec and the repo's standards, then run the Standards and
Spec reviews as parallel sub-agents and present the two reports side by side
under `## Standards` and `## Spec`. The argument is the fixed point to
review from, e.g. `main`, `HEAD~5`, or a SHA.

User request:

$ARGUMENTS
