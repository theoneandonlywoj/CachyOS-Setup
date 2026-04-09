---
name: permissions-update
description: Extract approved permissions from OpenCode session history and merge them into the global config so you stop being prompted for already-approved tools.
---

# permissions-update — Sync session permissions to global config

Scans the OpenCode SQLite database for tool calls that were approved (completed)
across sessions, extracts command and file patterns, and merges them into
`~/.config/opencode/opencode.json` so you are not repeatedly prompted.

## When to Use

- You are tired of approving the same bash commands or file edits every session
- After a productive session where you approved many new tool patterns
- Periodically to keep your permission config up to date

## Usage

```
/permissions-update
```

Or ask: "update my opencode permissions from session history"

## How It Works

1. Reads all completed tool calls from `~/.local/share/opencode/opencode.db`
2. Extracts patterns:
   - **bash**: command prefixes (e.g. `mix *`, `git *`)
   - **edit**: file extension globs (e.g. `**/*.ex`, `**/*.heex`)
   - **read**: file extension globs
   - **glob**: directory-based globs
3. Shows a diff of what will be added
4. Backs up existing config before writing
5. Merges new `allow` rules — never overrides existing `ask` or `deny` rules

## Safety

- Existing `deny` and `ask` rules are never overridden
- A timestamped backup is created before any config change
- Dangerous commands (`rm -rf`, `git push --force`, `git reset --hard`, `sudo`) are never auto-allowed
- You are shown the diff and asked to confirm before applying

## Files

- **Skill**: `.opencode/skills/permissions-update/SKILL.md`
- **Script**: `.opencode/skills/permissions-update/update_permissions.py`
- **Command**: `.opencode/commands/permissions-update.md`
- **Global config**: `~/.config/opencode/opencode.json`
- **Session DB**: `~/.local/share/opencode/opencode.db`
