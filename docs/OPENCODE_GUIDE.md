# OpenCode with Oh My OpenCode: Step-by-Step Masterclass

A comprehensive, practical guide to OpenCode and Oh My OpenCode -- from first install through multi-agent orchestration mastery. Covers the open-source AI coding CLI, its plugin ecosystem, and how to unlock the full power of multi-model agent teams in your terminal.

For the CachyOS automated installer, see [opencode_with_oh_my_opencode.fish](../opencode_with_oh_my_opencode.fish).

---

## Table of Contents

1. [What Are OpenCode and Oh My OpenCode?](#1-what-are-opencode-and-oh-my-opencode)
2. [Installation](#2-installation)
3. [Authentication and Providers](#3-authentication-and-providers)
4. [First Launch -- The TUI](#4-first-launch----the-tui)
5. [AGENTS.md -- The Project Brain](#5-agentsmd----the-project-brain)
6. [Configuration Deep Dive](#6-configuration-deep-dive)
7. [Built-in Tools](#7-built-in-tools)
8. [Slash Commands](#8-slash-commands)
9. [Models and Provider Routing](#9-models-and-provider-routing)
10. [Agents -- The Core of OpenCode](#10-agents----the-core-of-opencode)
11. [Oh My OpenCode Agents](#11-oh-my-opencode-agents)
12. [Permissions System](#12-permissions-system)
13. [MCP Servers](#13-mcp-servers)
14. [LSP Integration](#14-lsp-integration)
15. [Sessions and Context Management](#15-sessions-and-context-management)
16. [Skills](#16-skills)
17. [Custom Commands](#17-custom-commands)
18. [Custom Tools and Plugins](#18-custom-tools-and-plugins)
19. [Oh My OpenCode Advanced Features](#19-oh-my-opencode-advanced-features)
20. [Keybindings Reference](#20-keybindings-reference)
21. [Themes and Visual Customization](#21-themes-and-visual-customization)
22. [Web Interface and Remote Access](#22-web-interface-and-remote-access)
23. [GitHub Automation](#23-github-automation)
24. [Formatters](#24-formatters)
25. [Tips, Workflows, and Best Practices](#25-tips-workflows-and-best-practices)

---

## 1. What Are OpenCode and Oh My OpenCode?

### OpenCode

**OpenCode** is an open-source AI coding agent built for the terminal. It is a full TUI (Terminal User Interface) application that delivers intelligent coding assistance -- code generation, file editing, shell command execution, web search, and multi-provider LLM support -- directly in your terminal.

Key facts:

- **Open-source** (MIT License), 100,000+ GitHub stars
- **Multi-provider** -- works with Anthropic, OpenAI, Google, Groq, local models, and 75+ more
- **No vendor lock-in** -- switch models mid-conversation
- **Full tool suite** -- bash, read, write, edit, grep, glob, LSP, MCP, web search
- **Plugin architecture** -- extensible with custom tools, agents, skills, and plugins

Think of it as an open-source alternative to Claude Code, Cursor Agent, or Windsurf -- but running entirely in your terminal, with the freedom to use any model from any provider.

### Oh My OpenCode (OmO)

**Oh My OpenCode** is a free, open-source plugin that transforms OpenCode from a single-agent tool into a multi-agent orchestration platform. It is to OpenCode what Oh My Zsh is to Zsh -- a community-driven enhancement layer that adds agents, tools, hooks, skills, and commands.

Key facts:

- **36,000+ GitHub stars**, created by code-yeongyu
- **11 specialized agents** that coordinate across multiple AI providers
- **Hash-anchored editing** (Hashline) for dramatically improved file edit accuracy
- **Category-based task routing** -- automatically selects the optimal model per task type
- **44 hooks** for quality control, recovery, and context management
- **Full Claude Code compatibility** -- existing `.claude/` configs work unchanged

---

## 2. Installation

### Prerequisites

- A terminal (any modern terminal emulator)
- `curl` (pre-installed on most Linux/macOS systems)
- At least one AI provider API key or subscription (see [Section 3](#3-authentication-and-providers))

### Install OpenCode

```bash
# Recommended -- official installer
curl -fsSL https://opencode.ai/install | bash
```

Alternative installation methods:

```bash
# npm
npm install -g opencode

# Bun
bun install -g opencode

# Homebrew (macOS/Linux)
brew install opencode-ai/tap/opencode

# AUR (Arch Linux / CachyOS)
paru -S opencode-ai-bin
```

Verify the installation:

```bash
opencode --version
```

### Install Oh My OpenCode

Oh My OpenCode requires Bun or Node.js for installation (only needed during install -- the plugin runs standalone afterward).

**Step 1 -- Install Bun (if not present):**

```bash
curl -fsSL https://bun.sh/install | bash
```

**Step 2 -- Run the Oh My OpenCode installer:**

```bash
# Interactive mode (recommended for first-timers)
bunx oh-my-opencode install

# Non-interactive mode (for automation)
bunx oh-my-opencode install --no-tui \
  --claude=yes \
  --openai=no \
  --gemini=no \
  --copilot=no \
  --opencode-zen=no \
  --zai-coding-plan=no \
  --kimi-for-coding=no
```

The interactive installer presents a TUI where you select which providers you subscribe to. It then configures agents, tools, hooks, and commands accordingly.

**Step 3 -- Verify:**

```bash
# Check that oh-my-opencode is registered as a plugin
cat ~/.config/opencode/opencode.json | grep oh-my-opencode
```

You should see `"oh-my-opencode"` in the `"plugin"` array.

### CachyOS One-Liner

This repository includes a Fish shell script that automates everything:

```bash
# Edit provider subscriptions at the top of the file first
chmod +x opencode_with_oh_my_opencode.fish
./opencode_with_oh_my_opencode.fish
```

### Upgrade

```bash
# Upgrade OpenCode
opencode upgrade

# Upgrade Oh My OpenCode -- re-run the installer
bunx oh-my-opencode install
```

### Uninstall

```bash
# Uninstall OpenCode
opencode uninstall
opencode uninstall --keep-config   # keep config files
opencode uninstall --dry-run       # preview what gets removed

# Uninstall Oh My OpenCode
# 1. Remove from plugin array in ~/.config/opencode/opencode.json
# 2. Delete config files:
rm -f ~/.config/opencode/oh-my-opencode.json
rm -f ~/.config/opencode/oh-my-opencode.jsonc
rm -f .opencode/oh-my-opencode.json
rm -f .opencode/oh-my-opencode.jsonc
```

---

## 3. Authentication and Providers

OpenCode supports 75+ AI providers. You authenticate either through OAuth (browser login) or API keys.

### OAuth Providers (Browser Login)

```bash
opencode auth login
# Select your provider and complete the browser flow
```

Supported OAuth flows:

| Provider | Subscription |
|----------|-------------|
| **Anthropic** | Claude Pro ($20/mo), Max ($100/mo, $200/mo) |
| **OpenAI** | ChatGPT Plus ($20/mo), Pro ($200/mo) |
| **GitHub Copilot** | Individual ($10/mo), Business ($19/mo) |
| **Google Gemini** | Free tier available, paid plans for higher limits |

### API Key Providers

Set API keys as environment variables in your shell config (`~/.bashrc`, `~/.zshrc`, `~/.config/fish/config.fish`):

```bash
# Anthropic
export ANTHROPIC_API_KEY="sk-ant-..."

# OpenAI
export OPENAI_API_KEY="sk-..."

# Google Gemini
export GEMINI_API_KEY="..."

# Groq
export GROQ_API_KEY="gsk_..."

# AWS Bedrock
export AWS_PROFILE="my-profile"
# or
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

# Azure OpenAI
export AZURE_RESOURCE_NAME="my-resource"
export AZURE_API_KEY="..."
```

Or use the `/connect` slash command inside the TUI to configure keys interactively.

### Managing Auth

```bash
# List authenticated providers
opencode auth list

# Remove a provider
opencode auth logout
```

Credentials are stored at `~/.local/share/opencode/auth.json`.

### Provider Priority with Oh My OpenCode

When Oh My OpenCode is installed, it sets intelligent provider priority:

1. **Native providers** (Anthropic, OpenAI, Google) -- highest priority, direct API access
2. **GitHub Copilot** -- good fallback, works with many models
3. **OpenCode Zen** -- curated model access
4. **Z.ai** -- additional model coverage

---

## 4. First Launch -- The TUI

### Starting OpenCode

```bash
# Navigate to your project
cd /path/to/your/project

# Launch OpenCode
opencode
```

### Understanding the Interface

```
┌─────────────────────────────────────────────────────────────┐
│  OpenCode v1.x.x                                            │
│  Model: anthropic/claude-sonnet-4-5                         │
│  Agent: build                                               │
│                                                             │
│  ┌─ Messages ──────────────────────────────────────────┐    │
│  │                                                      │    │
│  │  Welcome to OpenCode! How can I help?               │    │
│  │                                                      │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                             │
│  > type your prompt here...                                 │
│                                                             │
│  [ctrl+x = leader]  [tab = cycle agents]  [ctrl+p = cmds]  │
└─────────────────────────────────────────────────────────────┘
```

Key elements:

- **Model indicator** -- shows which provider/model is active
- **Agent indicator** -- shows which agent is handling your request
- **Message area** -- scrollable conversation history
- **Input area** -- where you type prompts (supports multiline with Shift+Enter)
- **Status bar** -- keybinding hints and context usage

### Your First Prompt

```
> hey, what files are in this project?
```

OpenCode will use its built-in tools (glob, list, read) to explore your project and respond. You are now running an AI coding agent connected to your filesystem.

### Essential Navigation

| Key | Action |
|-----|--------|
| `Enter` | Send your prompt |
| `Shift+Enter` | Add a new line in the input |
| `Escape` | Interrupt the current response |
| `ctrl+p` | Open the command palette |
| `tab` | Cycle through available agents |
| `ctrl+c` | Quit OpenCode |
| `PageUp/PageDown` | Scroll through messages |

---

## 5. AGENTS.md -- The Project Brain

`AGENTS.md` is to OpenCode what `CLAUDE.md` is to Claude Code -- a file that gives the AI context about your project, coding standards, and preferences.

### Create AGENTS.md

**Option 1 -- Auto-generate with `/init`:**

```
> /init
```

OpenCode scans your project structure, dependencies, and code patterns, then generates an `AGENTS.md` in the project root.

**Option 2 -- Deep initialization with Oh My OpenCode:**

```
> /init-deep
```

This generates hierarchical `AGENTS.md` files throughout your project:

```
project/
  AGENTS.md                  # project-wide context
  src/
    AGENTS.md                # src-specific patterns
    components/
      AGENTS.md              # component conventions
    api/
      AGENTS.md              # API layer rules
```

Agents automatically read the relevant `AGENTS.md` when working in a directory. Zero manual context management.

**Option 3 -- Write it manually:**

```markdown
# Project: My App

## Tech Stack
- Frontend: React 19, TypeScript, Tailwind CSS 4
- Backend: Elixir, Phoenix 1.8
- Database: PostgreSQL 17
- Deployment: Docker, fly.io

## Coding Standards
- Use functional components with hooks, never class components
- All functions must have TypeScript types, no `any`
- Tests go in `__tests__/` next to source files
- Use `pnpm` as the package manager

## Project Structure
- `src/` -- application source code
- `src/components/` -- reusable UI components
- `src/pages/` -- route-level page components
- `lib/` -- Elixir backend code
- `test/` -- backend tests

## Important Notes
- Always run `pnpm check` before committing
- Database migrations live in `priv/repo/migrations/`
```

### AGENTS.md Precedence

1. Local `AGENTS.md` files (traverses up directories from the current file)
2. `~/.config/opencode/AGENTS.md` (global rules)
3. `~/.claude/CLAUDE.md` (Claude Code fallback, if enabled)

### Claude Code Compatibility

OpenCode reads `CLAUDE.md` files as a fallback when no `AGENTS.md` exists. Your existing Claude Code setup works unchanged. Disable this with:

```bash
export OPENCODE_DISABLE_CLAUDE_CODE=true
```

---

## 6. Configuration Deep Dive

OpenCode uses JSON (or JSONC -- JSON with comments) configuration files.

### Config File Locations (Precedence Order)

| Priority | Location | Scope |
|----------|----------|-------|
| 1 (lowest) | Remote `.well-known/opencode` | Organization |
| 2 | `~/.config/opencode/opencode.json` | Global (user) |
| 3 | `$OPENCODE_CONFIG` path | Custom |
| 4 | `opencode.json` in project root | Project |
| 5 | `.opencode/` directory | Project |
| 6 (highest) | `$OPENCODE_CONFIG_CONTENT` env var | Inline |

Config files **merge** together -- later entries override earlier ones.

### Minimal Configuration

```jsonc
// opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

### Full Configuration Reference

```jsonc
{
  "$schema": "https://opencode.ai/config.json",

  // === Models ===
  "model": "anthropic/claude-sonnet-4-5",          // default model
  "small_model": "anthropic/claude-haiku-4-5",     // model for quick tasks

  // === Provider Configuration ===
  "provider": {
    // Custom OpenAI-compatible provider
    "my-local-llm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local LLM",
      "options": {
        "baseURL": "http://localhost:11434/v1",
        "apiKey": "{env:LOCAL_API_KEY}"
      },
      "models": {
        "my-model": {
          "name": "My Custom Model",
          "limit": {
            "context": 200000,
            "output": 65536
          }
        }
      }
    }
  },

  // === Provider Controls ===
  "disabled_providers": ["groq"],
  "enabled_providers": ["anthropic", "openai"],

  // === Agents ===
  "default_agent": "build",

  // === MCP Servers ===
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    }
  },

  // === LSP ===
  "lsp": {
    "typescript": {
      "command": ["typescript-language-server", "--stdio"],
      "extensions": [".ts", ".tsx"]
    }
  },

  // === Permissions ===
  "permission": {
    "read": "allow",
    "glob": "allow",
    "grep": "allow",
    "edit": { "*": "ask" },
    "bash": {
      "*": "ask",
      "git *": "allow"
    }
  },

  // === Custom Instructions ===
  "instructions": ["CONTRIBUTING.md", "docs/guidelines.md"],

  // === Context Management ===
  "compaction": {
    "auto": true,
    "prune": true,
    "reserved": 10000
  },

  // === Session Sharing ===
  "share": "manual",

  // === Auto-update ===
  "autoupdate": true,

  // === Plugins ===
  "plugin": ["oh-my-opencode"]
}
```

### Variable Substitution

Use these patterns in config values:

- **Environment variables:** `"{env:VARIABLE_NAME}"` -- replaced with the env var value
- **File contents:** `"{file:path/to/file}"` -- replaced with file contents (supports `~`)

### TUI Configuration

The TUI has its own config file (`tui.json`):

```jsonc
{
  "scroll_speed": 3,
  "scroll_acceleration": { "enabled": true },
  "diff_style": "auto",
  "theme": "tokyonight",
  "keybinds": {
    "session_new": "ctrl+n",
    "app_quit": "ctrl+q"
  }
}
```

---

## 7. Built-in Tools

OpenCode ships with 15 built-in tools that the AI uses to interact with your system.

| Tool | What It Does | Permission Key |
|------|-------------|----------------|
| `bash` | Execute shell commands | `bash` |
| `edit` | Modify files via string replacement | `edit` |
| `write` | Create or overwrite files | `edit` |
| `read` | Read file contents | `read` |
| `grep` | Regex content search (uses ripgrep) | `grep` |
| `glob` | Pattern-based file search | `glob` |
| `list` | Directory listing | `list` |
| `lsp` | Code intelligence (diagnostics, refs) | `lsp` |
| `patch` | Apply patch files | `edit` |
| `skill` | Load skill documentation | `skill` |
| `todowrite` | Create/manage task lists | `todowrite` |
| `todoread` | Read task lists | `todoread` |
| `webfetch` | Retrieve web content | `webfetch` |
| `websearch` | Web search via Exa AI | `websearch` |
| `question` | Ask user for input/clarification | `question` |

All tools are enabled by default. Search tools (`grep`, `glob`, `list`) respect `.gitignore`.

### Enabling Hidden Files in Search

Create a `.ignore` file in your project root to selectively include gitignored paths:

```
# .ignore
!.env.example
!dist/
```

---

## 8. Slash Commands

### Built-in Commands

| Command | What It Does |
|---------|-------------|
| `/init` | Scan project and generate `AGENTS.md` |
| `/undo` | Revert the last action |
| `/redo` | Repeat an undone action |
| `/share` | Generate a public URL for the current session |
| `/unshare` | Remove public access to a shared session |
| `/help` | Display available commands |
| `/models` | Browse and select models interactively |
| `/theme` | Select a theme interactively |
| `/connect` | Add provider API keys |
| `/compact` | Manually trigger context compaction |

### Oh My OpenCode Commands

| Command | What It Does |
|---------|-------------|
| `/init-deep` | Generate hierarchical `AGENTS.md` files throughout the project |
| `/start-work` | Invoke the Prometheus strategic planner |
| `/refactor` | Intelligent refactoring with LSP, AST-grep, and TDD |
| `/handoff` | Create a context summary for session continuation |
| `/stop-continuation` | Halt all continuation mechanisms |

### Keywords (Type Directly)

| Keyword | What It Does |
|---------|-------------|
| `ultrawork` or `ulw` | Activate all agents and run to completion |
| `/ulw-loop` | Self-referential loop that does not stop until 100% done |

### Custom Commands

Create markdown files to define your own slash commands:

**Global:** `~/.config/opencode/commands/<name>.md`
**Project:** `.opencode/commands/<name>.md`

Example -- `.opencode/commands/deploy.md`:

```markdown
---
description: Deploy the application to production
agent: build
---

Run the deployment pipeline:
1. Run `pnpm build` to create a production build
2. Run `pnpm test` to verify all tests pass
3. Run `docker build -t myapp:latest .`
4. Confirm with the user before pushing

Use $ARGUMENTS for any additional deploy flags.
```

Then use it: `/deploy --dry-run`

Features:

- `$ARGUMENTS` -- captures everything after the command name
- `$1`, `$2`, `$3` -- positional arguments
- `` !`command` `` -- embeds shell output inline
- `@filename` -- includes file contents

---

## 9. Models and Provider Routing

### Model Format

Models use the format `provider_id/model_id`:

```
anthropic/claude-sonnet-4-5
openai/gpt-5.2
google/gemini-3-pro
groq/llama-4-maverick
ollama/codellama
```

### Switching Models

**In the TUI:**

- Press `<leader>m` (Ctrl+X, then M) to open the model picker
- Press `F2` / `Shift+F2` to cycle through recently used models
- Use `/models` to browse all available models

**From the command line:**

```bash
opencode --model anthropic/claude-opus-4-5
opencode -m openai/gpt-5.2
```

**In config:**

```jsonc
{
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

### Model Loading Priority

1. Command-line flag (`--model` / `-m`)
2. Config file `model` setting
3. Previously used model
4. First model by internal priority

### Model Variants

Some providers support thinking/reasoning variants:

| Provider | Variants |
|----------|----------|
| Anthropic | `high` (default), `max` (extended thinking) |
| OpenAI | `none`, `minimal`, `low`, `medium`, `high`, `xhigh` |
| Google | `low`, `high` |

### Local Models

OpenCode works with locally running models through Ollama and LM Studio:

```bash
# Start Ollama with a model
ollama run codellama

# Use it in OpenCode
opencode -m ollama/codellama
```

Or configure in `opencode.json`:

```jsonc
{
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "codellama": {
          "name": "Code Llama",
          "limit": { "context": 32768, "output": 4096 }
        }
      }
    }
  }
}
```

### Oh My OpenCode Category-Based Routing

When Oh My OpenCode is installed, tasks are automatically routed to the best model:

| Category | Default Model | When Used |
|----------|--------------|-----------|
| `visual-engineering` | gemini-3-pro | Frontend, UI/UX, design work |
| `ultrabrain` | gpt-5.3-codex (xhigh) | Hard logic, architecture decisions |
| `deep` | gpt-5.3-codex | Autonomous research + execution |
| `artistry` | gemini-3-pro (max) | Creative, design-heavy tasks |
| `quick` | claude-haiku-4-5 | Single-file changes, typos |
| `writing` | kimi-k2.5 | Documentation, prose |
| `unspecified-low` | claude-sonnet-4-6 | General low-complexity |
| `unspecified-high` | claude-opus-4-6 (max) | General high-complexity |

---

## 10. Agents -- The Core of OpenCode

Agents are personas with specific models, tools, permissions, and system prompts.

### Built-in Agents

| Agent | Mode | Tools | Purpose |
|-------|------|-------|---------|
| **build** | Primary (default) | All tools | Full development with unrestricted access |
| **plan** | Primary | Read-only (edit/bash require approval) | Analysis and planning |
| **general** | Subagent | All tools (except todo) | Research and multi-step tasks |
| **explore** | Subagent | Read-only | Fast file search and code discovery |

### Switching Agents

| Key | Action |
|-----|--------|
| `tab` / `shift+tab` | Cycle through primary agents |
| `<leader>a` (Ctrl+X, then A) | Open the agent picker |
| `@agentname` in prompt | Invoke a specific subagent |

### Creating Custom Agents

**Method 1 -- Interactive wizard:**

```bash
opencode agent create
```

**Method 2 -- JSON config:**

```jsonc
{
  "agent": {
    "reviewer": {
      "description": "Code review specialist",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-5",
      "prompt": "You are a senior code reviewer. Focus on correctness, performance, and security.",
      "temperature": 0.1,
      "tools": { "write": false, "bash": false },
      "permission": { "edit": "deny", "bash": "deny" }
    }
  }
}
```

**Method 3 -- Markdown file:**

Create `~/.config/opencode/agents/reviewer.md` (global) or `.opencode/agents/reviewer.md` (project):

```markdown
---
description: Code review specialist
mode: subagent
model: anthropic/claude-sonnet-4-5
temperature: 0.1
---

You are a senior code reviewer. Focus on:
- Correctness and edge cases
- Performance implications
- Security vulnerabilities
- Code style consistency
```

The filename becomes the agent ID.

---

## 11. Oh My OpenCode Agents

Oh My OpenCode adds 11 specialized agents that work as a coordinated team.

### Core Agents

#### Sisyphus -- The Orchestrator

- **Model:** claude-opus-4-6 / kimi-k2.5 / glm-5
- **Role:** Main orchestrator and planner. Receives your task, breaks it into subtasks, and delegates to specialists in parallel. Never stops halfway -- rolls the boulder uphill until the job is done.
- **When to use:** Complex tasks that need multiple specialists

```
> Build a full user authentication system with login, signup,
  password reset, and email verification
```

Sisyphus will create a plan, then delegate frontend work to one agent, backend to another, and database migrations to a third -- all running in parallel.

#### Hephaestus -- The Deep Worker

- **Model:** gpt-5.3-codex
- **Role:** Autonomous deep worker. Explores the codebase, researches patterns, and executes end-to-end without needing hand-holding. The blacksmith god who forges complete solutions.
- **When to use:** Large implementation tasks that need thorough exploration first

#### Oracle -- The Consultant

- **Model:** gpt-5.2 / gemini-3-pro / opus
- **Role:** Read-only architecture consultant. Reviews code, identifies bugs, suggests improvements -- but never modifies files directly. Your senior architect on call.
- **When to use:** Code review, debugging analysis, architecture decisions

#### Librarian -- The Researcher

- **Model:** minimax-m2.5-free / gemini-flash
- **Role:** Multi-repo analyst. Searches documentation, OSS patterns, and external references. Knows where to find answers.
- **When to use:** "How does library X handle Y?" or "Find examples of pattern Z"

#### Explore -- The Scout

- **Model:** minimax-m2.5-free / grok-code-fast
- **Role:** Fast codebase grep and exploration. Lightweight, quick, focused on finding things.
- **When to use:** "Where is the auth middleware?" or "Find all API endpoints"

#### Multimodal-Looker -- The Visual Analyst

- **Model:** kimi-k2.5 / gemini-flash / gpt-5.2
- **Role:** Visual content specialist. Reads PDFs, images, diagrams, mockups. Understands visual designs and translates them into code requirements.
- **When to use:** "Implement this mockup" (with image) or "Parse this PDF specification"

### Planning Agents

#### Prometheus -- The Strategic Planner

- **Model:** claude-opus-4-6 / gpt-5.2 / kimi-k2.5
- **Role:** Interview-mode strategic planner. Asks clarifying questions before building a detailed plan. Ensures you think through edge cases before writing code.
- **Invoked via:** `/start-work`

```
> /start-work
Prometheus: What are you building today?
> A REST API for a recipe management app
Prometheus: What authentication method? JWT, session-based, or OAuth?
> JWT
Prometheus: Should recipes support images? What about categories/tags?
> Yes to both
Prometheus: Here's the detailed plan...
```

#### Metis -- The Risk Analyst

- **Model:** opus / kimi-k2.5 / gpt-5.2
- **Role:** Pre-planning analyst. Identifies hidden issues, failure points, and edge cases that Prometheus might miss. Your pessimistic-but-valuable team member.

#### Momus -- The Plan Validator

- **Model:** gpt-5.2 / opus / gemini-3-pro
- **Role:** Plan critic. Checks plans for clarity, verifiability, and completeness. Ensures the plan is actually executable before work begins.

### Orchestration Agents

#### Atlas -- The Task Manager

- **Role:** Todo-list executor. Manages systematic task completion by tracking and assigning items from the task list.

#### Sisyphus-Junior -- The Focused Executor

- **Role:** Category-dependent executor that cannot re-delegate. Receives a specific task and completes it without spawning sub-tasks. Prevents infinite delegation chains.

### Using Agents Effectively

**Let Sisyphus orchestrate complex work:**

```
> ultrawork
> Build a complete blog system with posts, comments, tags,
  and full-text search
```

**Use Prometheus for planning first:**

```
> /start-work
> I need to migrate our monolith to microservices
```

**Invoke specific agents with @:**

```
> @oracle Review the authentication flow in src/auth/
> @librarian How does Next.js 15 handle server components?
> @explore Find all files that import the UserService class
```

---

## 12. Permissions System

Permissions control what tools the AI can use and when it needs your approval.

### Permission Levels

| Level | Meaning |
|-------|---------|
| `allow` | Tool runs without asking |
| `ask` | Tool asks for your approval each time |
| `deny` | Tool is blocked entirely |

### Configuring Permissions

```jsonc
{
  "permission": {
    // Global defaults
    "*": "ask",

    // Read-only tools -- always allow
    "read": "allow",
    "glob": "allow",
    "grep": "allow",
    "list": "allow",

    // Edit tools -- ask first
    "edit": {
      "*": "ask",
      // Allow edits to docs without asking
      "docs/**/*.md": "allow"
    },

    // Bash -- granular control
    "bash": {
      "*": "ask",
      "git *": "allow",
      "pnpm test *": "allow",
      "rm *": "deny"
    },

    // External directories
    "external_directory": {
      "~/projects/shared-lib/**": "allow"
    }
  }
}
```

### Per-Agent Permissions

```jsonc
{
  "agent": {
    "safe-coder": {
      "permission": {
        "edit": "ask",
        "bash": "deny"
      }
    }
  }
}
```

### MCP Tool Permissions

```jsonc
{
  "tools": {
    "mcp_sentry_*": true,
    "mcp_dangerous_*": false
  }
}
```

---

## 13. MCP Servers

MCP (Model Context Protocol) servers extend OpenCode with external capabilities -- databases, APIs, documentation, monitoring, and more.

### Adding MCP Servers

**In config:**

```jsonc
{
  "mcp": {
    // Local server (runs a subprocess)
    "sqlite": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-sqlite", "mydb.sqlite"],
      "enabled": true,
      "timeout": 5000
    },

    // Remote server (HTTP endpoint)
    "sentry": {
      "type": "remote",
      "url": "https://mcp.sentry.dev/mcp",
      "oauth": true,
      "enabled": true
    },

    // Remote server with API key
    "my-api": {
      "type": "remote",
      "url": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer {env:MY_API_KEY}" },
      "oauth": false
    }
  }
}
```

**Via CLI:**

```bash
opencode mcp add          # interactive setup
opencode mcp list         # show all servers and their status
opencode mcp debug sentry # troubleshoot connection issues
opencode mcp auth sentry  # authenticate OAuth server manually
```

### Oh My OpenCode Built-in MCPs

Oh My OpenCode bundles three MCP servers:

| MCP | URL | Purpose |
|-----|-----|---------|
| **websearch** (Exa) | Built-in | Real-time web search |
| **context7** | `https://mcp.context7.com/mcp` | Library/framework documentation lookup |
| **grep_app** | `https://mcp.grep.app` | GitHub code search across all public repos |

### Notable Community MCP Servers

| Server | Purpose |
|--------|---------|
| `@modelcontextprotocol/server-sqlite` | SQLite database access |
| `@modelcontextprotocol/server-filesystem` | Extended filesystem operations |
| `@modelcontextprotocol/server-github` | GitHub API integration |
| `@modelcontextprotocol/server-postgres` | PostgreSQL access |
| Sentry MCP | Error monitoring and debugging |

### OAuth Flow

OpenCode handles OAuth automatically for remote MCP servers:

1. Server returns 401
2. OpenCode attempts Dynamic Client Registration (RFC 7591)
3. Browser opens for authorization
4. Tokens stored at `~/.local/share/opencode/mcp-auth.json`

---

## 14. LSP Integration

OpenCode integrates with Language Server Protocol servers to give the AI real-time code intelligence.

### What LSP Provides

- **Diagnostics** -- the AI sees compiler errors and warnings as it edits
- **Go to definition** -- the AI can navigate to function/class definitions
- **Find references** -- the AI finds all usages of a symbol
- **Rename** -- workspace-aware renaming
- **Symbols** -- list all symbols in a file/project

### 27+ Built-in Language Servers

Automatically detected and configured for: Astro, Bash, C/C++, C#, Clojure, Dart, Deno, Elixir, F#, Gleam, Go, Haskell, Java, Julia, Kotlin, Lua, Nix, OCaml, PHP, Prisma, Python, Ruby, Rust, Swift, Svelte, Terraform, TypeScript, Vue, YAML, Zig.

Many install automatically when project files are detected.

### Custom LSP Configuration

```jsonc
{
  "lsp": {
    "my-language": {
      "command": ["my-language-server", "--stdio"],
      "extensions": [".mylang"],
      "env": { "LOG_LEVEL": "warn" },
      "initialization": {
        "settings": {
          "formatOnSave": true
        }
      }
    }
  }
}
```

### Oh My OpenCode LSP Tools

Oh My OpenCode exposes LSP capabilities as explicit tools the AI can use:

| Tool | Purpose |
|------|---------|
| `lsp_rename` | Workspace-aware symbol renaming |
| `lsp_goto_definition` | Navigate to definitions |
| `lsp_find_references` | Find all usages |
| `lsp_diagnostics` | Get current errors/warnings |
| `lsp_symbols` | List symbols in scope |

### Disable LSP

```jsonc
// Disable all LSP
{ "lsp": false }

// Disable specific server
{ "lsp": { "typescript": { "disabled": true } } }
```

Prevent automatic LSP downloads:

```bash
export OPENCODE_DISABLE_LSP_DOWNLOAD=true
```

---

## 15. Sessions and Context Management

### Session Basics

Every conversation is a **session**. Sessions persist to disk and can be resumed later.

**Resume last session:**

```bash
opencode --continue
opencode -c
```

**Resume specific session:**

```bash
opencode --session <session-id>
opencode -s <session-id>
```

**Fork a session (branch off):**

```bash
opencode --continue --fork
```

### TUI Session Navigation

| Key | Action |
|-----|--------|
| `<leader>n` | New session |
| `<leader>l` | Session list |
| `<leader>g` | Session timeline |
| `<leader>right` / `<leader>left` | Navigate child sessions |
| `<leader>up` | Navigate to parent session |
| `<leader>x` | Export session |

### Context Compaction

When the conversation gets long, the context window fills up. OpenCode handles this automatically:

```jsonc
{
  "compaction": {
    "auto": true,       // auto-compact at 95% context usage
    "prune": true,      // aggressively prune old messages
    "reserved": 10000   // tokens reserved for compaction summary
  }
}
```

**Manual compaction:** `/compact` command or `<leader>c`.

How it works: A hidden "compaction agent" summarizes the conversation so far, creates a continuation, and carries forward the essential context. You lose the raw history but keep the knowledge.

### Session Sharing

```
> /share         # generates a public URL
> /unshare       # removes public access
```

Configure default behavior:

```jsonc
{
  "share": "manual"    // "manual", "auto", or "disabled"
}
```

### Session CLI

```bash
opencode session                        # list sessions
opencode session -n 20                  # show last 20
opencode session --format json          # JSON output
opencode export                         # export current session to JSON
opencode import session-backup.json     # import from file
```

---

## 16. Skills

Skills are reusable instruction sets that agents load on-demand -- think of them as specialized knowledge packs.

### Skill Locations

| Location | Scope |
|----------|-------|
| `.opencode/skills/<name>/SKILL.md` | Project |
| `~/.config/opencode/skills/<name>/SKILL.md` | Global |
| `.claude/skills/<name>/SKILL.md` | Claude Code compatible (project) |
| `~/.claude/skills/<name>/SKILL.md` | Claude Code compatible (global) |

### Creating a Skill

Create `.opencode/skills/database/SKILL.md`:

```markdown
---
name: database
description: Database migration and query optimization specialist
---

## Database Conventions

- Use snake_case for table and column names
- Always include `created_at` and `updated_at` timestamps
- Foreign keys must have indexes
- Use UUID v7 for primary keys
- Never use `DELETE` -- use soft deletes with `deleted_at`

## Migration Pattern

1. Create migration file: `mix ecto.gen.migration <name>`
2. Write the up/down functions
3. Run `mix ecto.migrate` to apply
4. Verify with `mix ecto.migrations`

## Query Optimization

- Always use `EXPLAIN ANALYZE` before optimizing
- Prefer CTEs over subqueries for readability
- Add indexes for columns used in WHERE, JOIN, ORDER BY
```

### Oh My OpenCode Built-in Skills

| Skill | Purpose |
|-------|---------|
| **playwright** | Browser automation -- testing, screenshots, web scraping |
| **git-master** | Atomic commits, rebase surgery, history analysis with automatic style detection |
| **frontend-ui-ux** | Design-first UI development with emphasis on aesthetics, typography, color palettes |

### Skill Permissions

```jsonc
{
  "permission": {
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

---

## 17. Custom Commands

### Creating Commands

**Global:** `~/.config/opencode/commands/`
**Project:** `.opencode/commands/`

Example -- `.opencode/commands/test.md`:

```markdown
---
description: Run tests with coverage report
agent: build
model: anthropic/claude-haiku-4-5
---

Run the test suite:

1. Execute `pnpm test --coverage $ARGUMENTS`
2. Analyze the coverage report
3. If coverage dropped, identify which lines are uncovered
4. Suggest specific tests to add
```

Usage: `/test src/auth/`

### Config-Based Commands

```jsonc
{
  "command": {
    "lint": {
      "template": "Run the linter and fix all issues: pnpm lint --fix",
      "description": "Auto-fix lint issues",
      "agent": "build"
    },
    "explain": {
      "template": "Explain this code in detail: $ARGUMENTS",
      "description": "Explain code",
      "agent": "plan",
      "model": "anthropic/claude-haiku-4-5",
      "subtask": false
    }
  }
}
```

### Command Features

| Feature | Syntax | Example |
|---------|--------|---------|
| All arguments | `$ARGUMENTS` | `/deploy staging --dry-run` -> `staging --dry-run` |
| Positional args | `$1`, `$2`, `$3` | `/compare main develop` -> `$1=main`, `$2=develop` |
| Shell output | `` !`command` `` | `` !`git branch --show-current` `` -> `main` |
| File contents | `@filename` | `@package.json` -> contents of package.json |

---

## 18. Custom Tools and Plugins

### Custom Tools

Create TypeScript/JavaScript tools that OpenCode can use:

**Location:** `.opencode/tools/` (project) or `~/.config/opencode/tools/` (global)

Example -- `.opencode/tools/database-query.ts`:

```typescript
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Execute a read-only SQL query against the project database",
  args: {
    query: tool.schema.string().describe("SQL SELECT query to execute"),
  },
  async execute(args) {
    // Your implementation here
    const result = await db.query(args.query)
    return JSON.stringify(result, null, 2)
  },
})
```

The filename becomes the tool name. The AI can then call `database-query` as a tool.

### Plugins

Plugins are deeper integrations that hook into OpenCode's event system.

**Local plugins:** `.opencode/plugins/` or `~/.config/opencode/plugins/`
**npm plugins:** Listed in config

```jsonc
{
  "plugin": ["oh-my-opencode", "opencode-helicone-session", "@my-org/custom-plugin"]
}
```

### Plugin Hook Events

Plugins can respond to 20+ event categories:

| Category | Events |
|----------|--------|
| **Session** | `created`, `updated`, `deleted`, `compacted`, `idle`, `error` |
| **Message** | `updated`, `removed`, `part.updated`, `part.removed` |
| **File** | `edited`, `watcher.updated` |
| **Tool** | `execute.before`, `execute.after` |
| **Command** | `executed` |
| **Permission** | `asked`, `replied` |
| **LSP** | `client.diagnostics`, `updated` |
| **TUI** | `prompt.append`, `command.execute`, `toast.show` |
| **Server** | `connected` |

---

## 19. Oh My OpenCode Advanced Features

### Hash-Anchored Editing (Hashline)

The biggest accuracy improvement in Oh My OpenCode. Every line shown to the AI is tagged with a content hash:

```
11#VK| function hello() {
12#3P|   return "world"
13#9X| }
```

When the AI edits, it references hash tags instead of reproducing full line content. This prevents stale-line errors (where the AI hallucinates or slightly misremembers existing code).

**Impact:** Edit success rate improved from 6.7% to 68.3% with weaker models like Grok Code Fast 1. With strong models like Claude Opus, it further reduces the already-low error rate.

This is automatic -- no configuration needed.

### Background Agents

Oh My OpenCode can fire 5+ specialist agents in parallel, each running in the background:

```
> ultrawork
> Refactor the auth module, update all tests, and write migration docs
```

Sisyphus orchestrates: one agent refactors, another updates tests, another writes docs -- all running concurrently. Results are collected via `background_output(task_id)`.

Configure concurrency:

```jsonc
{
  "background_task": {
    "defaultConcurrency": 5,
    "staleTimeoutMs": 180000,
    "providerConcurrency": {
      "anthropic": 3,
      "openai": 5
    },
    "modelConcurrency": {
      "anthropic/claude-opus-4-6": 2
    }
  }
}
```

### Runtime Fallback

If a provider API errors out (rate limit, outage), Oh My OpenCode automatically switches to a fallback:

```jsonc
{
  "runtime_fallback": {
    "enabled": true,
    "retry_on_errors": [400, 429, 503, 529],
    "max_fallback_attempts": 3,
    "cooldown_seconds": 60,
    "timeout_seconds": 30,
    "notify_on_fallback": true
  }
}
```

### AST-Grep Tools

Pattern-aware code search and rewriting across 25+ languages. Goes beyond text grep -- understands syntax trees:

```
> Find all functions that take more than 3 parameters
> Rename all instances of UserService to AccountService across the codebase
```

### IntentGate

Analyzes your true intent before classifying tasks. Prevents the AI from taking your words too literally:

- You say: "clean up this function" -- IntentGate understands you mean refactor, not delete
- You say: "make it faster" -- IntentGate routes to profiling and optimization, not just removing code

### Comment Checker

Prevents AI-generated noise in code comments. Strips out comments like:

```javascript
// This function handles user authentication  <-- removed (obvious)
// Added on 2026-03-02                         <-- removed (noise)
// TODO: Consider refactoring later            <-- removed (vague)
```

Code reads like a senior engineer wrote it.

### Todo Enforcer

Agents that go idle get pulled back to work. If a task list has pending items, the enforcer ensures they get completed. No agent gets to slack off.

### The Ralph Loop (`/ulw-loop`)

A self-referential loop that does not stop until 100% task completion. Named after Ralph from The Simpsons rolling a boulder.

```
> /ulw-loop
> Build a complete e-commerce checkout flow with cart, payment,
  shipping, and order confirmation
```

The loop continues running, checking off todos, spawning new agents as needed, until every task is verified complete.

### Tmux Integration

```jsonc
{
  "tmux": {
    "enabled": true,
    "layout": "main-vertical",
    "main_pane_size": 60,
    "main_pane_min_width": 120,
    "agent_pane_min_width": 40
  }
}
```

With Tmux enabled, agents run in visible panes. You can watch multiple agents working simultaneously. REPLs, debuggers, and TUI apps stay live in their own panes.

### Hooks System (44 Hooks)

Oh My OpenCode includes 44 hooks across 5 tiers:

| Tier | Examples |
|------|---------|
| **Context Injection** | Auto-load AGENTS.md, README, rules |
| **Productivity Control** | Keyword detection, think-mode, ralph-loop |
| **Quality & Safety** | Comment checking, edit recovery, write guards |
| **Recovery & Stability** | Session recovery, fallback chains, JSON error recovery |
| **Context Management** | Output truncation, compaction preservation |

Disable specific hooks:

```jsonc
{
  "disabled_hooks": ["comment-checker", "session-recovery"]
}
```

---

## 20. Keybindings Reference

### Leader Key

The leader key is `ctrl+x` by default. Keybindings written as `<leader>n` mean press `ctrl+x`, release, then press `n`.

### Complete Keybinding Table

#### Application

| Key | Action |
|-----|--------|
| `ctrl+c` / `ctrl+d` / `<leader>q` | Quit |
| `ctrl+p` | Command palette |
| `escape` | Interrupt / close overlay |

#### Sessions

| Key | Action |
|-----|--------|
| `<leader>n` | New session |
| `<leader>l` | Session list |
| `<leader>g` | Timeline |
| `<leader>c` | Compact view |
| `<leader>x` | Export session |
| `<leader>right` / `<leader>left` | Cycle child sessions |
| `<leader>up` | Go to parent session |

#### Messages

| Key | Action |
|-----|--------|
| `PageUp` / `PageDown` | Page up/down |
| `ctrl+alt+b` / `ctrl+alt+f` | Page up/down (alt) |
| `ctrl+alt+y` / `ctrl+alt+e` | Line up/down |
| `ctrl+alt+u` / `ctrl+alt+d` | Half-page up/down |
| `ctrl+g` / `Home` | First message |
| `ctrl+alt+g` / `End` | Last message |
| `<leader>y` | Copy last response |
| `<leader>u` / `<leader>r` | Undo / Redo |
| `<leader>h` | Toggle conceal (show/hide details) |

#### Models & Agents

| Key | Action |
|-----|--------|
| `<leader>m` | Model picker |
| `F2` / `Shift+F2` | Cycle recent models forward/backward |
| `<leader>a` | Agent picker |
| `tab` / `shift+tab` | Cycle agents |

#### Editor & Display

| Key | Action |
|-----|--------|
| `<leader>e` | Open external editor |
| `<leader>t` | Theme picker |
| `<leader>b` | Toggle sidebar |
| `<leader>s` | Status view |

#### Input Editing (Readline-style)

| Key | Action |
|-----|--------|
| `ctrl+a` | Move to beginning of line |
| `ctrl+e` | Move to end of line |
| `ctrl+b` / `ctrl+f` | Move left/right by character |
| `alt+b` / `alt+f` | Move left/right by word |
| `ctrl+d` | Delete character under cursor |
| `ctrl+k` | Delete from cursor to end of line |
| `ctrl+u` | Delete from cursor to start of line |
| `shift+return` / `ctrl+return` / `alt+return` / `ctrl+j` | Insert newline |
| `up` / `down` | History navigation |

### Custom Keybindings

Override any keybinding in `tui.json`:

```jsonc
{
  "keybinds": {
    "session_new": "ctrl+n",
    "app_quit": "ctrl+q",
    "model_list": "ctrl+m",
    "agent_list": "ctrl+shift+a"
  }
}
```

Set any keybind to `"none"` to disable it.

---

## 21. Themes and Visual Customization

### Built-in Themes

opencode (default), system, tokyonight, everforest, ayu, catppuccin, catppuccin-macchiato, gruvbox, kanagawa, nord, matrix, one-dark.

### Switching Themes

**In TUI:** `/theme` or `<leader>t`
**In config:**

```jsonc
// tui.json
{ "theme": "tokyonight" }
```

### Custom Themes

Create JSON files in `~/.config/opencode/themes/` or `.opencode/themes/`.

Requires a truecolor (24-bit) terminal for full accuracy.

---

## 22. Web Interface and Remote Access

OpenCode can run as a web server with a browser-based UI.

### Start the Web Interface

```bash
opencode web                             # default (localhost:4096)
opencode web --port 8080                 # custom port
opencode web --hostname 0.0.0.0          # network-accessible
opencode web --mdns                      # mDNS discovery on local network
```

### Attach a TUI to a Running Server

```bash
# Start server on machine A
opencode serve --port 4096

# Attach TUI from machine B
opencode attach http://machine-a:4096
```

### Authentication

```bash
export OPENCODE_SERVER_USERNAME="admin"
export OPENCODE_SERVER_PASSWORD="secure-password"
opencode web
```

### Config

```jsonc
{
  "server": {
    "port": 4096,
    "hostname": "0.0.0.0",
    "mdns": true,
    "mdnsDomain": "myproject.local",
    "cors": ["http://localhost:5173"]
  }
}
```

---

## 23. GitHub Automation

OpenCode can run as a GitHub Action, triggered by issue and PR comments.

### Setup

```bash
opencode github install    # guided setup wizard
```

This creates a GitHub Actions workflow file. Then mention `/opencode` or `/oc` in any issue or PR comment to trigger the agent.

### Supported Triggers

- `issue_comment` -- comment on an issue
- `pull_request_review_comment` -- comment on a PR review
- `issues` -- issue opened/edited
- `pull_request` -- PR opened/edited
- `schedule` -- cron-based
- `workflow_dispatch` -- manual trigger

### Run Manually

```bash
opencode github run --event issue_comment --token $GITHUB_TOKEN
```

---

## 24. Formatters

OpenCode auto-formats files after write/edit operations using 24+ built-in formatters.

### Supported Formatters

biome, prettier, ruff, gofmt, rustfmt, rubocop, clang-format, mix (Elixir), nixfmt, black, autopep8, and many more.

### Custom Formatter

```jsonc
{
  "formatter": {
    "my-formatter": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "extensions": [".js", ".ts", ".jsx", ".tsx"]
    }
  }
}
```

### Disable Formatters

```jsonc
// Disable all
{ "formatter": false }

// Disable specific
{ "formatter": { "prettier": { "disabled": true } } }
```

---

## 25. Tips, Workflows, and Best Practices

### Beginner Tips

1. **Start with `/init`** -- always generate an `AGENTS.md` before starting work on a new project
2. **Use the plan agent first** -- press `tab` to switch to `plan` before diving into code changes
3. **Be specific** -- "add a login form with email/password fields and validation" beats "add login"
4. **Read before writing** -- ask the AI to explore the codebase before making changes
5. **Use `/compact` when things get slow** -- context compaction frees up the conversation window

### Intermediate Workflows

1. **Plan, then build:**
   ```
   [tab to plan agent]
   > Analyze the current auth system and propose improvements
   [read the plan, switch back to build]
   > Implement the plan above
   ```

2. **Multi-model strategy:**
   - Use Claude Opus for architecture decisions
   - Use Claude Sonnet for day-to-day coding
   - Use Claude Haiku for quick tasks and one-liners
   - Switch with `F2` or `<leader>m`

3. **Session branching:**
   ```bash
   opencode -c --fork    # branch off from last session
   ```
   Try experimental changes without losing your main conversation.

4. **Custom commands for repetitive tasks:**
   Create `.opencode/commands/pr.md`:
   ```markdown
   ---
   description: Create a PR with conventional commit title
   ---
   1. Run `git diff main...HEAD` to see all changes
   2. Write a PR title using conventional commits (feat:, fix:, etc.)
   3. Write a detailed description with bullet points
   4. Create the PR with `gh pr create`
   ```

### Advanced Workflows

1. **`ultrawork` for big tasks:**
   ```
   > ultrawork
   > Implement full CRUD for the products API with tests,
     migrations, and OpenAPI docs
   ```

2. **`/start-work` for strategic planning:**
   ```
   > /start-work
   ```
   Let Prometheus interview you, then hand off to Sisyphus for execution.

3. **Background agent parallelism:**
   Sisyphus fires multiple agents simultaneously. Monitor progress with `<leader>s` (status view).

4. **Chain sessions:**
   ```bash
   # Session 1: Plan
   opencode
   > /start-work ...

   # Session 2: Execute (carries context)
   opencode -c
   > ultrawork
   > Execute the plan from last session

   # Session 3: Review (fork to preserve execution state)
   opencode -c --fork
   > @oracle Review all changes made in this session
   ```

5. **MCP-powered workflows:**
   ```jsonc
   {
     "mcp": {
       "sentry": { "type": "remote", "url": "https://mcp.sentry.dev/mcp", "oauth": true },
       "context7": { "type": "remote", "url": "https://mcp.context7.com/mcp" }
     }
   }
   ```
   Now the AI can look up Sentry errors and library docs without leaving the conversation.

### Performance Tips

1. **Disable unused providers** to reduce model list noise:
   ```jsonc
   { "disabled_providers": ["groq", "deepseek"] }
   ```

2. **Be selective with MCP servers** -- each one adds to context window usage

3. **Use `<leader>c` (compact)** proactively when conversations get long

4. **Set concurrency limits** for background agents to avoid API rate limits:
   ```jsonc
   {
     "background_task": {
       "providerConcurrency": { "anthropic": 2 }
     }
   }
   ```

5. **Use the right model for the job** -- Haiku for exploration, Sonnet for coding, Opus for architecture

### Security Best Practices

1. **Never commit API keys** -- use environment variables
2. **Review bash permissions** -- deny dangerous commands:
   ```jsonc
   { "permission": { "bash": { "rm -rf *": "deny", "curl * | bash": "deny" } } }
   ```
3. **Use read-only agents for review** -- the `plan` agent and `Oracle` cannot modify files
4. **Set `OPENCODE_SERVER_PASSWORD`** when using the web interface
5. **Audit MCP server access** -- only enable trusted servers

### Data Locations Reference

| What | Where |
|------|-------|
| Global config | `~/.config/opencode/opencode.json` |
| TUI config | `tui.json` |
| OmO config | `~/.config/opencode/oh-my-opencode.jsonc` |
| API credentials | `~/.local/share/opencode/auth.json` |
| MCP OAuth tokens | `~/.local/share/opencode/mcp-auth.json` |
| Global agents | `~/.config/opencode/agents/` |
| Global commands | `~/.config/opencode/commands/` |
| Global skills | `~/.config/opencode/skills/` |
| Global tools | `~/.config/opencode/tools/` |
| Global plugins | `~/.config/opencode/plugins/` |
| Global themes | `~/.config/opencode/themes/` |
| Global rules | `~/.config/opencode/AGENTS.md` |
| Project config | `opencode.json` or `.opencode/` |
| Project agents | `.opencode/agents/` |
| Project commands | `.opencode/commands/` |
| Project skills | `.opencode/skills/` |
| Project tools | `.opencode/tools/` |

### CLI Quick Reference

```bash
# Core
opencode                    # start TUI
opencode -c                 # resume last session
opencode -s <id>            # resume specific session
opencode -m provider/model  # start with specific model
opencode run "prompt"       # non-interactive one-shot

# Server modes
opencode web                # web interface
opencode serve              # headless server
opencode attach <url>       # connect TUI to server

# Management
opencode auth login         # authenticate
opencode auth list          # list providers
opencode models             # list models
opencode mcp list           # list MCP servers
opencode session            # list sessions
opencode stats              # usage statistics
opencode export             # export session
opencode upgrade            # update OpenCode

# Environment
OPENCODE_CONFIG=path        # custom config path
OPENCODE_CONFIG_CONTENT='{}'# inline JSON config
ANTHROPIC_API_KEY=sk-...    # provider keys
```

---

*Built for CachyOS. Works everywhere.*
