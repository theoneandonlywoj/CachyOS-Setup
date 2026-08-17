# Reflection Configuration

The invoking harness reads configuration from its own skill directory:

- Claude Code: `.claude/skills/reflect/.env`
- OpenCode: `.opencode/skills/reflect/.env`

Copy the matching `.env.example` to `.env` when local overrides are needed. The `.env` file is ignored by Git and must contain paths and behavior settings only, never credentials.

## Variables

| Variable | Default | Meaning |
| --- | --- | --- |
| `REFLECT_OPENCODE_DB_PATH` | Discovered | Optional OpenCode SQLite path. Empty or unset uses harness-aware default discovery. |
| `REFLECT_CLAUDE_DATA_PATH` | Discovered | Optional Claude data path. Empty or unset uses harness-aware default discovery. |
| `REFLECT_USE_OPENCODE` | `true` | Include a detected OpenCode source. Set to `false` to skip it. |
| `REFLECT_USE_CLAUDE` | `true` | Include a detected Claude source. Set to `false` to skip it. |
| `REFLECT_MODEL_CONTEXT_PERCENTAGE_SIZE` | `20` | Percentage of a known model context window allocated to evidence. Values above `20` are accepted with a warning. |
| `REFLECT_FALLBACK_CONTEXT_MAX_TOKENS` | `100000` | Exact evidence budget when model context metadata cannot be determined. |
| `REFLECT_WORKER_LIMIT` | `4` | Maximum number of parallel session workers. |
| `MAX_REFLECT_WORKER_RETRIES` | `2` | Maximum retries for a failed session worker. |

Unset or empty source paths trigger default discovery. Source toggles are evaluated after discovery. Command arguments may change reflection scope and evidence inclusion, but source enablement is controlled by this file.

## Dependency Guidance

The helper requires Bash, SQLite, `jq`, Git, and standard core utilities. If a dependency is missing, the workflow stops and prints a package-manager suggestion based on the host. It never installs packages automatically. When using a repository Makefile for local setup, run it from the Git root returned by `git rev-parse --show-toplevel`, not from this repository's directory.

## Precedence

Explicit command arguments override `.env` for supported behavior. Source enablement remains configured through `REFLECT_USE_OPENCODE` and `REFLECT_USE_CLAUDE`, with detected sources enabled by default.
