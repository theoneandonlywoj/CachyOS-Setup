# Domain docs

This repo uses feature-scoped context files.

## Layout

```
/
├── _CONTEXT_<feature>.md # feature glossary and domain terms
├── _INTERVIEW_<feature>.md # feature grilling transcript
├── docs/
│   └── adr/              # architecture decision records
│       ├── 0001-...md
│       └── 0002-...md
└── ...
```

## Rules

- `_CONTEXT_<feature>.md` is a glossary only — no implementation details, no specs, no scratch notes.
- `_INTERVIEW_<feature>.md` records the questions and answers from the associated grilling session.
- A legacy root `CONTEXT.md` may be read for existing vocabulary, but feature workflows do not write to it.
- ADRs live in `docs/adr/` with sequential numbering.
- Create these files lazily: only when a term or decision actually crystallizes.
- Use the terms in `_CONTEXT_<feature>.md` consistently in all commands, specs, tickets, and code.
