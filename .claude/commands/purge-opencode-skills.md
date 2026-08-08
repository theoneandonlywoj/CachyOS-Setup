---
description: Remove every skill from OpenCode's global skills directory while preserving the rest of ~/.config/opencode.
---

Run `make purge-opencode-skills` from the repository root.

The target must stop with an error if `~/.config/opencode/skills` is missing or
is a symlink. It removes only the contents of that directory, never
`~/.config/opencode`.

$ARGUMENTS
