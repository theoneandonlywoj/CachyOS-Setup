---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

For Phoenix, IEx, Bun, JavaScript, or TypeScript work with a user-facing change, use the `playwright-cli-testing` skill after the implementation slice is available. Run `/branching-scenarios` when exhaustive branch and old/new workflow evidence is required. Use `playwright-cli` for browser verification, leave scenario artifacts untracked, and stop at the skill's seed, manual-intervention, failure-recovery, and PR-review gates.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.
