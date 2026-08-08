# Agent skills

This repo is configured for the engineering skills. The files below tell the agent how to read and write project metadata.

## Issue tracker

Issues live in **GitHub Issues**. See `docs/agents/issue-tracker.md`.

## Triage labels

Default canonical labels are used. See `docs/agents/triage-labels.md`.

## Domain docs

Feature-scoped glossaries use `_CONTEXT_<feature>.md`; legacy `CONTEXT.md` remains readable. See `docs/agents/domain.md` and `docs/agents/intermediate-artifacts.md`.

## User-invoked skills

These workflows run when explicitly selected by the user:

- `/ask-woj` — route a situation to the best workflow
- `/ask-matt` — upstream router for the full engineering and productivity set
- `/grill-with-docs` — sharpen an idea while updating `_CONTEXT_<feature>.md`, `_INTERVIEW_<feature>.md`, and ADRs
- `/grill-me` — interview a plan without writing repository context
- `/triage` — move incoming issues through the triage state machine
- `/setup-matt-pocock-skills` — configure issue tracker and domain-doc conventions
- `/to-spec` — turn a conversation into a spec
- `/to-tickets` — break a spec into tracer-bullet tickets
- `/implement` — build work from a spec or tickets
- `/wayfinder` — chart decision tickets for a large, unclear effort
- `/handoff` — write a portable handoff for another session or harness
- `/teach` — teach a concept over multiple sessions
- `/to-questionnaire` — capture questions for a person who must decide

## Model-invoked skills

These are auto-reachable when the conversation matches their triggers:

- `grilling` — the interview primitive used by planning workflows
- `prototype` — throwaway code to answer a design question
- `diagnosing-bugs` — disciplined bug diagnosis loop
- `research` — background research with cited output
- `tdd` — red-green-refactor development
- `domain-modeling` — sharpen project vocabulary
- `codebase-design` — deep-module design vocabulary
- `code-review` — two-axis Standards and Spec review
- `resolving-merge-conflicts` — hunk-by-hunk conflict resolution
- `improve-codebase-architecture` — scan for deepening opportunities
- `wizard` — generate a repeatable human-in-the-loop setup script
- `wait-what` — re-explain a message that did not land
- `writing-for-agents` — guidance for agent-facing documents
