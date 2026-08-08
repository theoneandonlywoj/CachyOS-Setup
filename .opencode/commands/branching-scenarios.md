---
description: Analyze every reachable branch of an implemented Phoenix or JavaScript feature with Playwright CLI and document the workflow, evidence, and results.
agent: build
---

Use the `playwright-cli-testing` skill for this entire command.

Analyze the implemented target feature on the current feature or ticket branch. Derive the short feature slug from the branch name and write the untracked artifact to `_scenarios_<feature-slug>/`.

Feature or route hints supplied by the user:

$ARGUMENTS

Follow the skill's complete workflow. Do not merely describe a plan: inspect the target repository, compare `main`/`master` with committed plus staged code, check prerequisites and server reachability, prepare and approve seed data, execute every scenario with `playwright-cli` against the new workflow, capture evidence, document uncovered branches and findings, validate Mermaid graphs, and create `_PR_<feature-slug>.md` for review. Stop for the user at every required approval or manual-intervention gate.
