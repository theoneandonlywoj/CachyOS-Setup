---
description: Generate a git commit command from staged changes.
subtask: true
---

Generate a `git commit` command for the currently staged changes.

## Instructions

1. Inspect the staged changes:
   - Run `git diff --cached --stat` to see which files are staged.
   - Run `git diff --cached` to see the actual diff.

2. Determine the Conventional Commit type from the changes. Use the most specific type that applies:
   - `feat` — new feature, script, or command
   - `fix` — bug fix or correction
   - `docs` — documentation or README changes only
   - `style` — formatting, whitespace, linting, semicolons, cosmetic changes
   - `refactor` — code change that neither fixes a bug nor adds a feature
   - `test` — adding or updating tests
   - `chore` — tooling, dependencies, build process, config updates
   - `other` — removals, cleanups, reorganization, or miscellaneous changes

3. Write a concise commit message in imperative mood (max 50 characters for the subject line).
   - If multiple distinct areas are affected, use a comma-separated list or a short scope.
   - Do not include the issue/PR number unless one is referenced in the staged changes.

4. Output the full command in exactly this format:

   ```sh
   git commit -m "(<type>): <message>"
   ```

5. Do **not** execute the command. Only print it and ask the user if they want to run it.
