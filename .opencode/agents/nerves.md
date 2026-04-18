description: Nerves embedded firmware development — IoT, cross-compiling, burning images

permission:
  edit:
    "**/*.ex": allow
    "**/*.exs": allow
    "config/*.exs": allow
    "rel/**/*": allow
    "**/nerves/**/*": allow
    "**/*.fish": allow
  bash:
    mix: allow
    "nerves.*": allow
    "mix firmware": allow
    "mix burn": allow
    fwup: allow
    lsusb: allow
    make: allow
    chmod: allow
    sudo: ask
  glob:
    "**/*.ex": allow
    "**/*.exs": allow

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

command:
  dialyzer-debug: .opencode/skills/dialyzer-debug/SKILL.md
  credo-debug: .opencode/skills/credo-debug/SKILL.md
  permissions-update: .opencode/commands/permissions-update.md
  review: .opencode/commands/review.md
  handoff: .opencode/commands/handoff.md
  test: .opencode/commands/test.md
