description: Phoenix Fullstack development — Web apps, LiveViews, APIs, Ecto

permission:
  edit:
    "**/*.ex": allow
    "**/*.exs": allow
    "**/*.heex": allow
    "**/*.eex": allow
    "config/*.exs": allow
    "**/priv/*": ask
    "**/*.fish": allow
  bash:
    mix: allow
    iex: allow
    Phoenix: allow
    make: allow
    chmod: allow
    sudo: ask
  glob:
    "**/*.ex": allow
    "**/*.exs": allow
    "**/*.heex": allow
    "**/*.fish": allow

mcp:
  sequential-thinking:
    type: local
    command:
      - npx
      - -y
      - "@modelcontextprotocol/server-sequential-thinking@2025.12.18"
  filesystem:
    type: local
    command:
      - npx
      - -y
      - "@modelcontextprotocol/server-filesystem@2026.1.14"
      - .
  memory:
    type: local
    command:
      - npx
      - -y
      - "@modelcontextprotocol/server-memory@2026.1.26"
  hexdocs-mcp:
    type: local
    command:
      - npx
      - -y
      - hexdocs-mcp@0.6.0
  tidewave:
    type: remote
    url: http://127.0.0.1:4000/tidewave/mcp

command:
  gen-context: .opencode/skills/gen-context/SKILL.md
  gen-migration: .opencode/skills/gen-migration/SKILL.md
  gen-schema: .opencode/skills/gen-schema/SKILL.md
  gen-test: .opencode/skills/gen-test/SKILL.md
  liveview: .opencode/skills/liveview/SKILL.md
  tidewave: .opencode/skills/tidewave/SKILL.md
  tidewave-status: .opencode/commands/tidewave-status.md
  dialyzer-debug: .opencode/skills/dialyzer-debug/SKILL.md
  credo-debug: .opencode/skills/credo-debug/SKILL.md
  permissions-update: .opencode/commands/permissions-update.md
  review: .opencode/commands/review.md
  handoff: .opencode/commands/handoff.md
  test: .opencode/commands/phoenix-test.md
  precommit: .opencode/commands/phoenix-precommit.md
  openapi: .opencode/commands/openapi.md
  changelog: .opencode/commands/changelog.md
