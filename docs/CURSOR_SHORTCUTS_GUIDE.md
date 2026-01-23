# Cursor IDE Keyboard Shortcuts Guide

A comprehensive guide to custom keyboard shortcuts for Cursor IDE, covering AI mode switching, agent control, window management, and Git operations.

---

## Table of Contents

1. [Overview](#overview)
2. [macOS Shortcuts](#macos-shortcuts)
3. [Linux Shortcuts](#linux-shortcuts)
4. [Required Extensions](#required-extensions)
5. [Troubleshooting](#troubleshooting)

---

## Overview

These shortcuts use a consistent modifier pattern:

| OS | Base Modifiers | With Shift (reverse/alternative) |
|----|----------------|----------------------------------|
| macOS | `Cmd + Option + [key]` | `Cmd + Option + Shift + [key]` |
| Linux | `Ctrl + Alt + [key]` | `Ctrl + Alt + Shift + [key]` |

### Key Concepts

- **Cycle Count**: Controls how many iterations the agent can run autonomously before pausing for user confirmation. Higher = more autonomous, lower = more control.
- **Auto Mode**: When enabled, the agent auto-approves tool calls. When disabled, you must approve each action.
- **Modes**: Ask (read-only Q&A), Agent (can make changes), Plan (collaborative design), Debug (troubleshooting)

---

## macOS Shortcuts

### AI Modes & Control

| Shortcut | Action | Context |
|----------|--------|---------|
| `Cmd + Option + A` | Toggle Auto Mode | Chat panel focused |
| `Cmd + Option + G` | Switch to Agent mode | Chat panel focused |
| `Cmd + Option + K` | Switch to Ask mode | Chat panel focused |
| `Cmd + Option + P` | Switch to Plan mode | Chat panel focused |
| `Cmd + Option + D` | Switch to Debug mode | Chat panel focused |
| `Cmd + Option + ↑` | Increase Cycle Count | Chat panel focused |
| `Cmd + Option + ↓` | Decrease Cycle Count | Chat panel focused |
| `Cmd + Option + M` | List MCP Tools | Anywhere |

### Window Management

| Shortcut | Action | Context |
|----------|--------|---------|
| `Cmd + Option + Enter` | Maximize agent panel | Panel focused |
| `Cmd + Option + Shift + Enter` | Restore panel size | Panel maximized |
| `Cmd + Option + O` | Detach as separate window | Chat focused |
| `Cmd + Option + Shift + O` | Re-attach / dock back | Chat focused |

### Git Operations

| Shortcut | Action | Context |
|----------|--------|---------|
| `Cmd + Option + B` | Toggle line blame | Editor focused |
| `Cmd + Option + Shift + B` | Toggle file blame (full annotations) | Editor focused |
| `Cmd + Option + H` | Show file history | Editor focused |
| `Cmd + Option + Shift + H` | Show line history | Editor focused |
| `Cmd + Option + C` | Diff with previous revision | Editor focused |
| `Cmd + Option + Shift + C` | Diff with HEAD | Editor focused |
| `Cmd + Option + S` | Stage current file | Anywhere |
| `Cmd + Option + Shift + S` | Unstage current file | Anywhere |
| `Cmd + Option + Shift + C` | Git commit | Outside editor |
| `Cmd + Option + Shift + P` | Git push | Anywhere |
| `Cmd + Option + Shift + L` | Git pull | Anywhere |
| `Cmd + Option + F` | Git fetch | Anywhere |
| `Cmd + Option + Shift + G` | Open Source Control view | Anywhere |
| `Cmd + Option + .` | Show commit details for line | Editor focused |
| `Cmd + Option + R` | Open file on GitHub/remote | Editor focused |

### Quick Reference Card (macOS)

```
┌─────────────────────────────────────────────────────────────┐
│  ⌘ + ⌥ (Cmd + Option) + ...                                 │
│                                                             │
│  AI MODES                                                   │
│  ────────                                                   │
│  A             → Toggle Auto mode                           │
│  G             → aGent mode                                 │
│  K             → asK mode                                   │
│  P             → Plan mode                                  │
│  D             → Debug mode                                 │
│  ↑             → Increase cycle count                       │
│  ↓             → Decrease cycle count                       │
│  M             → MCP tools list                             │
│                                                             │
│  WINDOW                                                     │
│  ──────                                                     │
│  Enter         → Maximize agent window                      │
│  Shift+Enter   → Restore window size                        │
│  O             → Detach (pop Out)                           │
│  Shift+O       → Re-attach (dock)                           │
│                                                             │
│  GIT OPERATIONS                                             │
│  ──────────────                                             │
│  B             → Line blame                                 │
│  Shift+B       → File blame                                 │
│  H             → File history                               │
│  Shift+H       → Line history                               │
│  C             → Diff with previous                         │
│  Shift+C       → Diff with HEAD / Commit (outside editor)   │
│  S             → Stage file                                 │
│  Shift+S       → Unstage file                               │
│  Shift+P       → Push                                       │
│  Shift+L       → Pull                                       │
│  F             → Fetch                                      │
│  Shift+G       → Source Control view                        │
│  .             → Show commit details                        │
│  R             → Open on GitHub                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Linux Shortcuts

### AI Modes & Control

| Shortcut | Action | Context |
|----------|--------|---------|
| `Ctrl + Alt + A` | Toggle Auto Mode | Chat panel focused |
| `Ctrl + Alt + G` | Switch to Agent mode | Chat panel focused |
| `Ctrl + Alt + K` | Switch to Ask mode | Chat panel focused |
| `Ctrl + Alt + P` | Switch to Plan mode | Chat panel focused |
| `Ctrl + Alt + D` | Switch to Debug mode | Chat panel focused |
| `Ctrl + Alt + ↑` | Increase Cycle Count | Chat panel focused |
| `Ctrl + Alt + ↓` | Decrease Cycle Count | Chat panel focused |
| `Ctrl + Alt + M` | List MCP Tools | Anywhere |

### Window Management

| Shortcut | Action | Context |
|----------|--------|---------|
| `Ctrl + Alt + Enter` | Maximize agent panel | Panel focused |
| `Ctrl + Alt + Shift + Enter` | Restore panel size | Panel maximized |
| `Ctrl + Alt + O` | Detach as separate window | Chat focused |
| `Ctrl + Alt + Shift + O` | Re-attach / dock back | Chat focused |

### Git Operations

| Shortcut | Action | Context |
|----------|--------|---------|
| `Ctrl + Alt + B` | Toggle line blame | Editor focused |
| `Ctrl + Alt + Shift + B` | Toggle file blame (full annotations) | Editor focused |
| `Ctrl + Alt + H` | Show file history | Editor focused |
| `Ctrl + Alt + Shift + H` | Show line history | Editor focused |
| `Ctrl + Alt + C` | Diff with previous revision | Editor focused |
| `Ctrl + Alt + Shift + C` | Diff with HEAD | Editor focused |
| `Ctrl + Alt + S` | Stage current file | Anywhere |
| `Ctrl + Alt + Shift + S` | Unstage current file | Anywhere |
| `Ctrl + Alt + Shift + C` | Git commit | Outside editor |
| `Ctrl + Alt + Shift + P` | Git push | Anywhere |
| `Ctrl + Alt + Shift + L` | Git pull | Anywhere |
| `Ctrl + Alt + F` | Git fetch | Anywhere |
| `Ctrl + Alt + Shift + G` | Open Source Control view | Anywhere |
| `Ctrl + Alt + .` | Show commit details for line | Editor focused |
| `Ctrl + Alt + R` | Open file on GitHub/remote | Editor focused |

### Quick Reference Card (Linux)

```
┌─────────────────────────────────────────────────────────────┐
│  Ctrl + Alt + ...                                           │
│                                                             │
│  AI MODES                                                   │
│  ────────                                                   │
│  A             → Toggle Auto mode                           │
│  G             → aGent mode                                 │
│  K             → asK mode                                   │
│  P             → Plan mode                                  │
│  D             → Debug mode                                 │
│  ↑             → Increase cycle count                       │
│  ↓             → Decrease cycle count                       │
│  M             → MCP tools list                             │
│                                                             │
│  WINDOW                                                     │
│  ──────                                                     │
│  Enter         → Maximize agent window                      │
│  Shift+Enter   → Restore window size                        │
│  O             → Detach (pop Out)                           │
│  Shift+O       → Re-attach (dock)                           │
│                                                             │
│  GIT OPERATIONS                                             │
│  ──────────────                                             │
│  B             → Line blame                                 │
│  Shift+B       → File blame                                 │
│  H             → File history                               │
│  Shift+H       → Line history                               │
│  C             → Diff with previous                         │
│  Shift+C       → Diff with HEAD / Commit (outside editor)   │
│  S             → Stage file                                 │
│  Shift+S       → Unstage file                               │
│  Shift+P       → Push                                       │
│  Shift+L       → Pull                                       │
│  F             → Fetch                                      │
│  Shift+G       → Source Control view                        │
│  .             → Show commit details                        │
│  R             → Open on GitHub                             │
└─────────────────────────────────────────────────────────────┘
```

### Linux-Specific Note: Right Alt Key (AltGr)

On Linux with many keyboard layouts, the **Right Alt key** is mapped as `AltGr` (Alt Graph), which is used for special characters and **will NOT work** as a regular Alt modifier.

**Solutions:**

1. **Use Left Alt only** (recommended - works out of the box)

2. **Remap Right Alt to regular Alt:**
   ```bash
   # GNOME (Ubuntu, Fedora, etc.)
   gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:ralt_alt']"
   
   # KDE Plasma
   # System Settings → Input Devices → Keyboard → Advanced
   # Set "Key to choose 3rd level" to "None"
   
   # Using setxkbmap (X11, temporary)
   setxkbmap -option "lv3:ralt_alt"
   
   # Make permanent - add to ~/.profile or ~/.xprofile
   ```

3. **Test your keys:**
   ```bash
   xev | grep -A2 KeyPress
   # Press Right Alt - if it shows "ISO_Level3_Shift", it's AltGr
   # If it shows "Alt_R", it will work as regular Alt
   ```

---

## Required Extensions

For full functionality of these shortcuts, install the following extensions:

| Extension | ID | Purpose |
|-----------|-----|---------|
| **GitLens** | `eamodio.gitlens` | Git blame, history, diff shortcuts |
| **ElixirLS** | `JakeBecker.elixir-ls` | Elixir format on save |
| **Cursor Quota Checker** | `sourabhr10122002.cursor-quota-checker` | Usage display in status bar |

### Installation

```
Cmd/Ctrl + Shift + X → Search extension name → Install
```

---

## Troubleshooting

### Shortcuts Not Working?

1. **Verify command names exist:**
   - Open Command Palette: `Cmd/Ctrl + Shift + P`
   - Search for "cursor" or "gitlens"
   - Note the exact command names

2. **Check for conflicts:**
   - Open Keyboard Shortcuts: `Cmd/Ctrl + K` then `Cmd/Ctrl + S`
   - Search for your key combination
   - Look for conflicting bindings

3. **Verify context:**
   - Some shortcuts only work in specific contexts (e.g., `editorTextFocus`, `cursorChatFocus`)
   - Make sure you're in the correct panel/view

4. **Test key recognition:**
   - In Keyboard Shortcuts, click the search box
   - Press your key combination
   - Cursor will show what it detects

### Common Issues

| Problem | Solution |
|---------|----------|
| Right Alt not working (Linux) | Use Left Alt, or remap with `setxkbmap -option "lv3:ralt_alt"` |
| Git shortcuts not working | Install GitLens extension |
| Mode switching not working | Cursor command names may differ by version - check Command Palette |
| Panel shortcuts not working | Make sure panel is focused (click on it first) |

---

## Configuration Files

These shortcuts are defined in:

| OS | Path |
|----|------|
| macOS | `~/Library/Application Support/Cursor/User/keybindings.json` |
| Linux | `~/.config/Cursor/User/keybindings.json` |

To edit: `Cmd/Ctrl + K` then `Cmd/Ctrl + S` → click file icon (top right) → Open JSON

---

## Memory Aid

```
Modifier: Cmd/Ctrl + Option/Alt

Letter Mnemonics:
  A = Auto toggle
  G = aGent mode
  K = asK mode  
  P = Plan mode
  D = Debug mode
  M = Mcp tools

  B = Blame
  H = History
  C = Compare/Commit
  S = Stage
  F = Fetch
  R = Remote (GitHub)
  O = pop Out (detach)

Shift = reverse/alternative action
  B → Shift+B = file blame instead of line
  S → Shift+S = unstage instead of stage
  O → Shift+O = attach instead of detach
```

---

*Generated based on keybindings.json configuration*
*Last updated: January 2026*
