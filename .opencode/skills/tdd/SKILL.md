---
name: tdd
description: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions red-green-refactor, or wants integration tests.
---

# Test-Driven Development

TDD is the red → green loop. Work in vertical slices: one seam, one test, one minimal implementation per cycle.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. A good test reads like a specification and survives refactors.

## Seams

A **seam** is the public boundary you test at. **Test only at pre-agreed seams.** Before writing any test, write down the seams and confirm them with the user.

## Anti-patterns

- **Implementation-coupled** — mocks internals, tests private methods, asserts through side channels.
- **Tautological** — expected value recomputed the way the code does.
- **Horizontal slicing** — writing all tests first, then all implementation.

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code to pass it.
- **One slice at a time.**
- **Refactoring is not part of the loop.** It belongs to review, not red-green implementation.
