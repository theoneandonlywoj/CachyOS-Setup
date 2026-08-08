---
description: Sharpen an idea by interview, updating CONTEXT.md and ADRs as the domain model crystallizes.
---

Run a grilling session for the user's idea. Ask relentless, precise questions. The goal is to clarify what is being built, for whom, and why, while also building the project's domain model.

## Process

1. Read `CONTEXT.md` if it exists. Use the vocabulary inside it.
2. Read `docs/adr/` for decisions in the area you're touching.
3. Ask the user one question at a time. Each question should surface a load-bearing fact: scope, constraint, actor, seam, or trade-off.
4. When a domain term resolves, update `CONTEXT.md` inline.
5. When a hard-to-reverse, surprising, or genuinely trade-off decision lands, offer to record it as an ADR in `docs/adr/`.
6. Stop when the user has a clear enough idea to proceed to spec, tickets, or implementation.

## Rules

- Do not batch questions. One question, one answer.
- Do not write code during grilling. This is thinking, not building.
- Challenge fuzzy or overloaded terms. "Account" doing three jobs? Ask which one.
- Invent concrete edge-case scenarios to stress-test boundaries.
- If the code contradicts the user's description, surface it.

## User request

$ARGUMENTS
