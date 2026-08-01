---
name: codebase-design
description: Shared discipline and vocabulary for designing deep modules. Use when the conversation is about module shape, interfaces, seams, adapters, or leverage.
---

# Codebase Design

A shared vocabulary for designing deep modules: small interfaces, clean seams, and testability through the interface.

## Core terms

- **Module** — a unit of code with an interface and implementation.
- **Interface** — what callers depend on.
- **Depth** — the ratio of implementation complexity to interface complexity. Deep modules hide a lot behind a small interface.
- **Seam** — a place where you can change behavior without editing the caller.
- **Adapter** — one adapter is a hypothetical seam; two adapters make it real.
- **Leverage** — a small change that unlocks a lot of value.
- **Locality** — related concepts live close together.

## Principles

- **The deletion test:** Would deleting this module concentrate complexity or just move it?
- **The interface is the test surface.** Test through the public seam.
- **One adapter = hypothetical; two = real.** Don't generalize until you have two real consumers.
- **Make the change easy, then make the easy change.** Prefactor before the feature.

## When to use

Reach for this skill when designing or reviewing a module's shape. Other skills (`tdd`, `improve-codebase-architecture`) speak this vocabulary.
