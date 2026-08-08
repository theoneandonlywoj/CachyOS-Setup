---
description: Break a spec, plan, or conversation into tracer-bullet tickets with blocking edges.
---

Break a spec, plan, or the current conversation into a set of tracer-bullet tickets, each declaring the tickets that block it.

## Process

1. Gather context from the conversation or from a spec passed by the user.
2. Explore the codebase if needed. Use `CONTEXT.md` vocabulary and respect ADRs.
3. Draft vertical slices:
   - Each slice cuts a narrow but complete path through every layer
   - A completed slice is demoable or verifiable on its own
   - Each slice fits in a single fresh context window
4. Identify prefactoring opportunities. "Make the change easy, then make the easy change."
5. For wide refactors, use expand–contract: add the new form beside the old, migrate call sites, then delete the old.
6. Present a numbered list to the user:
   - Title
   - Blocked by
   - What it delivers
7. Ask:
   - Is the granularity right?
   - Are the blocking edges correct?
   - Should any tickets be merged or split?
8. Iterate until the user approves.
9. Publish to GitHub Issues in dependency order (blockers first). Apply the `ready-for-agent` label.

## Ticket template

```markdown
## What to build
...

## Acceptance criteria
- Criterion 1
- Criterion 2

## Blocked by
- #...

## Status
ready-for-agent
```

Do not close or modify the parent issue.

## User request

$ARGUMENTS
