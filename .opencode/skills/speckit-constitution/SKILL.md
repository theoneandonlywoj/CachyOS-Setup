---
name: speckit-constitution
description: Create or update project governing principles and development guidelines
---

# speckit-constitution

## When to Use

The user wants to establish or modify the project's governing principles, development guidelines, or architectural standards that will guide all subsequent development.

## Prerequisites

1. Check if `.specify/` directory exists
2. If not, auto-run: `specify init . --ai opencode`
3. No other prerequisites required

## What It Does

1. Ensures Speckit is initialized in the project
2. Executes the constitution workflow using Speckit's `/speckit.constitution` command
3. Creates or updates `memory/constitution.md` with project principles

## Speckit Command

```
/speckit.constitution Create principles focused on code quality, testing standards, user experience consistency, and performance requirements
```

Or with custom principles:
```
/speckit.constitution [user-provided principles]
```

## Expected Output

- `memory/constitution.md` — Project governing principles and development guidelines

## Constitution Template Location

The default constitution template is sourced from Speckit's templates:
```
https://github.com/github/spec-kit/blob/main/templates/constitution-template.md
```

The template includes sections for:
- Core Principles (Library-First, CLI Interface, Test-First, Integration Testing, Observability, etc.)
- Additional Constraints
- Development Workflow
- Governance rules

## Customizing the Constitution

To customize the default template for your project:

1. **In-place editing**: After `/speckit.constitution` creates `memory/constitution.md`, edit that file directly

2. **Project-local override**: Create a file at:
   ```
   .specify/templates/overrides/constitution/constitution.md
   ```
   This overrides the default template for this project only.

3. **Amendment process**: The constitution should document rationale for changes, require approval, and include a migration plan

For the full template structure, see:
https://github.com/github/spec-kit/blob/main/templates/constitution-template.md
