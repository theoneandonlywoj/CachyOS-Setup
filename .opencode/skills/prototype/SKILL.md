---
name: prototype
description: Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like.
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape.

## Pick a branch

Identify which question is being answered:

- **"Does this logic / state model feel right?"** — Build a tiny interactive terminal app that pushes the state machine through hard cases.
- **"What should this look like?"** — Generate several radically different UI variations on a single route, switchable via URL param or floating bar.

If the question is ambiguous and the user isn't reachable, default to whichever branch matches the surrounding code: backend module → logic; page/component → UI. State the assumption.

## Rules

1. **Throwaway from day one.** Name it so a casual reader can tell it's a prototype.
2. **One command to run.** Use the project's task runner.
3. **No persistence by default.** State lives in memory.
4. **Skip the polish.** No tests, no error handling beyond runnable, no abstractions.
5. **Surface the state.** After every action, print or render the full relevant state.
6. **Capture it when done.** Fold validated decisions into real code. Capture the prototype and verdict in the issue or a throwaway branch.
