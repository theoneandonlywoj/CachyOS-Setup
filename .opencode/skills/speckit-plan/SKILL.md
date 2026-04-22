---
name: speckit-plan
description: Create technical implementation plans with chosen tech stack
---

# speckit-plan

## When to Use

After a feature specification exists (`spec.md`), and the user wants to define the technical architecture, technology choices, and implementation approach.

## Prerequisites

1. Check if `.specify/` directory exists
2. If not, auto-run: `specify init . --ai opencode`
3. Verify `specs/XXX-feature-name/spec.md` exists
4. If spec.md is missing, prompt user to run `/speckit.specify` first

## What It Does

1. Ensures Speckit is initialized in the project
2. Reads and analyzes the feature specification (`spec.md`)
3. Ensures alignment with project constitution and architectural principles
4. Creates a comprehensive implementation plan with:
   - Technology choices and rationale
   - Data models
   - API contracts
   - Project structure
   - Quickstart guide

## Speckit Command

```
/speckit.plan [tech stack and architecture details]
```

Example:
```
/speckit.plan The application uses Vite with minimal number of libraries. Use vanilla HTML, CSS, and JavaScript as much as possible. Images are not uploaded anywhere and metadata is stored in a local SQLite database.
```

## Expected Output

- `specs/XXX-feature-name/plan.md` — Implementation plan
- `specs/XXX-feature-name/data-model.md` — Data model definitions
- `specs/XXX-feature-name/contracts/` — API contracts
- `specs/XXX-feature-name/quickstart.md` — Key validation scenarios
- `specs/XXX-feature-name/research.md` — Technology research notes

## Constitutional Compliance

The plan template enforces architectural principles through pre-implementation gates:
- Simplicity Gate — Using ≤3 projects, no future-proofing
- Anti-Abstraction Gate — Using framework directly, single model representation
- Integration-First Gate — Contracts defined, contract tests written
