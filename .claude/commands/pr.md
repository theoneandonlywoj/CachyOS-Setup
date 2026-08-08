---
description: Generate a PR description from the PR template
---

Base branch: ${1:-main}

If `.github/PULL_REQUEST_TEMPLATE.md` exists, use it as the structure. If it
does not exist, use the sections below as the structure.

Using the PR template structure above, generate a complete PR description. Fill in all sections:

1. **Description** — Summarize the changes from the diff. Be specific about what was added, changed, or removed.
2. **Related Issues / Tickets** — Leave as "N/A" if none are referenced in commits.
3. **Author** — Extract from the git log author if possible (with @), otherwise leave placeholder.
4. **Type of Change** — Check the appropriate box(es) based on the diff.
5. **Area Affected** — Check the appropriate box(es) based on which directories were changed.
6. **Knowledge Tags** — Suggest relevant comma-separated tags based on the content changed.

Write the completed PR description to a file named `PR.md` in the repo root. The output must be in markdown format ready to paste into a GitHub PR body.
