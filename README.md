# CachyOS Setup Guide

Automated Fish shell scripts to set up a development environment on CachyOS (Arch Linux).

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Before You Start](#before-you-start)
- [Manual command catalog](#manual-command-catalog)
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

## 🗂️ Manual command catalog

Every root script, run one at a time from the repository root; suggested first runs are `./git_setup.fish`, `./mise.fish`, `./nodejs.fish` and `./podman.fish`.

The **Rerun** column says what a second run does:

- `skip`: pacman/AUR. A rerun makes no package change; upgrades come from `paru -Syu`.
- `update`: vendor/npm/mise/uv/cargo. A rerun updates in place.
- `guide`: prints instructions only.
- `setup`: config-only, and its prompts are kept.
- `legacy`: CachyOS-only, not migrated. A rerun may still prompt and remove; these scripts are not covered by the rerun gate.

`./test-local.sh` (and `make soft-test`/CI) checks that this table lists every root `*.fish` exactly once. Keep rows unpadded (`| \`./x.fish\` | … |`, one space on each side of each cell) and without `\|`: a formatter that pads the table makes the check fail.

<!-- root-command-catalog -->
| Command | Installs via | Rerun | Notes |
|---|---|---|---|
| `./1password.fish` | AUR | skip | 1Password |
| `./act.fish` | pacman | skip | act (GitHub Actions runner) installation and setup |
| `./ansible.fish` | pacman | legacy | Ansible (automation platform) |
| `./antigravity.fish` | AUR | legacy | Google Antigravity IDE |
| `./atuin.fish` | pacman | skip | Atuin (searchable shell history) with Fish integration |
| `./audacity.fish` | pacman | legacy | Audacity audio editor |
| `./auto_ontology.fish` | git + podman compose | update | NVIDIA Auto Ontology (local compose stack) |
| `./aws_cli.fish` | pacman | legacy | AWS CLI |
| `./bend.fish` | vendor installer | update | Bend language |
| `./blender.fish` | pacman | legacy | Blender 3D creation suite |
| `./browse.fish` | vendor installer | update | browse (browser control for coding agents) |
| `./btop.fish` | pacman | skip | btop resource monitor |
| `./caddy.fish` | pacman / AUR | legacy | Caddy (web server with automatic HTTPS) |
| `./chromium.fish` | pacman | legacy | Chromium browser |
| `./claude-code-cli.fish` | vendor installer | update | Claude Code CLI |
| `./codex.fish` | vendor installer | update | OpenAI Codex CLI |
| `./comfyui.fish` | git + Podman | legacy | ComfyUI with Podman |
| `./container_tui.fish` | pacman | skip | Container TUIs (lazydocker and ctop) |
| `./copyq.fish` | pacman | legacy | CopyQ (clipboard manager with history) |
| `./credo.fish` | instructions only | guide | Credo (Elixir linter) project setup |
| `./cuda_11_8.fish` | pacman | legacy | CUDA toolkit 11.8.0 |
| `./cursor.fish` | AppImage download | legacy | Cursor AI (install or update) |
| `./darktable.fish` | pacman | legacy | darktable (RAW photo workflow) |
| `./dbeaver.fish` | pacman | legacy | DBeaver database tool |
| `./deepeval.fish` | uv | update | DeepEval CLI (LLM output testing) |
| `./deepseek_harness.fish` | git + pnpm | update | DeepSeek Harness (dsh) from source |
| `./dexter.fish` | mise (aqua) | update | Dexter (Elixir LSP) |
| `./dialyxir.fish` | instructions only | guide | Dialyxir (Dialyzer wrapper) project setup |
| `./doom_emacs.fish` | git | legacy | Full Doom Emacs setup |
| `./drone.fish` | pacman / AUR / GitHub release | legacy | Drone CLI (CI/CD command-line tool) |
| `./dust.fish` | mise / cargo / pacman | legacy | dust (disk usage analyzer) |
| `./elixir_and_erlang.fish` | mise | update | Pinned versions of Erlang & Elixir via Mise |
| `./emacs.fish` | pacman / AUR | legacy | Emacs 30 |
| `./epub_reader.fish` | pacman | legacy | Free epub reader |
| `./executor.fish` | npm via mise | update | Executor (MCP gateway for coding agents) |
| `./exiftool.fish` | pacman | legacy | ExifTool |
| `./ffmpeg.fish` | pacman | legacy | FFmpeg multimedia framework |
| `./filezilla.fish` | pacman | legacy | FileZilla (FTP client) |
| `./fwup.fish` | source build | update | fwup (firmware update tool) from source |
| `./fzf.fish` | pacman | skip | fzf (fuzzy finder) with Fish integration |
| `./ghostty.fish` | pacman | skip | Ghostty terminal emulator |
| `./gimp.fish` | pacman | legacy | GIMP image editor |
| `./git_setup.fish` | config only (SSH key, git config) | setup | Git identity and SSH key setup |
| `./github_cli.fish` | pacman | update | GitHub CLI (gh) |
| `./gitleaks.fish` | pacman / AUR / mise | legacy | gitleaks (secret detection tool) |
| `./glances.fish` | pacman / pip | legacy | glances system monitoring tool |
| `./gmic.fish` | pacman | legacy | G'MIC (GREYC's Magic Image Converter) |
| `./godclaude-setup.fish` | mise + npx | legacy | Require Mise and Claude Code, ensure npx/gsd, add godclaude alias |
| `./godot.fish` | pacman | skip | Godot game engine |
| `./google_chrome.fish` | AUR | skip | Google Chrome |
| `./google_cloud_sdk.fish` | pacman / AUR | legacy | Google Cloud SDK (install or update) |
| `./gping.fish` | pacman | legacy | gping (ping with graph visualization) |
| `./graphify.fish` | mise / uv | update | Graphify (codebase → queryable knowledge graph) |
| `./graphviz.fish` | pacman | legacy | Graphviz graph visualization tool |
| `./handy.fish` | AUR | skip | Handy (offline speech-to-text) |
| `./harness2.fish` | git + uv | update | Harness2 (recursive agent harness) |
| `./helm.fish` | pacman / AUR / mise | legacy | Helm (Kubernetes package manager) |
| `./herdr.fish` | vendor installer | update | Herdr and configure it for Fish |
| `./hermes_agent.fish` | vendor installer | update | Hermes Agent via official install script |
| `./htop.fish` | pacman | legacy | htop interactive process viewer |
| `./image_optimizers.fish` | pacman | legacy | image optimization tools (gifsicle, oxipng, jpegoptim) |
| `./imagemagick.fish` | pacman | legacy | ImageMagick image manipulation library |
| `./inkscape.fish` | pacman | legacy | Inkscape vector graphics editor |
| `./inotify-tools.fish` | pacman | legacy | inotify-tools for file system monitoring |
| `./just.fish` | pacman / AUR / cargo | legacy | Just (command runner) |
| `./kafka_cli.fish` | mise / Apache release | update | Kafka CLI tools via Mise or Apache Kafka releases |
| `./kdenlive.fish` | pacman | legacy | Kdenlive video editor |
| `./keymapp.fish` | vendor tarball | update | Keymapp for ZSA keyboards (install or update) |
| `./kompose.fish` | pacman | legacy | Kompose (Docker Compose to Kubernetes converter) |
| `./krita.fish` | pacman | legacy | Krita digital painting application |
| `./kubectl.fish` | pacman | skip | kubectl (Kubernetes CLI) |
| `./lazygit.fish` | pacman | skip | lazygit (terminal UI for Git) |
| `./livebook.fish` | mix escript | update | Livebook CLI |
| `./livediff.fish` | cargo via mise | update | Livediff (live terminal diff TUI) |
| `./llmfit.fish` | vendor installer | legacy | LLMFit (hardware-aware LLM model finder) |
| `./lynx.fish` | vendor installer (elan) | update | Lynx (Lean proofs for Erlang/Elixir) |
| `./mcp_servers.fish` | npm via mise | legacy | MCP servers for Cursor AI |
| `./mdbook.fish` | pacman / cargo | legacy | mdbook (create books with Markdown) |
| `./mise.fish` | vendor installer | update | Mise (environment/version manager) |
| `./mkcert.fish` | pacman | legacy | mkcert (local SSL certificates) |
| `./models.fish` | cargo / GitHub release | legacy | Models CLI (AI model browser & benchmark explorer) |
| `./mtr.fish` | pacman | legacy | mtr (My Traceroute - network diagnostic tool) |
| `./nerves_bootstrap.fish` | pacman / AUR | update | Nerves Bootstrap for embedded Elixir development |
| `./netcat.fish` | pacman | legacy | Netcat (nc) network utility |
| `./ngrok.fish` | AUR | legacy | ngrok installation and setup |
| `./nmap.fish` | pacman | legacy | nmap |
| `./nodejs.fish` | mise | update | Node.js 24+ via Mise |
| `./obs_studio.fish` | pacman | legacy | OBS Studio |
| `./observer_cli.fish` | instructions only | guide | observer_cli (terminal BEAM observer) project setup |
| `./ollama.fish` | vendor installer | legacy | Clean install or update of Ollama |
| `./omniroute.fish` | npm via mise | update | OmniRoute (self-hosted AI gateway) |
| `./opencode.fish` | vendor installer | update | OpenCode CLI |
| `./openshot.fish` | pacman | legacy | OpenShot video editor |
| `./orca.fish` | AUR | skip | Stably Orca (agentic coding IDE) |
| `./pandoc.fish` | pacman | legacy | Pandoc (universal document converter) |
| `./pdf_support.fish` | pacman | legacy | Xournal++ installation with full PDF annotation support |
| `./pi_agent.fish` | npm via mise | update | Pi coding agent |
| `./plantuml.fish` | pacman | legacy | PlantUML diagramming tool |
| `./playwright_cli.fish` | npm via mise | update | Playwright CLI for coding agents via npm and Mise |
| `./podman.fish` | pacman | skip | Podman, Docker Compose, and Docker CLI alias |
| `./podman_compose.fish` | pacman / pip | skip | podman-compose (docker-compose alternative for Podman) |
| `./postman.fish` | vendor tarball | update | Postman API client |
| `./prime_agent.fish` | vendor installer | update | Prime Agent (Prime Intellect) |
| `./python_and_uv.fish` | vendor installer (uv) | legacy | uv and Python 3.11+ |
| `./qbittorrent.fish` | pacman | legacy | qBittorrent torrent client |
| `./rclone.fish` | pacman | legacy | rclone (cloud storage sync tool) |
| `./rebar3.fish` | mise | update | rebar3 (Erlang build tool) |
| `./redis_cli.fish` | mise | legacy | Redis CLI via Mise |
| `./ripgrep.fish` | pacman | legacy | ripgrep (fast text search tool) |
| `./rust.fish` | mise | update | Rust (rustc and cargo) |
| `./slack.fish` | AUR | skip | Slack from AUR |
| `./spotify.fish` | pacman | skip | Spotify (spotify-launcher) |
| `./squashfs.fish` | pacman | legacy | squashfs-tools |
| `./step_cli.fish` | pacman | skip | step-cli (certificate and PKI toolkit) |
| `./stern.fish` | pacman / AUR / mise | legacy | Stern (Kubernetes log tailing tool) |
| `./syncthing.fish` | pacman | legacy | Syncthing continuous file synchronization |
| `./telegram.fish` | pacman | legacy | Telegram Desktop |
| `./terraform.fish` | pacman | legacy | Terraform (IaC) tool |
| `./tidewave.fish` | GitHub release | legacy | Tidewave CLI (coding agent for full-stack web development) |
| `./tmux.fish` | pacman | legacy | tmux terminal multiplexer |
| `./toktrack.fish` | cargo via mise | update | toktrack (AI coding token and cost tracker) |
| `./vault.fish` | pacman / AUR / mise | legacy | Vault (HashiCorp secrets management) |
| `./ventoy.fish` | pacman / AUR | legacy | Ventoy |
| `./visual_studio_code.fish` | pacman / AUR | skip | Visual Studio Code |
| `./vivaldi.fish` | pacman | skip | Vivaldi browser |
| `./vlc.fish` | pacman | legacy | VLC media player |
| `./watchman.fish` | pacman / AUR | legacy | Watchman (file watching service) |
| `./webcord.fish` | pacman | legacy | WebCord as a privacy-focused Discord replacement |
| `./websocat.fish` | pacman | skip | websocat (WebSocket client) |
| `./wireshark.fish` | pacman | legacy | Wireshark network protocol analyzer |
| `./wrk.fish` | pacman / AUR | legacy | wrk HTTP benchmarking tool |
| `./yt_dlp.fish` | mise | update | yt-dlp (YouTube downloader) |
| `./zed.fish` | vendor installer | update | Zed editor |
| `./zigbee2mqtt.fish` | git + npm | legacy | Zigbee2MQTT |
| `./zoxide.fish` | pacman | legacy | zoxide (smarter cd command) |
<!-- /root-command-catalog -->

### Not ported from macOS

- `brew`, `dock_cleanup`, `macusb`, `mole`, `kiri`: macOS-only.
- `vorssaint`: no Linux build.


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

Deploy or manage the repository's Herdr config with make (backups go to
gitignored `./.herdr-<timestamp>/` folders):

```sh
make herdr-global-set       # back up, then copy config.toml and scripts/
make herdr-global-unset     # back up, then remove ~/.config/herdr/config.toml
make herdr-global-backup    # back up ~/.config/herdr/config.toml
make herdr-global-restore   # restore the newest backup
make herdr-global-diff      # compare installed and repo config
make herdr-remove-backups   # delete ./.herdr-* backups (asks first)
```

Keybindings: [docs/herdr_cheatsheet.md](docs/herdr_cheatsheet.md).

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

Validate the scripts before pushing:

```sh
make soft-test
```

This runs `./test-local.sh` (the same checks CI runs):
- shebang, Fish syntax, executable bit and header of every root script
- the Manual command catalog lists every root script exactly once
- rerun safety: scripts not tagged `legacy` never remove packages, partially upgrade, or install without `--needed`

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
3. Add its row to the Manual command catalog in this README.
4. Open a pull request.

## 📄 License

This repository contains installation scripts for various open-source tools. Each tool maintains its own license.
