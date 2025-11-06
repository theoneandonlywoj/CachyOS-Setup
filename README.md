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
4. Editors & IDEs
   - `cursor.fish`, `emacs.fish`, `doom_emacs.fish`
5. Language Runtime & Version Manager
   - `mise.fish`, `elixir_and_erlang.fish`
6. API & Communication Tools
   - `postman.fish`, `slack.fish`, `webcord.fish`
7. Networking & Monitoring
   - `wireshark.fish`, `wrk.fish`
8. Cloud & Infrastructure
   - `cuda.fish`, `dbeaver.fish`, `kubectl.fish`, `ngrok.fish`
9. AI & Media
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

# Editors & IDEs
./cursor.fish
./emacs.fish
./doom_emacs.fish

# Language Runtime & Version Manager
./mise.fish
./elixir_and_erlang.fish

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
./elixir_and_erlang.fish && ./postman.fish && ./slack.fish && \
./webcord.fish && ./wireshark.fish && ./wrk.fish && ./cuda.fish && \
./dbeaver.fish && ./ollama.fish && ./ngrok.fish && ./vlc.fish && \
./pdf_support.fish && ./kubectl.fish && ./exiftool.fish
```

Run a single script explicitly with Fish (if needed):

```sh
fish ./cursor.fish
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