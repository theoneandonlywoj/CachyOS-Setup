---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs and performance regressions. Use when the user says diagnose/debug this, or reports something broken/throwing/failing/slow.
---

# Diagnosing Bugs

A discipline for hard bugs. Skip phases only when explicitly justified.

When exploring the codebase, read `CONTEXT.md` and check relevant ADRs.

## Phase 1 — Build a feedback loop

This is the skill. Without a tight pass/fail signal, no amount of code reading will save you.

Construct the loop in this order:

1. Failing test at the right seam
2. Curl / HTTP script against a dev server
3. CLI invocation with a fixture
4. Headless browser script
5. Replay a captured trace
6. Throwaway harness
7. Property / fuzz loop
8. Bisection harness
9. Differential loop
10. HITL bash script

Tighten it: faster, sharper signal, more deterministic.

For non-deterministic bugs, raise the reproduction rate until it's debuggable.

If you genuinely cannot build a loop, stop and ask the user for access, artifacts, or permission to instrument production.

**Completion criterion:** you can name one command, already run, that is red-capable, deterministic, fast, and agent-runnable.

## Phase 2 — Reproduce + minimise

Run the loop. Confirm it produces the user's exact symptom. Shrink the repro to the smallest scenario that still goes red. Every remaining element must be load-bearing.

## Phase 3 — Hypothesise

Generate 3–5 ranked, falsifiable hypotheses before testing any. Format: "If X is the cause, then Y will make the bug disappear / worse." Show the list to the user.

## Phase 4 — Instrument

Each probe maps to a specific prediction. Change one variable at a time. Prefer debugger/REPL, then targeted logs. Tag every debug log with a unique prefix like `[DEBUG-a4f2]`.

For performance regressions: measure first, fix second.

## Phase 5 — Fix + regression test

Write the regression test before the fix, but only at a correct seam — one that exercises the real bug pattern as it occurs at the call site. If no correct seam exists, that itself is the finding: flag it for `improve-codebase-architecture`.

## Phase 6 — Cleanup + post-mortem

- Original repro no longer reproduces
- Regression test passes
- All `[DEBUG-...]` instrumentation removed
- Throwaway prototypes deleted
- Correct hypothesis stated in commit message

Then ask: what would have prevented this bug? If the answer is architectural, hand off to `improve-codebase-architecture`.
