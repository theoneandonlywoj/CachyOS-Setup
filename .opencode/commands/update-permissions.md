# update-permissions — Sync approved permissions to global config

Extracts all tool calls you have approved across OpenCode sessions and
merges them into `~/.config/opencode/opencode.json` so you stop being
prompted for the same actions.

## Usage

```
/update-permissions
```

## Steps

1. Run the update script:
   ```bash
   python3 .opencode/skills/permissions-update/update_permissions.py
   ```
2. Review the diff output — verify no unwanted patterns are being added
3. Confirm when prompted to apply

## Common Patterns Added

This session added these common patterns:

**Bash commands:** `uvx *`, `npx *`, `node *`, `python3 *`, `mkdir *`, `cp *`, `mv *`, `tmux *`

**File types:** `**/*.jsonc`, `**/*.json`, `**/*.md`, `**/*.py`, `**/Makefile`, `**/*.fish`, `**/*.ex`, `**/*.exs`, `**/*.heex`

## Notes

- Dangerous commands (`rm -rf`, `sudo`, `git push --force`) are never auto-allowed
- Existing `ask` and `deny` rules are never overridden
- A backup is created at `~/.config/opencode/backups/` before each update
- Run `/permissions-update` as an alias for this command
