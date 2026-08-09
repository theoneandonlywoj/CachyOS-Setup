---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.
disable-model-invocation: true
---

Run a `/grilling` session, using the `/domain-modeling` skill. The grilling skill owns the questioning rule — ask the whole frontier in one round, numbered, with a recommended answer each — and the domain-modeling skill owns the glossary and ADR discipline.

## Exit condition

Grilling ends when its design-tree frontier is empty. For this flow that is necessary but not sufficient: stop only when the user has a clear enough idea to proceed to `/to-spec`, `/to-tickets`, or `/implement`. An empty frontier means there are no more settled-prerequisite questions to ask; it does not by itself mean the user is ready to move from thinking to building. Confirm proceeding-readiness with the user before ending the session.