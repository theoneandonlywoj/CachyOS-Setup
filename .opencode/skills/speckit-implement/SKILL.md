---
name: speckit-implement
description: Execute all tasks to build the feature according to the plan
---

# speckit-implement

## When to Use

After a task list exists (`tasks.md`), and the user is ready to execute implementation and build the feature.

## Prerequisites

1. Check if `.specify/` directory exists
2. If not, auto-run: `specify init . --ai opencode`
3. Verify `specs/XXX-feature-name/tasks.md` exists
4. If tasks.md is missing, prompt user to run `/speckit.tasks` first

## What It Does

1. Ensures Speckit is initialized in the project
2. Reads `tasks.md` to understand the implementation work
3. Executes all tasks in order, respecting dependencies and parallel markers
4. Generates code from specifications following constitutional principles:
   - Test-first (write tests before implementation)
   - Library-first (modular design)
   - CLI interface (text in/out)
5. Creates source files, tests, and documentation

## Speckit Command

```
/speckit.implement
```

## Execution Approach

1. **Test-First**: Write tests that define expected behavior before implementation
2. **Contract-Driven**: Implement to satisfy contracts defined in `contracts/`
3. **Parallel Execution**: Execute independent tasks marked `[P]` concurrently
4. **Constitutional Compliance**: Follow gates from the constitution during implementation

## Expected Output

- Source code files in `src/` or `lib/`
- Test files
- Updated documentation
- All code traceable back to specifications
