# Agent skills

This repo is configured for the engineering skills. The files below tell the agent how to read and write project metadata.

## Issue tracker

Issues live in **GitHub Issues**. See `docs/agents/issue-tracker.md`.

## Triage labels

Default canonical labels are used. See `docs/agents/triage-labels.md`.

## Domain docs

Single-context layout with `CONTEXT.md` and `docs/adr/`. See `docs/agents/domain.md`.

## Skills

- `/ask-woj` — which skill or flow fits your situation
- `/grill-with-docs` — sharpen an idea by interview, updating `CONTEXT.md` and ADRs
- `/triage` — move issues through triage states
- `/improve-codebase-architecture` — scan codebase, present HTML report, grill through a candidate
- `/to-spec` — turn conversation into a spec
- `/to-tickets` — break spec into tracer-bullet tickets
- `/implement` — build from spec/tickets
- `/wayfinder` — chart decision-ticket map for foggy work

## Model-invoked skills

These are auto-reachable when the conversation matches their triggers:

- `prototype` — throwaway code to answer a design question
- `diagnosing-bugs` — disciplined bug diagnosis loop
- `research` — background research with cited output
- `tdd` — red-green-refactor test-driven development
- `domain-modeling` — sharpen project vocabulary
- `codebase-design` — deep-module design vocabulary
- `code-review` — two-axis review (Standards + Spec)
- `resolving-merge-conflicts` — hunk-by-hunk conflict resolution
