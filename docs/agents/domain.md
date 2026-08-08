# Domain docs

This repo uses a single-context layout.

## Layout

```
/
├── CONTEXT.md          # project glossary and domain terms
├── docs/
│   └── adr/              # architecture decision records
│       ├── 0001-...md
│       └── 0002-...md
└── ...
```

## Rules

- `CONTEXT.md` is a glossary only — no implementation details, no specs, no scratch notes.
- ADRs live in `docs/adr/` with sequential numbering.
- Create these files lazily: only when a term or decision actually crystallizes.
- Use the terms in `CONTEXT.md` consistently in all commands, specs, tickets, and code.
