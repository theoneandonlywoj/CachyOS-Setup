---
name: speckit-clarify
description: Clarify underspecified areas in requirements
---

# speckit-clarify

## When to Use

The user wants to clarify, refine, or fill in gaps in underspecified requirements. Recommended to run before `/speckit.plan` when spec contains [NEEDS CLARIFICATION] markers.

## Prerequisites

1. Check if `.specify/` directory exists
2. If not, auto-run: `specify init . --ai opencode`
3. No other prerequisites required

## What It Does

1. Ensures Speckit is initialized in the project
2. Identifies [NEEDS CLARIFICATION] markers in spec documents
3. Guides interactive dialogue to resolve ambiguities
4. Updates specifications with clarified requirements
5. Ensures all ambiguities are resolved before moving to planning

## Speckit Command

```
/speckit.clarify
```

## Recommended Workflow

1. Run `/speckit.specify` to create initial specification
2. Run `/speckit.clarify` to resolve any [NEEDS CLARIFICATION] markers
3. Run `/speckit.plan` with clarified requirements

## Expected Output

- Updated `specs/XXX-feature-name/spec.md` with ambiguities resolved
- Clear acceptance criteria ready for implementation planning
