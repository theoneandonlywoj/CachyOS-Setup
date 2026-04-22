---
name: speckit-checklist
description: Generate custom quality checklists for requirements validation
---

# speckit-checklist

## When to Use

The user wants to validate requirements completeness, clarity, and consistency using structured checklists. Can be used before or after implementation.

## Prerequisites

1. Check if `.specify/` directory exists
2. If not, auto-run: `specify init . --ai opencode`
3. No other prerequisites required

## What It Does

1. Ensures Speckit is initialized in the project
2. Generates custom quality checklists that validate:
   - Requirements completeness
   - Requirements clarity
   - Requirements consistency
   - Testability of specifications
3. Provides a systematic review framework (like "unit tests for English")

## Speckit Command

```
/speckit.checklist
```

## Checklist Categories

The generated checklists typically cover:

- **Completeness**: Are all requirements defined without [NEEDS CLARIFICATION] markers?
- **Clarity**: Are requirements unambiguous and testable?
- **Consistency**: Do requirements contradict each other?
- **Traceability**: Can each requirement be traced to acceptance criteria?
- **Testability**: Can each requirement be verified through testing?

## Expected Output

- Custom quality checklist tailored to the project specifications
- Actionable items for improving specification quality
