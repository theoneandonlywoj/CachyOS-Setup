# Google Antigravity + Claude Code Guide

A comprehensive guide to integrating Claude Code with Google Antigravity IDE and mastering keyboard shortcuts on CachyOS (Linux).

---

## Table of Contents

1. [Overview](#overview)
2. [Claude Code Integration Setup](#claude-code-integration-setup)
3. [Claude Code Shortcuts](#claude-code-shortcuts)
4. [Antigravity Native Shortcuts](#antigravity-native-shortcuts)
5. [Agent Context & Workflow Commands](#agent-context--workflow-commands)
6. [Quick Reference Card](#quick-reference-card)
7. [Customizing Keybindings](#customizing-keybindings)
8. [Recommended Extensions](#recommended-extensions)
9. [Multi-Agent Workflow Tips](#multi-agent-workflow-tips)
10. [Troubleshooting](#troubleshooting)
11. [Configuration Files](#configuration-files)
12. [Memory Aid](#memory-aid)

---

## Overview

**Google Antigravity** is Google's agent-first IDE, built on the VS Code engine. It ships with Gemini 3 Pro and supports third-party models including Claude Sonnet 4.5.

**Claude Code** is Anthropic's CLI and IDE extension for Claude. Since Antigravity is VS Code-based, the Claude Code extension installs and works natively — giving you Claude's reasoning capabilities alongside Antigravity's built-in Gemini agent.

### Why Use Both?

- **Gemini** excels at planning, scaffolding, and Google Cloud integration
- **Claude Code** excels at high-quality implementation, complex refactoring, and deep reasoning
- When Gemini rate limits hit, switch to Claude Code and keep shipping
- Two independent agents = two different perspectives on your code

---

## Claude Code Integration Setup

### 1. Install the Extension

```
Ctrl+Shift+X → Search "Claude Code" → Install (by Anthropic)
```

After installation, the **Spark icon** appears in the Activity Bar (left sidebar).

> **Note:** If the Spark icon doesn't appear, reload the window: `Ctrl+Shift+P` → "Developer: Reload Window"

### 2. Authenticate

1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Create an account and add billing credits (minimum ~$5)
3. Go to **Get API Keys** → **Create Key**
4. Copy the key (shown only once)
5. Open Claude Code in Antigravity and sign in when prompted

Alternatively, set the key in your environment:

```bash
set -Ux ANTHROPIC_API_KEY sk-ant-...
```

### 3. Open Claude Code

| Method | How |
|--------|-----|
| Sidebar | Click the Spark icon in the Activity Bar |
| Focus toggle | `Ctrl+Esc` — toggles focus between editor and Claude |
| New tab | `Ctrl+Shift+Esc` — opens Claude as an editor tab |
| Terminal CLI | `` Ctrl+` `` to open terminal, then type `claude` |

### 4. Configure the Extension

Open settings: `Ctrl+,` → Extensions → Claude Code

| Setting | Default | Description |
|---------|---------|-------------|
| `selectedModel` | `default` | Model for new conversations |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, `auto` |
| `preferredLocation` | `panel` | `sidebar` or `panel` (editor tab) |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use `Ctrl+Enter` instead of `Enter` to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |

### 5. File References with @-Mentions

Press `Alt+K` to insert a file reference with exact line ranges. Claude will read those lines as context.

---

## Claude Code Shortcuts

These shortcuts control the Claude Code extension within Antigravity.

### Extension Commands

| Shortcut | Action | Context |
|----------|--------|---------|
| `Ctrl+Esc` | Toggle focus between editor and Claude | Anywhere |
| `Ctrl+Shift+Esc` | Open Claude in new editor tab | Anywhere |
| `Ctrl+N` | New conversation | Claude panel focused |
| `Alt+K` | Insert @-mention (file reference) | Claude input focused |
| `Ctrl+Shift+P` | Command Palette (search "Claude Code") | Anywhere |

### Chat Actions (Claude Input)

| Shortcut | Action |
|----------|--------|
| `Enter` | Send message |
| `Escape` | Cancel current input |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+P` / `Meta+P` | Open model picker |
| `Ctrl+T` / `Meta+T` | Toggle extended thinking |
| `Meta+O` | Toggle fast mode |
| `Ctrl+G` | Open in external editor |
| `Ctrl+S` | Stash current prompt |
| `Ctrl+V` | Paste image |

### App Actions

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel current operation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+T` | Toggle task list |
| `Ctrl+O` | Toggle verbose transcript |
| `Ctrl+R` | Search conversation history |

### Diff Review

| Shortcut | Action |
|----------|--------|
| `Escape` | Close diff viewer |
| `Up/Down` | Navigate between files |
| `Left/Right` | Navigate between sources |
| `Enter` | View diff details |

---

## Antigravity Native Shortcuts

Standard Antigravity shortcuts for Linux (CachyOS). Since Antigravity is VS Code-based, most VS Code shortcuts carry over.

### Agent / AI

| Shortcut | Action |
|----------|--------|
| `Ctrl+L` | Toggle/focus Agent panel (Gemini) |
| `Ctrl+E` | Toggle between Agent Manager and Editor |
| `Ctrl+Shift+M` | Toggle between Editor and Manager View |
| `Ctrl+I` | Inline AI command (editor and terminal) |
| `Ctrl+Shift+I` | Open/focus Agent panel |
| `Ctrl+Shift+L` | New conversation thread |
| `Tab` | Accept AI code completion |
| `Esc` | Dismiss AI suggestion |

### Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl+P` | Quick Open (file search) |
| `Ctrl+Shift+P` | Command Palette |
| `Ctrl+Shift+E` | Focus File Explorer |
| `Ctrl+Shift+F` | Search across project |
| `Ctrl+B` | Toggle sidebar |
| `F12` | Go to definition |
| `Ctrl+Click` | Go to definition (mouse) |
| `Shift+F12` | Find all references |
| `Ctrl+G` | Go to line number |
| `Ctrl+-` | Navigate back |

### Editor

| Shortcut | Action |
|----------|--------|
| `Ctrl+D` | Select next occurrence |
| `Ctrl+Shift+L` | Select all occurrences |
| `Alt+Up/Down` | Move line up/down |
| `Ctrl+Shift+K` | Delete line |
| `Ctrl+/` | Toggle line comment |
| `Ctrl+Z` | Undo |
| `Ctrl+Shift+Z` | Redo |
| `Ctrl+Shift+[` | Fold code block |
| `Ctrl+Shift+]` | Unfold code block |
| `Ctrl+\` | Split editor vertically |
| `Ctrl+1/2/3` | Focus editor group 1/2/3 |

### Terminal

| Shortcut | Action |
|----------|--------|
| `` Ctrl+` `` | Toggle integrated terminal |
| `` Ctrl+Shift+` `` | New terminal instance |
| `Ctrl+I` (in terminal) | Inline AI command |
| `Ctrl+K` (in terminal) | Clear terminal |
| `Ctrl+C` | Interrupt process |

### Git

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+G` | Open Source Control panel |
| `Ctrl+Enter` (in SCM) | Commit staged changes |

For other git operations, use the Command Palette (`Ctrl+Shift+P`):

| Command | Action |
|---------|--------|
| `Git: Stage All Changes` | Stage all files |
| `Git: Pull` | Pull from remote |
| `Git: Push` | Push to remote |
| `Git: Sync` | Pull + Push |

### Appearance

| Shortcut | Action |
|----------|--------|
| `Ctrl+K Ctrl+T` | Color Theme picker |
| `Ctrl+,` | Open Settings |
| `Ctrl+=` | Zoom in |
| `Ctrl+-` | Zoom out |
| `Ctrl+0` | Reset zoom |
| `Ctrl+Shift+V` | Markdown preview |

---

## Agent Context & Workflow Commands

### Context Commands (@ prefix in agent chat)

Type these in the Antigravity agent panel to provide context:

| Command | Description |
|---------|-------------|
| `@workspace` | Include entire project context |
| `@file` | Reference a specific file |
| `@terminal` | Send terminal output |
| `@problems` | Attach Problems panel diagnostics |
| `@selection` | Pass currently selected text |
| `@codebase` | Search indexed files |
| `@Supabase` | Connect to Supabase MCP |
| `@Firebase` | Connect to Firebase MCP |
| `@Cloudflare` | Connect to Cloudflare MCP |

### Workflow Commands (/ prefix in agent chat)

| Command | Description |
|---------|-------------|
| `/generate-unit-tests` | Create unit tests for selection |
| `/fix-errors` | Batch fix Problems panel errors |
| `/explain` | Explain selected code block |
| `/refactor` | Improve readability/performance |
| `/document` | Add JSDoc/docstrings |
| `/review` | Review code for issues |
| `/test` | Run tests |
| `/deploy` | Trigger deployment workflow |

Custom workflows are saved prompt templates invoked with `/` prefix.

---

## Quick Reference Card

```
┌──────────────────────────────────────────────────────────────┐
│  CLAUDE CODE (in Antigravity)                                │
│  ─────────────────────────                                   │
│  Ctrl+Esc           → Toggle focus editor ↔ Claude           │
│  Ctrl+Shift+Esc     → Open Claude in new tab                 │
│  Ctrl+N             → New conversation (Claude focused)      │
│  Alt+K              → Insert @-mention (file ref)            │
│  Enter              → Send message                           │
│  Escape             → Cancel input                           │
│  Shift+Tab          → Cycle permission modes                 │
│  Ctrl+R             → Search history                         │
│                                                              │
│  ANTIGRAVITY AGENT (Gemini)                                  │
│  ───────────────────────────                                 │
│  Ctrl+L             → Toggle Agent panel                     │
│  Ctrl+E             → Agent Manager ↔ Editor                 │
│  Ctrl+I             → Inline AI (editor/terminal)            │
│  Ctrl+Shift+I       → Open Agent panel                       │
│  Tab                → Accept AI completion                   │
│  Esc                → Dismiss AI suggestion                  │
│                                                              │
│  NAVIGATION                                                  │
│  ──────────                                                  │
│  Ctrl+P             → Quick Open (file search)               │
│  Ctrl+Shift+P       → Command Palette                        │
│  Ctrl+Shift+F       → Global search                          │
│  Ctrl+B             → Toggle sidebar                         │
│  F12                → Go to definition                       │
│  Ctrl+G             → Go to line                             │
│                                                              │
│  EDITOR                                                      │
│  ──────                                                      │
│  Ctrl+D             → Select next occurrence                 │
│  Alt+↑/↓            → Move line up/down                      │
│  Ctrl+Shift+K       → Delete line                            │
│  Ctrl+/             → Toggle comment                         │
│  Ctrl+\             → Split editor                           │
│                                                              │
│  TERMINAL                                                    │
│  ────────                                                    │
│  Ctrl+`             → Toggle terminal                        │
│  Ctrl+Shift+`       → New terminal                           │
│                                                              │
│  GIT                                                         │
│  ───                                                         │
│  Ctrl+Shift+G       → Source Control                         │
│  Ctrl+Enter         → Commit (in SCM)                        │
└──────────────────────────────────────────────────────────────┘
```

---

## Customizing Keybindings

### Antigravity Keybindings

Open the keybindings editor:

```
Ctrl+Shift+P → "Preferences: Open Keyboard Shortcuts (JSON)"
```

Or edit the file directly at:

```
~/.config/Antigravity/User/keybindings.json
```

Example — one-keystroke stage + AI commit + sync:

```json
[
  {
    "key": "ctrl+alt+enter",
    "command": "runCommands",
    "args": {
      "commands": [
        "git.stageAll",
        "workbench.action.antigravity.generateCommitMessage",
        "git.commitStaged",
        "git.sync"
      ]
    }
  }
]
```

### Claude Code Keybindings

Claude Code has its own keybindings file:

```
~/.claude/keybindings.json
```

Run `/keybindings` inside Claude Code to create/edit it. Format:

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

**Key syntax:**
- Modifiers: `ctrl`, `alt`/`opt`, `shift`, `meta`/`cmd`
- Chords: `ctrl+k ctrl+s` (sequence of key combos)
- Unbind: set to `null`
- Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`

**Available contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `DiffDialog`, `ModelPicker`

---

## Recommended Extensions

| Extension | ID | Purpose |
|-----------|----|---------|
| **Claude Code** | `anthropic.claude-code` | Claude AI integration |
| **GitLens** | `eamodio.gitlens` | Git blame, history, diff |
| **Error Lens** | `usernamehw.errorlens` | Inline error highlighting |

### Installation

```
Ctrl+Shift+X → Search extension name → Install
```

---

## Multi-Agent Workflow Tips

### Gemini + Claude Code Strategy

1. **Planning phase** — Use Antigravity's built-in Gemini agent (`Ctrl+L`) for architecture, scaffolding, and planning. This saves Claude tokens.

2. **Implementation phase** — Switch to Claude Code (`Ctrl+Esc`) for complex implementation, refactoring, and bug fixing where deep reasoning matters.

3. **Rate limit fallback** — When Gemini rate limits hit, Claude Code keeps you productive. When Claude limits hit, switch back to Gemini.

### Switching Between Agents

| Agent | Access | Best For |
|-------|--------|----------|
| Gemini (built-in) | `Ctrl+L` | Planning, Google Cloud, quick scaffolding |
| Claude Code | `Ctrl+Esc` / Spark icon | Complex implementation, reasoning, refactoring |
| Claude CLI | Terminal → `claude` | Full CLI power, scripts, automation |

### Tips

- Use `@workspace` in Gemini for broad context, `Alt+K` in Claude for precise file references
- Both agents can read your terminal output — pick whichever is faster
- Claude Code's `/` skills (like `/commit`) work independently of Antigravity's `/` workflows

---

## Troubleshooting

### Shortcuts Not Working?

1. **Check for conflicts:** `Ctrl+K` then `Ctrl+S` → search your key combination
2. **Verify context:** Some shortcuts only work when specific panels are focused
3. **Test key recognition:** In Keyboard Shortcuts, click the search box and press your combo

### Common Issues

| Problem | Solution |
|---------|----------|
| Spark icon not visible | Reload window (`Ctrl+Shift+P` → "Developer: Reload Window"), check VS Code 1.98.0+ |
| Claude not responding | Check API key and billing at console.anthropic.com |
| Right Alt not working | Use Left Alt only — Right Alt is `AltGr` on many Linux layouts |
| `Ctrl+I` conflict | Antigravity v1.20.5 has a known conflict with Trigger Suggest; rebind in keybindings.json |
| Conflicting AI extensions | Disable other AI extensions (Cline, Continue) if Spark icon doesn't appear |
| `Ctrl+E` not toggling views | Ensure Antigravity is updated to v1.20+ |

### Right Alt Key (AltGr) on Linux

On Linux with many keyboard layouts, the **Right Alt key** is `AltGr` (Alt Graph) and **will not work** as a regular Alt modifier.

**Fix — remap Right Alt:**

```bash
# KDE Plasma (CachyOS default)
# System Settings → Input Devices → Keyboard → Advanced
# Set "Key to choose 3rd level" to "None"

# Using setxkbmap (X11, temporary)
setxkbmap -option "lv3:ralt_alt"

# Test your keys
xev | grep -A2 KeyPress
# If Right Alt shows "ISO_Level3_Shift" → it's AltGr
# If it shows "Alt_R" → it works as regular Alt
```

---

## Configuration Files

| File | Path |
|------|------|
| Antigravity keybindings | `~/.config/Antigravity/User/keybindings.json` |
| Antigravity settings | `~/.config/Antigravity/User/settings.json` |
| Claude Code keybindings | `~/.claude/keybindings.json` |
| Claude Code settings | `~/.claude/settings.json` |
| Claude Code project settings | `.claude/settings.json` (in project root) |

---

## Memory Aid

```
CLAUDE CODE
  Ctrl+Esc       → Escape to Claude (toggle focus)
  Ctrl+Shift+Esc → Shift it out to a new tab
  Alt+K          → @-mention (K for kontext)
  Ctrl+R         → Recall history

ANTIGRAVITY AGENT
  L = Launch agent panel         (Ctrl+L)
  E = Editor ↔ Agent toggle      (Ctrl+E)
  I = Inline AI command           (Ctrl+I)

NAVIGATION
  P = open file (Ctrl+P)
  Shift+P = Palette (Ctrl+Shift+P)
  Shift+F = Find in project (Ctrl+Shift+F)
  B = sidebar Bar (Ctrl+B)
  G = Go to line (Ctrl+G)

EDITOR
  D = next Duplicate selection    (Ctrl+D)
  / = comment slash               (Ctrl+/)
  Alt+↑↓ = move lines

GIT
  Shift+G = Git panel             (Ctrl+Shift+G)
  Enter = commit                  (Ctrl+Enter in SCM)
```

---

*Generated for CachyOS (Linux) — Antigravity v1.20.6, Claude Code VS Code extension*
*Last updated: March 2026*
