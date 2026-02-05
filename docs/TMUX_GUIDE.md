# Tmux Guide for Elixir Phoenix Developers

A comprehensive guide to tmux, from basics to advanced workflows, optimized for Elixir Phoenix development with Doom Emacs compatibility.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Core Concepts](#core-concepts)
3. [Essential Keybindings](#essential-keybindings)
4. [Pane Management](#pane-management)
5. [Window Management](#window-management)
6. [Session Management](#session-management)
7. [Copy Mode](#copy-mode)
8. [Phoenix Development Workflows](#phoenix-development-workflows)
9. [Advanced Features](#advanced-features)
10. [Customization](#customization)
11. [Plugin Management](#plugin-management)
12. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Installation

```bash
# Install tmux
./tmux.fish

# Sync configuration (backup existing, install new, setup TPM)
make tmux-sync

# Start tmux
tmux
```

### 60-Second Crash Course

```bash
tmux                    # Start tmux
Ctrl+a |                # Split vertically (left/right)
Ctrl+a -                # Split horizontally (top/bottom)
Ctrl+a h/j/k/l          # Navigate panes (vim-style)
Ctrl+a d                # Detach (session keeps running)
tmux attach             # Reattach to session
```

---

## Core Concepts

### The Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│ SERVER                                                      │
│  └── SESSION (e.g., "phoenix-app")                          │
│       ├── WINDOW 1 (e.g., "editor")                         │
│       │    ├── PANE 1 (nvim)                                │
│       │    └── PANE 2 (terminal)                            │
│       └── WINDOW 2 (e.g., "servers")                        │
│            ├── PANE 1 (mix phx.server)                      │
│            └── PANE 2 (iex -S mix)                          │
└─────────────────────────────────────────────────────────────┘
```

| Concept | Description | Analogy |
|---------|-------------|---------|
| **Server** | Background process managing everything | The building |
| **Session** | Named collection of windows | A floor/department |
| **Window** | Full-screen container with tabs | A room |
| **Pane** | Split section within a window | A desk in the room |

### The Prefix Key

All tmux commands start with the **prefix key**: `Ctrl+a`

To execute a command:
1. Press `Ctrl+a` (release)
2. Press the command key

Example: To split vertically, press `Ctrl+a` then `|`

> **Note for Doom Emacs users**: `Ctrl+a` is safe because Evil mode uses `0` or `^` for beginning-of-line. If you ever need literal `Ctrl+a`, press `Ctrl+a Ctrl+a`.

---

## Essential Keybindings

### Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│  Prefix = Ctrl+a                                            │
│                                                             │
│  SESSIONS           WINDOWS           PANES                 │
│  ────────           ───────           ─────                 │
│  d    detach        c    create       |    split vertical   │
│  s    list          ,    rename       -    split horizontal │
│  $    rename        n    next         x    close            │
│  (    previous      p    previous     z    zoom (toggle)    │
│  )    next          w    list         hjkl navigate         │
│  S    new           Tab  last         HJKL resize           │
│                     1-9  go to #      y    sync panes       │
│                                                             │
│  COPY MODE          UTILITY           PHOENIX LAYOUTS       │
│  ─────────          ───────           ───────────────       │
│  Enter  start       r    reload       P    dev layout       │
│  v      select      b    toggle bar   T    test layout      │
│  y      copy        C-l  clear                              │
│  /      search                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Pane Management

### Creating Panes

| Keybinding | Action | Visual |
|------------|--------|--------|
| `prefix + \|` | Split vertically (left/right) | `[ \| ]` |
| `prefix + \\` | Split vertically (no shift) | `[ \| ]` |
| `prefix + -` | Split horizontally (top/bottom) | `[─]` |
| `prefix + _` | Split horizontally (with shift) | `[─]` |

### Navigating Panes (Vim-style)

| Keybinding | Action |
|------------|--------|
| `prefix + h` | Move left |
| `prefix + j` | Move down |
| `prefix + k` | Move up |
| `prefix + l` | Move right |

### Resizing Panes

| Keybinding | Action |
|------------|--------|
| `prefix + H` | Resize left (5 cells) |
| `prefix + J` | Resize down (5 cells) |
| `prefix + K` | Resize up (5 cells) |
| `prefix + L` | Resize right (5 cells) |
| `Alt + Arrow` | Fine resize (2 cells, no prefix) |

### Pane Operations

| Keybinding | Action |
|------------|--------|
| `prefix + z` | Zoom pane (toggle fullscreen) |
| `prefix + x` | Close pane (with confirmation) |
| `prefix + >` | Swap pane with next |
| `prefix + <` | Swap pane with previous |
| `prefix + y` | Toggle synchronized input |

### Synchronized Panes

Type in all panes simultaneously (useful for running same command on multiple servers):

```
prefix + y    → Toggle sync ON/OFF
```

When sync is ON, everything you type appears in ALL panes of the current window.

---

## Window Management

### Creating and Naming

| Keybinding | Action |
|------------|--------|
| `prefix + c` | Create new window |
| `prefix + ,` | Rename current window |

### Navigation

| Keybinding | Action |
|------------|--------|
| `prefix + n` | Next window |
| `prefix + p` | Previous window |
| `prefix + Tab` | Last used window |
| `prefix + 1-9` | Go to window by number |
| `prefix + w` | List all windows (interactive) |

### Window Tips

- Windows are numbered starting at 1 (matches keyboard)
- When you close a window, numbers auto-renumber
- Name your windows for easier navigation: `editor`, `server`, `tests`

---

## Session Management

### Basic Commands

| Command | Action |
|---------|--------|
| `tmux` | Start new session |
| `tmux new -s name` | Start named session |
| `tmux ls` | List sessions |
| `tmux attach` | Attach to last session |
| `tmux attach -t name` | Attach to named session |
| `tmux kill-session -t name` | Kill session |

### Keybindings (Inside tmux)

| Keybinding | Action |
|------------|--------|
| `prefix + d` | Detach from session |
| `prefix + s` | List sessions (interactive) |
| `prefix + $` | Rename session |
| `prefix + S` | Create new session |
| `prefix + (` | Previous session |
| `prefix + )` | Next session |

### Session Workflow

```bash
# Start a session for your project
tmux new -s phoenix-app

# ... work on your project ...

# Detach when done (session keeps running)
Ctrl+a d

# Later, reattach
tmux attach -t phoenix-app

# List all running sessions
tmux ls
```

---

## Copy Mode

Copy mode allows you to scroll, search, and copy text using vim keybindings.

### Entering Copy Mode

| Keybinding | Action |
|------------|--------|
| `prefix + Enter` | Enter copy mode |
| `prefix + [` | Enter copy mode (alternative) |

### Navigation in Copy Mode

| Key | Action |
|-----|--------|
| `h/j/k/l` | Move cursor (vim-style) |
| `Ctrl+u` | Page up |
| `Ctrl+d` | Page down |
| `g` | Go to top |
| `G` | Go to bottom |
| `w/b` | Word forward/backward |
| `0/$` | Beginning/end of line |

### Selection and Copy

| Key | Action |
|-----|--------|
| `v` | Start selection |
| `V` | Start line selection |
| `r` | Toggle rectangle selection |
| `y` | Copy selection and exit |
| `Escape` | Cancel and exit |

### Searching

| Key | Action |
|-----|--------|
| `/` | Search forward |
| `?` | Search backward |
| `n` | Next match |
| `N` | Previous match |

### Copy Mode Workflow

```
1. prefix + Enter       → Enter copy mode
2. Navigate to start    → Use h/j/k/l or search with /
3. Press v              → Start selection
4. Navigate to end      → Use movement keys
5. Press y              → Copy and exit
6. prefix + ]           → Paste (or use system paste)
```

---

## Phoenix Development Workflows

### Workflow 1: Standard Development Layout

Press `prefix + P` to auto-create this layout:

```
┌─────────────────────────────────────┬─────────────────────────────────────┐
│                                     │           Phoenix Server            │
│                                     │         $ mix phx.server            │
│            PANE 1                   ├─────────────────────────────────────┤
│           (Editor)                  │           IEx Console               │
│                                     │         $ iex -S mix                │
│                                     │                                     │
└─────────────────────────────────────┴─────────────────────────────────────┘
```

**Manual creation:**
```
prefix + |          → Split vertical
prefix + l          → Move to right pane
prefix + -          → Split horizontal
mix phx.server      → Start Phoenix
prefix + j          → Move to bottom pane
iex -S mix          → Start IEx
prefix + h          → Back to editor pane
```

### Workflow 2: Test-Driven Development

Press `prefix + T` to auto-create this layout:

```
┌─────────────────────────────────────┬─────────────────────────────────────┐
│                                     │           Test Watcher              │
│            Editor                   │   $ mix test --stale --listen...    │
│                                     │                                     │
└─────────────────────────────────────┴─────────────────────────────────────┘
```

### Workflow 3: Full-Stack Development

Use multiple windows for different concerns:

```
Window 1: backend     │ Window 2: frontend    │ Window 3: data
──────────────────────┼───────────────────────┼──────────────────
┌───────┬───────────┐ │ ┌───────────────────┐ │ ┌───────────────┐
│       │ phx.server│ │ │   npm run dev     │ │ │    psql       │
│ editor├───────────┤ │ │   (or esbuild)    │ │ │               │
│       │    iex    │ │ └───────────────────┘ │ ├───────────────┤
└───────┴───────────┘ │                       │ │  redis-cli    │
                      │                       │ └───────────────┘
```

**Setup:**
```bash
# Window 1: Backend (auto-created with prefix + P)
tmux new -s myapp -n backend
prefix + P

# Window 2: Frontend
prefix + c
prefix + , → rename to "frontend"
npm run dev

# Window 3: Database
prefix + c
prefix + , → rename to "data"
prefix + -
# Top pane: psql
# Bottom pane: redis-cli
```

### Workflow 4: Doom Emacs + Phoenix

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                        Doom Emacs (emacs -nw)                               │
│                                                                             │
├─────────────────────────────────────┬───────────────────────────────────────┤
│          Phoenix Server             │            IEx Console                │
│        $ mix phx.server             │          $ iex -S mix                 │
└─────────────────────────────────────┴───────────────────────────────────────┘
```

**Setup:**
```
prefix + -          → Split horizontal (editor on top)
emacs -nw .         → Start Doom Emacs in terminal
prefix + j          → Move to bottom
prefix + |          → Split vertical
mix phx.server      → Left: Phoenix
prefix + l          → Move right
iex -S mix          → Right: IEx
prefix + k          → Back to Emacs
```

### Workflow 5: Production Debugging

```bash
# SSH into production server
ssh prod-server

# Attach to existing tmux session (or create new)
tmux attach -t prod || tmux new -s prod

# Setup debugging layout
prefix + |
# Left: tail -f log/phoenix.log
# Right: bin/myapp remote (remote IEx)
```

---

## Advanced Features

### Command Line Usage

```bash
# Create session with specific layout
tmux new-session -s dev -n editor \; \
  split-window -h \; \
  split-window -v \; \
  select-pane -t 0

# Send keys to a specific pane
tmux send-keys -t dev:editor.1 "mix phx.server" Enter

# Run command in new window
tmux new-window -n tests "mix test.watch"
```

### Scripting Layouts

Create `~/.tmux/phoenix-layout.sh`:

```bash
#!/bin/bash
SESSION="phoenix"
PROJECT_DIR="$1"

# Create session
tmux new-session -d -s $SESSION -c "$PROJECT_DIR"

# Window 1: Development
tmux rename-window -t $SESSION:1 'dev'
tmux split-window -h -t $SESSION:dev -c "$PROJECT_DIR"
tmux split-window -v -t $SESSION:dev.2 -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:dev.2 'mix phx.server' Enter
tmux send-keys -t $SESSION:dev.3 'iex -S mix' Enter

# Window 2: Tests
tmux new-window -t $SESSION -n 'tests' -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:tests 'mix test.watch' Enter

# Window 3: Git
tmux new-window -t $SESSION -n 'git' -c "$PROJECT_DIR"

# Select first window, first pane
tmux select-window -t $SESSION:dev
tmux select-pane -t $SESSION:dev.1

# Attach
tmux attach -t $SESSION
```

Usage:
```bash
chmod +x ~/.tmux/phoenix-layout.sh
~/.tmux/phoenix-layout.sh ~/projects/my_phoenix_app
```

### Environment Variables

```bash
# Check if inside tmux
if [ -n "$TMUX" ]; then
  echo "Inside tmux"
fi

# Get current session name
tmux display-message -p '#S'

# Get current window name
tmux display-message -p '#W'
```

---

## Customization

### Configuration File

The configuration is stored in `~/.tmux.conf`. Key sections:

#### Prefix Key

```bash
# Change prefix to Ctrl+a
unbind C-b
set -g prefix C-a
bind C-a send-prefix  # Double-tap sends literal Ctrl+a
```

#### Colors (doom-one compatible)

```bash
set -g default-terminal "tmux-256color"
set -sa terminal-overrides ",xterm*:Tc"

# Status bar colors (doom-one theme)
set -g status-style 'bg=#282c34 fg=#bbc2cf'
set -g pane-active-border-style 'fg=#51afef'
```

#### Mouse

```bash
set -g mouse on
```

#### Vim-style Navigation

```bash
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

### Reload Configuration

```bash
# Inside tmux
prefix + r

# From command line
tmux source-file ~/.tmux.conf
```

---

## Plugin Management

### TPM (Tmux Plugin Manager)

TPM is installed automatically with `make tmux-sync`.

#### Manual Installation

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### Plugin Commands

| Keybinding | Action |
|------------|--------|
| `prefix + I` | Install plugins |
| `prefix + U` | Update plugins |
| `prefix + Alt+u` | Remove unused plugins |

### Included Plugins

| Plugin | Purpose |
|--------|---------|
| `tmux-sensible` | Sensible default settings |
| `tmux-resurrect` | Save/restore sessions (survives reboot) |
| `tmux-continuum` | Auto-save sessions every 15 minutes |
| `tmux-yank` | System clipboard integration |

### Using Resurrect

```
prefix + Ctrl+s     → Save session
prefix + Ctrl+r     → Restore session
```

Sessions are saved to `~/.tmux/resurrect/`

---

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Colors look wrong | Ensure terminal supports true color; check `$TERM` |
| Escape delay in vim/Evil | `escape-time` should be 0 (already configured) |
| Mouse not working | Check `set -g mouse on` in config |
| Copy not working | Install `xclip` or `xsel` for clipboard |
| Plugins not loading | Run `prefix + I` to install |

### Verify True Color Support

```bash
# Test true color
curl -s https://raw.githubusercontent.com/JohnMorris/dotfiles/master/colors/24-bit-color.sh | bash
```

### Check Tmux Version

```bash
tmux -V
# Should be 3.0+ for all features
```

### Reset to Default

```bash
# Restore from backup
make tmux-restore

# Or remove config entirely
rm ~/.tmux.conf
```

### Debug Mode

```bash
# Start tmux with verbose logging
tmux -vv new-session
# Check ~/.tmux-server-*.log
```

---

## Command Reference

### External Commands

```bash
tmux                          # Start new session
tmux new -s NAME              # Start named session
tmux ls                       # List sessions
tmux attach [-t NAME]         # Attach to session
tmux kill-session -t NAME     # Kill session
tmux kill-server              # Kill all sessions
tmux source-file ~/.tmux.conf # Reload config
```

### All Keybindings (This Config)

| Category | Keybinding | Action |
|----------|------------|--------|
| **Prefix** | `Ctrl+a` | Prefix key |
| | `Ctrl+a Ctrl+a` | Send literal Ctrl+a |
| **Sessions** | `prefix + d` | Detach |
| | `prefix + s` | List sessions |
| | `prefix + S` | New session |
| | `prefix + $` | Rename session |
| | `prefix + (` | Previous session |
| | `prefix + )` | Next session |
| **Windows** | `prefix + c` | New window |
| | `prefix + ,` | Rename window |
| | `prefix + n` | Next window |
| | `prefix + p` | Previous window |
| | `prefix + Tab` | Last window |
| | `prefix + w` | List windows |
| | `prefix + 1-9` | Go to window # |
| **Panes** | `prefix + \|` | Split vertical |
| | `prefix + -` | Split horizontal |
| | `prefix + h/j/k/l` | Navigate |
| | `prefix + H/J/K/L` | Resize |
| | `prefix + z` | Zoom toggle |
| | `prefix + x` | Close pane |
| | `prefix + y` | Sync panes |
| | `prefix + >/<` | Swap panes |
| **Copy** | `prefix + Enter` | Copy mode |
| | `v` | Start selection |
| | `y` | Copy |
| | `/` | Search forward |
| **Utility** | `prefix + r` | Reload config |
| | `prefix + b` | Toggle status bar |
| | `prefix + C-l` | Clear history |
| **Phoenix** | `prefix + P` | Dev layout |
| | `prefix + T` | Test layout |
| **Plugins** | `prefix + I` | Install plugins |
| | `prefix + U` | Update plugins |
| | `prefix + Ctrl+s` | Save session |
| | `prefix + Ctrl+r` | Restore session |

---

## Memory Aid

```
Prefix = Ctrl+a (think: "a" for action)

SPLITS: Think of the character shape
  |  → vertical split (looks like |)
  -  → horizontal split (looks like ─)

NAVIGATION: Vim keys (hjkl)
  h ← left    l → right
  j ↓ down    k ↑ up

RESIZE: Same as navigation, but UPPERCASE
  H ← bigger left    L → bigger right
  J ↓ bigger down    K ↑ bigger up

WINDOWS: Sequential
  c = create    n = next    p = previous

SESSIONS:
  d = detach    s = sessions list

PHOENIX:
  P = Phoenix dev layout
  T = Test layout
```

---

*Last updated: February 2026*
*Compatible with tmux 3.0+*
