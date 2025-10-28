# CachyOS Setup Guide

Automated installation scripts for setting up a development environment on CachyOS (Arch Linux) with Fish shell.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Quick Start Installation](#quick-start-installation)
- [Installation Order](#installation-order)
- [Tools by Category](#tools-by-category)
- [Verification](#verification)
- [CI/CD Testing](#cicd-testing)
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

## ✅ Verification

Run a comprehensive health check to verify all installations:

```sh
make healthcheck
```

This will check:
- ✅ Git Setup (SSH keys, configuration)
- ✅ Mise installation
- ✅ Ollama service
- ✅ Podman socket
- ✅ Doom Emacs
- ✅ Cursor IDE
- ✅ GitHub CLI
- ✅ And more...

## 🤖 CI/CD Testing

This repository includes GitHub Actions workflows to test the installation scripts in a CachyOS/Arch Linux environment:

### Available Workflows

1. **test-cachyos-setup.yml** - Basic setup and execution
   - Sets up Arch Linux environment (CachyOS-compatible)
   - Installs Fish shell and dependencies
   - Makes all scripts executable
   - Runs syntax checks
   - Can execute specific scripts via manual trigger

2. **install-test.yml** - Comprehensive testing
   - Syntax checking (runs on every push)
   - Smoke tests for core utilities
   - Full test suite for multiple tools
   - Single script testing mode
   - Manual trigger with multiple test options

### Viewing Workflows

- Go to the **Actions** tab in your GitHub repository
- Each workflow shows:
  - ✅ Success status
  - ⏱️ Execution time
  - 📋 Detailed logs

### Local Testing

For quick local testing without Docker, use the provided script:

```sh
./test-local.sh
```

This script:
- ✅ Checks Fish syntax on all scripts
- ✅ Validates shebang lines
- ✅ Verifies file permissions
- ✅ Checks script structure and documentation
- ⚡ Fast - No Docker required

### Running Workflows Locally with Docker

If you have Docker properly configured, you can test the full workflows:

```sh
# Test basic setup
act -W .github/workflows/test-cachyos-setup.yml

# Test installation scripts
act -W .github/workflows/install-test.yml
```

**Note:** If you encounter Docker permission errors locally, just push to GitHub - the workflows will run automatically without any local Docker setup needed.

## 📝 Contributing

To add a new tool:

1. Create a new `<tool>.fish` script
2. Follow the existing script patterns
3. Test locally first
4. Update this README
5. Create a pull request
6. Ensure GitHub Actions pass

## 📄 License

This repository contains installation scripts for various open-source tools. Each tool maintains its own license.