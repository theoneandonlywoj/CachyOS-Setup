---
description: Chart a huge, foggy effort as a shared map of decision tickets on GitHub Issues.
---

Plan a huge chunk of work — more than one session can hold — as a shared map of decision tickets on GitHub Issues. Resolve them one at a time until the way to the destination is clear.

## Plan, don't do

Each ticket resolves a decision, not a deliverable. The map is done when the way is clear.

## The map

The map is a single GitHub issue labelled `wayfinder:map`. Its tickets are child issues.

### Map body

```markdown
## Destination
<what reaching the end looks like>

## Notes
<domain, skills to consult, standing preferences>

## Decisions so far
- [<ticket title>](link) — one-line gist

## Not yet specified
<suspected questions that are not sharp enough to ticket yet>

## Out of scope
<work ruled beyond the destination>
```

## Ticket types

- `wayfinder:research` — background reading (AFK)
- `wayfinder:prototype` — throwaway artifact to react to (HITL)
- `wayfinder:grilling` — conversation to sharpen a decision (HITL)
- `wayfinder:task` — manual work that unblocks a decision (HITL or AFK)

## Process

1. **Chart the map.** Name the destination. Run the `domain-modeling` skill. Map the frontier breadth-first. Create the map issue. Create the tickets you can specify now. Wire blocking edges in a second pass. Fire research subagents.
2. **Work through the map.** Load the map. Pick the next frontier ticket (or use the one the user named). Claim it. Resolve it. Record the answer, close the ticket, and append to the map's Decisions-so-far.
3. Graduate fog into new tickets as decisions land. Rule tickets out of scope if they sit past the destination.

## User request

$ARGUMENTS
