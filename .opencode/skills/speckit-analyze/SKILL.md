---
name: speckit-analyze
description: Cross-artifact consistency and coverage analysis
---

# speckit-analyze

## When to Use

After `/speckit.tasks` but before `/speckit.implement`. Performs cross-artifact consistency and coverage analysis to validate the specification, plan, and tasks are aligned.

## Prerequisites

1. Check if `.specify/` directory exists
2. If not, auto-run: `specify init . --ai opencode`
3. Verify `specs/XXX-feature-name/tasks.md` exists
4. If tasks.md is missing, prompt user to run `/speckit.tasks` first

## What It Does

1. Ensures Speckit is initialized in the project
2. Reads all artifact files: `spec.md`, `plan.md`, `tasks.md`, `data-model.md`, contracts
3. Performs cross-artifact consistency analysis:
   - Requirements coverage (all spec items have corresponding tasks)
   - No contradictions between artifacts
   - Completeness check for acceptance criteria
4. Reports findings and suggests fixes

## Speckit Command

```
/speckit.analyze
```

## Recommended Workflow

1. `/speckit.specify` → Create specification
2. `/speckit.plan` → Create implementation plan
3. `/speckit.tasks` → Create task list
4. `/speckit.analyze` → Validate consistency
5. `/speckit.implement` → Execute implementation

## Expected Output

- Analysis report identifying:
  - Gaps in requirements coverage
  - Contradictions between artifacts
  - Missing acceptance criteria
  - Recommendations for fixes
