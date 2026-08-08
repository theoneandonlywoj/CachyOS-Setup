---
description: Sharpen an idea by interview, updating _CONTEXT_<feature>.md and ADRs as the domain model crystallizes.
---

Run a grilling session for the user's idea. Ask relentless, precise questions. The goal is to clarify what is being built, for whom, and why, while also building the project's domain model.

## Context file

Each grilling session works on a single feature and keeps its artifacts in two feature-scoped files:

- `_CONTEXT_<feature>.md` — the glossary-only record of resolved domain terms.
- `_INTERVIEW_<feature>.md` — the full transcript of questions asked and answers given.

Resolve `<feature>` from, in order: an existing `_CONTEXT_<feature>.md` file named in the request, the `$ARGUMENTS` argument, or the current feature branch name (slugified, lowercase, filesystem-safe).

If the request names an existing context file, including a legacy `CONTEXT.md`, use it as the starting glossary and continue asking questions. Infer the feature slug from the other argument or current feature branch, create `_CONTEXT_<feature>.md` when needed, and never write to the legacy file. If the feature already has a `_CONTEXT_<feature>.md` or `_INTERVIEW_<feature>.md`, read it and continue the session from where it left off.

## Process

1. Resolve the feature and locate its `_CONTEXT_<feature>.md` and `_INTERVIEW_<feature>.md`. Read them if they exist; otherwise create them lazily.
2. Read `docs/adr/` for decisions in the area you're touching. Also read a legacy root `CONTEXT.md` if it exists and use its vocabulary.
3. Ask the user one question at a time. Each question should surface a load-bearing fact: scope, constraint, actor, seam, or trade-off.
4. After every answer, append the question and answer to `_INTERVIEW_<feature>.md` before asking the next question.
5. When a domain term resolves, update `_CONTEXT_<feature>.md` inline with the [CONTEXT-FORMAT.md](../skills/domain-modeling/CONTEXT-FORMAT.md) format. Never treat the context file as a transcript or scratch pad.
6. When a hard-to-reverse, surprising, or genuinely trade-off decision lands, offer to record it as an ADR in `docs/adr/`.
7. Stop when the user has a clear enough idea to proceed to spec, tickets, or implementation.

## Review gate

Before any implementation step (`/to-spec`, `/to-tickets`, `/implement`, or writing code):

1. Confirm the session state is persisted: `_INTERVIEW_<feature>.md` has every answer, `_CONTEXT_<feature>.md` has every resolved term.
2. Ask the user to review `_CONTEXT_<feature>.md`, stating its exact filename and path.
3. Wait for explicit approval before continuing.
4. If the user edited the file, reread it and ask for approval again.

Do not proceed to implementation until the user has approved the reviewed context file.

## Rules

- Do not batch questions. One question, one answer.
- Do not write code during grilling. This is thinking, not building.
- Challenge fuzzy or overloaded terms. "Account" doing three jobs? Ask which one.
- Invent concrete edge-case scenarios to stress-test boundaries.
- If the code contradicts the user's description, surface it.

## User request

$ARGUMENTS
