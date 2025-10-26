# CachyOS Setup Guide

Automated installation scripts for setting up a development environment on CachyOS (Arch Linux) with Fish shell.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Quick Start Installation](#quick-start-installation)
- [Installation Order](#installation-order)
- [Tools by Category](#tools-by-category)
- [Verification](#verification)
- [Contributing](#contributing)

## 🚀 Getting Started

### Prerequisites
- CachyOS (Arch Linux-based)
- Fish shell
- sudo access
- Internet connection

### Initial Setup

1. **Setup Git and SSH Keys** (required for development)
```sh
chmod +x git_setup.fish
./git_setup.fish
```

This script will:
- Generate SSH keys for GitHub
- Configure Git user name and email
- Copy SSH public key to clipboard
- Guide you to add the key to GitHub

### Quick Start Installation

Run the following scripts in order to set up your development environment:

```sh
# System Utilities
chmod +x htop.fish netcat.fish
./htop.fish
./netcat.fish

# Containers & Development Tools
chmod +x podman.fish
./podman.fish

# Web Browsers
chmod +x chromium.fish
./chromium.fish

# Editors & IDEs
chmod +x cursor.fish emacs.fish doom_emacs.fish
./cursor.fish
./emacs.fish
./doom_emacs.fish

# Language Runtime & Version Manager
chmod +x mise.fish elixir_and_erlang.fish
./mise.fish
./elixir_and_erlang.fish

# API & Communication Tools
chmod +x postman.fish slack.fish webcord.fish
./postman.fish
./slack.fish
./webcord.fish

# Networking & Monitoring
chmod +x wireshark.fish wrk.fish
./wireshark.fish
./wrk.fish

# Cloud & Infrastructure
chmod +x cuda.fish dbeaver.fish kubectl.fish ngrok.fish
./cuda.fish
./dbeaver.fish
./kubectl.fish
./ngrok.fish

# AI & Media
chmod +x ollama.fish vlc.fish pdf_support.fish exiftool.fish vivaldi.fish
./ollama.fish
./vlc.fish
./pdf_support.fish
./exiftool.fish
./vivaldi.fish
```

**Alternative: Install all at once**

```sh
# Make all scripts executable
chmod +x *.fish

# Install in order
./htop.fish && ./netcat.fish && ./podman.fish && ./chromium.fish && \
./cursor.fish && ./emacs.fish && ./doom_emacs.fish && ./mise.fish && \
./elixir_and_erlang.fish && ./postman.fish && ./slack.fish && \
./webcord.fish && ./wireshark.fish && ./wrk.fish && ./cuda.fish && \
./dbeaver.fish && ./ollama.fish && ./ngrok.fish && ./vlc.fish && \
./pdf_support.fish && ./kubectl.fish && ./exiftool.fish
```