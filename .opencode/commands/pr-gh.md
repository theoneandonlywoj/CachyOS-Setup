---
description: Create or update a GitHub PR from the PR template without writing PR.md
agent: build
subtask: true
---

Base branch: ${1:-main}

Create or update a pull request on GitHub for the current branch, without
writing a `PR.md` file.

## Instructions

1. Generate the PR description in memory (do **not** write any file):

   - If `.github/PULL_REQUEST_TEMPLATE.md` exists, use it as the structure. If
     it does not exist, use the sections below as the structure.
   - **Description** — Summarize the changes from the diff. Be specific about
     what was added, changed, or removed.
   - **Related Issues / Tickets** — Leave as "N/A" if none are referenced in
     commits.
   - **Author** — Extract from the git log author if possible (with @).
   - **Type of Change** — Check the appropriate box(es) based on the diff.
   - **Area Affected** — Check the appropriate box(es) based on which
     directories were changed.
   - **Knowledge Tags** — Suggest relevant comma-separated tags based on the
     content changed.

2. Check whether a PR already exists for the current branch:

   ```sh
   gh pr view --json number --jq .number
   ```

3. If a PR exists, update it with `gh pr edit`. If not, create it with
   `gh pr create`. Use the generated description as the body and the current
   branch name (or first commit subject) as the title. Use `--base` set to the
   base branch and `--head` set to the current branch.

4. Print the resulting PR URL.
