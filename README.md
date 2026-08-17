# CachyOS Setup Guide

Automated Fish shell scripts to set up a development environment on CachyOS (Arch Linux).

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Before You Start](#before-you-start)
- [Recommended Install Order](#recommended-install-order)
- [Quick Start](#quick-start)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🚀 Getting Started

Use these scripts to install common developer tools on CachyOS/Arch. Each script is idempotent where possible and safe to re-run.

Download this repository:

```sh
curl -L https://github.com/theoneandonlywoj/CachyOS-Setup/archive/refs/heads/main.zip -o CachyOS-Setup.zip && unzip CachyOS-Setup.zip && cd CachyOS-Setup-main
```

## 🧰 Prerequisites

- CachyOS (Arch Linux–based)
- Fish shell
- sudo access
- Internet connection

Optional (for some scripts):
- Podman (installed by `podman.fish` if missing)

## ⚙️ Before You Start

Make scripts executable (recommended):

```sh
chmod +x *.fish
```

Run a script (from this repository root):

```sh
./podman.fish
```

If Fish is not your login shell, you can run explicitly:

```sh
fish ./podman.fish
```

Git and SSH setup (optional but recommended for development):

```sh
chmod +x git_setup.fish
./git_setup.fish
```

## 🗂️ Recommended Install Order

Install in this order to satisfy dependencies and get the fastest path to a working dev environment:

1. System Utilities
   - `htop.fish`, `netcat.fish`
2. Containers & Development Tools
   - `podman.fish`
3. Web Browsers
   - `chromium.fish`
   - Optional: `vivaldi.fish`
   - Optional: `playwright_cli.fish`
4. Editors & IDEs
   - `cursor.fish`, `emacs.fish`, `doom_emacs.fish`
5. Language Runtime & Version Manager
   - `mise.fish`, `elixir_and_erlang.fish`
6. AI Agent & Terminal Tools
   - `herdr.fish`, `opencode.fish`, `claude-code-cli.fish`
   - `deepseek_harness.fish`
7. API & Communication Tools
   - `postman.fish`, `slack.fish`, `webcord.fish`
8. Networking & Monitoring
   - `wireshark.fish`, `wrk.fish`
9. Cloud & Infrastructure
   - `cuda.fish`, `dbeaver.fish`, `kubectl.fish`, `ngrok.fish`
10. AI & Media
   - `ollama.fish`, `vlc.fish`, `pdf_support.fish`, `exiftool.fish`

## ⚡ Quick Start

Run category-by-category:

```sh
# System Utilities
./htop.fish
./netcat.fish

# Containers & Development Tools
./podman.fish

# Web Browsers
./chromium.fish
# Optional: ./vivaldi.fish
# Optional: ./playwright_cli.fish

# Editors & IDEs
./cursor.fish
./emacs.fish
./doom_emacs.fish

# Language Runtime & Version Manager
./mise.fish
./elixir_and_erlang.fish

# AI Agent & Terminal Tools
./herdr.fish
./opencode.fish
./claude-code-cli.fish
./deepseek_harness.fish

# API & Communication Tools
./postman.fish
./slack.fish
./webcord.fish

# Networking & Monitoring
./wireshark.fish
./wrk.fish

# Cloud & Infrastructure
./cuda.fish
./dbeaver.fish
./kubectl.fish
./ngrok.fish

# AI & Media
./ollama.fish
./vlc.fish
./pdf_support.fish
./exiftool.fish
```

Install all at once (ordered):

```sh
chmod +x *.fish
./htop.fish && ./netcat.fish && ./podman.fish && ./chromium.fish && \
./cursor.fish && ./emacs.fish && ./doom_emacs.fish && ./mise.fish && \
./herdr.fish && ./opencode.fish && ./claude-code-cli.fish && \
./deepseek_harness.fish && \
./elixir_and_erlang.fish && ./postman.fish && ./slack.fish && \
./webcord.fish && ./wireshark.fish && ./wrk.fish && ./cuda.fish && \
./dbeaver.fish && ./ollama.fish && ./ngrok.fish && ./vlc.fish && \
./pdf_support.fish && ./kubectl.fish && ./exiftool.fish
```

Run a single script explicitly with Fish (if needed):

```sh
fish ./cursor.fish
```

### Herdr

Install Herdr with the custom Fish configuration, workspace helpers, and
detected agent integrations:

```sh
chmod +x herdr.fish
./herdr.fish
```

The installer preserves an existing `~/.config/herdr/config.toml`. The custom
configuration adds `prefix+ctrl+w` for a four-tab workspace and
`prefix+ctrl+a` for starting an agent in a new background workspace without
stealing focus from the current terminal.

Start a hidden agent manually:

```sh
~/.config/herdr/scripts/start-agent-hidden.fish opencode reviewer ~/project
```

### DeepSeek Harness

Install DeepSeek Harness from source and expose it as `dsh` in
`~/.local/bin`:

```sh
chmod +x deepseek_harness.fish
./deepseek_harness.fish
```

Start the Web UI:

```sh
dsh web
```

The Web UI is served at `http://127.0.0.1:3080` by default. Configure a
model in **Settings → Models**, then choose a workspace.

Manage profile plugins from the command line:

```sh
dsh plugin --profile web add <package-or-git-spec>
dsh plugin --profile web update
dsh plugin --profile web remove <package>
```

The current developer-preview GUI can configure already-loaded plugins and
show the plugin inventory, but does not install plugins directly. For a local
development plugin, start the Web UI with a patch overlay:

```sh
dsh web --patch /absolute/path/to/cordis.yml
```

## ✅ Verification

Verify installations with the health check:

```sh
make healthcheck
```

This runs checks such as:
- Git setup (SSH keys, configuration)
- Mise installation
- Ollama service
- Podman socket
- Doom Emacs
- Cursor IDE
- GitHub CLI

## 🛠️ Troubleshooting

- Permissions: Ensure scripts are executable (`chmod +x *.fish`).
- Missing Fish: Install Fish via your package manager, or use `fish ./script.fish`.
- Network issues: Retry after confirming connectivity and mirrors.
- Package cache: Update package databases if installs fail (`sudo pacman -Syu`).
- Podman socket: Re-run `./podman.fish` if the socket isn’t active.

## 📝 Contributing

To add a new tool:

1. Create a new `<tool>.fish` script following existing patterns.
2. Test locally.
3. Update this README.
4. Open a pull request.

## 📄 License

This repository contains installation scripts for various open-source tools. Each tool maintains its own license.
