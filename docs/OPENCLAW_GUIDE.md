# OpenClaw: Complete Setup Guide (Beginner to Advanced)

A comprehensive guide to OpenClaw — the open-source, self-hosted AI assistant platform that connects AI models to your local files and messaging apps.

---

## Table of Contents

1. [What is OpenClaw?](#what-is-openclaw)
2. [Installation](#installation)
3. [Workspace Files](#workspace-files)
4. [BOOT.md (Startup Configuration)](#bootmd-startup-configuration)
5. [Skills System](#skills-system)
6. [Slash Commands](#slash-commands)
7. [AI Provider Configuration](#ai-provider-configuration)
8. [Platform Integrations](#platform-integrations)
9. [Environment & Configuration](#environment--configuration)
10. [Security Hardening](#security-hardening)
11. [Docker Sandboxing](#docker-sandboxing)
12. [Deployment Options](#deployment-options)
13. [First Week Roadmap](#first-week-roadmap)
14. [Troubleshooting](#troubleshooting)

---

## What is OpenClaw?

OpenClaw (formerly Clawdbot/Moltbot) is a **local-first AI assistant** with a hub-and-spoke architecture created by Peter Steinberger. It connects AI models to messaging apps (WhatsApp, Discord, Telegram, Slack, Signal, iMessage, and 15+ others), acting as a proactive personal agent.

### Core Architecture

| Component | Purpose |
|-----------|---------|
| **Gateway** | WebSocket server (`ws://127.0.0.1:18789`) that orchestrates everything — messaging channels, agent runtime, CLI, web UI, and device nodes |
| **Agent Runtime (Pi Agent Core)** | Executes the AI loop — resolves sessions, assembles context, streams model responses, executes tools, persists state |
| **Channel Adapters** | Normalize messaging across platforms (WhatsApp, Telegram, Discord, etc.) |
| **Skills** | Modular capabilities defined as Markdown files |
| **Workspace** | Directory of Markdown files that define your agent's identity, behavior, and memory |

---

## Installation

### Prerequisites

- **Node.js >= 22** (Node 24 recommended)
- macOS, Linux, or Windows (WSL2)

### Method A: Installer Script (Recommended)

```bash
# macOS / Linux / WSL2
curl -fsSL https://openclaw.ai/install.sh | bash

# Windows PowerShell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

### Method B: NPM/PNPM

```bash
npm install -g openclaw@latest
# or
pnpm add -g openclaw@latest
```

### Method C: CachyOS Setup Script

Use the included Fish shell script:

```bash
./openclaw-cli.fish
```

This handles:
- Checking for existing installations
- Creating `~/.local/bin` directory
- Running the official installer
- Adding to PATH
- Verifying installation

### First-Time Setup

```bash
openclaw onboard --install-daemon
```

This interactive wizard walks you through:
1. Gateway configuration
2. Workspace creation
3. Channel connections (pick your messaging platforms)
4. Skills installation
5. AI provider setup (API keys)

### Verify Installation

```bash
openclaw doctor      # Check configuration health
openclaw status      # Check gateway status
openclaw dashboard   # Open web UI
```

---

## Workspace Files

The workspace (`~/.openclaw/workspace/`) is the brain of your agent. It contains Markdown files that shape behavior:

```
~/.openclaw/workspace/
├── AGENTS.md      # Operational rules, workflow, safety boundaries
├── SOUL.md        # Personality, tone, communication style, values
├── IDENTITY.md    # External persona: display name, emoji, avatar, quirks
├── USER.md        # Information about you (name, timezone, preferences)
├── TOOLS.md       # Available tools and their configuration
├── BOOT.md        # Startup sequence instructions
├── MEMORY.md      # Long-term memory (persists across restarts)
└── memory/
    └── YYYY-MM-DD.md  # Daily logs
```

### SOUL.md — Who Your Agent Is

Defines personality, communication style, ethical boundaries. Keep to 50-150 lines.

```markdown
# Who I Am
I am a technical assistant. I work for Acme Corp.

## Communication Style
- Concise and direct
- Bullet points preferred
- No unnecessary pleasantries

## Ethical Boundaries
- Never delete files without explicit confirmation
- Bold on internal actions, cautious on external ones
```

### AGENTS.md — How Your Agent Operates

Operational contract: priorities, safety rules, memory management, group chat behavior.

### USER.md — Who You Are

Describe yourself so the agent can personalize responses:

```markdown
Name: John Smith
Timezone: PST
Role: Software Engineer
Work Hours: 9am-5pm Pacific
```

### IDENTITY.md — External Presentation

Display name, personality theme, emoji, avatar URL — how the agent presents itself on messaging platforms.

---

## BOOT.md (Startup Configuration)

**BOOT.md** defines what OpenClaw executes when the gateway starts. It runs once against the default agent workspace.

**Location:** `~/.openclaw/workspace/BOOT.md`

### How It Works

- Contains explicit, concise instructions for the startup sequence
- Enable via `hooks.internal.enabled` configuration
- If the task sends a message, use the message tool and reply with `NO_REPLY`

### Example

```markdown
# BOOT.md
Enable the following on startup:
- hooks.internal.enabled: true

Send a startup notification to the owner channel, then reply with NO_REPLY.
```

### Key Rules

- Instructions must be concise and unambiguous
- Always return `NO_REPLY` after message operations to prevent hanging
- Don't dump directories or secrets into chat
- **Limitation**: In multi-agent setups, only the default agent's BOOT.md runs on startup

---

## Skills System

Skills equip your agent with tools and capabilities. They're simple Markdown + YAML files — no SDK or compilation needed.

### Skill Structure

Each skill is a folder containing a `SKILL.md` file:

```
~/.openclaw/skills/my-skill/
└── SKILL.md
```

```markdown
---
name: my-skill
description: What this skill does
version: 1.0.0
requires:
  bins: ["curl"]           # Required binaries on PATH
  env: ["MY_API_KEY"]      # Required environment variables
  os: ["darwin", "linux"]  # Platform restrictions
---

## Instructions
Step-by-step instructions for the agent to follow when using this skill...
```

### Skill Loading Priority

1. **Workspace skills** (`<workspace>/skills/`) — highest priority
2. **Managed skills** (`~/.openclaw/skills/`) — shared across agents
3. **Bundled skills** (49 pre-built) — lowest priority
4. **Extra directories** — via `skills.load.extraDirs` config

### Installing Skills from ClawHub

ClawHub (https://clawhub.com) is the official registry with 13,700+ community-built skills:

```bash
npm install -g clawhub        # Install ClawHub CLI
clawhub search <query>        # Search for skills
clawhub install <skill-slug>  # Install a skill
clawhub update --all          # Update all skills
clawhub list                  # List installed skills
```

### Creating Custom Skills

1. Create folder: `~/.openclaw/skills/<skill-name>/`
2. Add `SKILL.md` with YAML frontmatter and instructions
3. Use `{baseDir}` to reference the skill folder path
4. Or use the bundled `skill-creator` skill interactively

### User-Invocable Skills

Skills can be exposed as slash commands:
- Names sanitized to alphanumeric + underscores (max 32 chars)
- Set `user-invocable: true` in frontmatter
- Optional `command-dispatch: tool` for deterministic execution (no model involvement)

### Security Warning

Treat third-party skills as untrusted code. Review SKILL.md before enabling. ClawHub has VirusTotal scanning, but always verify.

---

## Slash Commands

OpenClaw has three command types:

### Commands (standalone `/` messages)

| Command | Purpose |
|---------|---------|
| `/help` | Show available commands |
| `/commands` | List all commands |
| `/status` | Show status and usage/quota |
| `/whoami` / `/id` | Show agent identity |
| `/model` | Select AI model |
| `/reset` / `/new` | Start fresh conversation |
| `/config` | Read/write settings (owner-only) |
| `/debug` | Runtime overrides (owner-only) |
| `/usage` | Control token/cost display |
| `/bash` | Execute shell commands |
| `/stop` | Stop current operation |
| `/restart` | Restart gateway |
| `/skill <name>` | Invoke a skill |
| `/context` | Explain session context |
| `/export-session` | Save session to HTML |
| `/btw <question>` | Ephemeral side question |
| `/allowlist` | Manage access controls |
| `/approve` | Resolve execution prompts |
| `/subagents` | Manage sub-agent runs |
| `/focus` / `/unfocus` | Discord thread binding |

### Directives (behavior modifiers)

Stripped before model processing. When sent alone, they persist to the session:

| Directive | Purpose |
|-----------|---------|
| `/think` | Enable reasoning/slow mode |
| `/fast` | Quick responses |
| `/verbose` | Detailed explanations |
| `/reasoning` | Show reasoning steps |
| `/elevated` | Elevated access mode |
| `/exec` | Execute mode |
| `/queue` | Queue mode |

### Authorization

- `commands.allowFrom` settings checked first
- Falls back to channel allowlists
- Unauthorized senders see directives as regular text
- Command-only messages from allowlisted senders bypass the queue and model

---

## AI Provider Configuration

### Supported Providers

Anthropic, OpenAI, Google Gemini, Mistral, Groq, xAI, OpenRouter, GitHub Copilot, Cerebras, Ollama, and many more.

### Quick Setup

**Anthropic:**

```bash
export ANTHROPIC_API_KEY="sk-..."
openclaw models set anthropic/claude-opus-4-6
```

**OpenAI:**

```bash
export OPENAI_API_KEY="sk-..."
openclaw models set openai/gpt-5.4
```

**Local Models (Ollama — zero cost):**

```bash
ollama serve  # Start Ollama server
export OLLAMA_API_KEY="any-value"
export OLLAMA_API_BASE="http://127.0.0.1:11434"
openclaw models set ollama/mistral
```

### Configuration in openclaw.json

```json
{
  "models": {
    "default": "anthropic/claude-opus-4-6",
    "fallback": "openai/gpt-5.4",
    "providers": {
      "anthropic": { "apiKey": "${ANTHROPIC_API_KEY}" },
      "openai": { "apiKey": "${OPENAI_API_KEY}" },
      "ollama": { "baseUrl": "http://127.0.0.1:11434" }
    }
  }
}
```

### Key Design Principle

Agent identity (SOUL.md) is completely separate from model provider. Switch providers without editing personality files.

### API Key Rotation

```bash
export ANTHROPIC_API_KEYS="sk-1,sk-2,sk-3"  # Multiple keys for load balancing
```

### Cost Expectations

| Usage Level | Estimated Daily Cost |
|-------------|---------------------|
| Light (Sonnet) | $2-5/day |
| Medium (Opus) | $10-15/day |
| Heavy/complex | $20-30/day |

Monitor with `/status` and `/usage` commands.

---

## Platform Integrations

### Supported Platforms

WhatsApp, Telegram, Discord, Slack, Signal, iMessage (via BlueBubbles), Google Chat, MS Teams, LINE, and more.

### Setup Highlights

**Telegram** (easiest, ~10 minutes): Bot token from @BotFather, excellent desktop/mobile apps, inline buttons, file sharing.

**WhatsApp**: Uses Baileys (open-source WhatsApp Web API), connects via QR code scan. Use a dedicated business number — not your personal one.

**Discord**: Multi-channel team tool with thread binding (`/focus`).

### Multi-Platform Features

- One persistent assistant across all platforms
- Same brain, memory, and context everywhere
- Unified conversation threads
- Session isolation and access control per platform

---

## Environment & Configuration

### Environment Variable Priority (highest to lowest)

1. Process environment
2. Local `.env` in working directory
3. Global `.env` at `~/.openclaw/.env`
4. Config file `env` block in `openclaw.json`
5. Optional shell import

### Key Environment Variables

| Variable | Purpose |
|----------|---------|
| `OPENCLAW_HOME` | Override home directory |
| `OPENCLAW_STATE_DIR` | Customize state directory |
| `OPENCLAW_LOG_LEVEL` | Logging verbosity (debug, trace) |
| `OPENCLAW_LOAD_SHELL_ENV=1` | Import shell env vars |

### openclaw.json Configuration

```json
{
  "gateway": {
    "port": 18789,
    "bind": "loopback"
  },
  "env": {
    "vars": { "API_KEY": "${MY_SECRET}" },
    "shellEnv": { "enabled": true }
  },
  "agents": {
    "defaults": { "workspace": "~/.openclaw/workspace" }
  },
  "skills": {
    "load": { "extraDirs": ["/custom/skills/path"] }
  }
}
```

### Version Management

```bash
openclaw update --channel stable   # Tagged releases (vYYYY.M.D)
openclaw update --channel beta     # Prerelease versions
openclaw update --channel dev      # Bleeding edge
```

---

## Security Hardening

### The RAK Threat Model

1. **Root Risk**: Remote code execution via prompt injection
2. **Agency Risk**: Unintended destructive actions from hallucinations
3. **Keys Risk**: API keys in `.env` vulnerable to agent leakage

### File Permissions

```bash
chmod 600 ~/.openclaw/openclaw.json   # User read/write only
chmod 700 ~/.openclaw/                # User access only
```

### Gateway Security

```json
{
  "gateway": {
    "bind": "loopback",
    "auth": { "mode": "token", "token": "strong-random-token" }
  }
}
```

### DM & Group Access Control

```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "pairing",
      "groups": { "*": { "requireMention": true } }
    }
  }
}
```

### Tool Access Hardening

```json
{
  "tools": {
    "profile": "messaging",
    "deny": ["group:automation", "group:runtime", "group:fs"],
    "exec": { "security": "deny", "ask": "always" }
  }
}
```

### Credential Best Practices

- **Never** put API keys directly in `.env` files the agent can read
- Use environment variables, secret managers (Vault, AWS Secrets Manager, 1Password CLI)
- Consider Composio for managed OAuth (agent gets reference IDs, never raw credentials)

### Security Audit

```bash
openclaw security audit
openclaw security audit --deep
openclaw security audit --fix
```

---

## Docker Sandboxing

Isolate tool execution in containers to reduce blast radius.

### Configuration

All sandbox settings live under `agents.defaults.sandbox` in `openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "non-main",
        "scope": "agent",
        "docker": {
          "image": "openclaw-sandbox:bookworm-slim",
          "network": "none",
          "readOnlyRoot": true
        }
      }
    }
  }
}
```

### Execution Modes (`agents.defaults.sandbox.mode`)

| Setting | Behavior |
|---------|----------|
| `"off"` | Disabled |
| `"non-main"` | Sandboxes only non-main sessions (default) |
| `"all"` | Every session containerized |

### Container Scope (`agents.defaults.sandbox.scope`)

| Setting | Behavior |
|---------|----------|
| `"session"` | One container per session (most isolated) |
| `"agent"` | One container per agent (default) |
| `"shared"` | All sessions share one container |

### Workspace Access

| Setting | Behavior |
|---------|----------|
| `"none"` | Isolated sandbox only |
| `"ro"` | Read-only agent workspace |
| `"rw"` | Read/write workspace access |

### Docker Hardening

```bash
docker run -d \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  --user openclaw:openclaw \
  --network=restricted \
  openclaw
```

Bind-mount `~/.openclaw` as volume for memory persistence in Docker.

---

## Deployment Options

| Environment | Method |
|-------------|--------|
| Local dev | macOS/Linux direct install |
| Production macOS | Menu bar LaunchAgent |
| Remote VPS | SSH tunnels or Tailscale |
| Cloud | Fly.io with persistent volumes |
| Cloudflare | MoltWorker (Cloudflare Workers) |
| Docker | Container with volume mounts |

### Remote Access

- Use SSH tunneling or Tailscale (private VPN)
- Avoid Funnel (public internet exposure); prefer Serve
- Docker: use dedicated bridge networks

---

## First Week Roadmap

| Days | Activity |
|------|----------|
| 1-2 | Casual conversation, get familiar with the agent |
| 3-4 | Connect tools (web search, knowledge base, calendar/email) |
| 5 | Add agent to group chats (with `requireMention: true`) |
| 6-7 | Provide feedback on writing style to train voice consistency |

---

## Troubleshooting

### Sandbox Image Not Found (Podman on CachyOS/Arch)

**Error:**
```
⚠️ Agent failed before reply: Failed to inspect sandbox image:
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
Error: openclaw-sandbox:bookworm-slim: image not known.
```

**Cause:** CachyOS and Arch Linux use Podman by default and alias `docker` to `podman`. OpenClaw's sandbox feature tries to use Docker to pull/inspect its sandbox image, but Podman's Docker emulation doesn't find it.

**Fix — Option 1: Disable sandboxing** (simplest, fine for local-only use):

```bash
openclaw config set agents.defaults.sandbox.mode off
```

Or set it directly in your `openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "off"
      }
    }
  }
}
```

**Fix — Option 2: Pull the sandbox image manually via Podman:**

```bash
podman pull docker.io/openclaw/openclaw-sandbox:bookworm-slim
```

If it still isn't found, tag it for Docker compatibility:
```bash
podman tag docker.io/openclaw/openclaw-sandbox:bookworm-slim localhost/openclaw-sandbox:bookworm-slim
```

**Fix — Option 3: Install Docker alongside Podman:**

```bash
sudo pacman -S docker
sudo systemctl enable --now docker
```

Then ensure OpenClaw uses Docker instead of the Podman alias by removing the alias or setting `DOCKER_HOST`:
```bash
# Suppress the Podman nodocker warning
sudo touch /etc/containers/nodocker
```

### Check Logs for More Details

```bash
openclaw logs --follow
```

### Gateway Won't Start

1. Check if the port is already in use:
   ```bash
   ss -tlnp | grep 18789
   ```
2. Verify configuration:
   ```bash
   openclaw doctor
   ```
3. Check daemon status:
   ```bash
   openclaw gateway status
   ```

### Skills Not Loading

1. Verify skill directory exists and contains `SKILL.md`
2. Check required binaries and env vars listed in the skill's `requires` block
3. Check loading priority — workspace skills override managed/bundled skills

### Channel Connection Issues

- **WhatsApp**: Re-scan QR code if session expires. Use a dedicated number.
- **Telegram**: Verify bot token with `@BotFather`. Ensure webhook URL is reachable.
- **Discord**: Check bot permissions in server settings.

### High Memory / CPU Usage

- Reduce container scope from `"shared"` to `"session"`
- Lower the number of concurrent sub-agents
- Use lighter models (Sonnet/Haiku) for routine tasks

---

## Sources

- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [OpenClaw Official Site](https://openclaw.ai/)
- [OpenClaw Docs](https://docs.openclaw.ai/)
- [ClawHub Registry](https://clawhub.com)
- [DigitalOcean: What is OpenClaw?](https://www.digitalocean.com/resources/articles/what-is-openclaw)
- [How to Make Your OpenClaw Agent Useful and Secure](https://amankhan1.substack.com/p/how-to-make-your-openclaw-agent-useful)
- [Cloudflare MoltWorker](https://github.com/cloudflare/moltworker)
