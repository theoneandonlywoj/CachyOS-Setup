---
description: Scan the codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one the user picks.
---

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

## Process

1. **Scope before scanning.** Read `git log --oneline` to find hot spots. If the user named a direction, use it.
2. Read `CONTEXT.md` and relevant ADRs in `docs/adr/`.
3. Use the `task` tool with `subagent_type=explore` to walk the codebase. Look for:
   - Shallow modules (interface nearly as complex as implementation)
   - Tight coupling across seams
   - Missing locality (bugs hide in how functions are called, not the functions themselves)
   - Untested or hard-to-test surfaces
4. Apply the **deletion test** to suspected shallow modules.
5. Write a self-contained HTML report to the OS temp directory.
   - Use Tailwind via CDN and Mermaid via CDN where a graph helps.
   - For each candidate: Files, Problem, Solution, Benefits, Before/After diagram, and a `Strong` / `Worth exploring` / `Speculative` badge.
   - End with a Top recommendation section.
6. Open the report for the user and tell them the absolute path.
7. Ask: "Which of these would you like to explore?"
8. Once picked, run the `domain-modeling` skill to keep vocabulary current, and the `codebase-design` skill to reason through the module shape.

## User request

$ARGUMENTS
