---
description: Turn the current conversation into a spec and publish it to GitHub Issues.
---

Turn the current conversation context and codebase understanding into a spec. Do NOT interview the user — synthesize what you already know.

## Process

1. Explore the repo if you haven't already. Read `_CONTEXT_<feature>.md` and relevant ADRs.
2. Sketch the seams at which the feature will be tested. Confirm them with the user before proceeding.
3. Write the spec using this template:

## Spec template

### Problem Statement
The problem from the user's perspective.

### Solution
The solution from the user's perspective.

### User Stories
A long, numbered list of user stories in the form:  
`As a <role>, I want <goal>, so that <benefit>`.

### Implementation Decisions
- Modules to build/modify
- Interfaces to modify
- Technical clarifications
- Architectural decisions
- Schema/API contracts
- Snippets from prototypes that encode decisions

Do NOT include specific file paths or code snippets unless they encode a decision more precisely than prose.

### Testing Decisions
- What makes a good test
- Which modules to test
- Prior art in the codebase

### Out of Scope
What this spec explicitly does not cover.

### Further Notes
Anything else.

4. Publish the spec to GitHub Issues with the `ready-for-agent` label.

## User request

$ARGUMENTS
