---
name: speckit-specify
description: Define what you want to build — requirements and user stories
---

# speckit-specify

## When to Use

The user describes a feature, functionality, or application they want to build. They focus on the **what** and **why**, not the technical implementation.

## Prerequisites

1. Check if `.specify/` directory exists
2. If not, auto-run: `specify init . --ai opencode`
3. No other prerequisites required

## What It Does

1. Ensures Speckit is initialized in the project
2. Analyzes existing specs to determine the next feature number (e.g., 001, 002, etc.)
3. Creates a feature branch automatically
4. Generates `specs/XXX-feature-name/spec.md` using Speckit's spec template
5. Populates it with structured requirements, user stories, and acceptance criteria

## Speckit Command

```
/speckit.specify [feature description]
```

Example:
```
/speckit.specify Build an application that can help me organize my photos in separate photo albums. Albums are grouped by date and can be re-organized by dragging and dropping on the main page. Albums are never in other nested albums. Within each album, photos are previewed in a tile-like interface.
```

## Expected Output

- `specs/XXX-feature-name/spec.md` — Feature specification with:
  - Feature number and name
  - User stories
  - Acceptance criteria
  - Requirement completeness checklist
  - [NEEDS CLARIFICATION] markers for ambiguities

## Focus Areas

- **WHAT** users need and **WHY** they need it
- **Avoid** technical implementation details (tech stack, APIs, code structure)
- Mark all ambiguities with [NEEDS CLARIFICATION] rather than guessing
