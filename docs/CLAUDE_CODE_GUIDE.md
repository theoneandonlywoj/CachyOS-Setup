# Claude Code Guide for Doom Emacs

A comprehensive guide to using Claude Code CLI with Doom Emacs, covering the IDE integration, workflows, and keybindings configured in this setup.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Core Concepts](#core-concepts)
3. [Doom Emacs Integration](#doom-emacs-integration)
4. [Essential Keybindings](#essential-keybindings)
5. [Common Workflows](#common-workflows)
6. [Slash Commands & Skills](#slash-commands--skills)
7. [Claude Code CLI Usage](#claude-code-cli-usage)
8. [MCP Servers](#mcp-servers)
9. [Configuration](#configuration)
10. [Tips & Best Practices](#tips--best-practices)
11. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Prerequisites

- Doom Emacs with Evil mode
- `eat` terminal emulator package (installed via `packages.el`)
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- Valid Anthropic API key or Claude Max subscription

### Installation

The integration is already configured in this setup. After cloning and running `doom sync`:

```bash
# Verify Claude Code is installed
claude --version

# Launch Emacs and open the Claude Code menu
# Press: SPC c l
```

### 30-Second Crash Course

```
SPC c l             → Open Claude Code menu
  s                 → Start Claude Code session
  c                 → Continue most recent conversation
  r                 → Resume a previous conversation
  b                 → Switch to Claude Code buffer
  w                 → Toggle Claude Code window visibility
  i                 → Insert selection (send selected text to Claude)
  p                 → Send prompt from minibuffer
  q                 → Stop current session
```

---

## Core Concepts

### What is Claude Code?

Claude Code is an agentic AI coding assistant that runs in your terminal. It can:

- Read, write, and edit files across your project
- Run shell commands (with your approval)
- Search codebases using grep, glob, and semantic search
- Interact with git, GitHub, and other dev tools
- Plan and execute multi-step coding tasks

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Doom Emacs                                                   │
│  ├── claude-code-ide.el (integration layer)                  │
│  │    ├── Emacs Tools (diagnostics, xref, imenu, etc.)       │
│  │    └── eat terminal (renders Claude Code CLI)             │
│  │                                                           │
│  └── Your Editing Buffers                                    │
│       ↕ context sharing (buffer/region/selection)            │
│       Claude Code CLI                                        │
│        ├── Reads/writes project files                        │
│        ├── Runs shell commands                               │
│        ├── Searches codebase                                 │
│        └── Talks to Claude API                               │
└─────────────────────────────────────────────────────────────┘
```

### How the Integration Works

The `claude-code-ide` package (from `manzaltu/claude-code-ide.el`) bridges Doom Emacs and the Claude Code CLI:

| Component | Role |
|-----------|------|
| **claude-code-ide.el** | Elisp package providing Emacs commands and menu |
| **eat** | Terminal emulator backend that renders Claude Code inside Emacs |
| **Emacs Tools** | Exposes LSP diagnostics, xref, tree-sitter, imenu, and project context to Claude |
| **Claude Code CLI** | The agentic AI that processes requests and modifies your project |

---

## Doom Emacs Integration

### Package Setup

From `packages.el`:

```elisp
;; Terminal emulator
(package! eat)

;; Claude Code IDE integration
(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el"))
```

From `config.el`:

```elisp
(use-package! claude-code-ide
  :config
  (setq claude-code-ide-terminal-backend 'eat)
  (claude-code-ide-emacs-tools-setup))

(map! :leader
      (:prefix ("c" . "code")
       :desc "Claude Code menu" "l" #'claude-code-ide-menu))
```

### What `claude-code-ide-emacs-tools-setup` Enables

Calling this function registers Emacs-side tools that Claude Code can use:

- **Diagnostics** - Claude can read flycheck/flymake errors and warnings from open buffers
- **Xref / LSP** - Claude can find definitions, references, and symbols via your LSP server
- **Tree-sitter** - Claude gets access to syntax tree information
- **Imenu** - Claude can navigate file structure (functions, classes, sections)
- **Project.el** - Claude is aware of project boundaries and file lists

This means Claude Code understands your Emacs environment, not just the raw files on disk.

---

## Essential Keybindings

### Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│  CLAUDE CODE (SPC c l)                                      │
│                                                             │
│  SESSION             INTERACTION          NAVIGATION        │
│  ───────             ───────────          ──────────        │
│  s    start          i    insert sel.     b    switch buf   │
│  c    continue       p    send prompt     w    toggle win   │
│  r    resume         e    send escape     W    toggle recent│
│  q    stop           n    insert newline                    │
│  l    list sessions                                         │
│                                                             │
│  INSIDE CLAUDE CODE TERMINAL (eat)                          │
│  ─────────────────────────────────                          │
│  Type naturally     Claude reads input as a prompt          │
│  Enter              Send prompt                             │
│  Ctrl+C             Interrupt current operation             │
│  /help              Show Claude Code built-in help          │
│  /clear             Clear conversation context              │
└─────────────────────────────────────────────────────────────┘
```

### Claude Code Menu (`SPC c l`)

| Key | Action | Description |
|-----|--------|-------------|
| **Session Management** | | |
| `s` | Start | Launch a new Claude Code session |
| `c` | Continue | Continue the most recent conversation |
| `r` | Resume | Resume a previous conversation |
| `q` | Stop | Stop the current session |
| `l` | List | List all sessions |
| **Navigation** | | |
| `b` | Switch buffer | Switch to the Claude Code terminal buffer |
| `w` | Toggle window | Toggle Claude Code window visibility |
| `W` | Toggle recent | Toggle the most recent Claude window |
| **Interaction** | | |
| `i` | Insert selection | Send selected text (or current line) to Claude |
| `p` | Send prompt | Type a prompt in the minibuffer and send it |
| `e` | Send escape | Send escape key to Claude |
| `n` | Insert newline | Insert a newline in Claude's input |
| **Submenus** | | |
| `C` | Configuration | Open configuration submenu |
| `d` | Debugging | Open debugging submenu |

### Navigation Between Emacs and Claude Code

Since Claude Code runs in an `eat` terminal buffer, you can use standard Doom window management:

| Keybinding | Action |
|------------|--------|
| `SPC w v` | Split right and focus (custom: auto-focuses new pane) |
| `SPC w s` | Split below and focus (custom: auto-focuses new pane) |
| `SPC w h/j/k/l` | Navigate between windows |
| `SPC w d` | Delete current window |
| `SPC b b` | Switch buffer (find Claude Code buffer) |

> **Tip**: Split your editor vertically (`SPC w v`), keep code on the left and Claude Code on the right.

---

## Common Workflows

### Workflow 1: Ask Claude About Current Code

```
1. Open the file you want to discuss
2. SPC c l → s              Start Claude Code (if not running)
3. SPC c l → i              Insert selection (sends current line or selection)
4. Type your question        "Explain what this function does"
```

### Workflow 2: Edit Code with Claude

```
1. Open the file to modify
2. SPC c l → s              Start Claude Code
3. SPC c l → p              Send a prompt from the minibuffer
4. Review changes            Claude edits the file directly
5. Check the buffer          Emacs auto-reloads changed files
```

### Workflow 3: Fix Errors Using Diagnostics

Since `claude-code-ide-emacs-tools-setup` is enabled, Claude can read your LSP diagnostics:

```
1. Open a file with errors (flycheck/flymake shows them)
2. SPC c l → s              Start Claude Code
3. SPC c l → p              Send prompt: "Fix the errors in the current file"
4. Claude reads diagnostics  It sees the same errors your editor shows
5. Claude fixes the code     Changes are applied to the file
```

### Workflow 4: Send a Specific Region

```
1. Select code in visual mode (v + motion)
2. SPC c l → i              Insert selection to Claude
3. Type your request         "Refactor this to use pattern matching"
```

### Workflow 5: Multi-File Task

```
1. SPC c l → s              Start Claude Code in project root
2. SPC c l → p              Send prompt: "Add authentication to the API endpoints"
3. Claude explores files     It reads, searches, and plans changes
4. Approve tool calls        Claude asks before running commands
5. Review changes            Use magit (SPC g g) to see all diffs
```

### Workflow 6: Accepting Recommendations One by One

When Claude proposes multiple changes (file edits, shell commands, etc.), each action is presented as a **tool call** that you approve or reject individually. This gives you fine-grained control over what gets applied.

#### Tips for Reviewing Changes

- **Read the diff carefully** — Claude shows you exactly what will change before you approve
- **Reject freely** — pressing `n` doesn't stop Claude, it just skips that one action and Claude adapts
- **Use "Always allow"** (`a`) when Claude is making many similar safe changes (e.g., renaming across files) to speed up the workflow
- **Review after** — use magit (`SPC g g`) to see the cumulative diff of all accepted changes and revert any you don't like

### Recommended Window Layout

```
┌────────────────────────────────┬────────────────────────────────┐
│                                │                                │
│        Code Buffer             │        Claude Code             │
│     (your source files)        │     (eat terminal)             │
│                                │                                │
│   Navigate with SPC w h        │   Navigate with SPC w l        │
│                                │                                │
└────────────────────────────────┴────────────────────────────────┘

Setup:
  SPC w v          → Split right and focus
  SPC c l → s      → Start Claude Code in the new pane
  SPC w h          → Back to code
```

---

## Slash Commands & Skills

Claude Code supports slash commands typed directly in the terminal.

### Built-in Commands

| Command | Description |
|---------|-------------|
| `/help` | Show help and available commands |
| `/clear` | Clear conversation history and start fresh |
| `/compact` | Compress conversation to save context window |
| `/cost` | Show token usage and cost for current session |
| `/doctor` | Check Claude Code health and configuration |
| `/init` | Create a CLAUDE.md project instructions file |
| `/review` | Review a pull request |
| `/fast` | Toggle fast mode (same model, faster output) |

### Context Management

| Command | Description |
|---------|-------------|
| `/clear` | Reset conversation (use when context gets cluttered) |
| `/compact` | Summarize conversation to free up context space |
| `/cost` | Check how much context you've used |

> **Tip**: Use `/compact` before hitting context limits. Use `/clear` to start completely fresh.

---

## Claude Code CLI Usage

### Starting Claude Code

```bash
# Start in current directory (interactive)
claude

# Start with an initial prompt
claude "explain the project structure"

# Non-interactive: run a single task and exit
claude -p "list all TODO comments in the codebase"

# Continue the most recent conversation
claude --continue

# Resume a specific conversation
claude --resume
```

### Permission Modes

Claude Code asks for approval before taking actions. You can configure the trust level:

| Mode | Description |
|------|-------------|
| **Default** | Asks before file writes and shell commands |
| **Approve all** | Maximum safety, asks for every action |
| **Trust project** | Reads project CLAUDE.md for pre-approved actions |

### CLAUDE.md Project Instructions

Create a `CLAUDE.md` in your project root to give Claude persistent context:

```bash
# Inside Claude Code
/init
```

This file can contain:
- Project description and architecture
- Build/test commands
- Coding conventions
- Files Claude should or should not modify

---

## MCP Servers

Claude Code supports Model Context Protocol (MCP) servers for extended capabilities.

### What are MCP Servers?

MCP servers provide Claude with additional tools beyond its built-in capabilities. The Emacs integration itself uses MCP to expose Emacs tools (diagnostics, xref, etc.) to Claude.

### Configuring MCP Servers

MCP servers are configured in `~/.claude/settings.json` or per-project in `.claude/settings.json`:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "some-mcp-server"]
    }
  }
}
```

### Useful MCP Servers

| Server | Purpose |
|--------|---------|
| **ide (Emacs)** | Already configured - provides diagnostics, xref, imenu |
| **context7** | Documentation lookup for libraries and frameworks |
| **filesystem** | Extended filesystem operations |
| **github** | GitHub API integration (PRs, issues, etc.) |

---

## Configuration

### Claude Code Settings

Global settings are stored in `~/.claude/settings.json`. Project-level settings go in `.claude/settings.json`.

### Key Configuration Files

| File | Purpose |
|------|---------|
| `~/.claude/settings.json` | Global Claude Code settings |
| `.claude/settings.json` | Project-level settings |
| `CLAUDE.md` | Project instructions for Claude (in project root) |
| `~/.claude/keybindings.json` | Custom CLI keybindings |

### Emacs-Side Configuration

All Emacs configuration lives in `config.el`:

```elisp
(use-package! claude-code-ide
  :config
  (setq claude-code-ide-terminal-backend 'eat)  ; Use eat terminal
  (claude-code-ide-emacs-tools-setup))           ; Enable Emacs tools

(map! :leader
      (:prefix ("c" . "code")
       :desc "Claude Code menu" "l" #'claude-code-ide-menu))
```

To change the menu keybinding, modify the `map!` binding. For example, to use `SPC c a`:

```elisp
:desc "Claude Code menu" "a" #'claude-code-ide-menu
```

---

## Tips & Best Practices

### Effective Prompting

- **Be specific**: "Add a `validate_email/1` function to `lib/auth.ex`" is better than "add validation"
- **Reference files**: Claude can see your project, but mentioning file paths helps focus
- **Use insert selection**: Instead of describing code, select it and send with `SPC c l i`
- **Iterate**: Start with a small change, verify it works, then ask for more

### Context Management

- Use `/compact` when the conversation gets long to avoid hitting context limits
- Use `/clear` when switching to a completely different task
- Select only relevant code before using `SPC c l i` instead of sending entire files
- Use `CLAUDE.md` so Claude doesn't need to rediscover project conventions each session

### Working with Evil Mode

Claude Code runs in an `eat` terminal buffer. When inside the terminal:

- The buffer is in `insert` state by default (you can type directly)
- Press `ESC` or `C-[` to enter normal state for scrolling/copying
- Press `i` or `a` to return to insert state and type prompts
- Use `SPC c l` from any buffer to access the Claude Code menu
- Use `SPC c l b` to quickly switch back to the Claude terminal

### Using with Magit

After Claude makes changes, use Doom's magit integration to review:

```
SPC g g             → Open magit status
TAB on a file       → Expand diff
s                   → Stage a file
c c                 → Commit
```

### Using with Relative Line Numbers

This setup uses relative line numbers (`display-line-numbers-type 'relative`). When telling Claude about specific code locations, use absolute line numbers (shown in the gutter when cursor is on that line) or reference function/variable names instead.

---

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| `SPC c l` doesn't work | Run `doom sync` and restart Emacs |
| Claude Code won't start | Check `claude --version` in a terminal outside Emacs |
| `eat` not found | Verify `(package! eat)` is in `packages.el`, then `doom sync` |
| No diagnostics available | Ensure an LSP server is running for your language |
| API key errors | Set `ANTHROPIC_API_KEY` in your shell profile or use `claude login` |
| Buffer not updating after edits | Enable `global-auto-revert-mode` or press `g r` on the file |
| Terminal rendering issues | Try `(setq eat-term-scrollback-size 131072)` for more scrollback |

### Verify the Integration

```elisp
;; In Emacs, evaluate (M-x eval-expression or M-:)
(require 'claude-code-ide)          ;; Should load without error
claude-code-ide-terminal-backend    ;; Should return 'eat
```

### Check Claude Code Health

```bash
# In a terminal or inside Claude Code
claude /doctor
```

### Reset Claude Code State

```bash
# Clear conversation history
# Inside Claude Code:
/clear

# Reset all settings (use with caution)
rm -rf ~/.claude
claude  # Will re-initialize on first run
```

---

## Command Reference

### Emacs Commands

| Command | Keybinding | Description |
|---------|------------|-------------|
| `claude-code-ide-menu` | `SPC c l` | Open the Claude Code action menu |
| `claude-code-ide` | `SPC c l s` | Start a new Claude Code session |
| `claude-code-ide-continue` | `SPC c l c` | Continue most recent conversation |
| `claude-code-ide-resume` | `SPC c l r` | Resume a previous conversation |
| `claude-code-ide-stop` | `SPC c l q` | Stop the current session |
| `claude-code-ide-list-sessions` | `SPC c l l` | List all sessions |
| `claude-code-ide-switch-to-buffer` | `SPC c l b` | Switch to Claude Code buffer |
| `claude-code-ide-toggle-window` | `SPC c l w` | Toggle Claude Code window visibility |
| `claude-code-ide-insert-at-mentioned` | `SPC c l i` | Send selected text to Claude |
| `claude-code-ide-send-prompt` | `SPC c l p` | Send prompt from minibuffer |

### Claude Code CLI Flags

```bash
claude                          # Start interactive session
claude "prompt"                 # Start with initial prompt
claude -p "prompt"              # Non-interactive single task
claude --continue               # Continue last conversation
claude --resume                 # Resume a specific past conversation
claude --model <model>          # Use a specific model
claude --version                # Show version
claude config                   # Open configuration
```

### Useful Doom Keybindings for Claude Code Workflow

| Keybinding | Action |
|------------|--------|
| `SPC w v` | Split window right and focus |
| `SPC w s` | Split window below and focus |
| `SPC w h/j/k/l` | Navigate windows |
| `SPC w d` | Delete window |
| `SPC b b` | Switch buffer |
| `SPC g g` | Magit status (review changes) |
| `SPC s p` | Search project (vertico) |
| `SPC f f` | Find file |
| `SPC p p` | Switch project |

---

*Last updated: February 2026*
*Compatible with Claude Code CLI and claude-code-ide.el*
