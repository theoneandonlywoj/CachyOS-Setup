---
name: handoff
description: Prepare session summary for next session. Use at end of session to document state.
---

# handoff — Session Handoff

Use when ending a session to document the current state for the next session.

## When to Use

- At the end of a working session
- When switching to a different task
- Before a break or meeting
- When handing off to another developer

## What It Does

Generates a structured summary containing:

1. **Current State** — What was completed
2. **Pending Decisions** — Open questions, trade-offs to consider
3. **Next Steps** — Concrete actions to continue
4. **Context** — Relevant links, ticket numbers, notes

Writes to `SESSION.md` in the repo root.

## Usage

/handoff

## Tips

- Be specific about what is done vs. what remains
- Include file paths and line numbers when relevant
- Note any temporary workarounds or hacks
- List dependencies that need to be resolved first

## Anti-patterns

- Do not write vague summaries like "working on feature X"
- Do not skip listing blocked items
- Do not forget to include ticket/issue references
