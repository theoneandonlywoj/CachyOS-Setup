# ADR Format

Architecture Decision Records live in `docs/adr/` with sequential numbering.

## Template

```markdown
# ADR-<NNNN>: <Title>

## Status
Proposed / Accepted / Superseded by ADR-NNNN

## Context
What forced the decision.

## Decision
What was decided.

## Consequences
What becomes easier or harder as a result.
```

## Rules

Create an ADR only when all three are true:

1. Hard to reverse
2. Surprising without context
3. Result of a real trade-off

## File naming

```
docs/adr/0001-event-sourced-orders.md
docs/adr/0002-postgres-for-write-model.md
```
