---
name: domain-modeling
description: Build and sharpen a project's domain model. Use when the user wants to pin down domain terminology, record an architectural decision, or when another skill needs to maintain the domain model.
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the active discipline: challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise.

## File structure

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-...
│   └── 0002-...
└── ...
```

Create files lazily — only when you have something to write.

## During the session

- **Challenge against the glossary.** If a term conflicts with `CONTEXT.md`, call it out.
- **Sharpen fuzzy language.** Propose precise canonical terms for overloaded words.
- **Discuss concrete scenarios.** Invent edge cases that probe boundaries.
- **Cross-reference with code.** If the code contradicts the user, surface it.
- **Update `CONTEXT.md` inline.** Don't batch. Capture terms as they resolve.
- **Offer ADRs sparingly.** Only when the decision is hard to reverse, surprising without context, and the result of a real trade-off.

`CONTEXT.md` must contain no implementation details. It is a glossary and nothing else.
