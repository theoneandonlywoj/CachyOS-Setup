---
description: Remove every skill from Claude Code's global skills directory while preserving the rest of ~/.claude.
---

Run `make purge-claude-skills` from the repository root.

The target must stop with an error if `~/.claude/skills` is missing or is a
symlink. It removes only the contents of that directory, never `~/.claude`.

$ARGUMENTS
