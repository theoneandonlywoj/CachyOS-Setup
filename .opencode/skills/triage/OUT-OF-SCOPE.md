# Out-of-Scope Knowledge Base

The `.out-of-scope/` directory stores reasons why specific enhancement requests were rejected. It is only for rejected enhancements, not built features or rejected bugs.

## When to write

Create an entry when:

- An enhancement request is rejected
- The reason would help future explorers avoid re-suggesting the same thing

## File naming

Use a slug derived from the request:

```
.out-of-scope/<feature-slug>.md
```

## Template

```markdown
# <Request title>

## Summary
One-line summary of the rejected request.

## Reason for rejection
Why it was rejected.

## Related issue
#<number>
```

## When not to write

- Already-implemented requests. Point to where the feature lives instead.
- Rejected bugs. Close with a polite explanation; don't add to this KB.
- Ephemeral reasons ("not worth it right now").
