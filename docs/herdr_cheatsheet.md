# herdr Cheatsheet

Prefix: **Ctrl+B**. This page lists the keys the repository's
[`.config/herdr/config.toml`](../.config/herdr/config.toml) adds or changes;
every other action keeps the herdr default (press `prefix+?` for the full list).

## Workspaces

| Action | Keys |
| --- | --- |
| Previous workspace | `prefix+left` |
| Next workspace | `prefix+right` |
| Switch workspace | `prefix+shift+1..9` |
| Close workspace | `prefix+ctrl+x` |
| New workspace with four tabs | `prefix+ctrl+w` |

## Agents

| Action | Keys |
| --- | --- |
| Previous agent | `prefix+shift+up` |
| Next agent | `prefix+shift+down` |
| Focus agent | `prefix+ctrl+1..9` |
| Start an agent in a background workspace | `prefix+ctrl+a` |
| Open notification target | `prefix+o` |

## Panes and worktrees

| Action | Keys |
| --- | --- |
| Last pane | `prefix+backtick` |
| Open worktree | `prefix+ctrl+o` |
| Remove worktree | `prefix+ctrl+d` |

## Fish helper scripts

Installed to `~/.config/herdr/scripts/` by `./herdr.fish` or `make herdr-global-set`:

| Script | Use |
| --- | --- |
| `new-workspace-3-tabs.fish` | Popup behind `prefix+ctrl+w`: creates a workspace with four tabs |
| `start-agent-hidden.fish` | Behind `prefix+ctrl+a`; also `~/.config/herdr/scripts/start-agent-hidden.fish opencode reviewer ~/project` |
| `workspace-status.fish` | Prints the workspace's user, location and git branch |

## Make targets

| Target | Effect |
| --- | --- |
| `make herdr-global-set` | Back up, then copy `config.toml` and `scripts/*` to `~/.config/herdr` and reload |
| `make herdr-global-unset` | Back up, then remove `~/.config/herdr/config.toml` (`scripts/` stays) |
| `make herdr-global-backup` | Copy `~/.config/herdr/config.toml` to `./.herdr-<timestamp>/config.toml` |
| `make herdr-global-restore` | Restore the newest `./.herdr-*` backup (falls back to `~/.config/herdr/config.toml.backup_*`) |
| `make herdr-global-diff` | Compare the installed and repository config |
| `make herdr-remove-backups` | Delete the `./.herdr-*` backups after a y/N prompt |

## Notes

- `./herdr.fish` installs herdr and keeps an existing `~/.config/herdr/config.toml`.
