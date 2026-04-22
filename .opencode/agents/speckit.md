---
description: Spec-Driven Development using Speckit — specifications become executable code
permission:
  edit:
    "specs/**/*": allow
    "features/**/*": allow
    "src/**/*": allow
    "lib/**/*": allow
    "memory/**/*": allow
    "**/*.ex": allow
    "**/*.exs": allow
    "**/*.heex": allow
    "**/*.eex": allow
    "config/*.exs": allow
    "priv/**/*": ask
    "**/*.md": ask
  bash:
    specify: allow
    git: allow
    uv: allow
    curl: allow
    chmod: allow
    rg: allow
    find: allow
    ls: allow
    cat: allow
    mix: allow
    iex: allow
    sudo: ask
  glob:
    "specs/**/*": allow
    "features/**/*": allow
    "src/**/*": allow
    "lib/**/*": allow
    "memory/**/*": allow
    "**/*.ex": allow
    "**/*.exs": allow
    "**/*.heex": allow
    "**/*.eex": allow
command:
  speckit-constitution: .opencode/skills/speckit-constitution/SKILL.md
  speckit-specify: .opencode/skills/speckit-specify/SKILL.md
  speckit-plan: .opencode/skills/speckit-plan/SKILL.md
  speckit-tasks: .opencode/skills/speckit-tasks/SKILL.md
  speckit-implement: .opencode/skills/speckit-implement/SKILL.md
  speckit-clarify: .opencode/skills/speckit-clarify/SKILL.md
  speckit-analyze: .opencode/skills/speckit-analyze/SKILL.md
  speckit-checklist: .opencode/skills/speckit-checklist/SKILL.md
mcp:
  sequential-thinking: inherit
  filesystem: inherit
  memory: inherit
  fetch: inherit
