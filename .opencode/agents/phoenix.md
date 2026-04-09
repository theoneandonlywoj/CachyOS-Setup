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
  tidewave:
    type: remote
    url: http://127.0.0.1:4000/tidewave/mcp

command:
  gen_context: .opencode/skills/phoenix/gen_context/SKILL.md
  gen_migration: .opencode/skills/phoenix/gen_migration/SKILL.md
  gen_schema: .opencode/skills/phoenix/gen_schema/SKILL.md
  gen_test: .opencode/skills/phoenix/gen_test/SKILL.md
  liveview: .opencode/skills/phoenix/liveview/SKILL.md
  tidewave: .opencode/skills/phoenix/tidewave/SKILL.md
  tidewave-status: .opencode/commands/tidewave-status.md
  dialyzer-debug: .opencode/skills/elixir/dialyzer-debug/SKILL.md
  credo-debug: .opencode/skills/elixir/credo-debug/SKILL.md
  review: .opencode/commands/review.md
  handoff: .opencode/commands/handoff.md
  test: .opencode/commands/test.md
