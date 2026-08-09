# Skills and commands layout

This repo carries parallel skill and command trees for two harnesses — **OpenCode** (`.opencode/`) and **Claude Code** (`.claude/`). They must stay in sync.

## Sources

- **Shared Matt Pocock skills** come from the upstream repo `github.com/mattpocock/skills`. `make add_pocock_skills` clones it to `~/.local/share/cachyos-setup/mattpocock-skills` and symlinks each skill into both `~/.claude/skills/` and `~/.config/opencode/skills/`. Remove them with `make delete_pocock_skills`; wipe the global dirs with `make purge-claude-skills` / `make purge-opencode-skills`.
- **This repo's skills and commands** live under `.opencode/skills/` + `.opencode/commands/` and are mirrored under `.claude/skills/` + `.claude/commands/`. `make opencode-sync` deploys `.opencode/` to `~/.config/opencode/` (a full copy, not a symlink), so the repo is the canonical source for OpenCode.

## Mirror rule

Every skill and command file exists in both trees and is byte-identical except for the only legitimate differences:

- the **harness path token** — `.opencode/` vs `.claude/` inside file contents;
- **OpenCode-only command frontmatter** — `agent:` and `subtask:` (Claude Code ignores these).

Any other difference is drift. Enforce it with:

```bash
make check-skills-mirror
```

It diffs every paired file with the two differences above normalized away, and fails non-zero on any remaining drift. Run it before committing skill or command changes.

## Invocation

- **User-invoked skills** set `disable-model-invocation: true` in their frontmatter and are reached via slash commands (e.g. `/grill-with-docs`). They have a matching `.opencode/commands/<name>.md` and `.claude/commands/<name>.md`.
- **Model-invoked skills** omit that flag and are auto-reachable when the conversation matches their trigger.

See `AGENTS.md` for the current inventory of both kinds.
