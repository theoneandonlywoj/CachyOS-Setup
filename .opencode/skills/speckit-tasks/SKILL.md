---
name: speckit-tasks
description: Generate actionable task lists from implementation plans
---

# speckit-tasks

## When to Use

After an implementation plan exists (`plan.md`), and the user wants to generate a concrete, actionable task list for execution.

## Prerequisites

1. Check if `.specify/` directory exists
2. If not, auto-run: `specify init . --ai opencode`
3. Verify `specs/XXX-feature-name/plan.md` exists
4. If plan.md is missing, prompt user to run `/speckit.plan` first

## What It Does

1. Ensures Speckit is initialized in the project
2. Reads the implementation plan (`plan.md`)
3. Reads related design documents if present (`data-model.md`, `contracts/`, `research.md`)
4. Analyzes contracts, entities, and scenarios to derive specific tasks
5. Marks independent tasks with `[P]` for parallel execution
6. Outputs a structured task list

## Speckit Command

```
/speckit.tasks
```

## Expected Output

- `specs/XXX-feature-name/tasks.md` — Task list containing:
  - Specific, actionable implementation tasks
  - `[P]` markers for parallelizable tasks
  - Dependencies noted where applicable
  - Ready for execution by `/speckit.implement`

## Task Derivation

Tasks are derived from:
- API contracts in `contracts/` directory
- Data models in `data-model.md`
- Research findings in `research.md`
- Implementation phases defined in `plan.md`
