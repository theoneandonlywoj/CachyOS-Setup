---
name: reflect
description: Reflect on recent Claude Code and OpenCode conversations to improve repository-local agent guidance.
disable-model-invocation: true
---

Follow the shared workflow in `docs/reflect/REFLECT_WORKFLOW.md`.

The Bash helper is `.opencode/skills/reflect/scripts/reflect`. The invoking harness skill directory contains the local `.env`; never read configuration from the other harness's skill directory.
