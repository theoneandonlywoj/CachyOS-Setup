# Beginner's Guide to Auto Ontology

This guide covers running NVIDIA Auto Ontology locally with the `auto_ontology.fish` installer from this repository. Upstream documentation lives at [github.com/NVIDIA/auto-ontology](https://github.com/NVIDIA/auto-ontology).

---

## Table of Contents

1. [What is Auto Ontology?](#what-is-auto-ontology)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Usage](#usage)
6. [Troubleshooting](#troubleshooting)
7. [Links](#links)

---

## What is Auto Ontology?

**Auto Ontology** is NVIDIA's open-source application that provides a semantic ontology layer for agents. This repository's installer brings up the upstream project's local compose stack on CachyOS with Podman (or Docker), including its web UI and backing services.

The installer does not modify the upstream repository; it clones (or reuses) it, generates a `.env` file once, and runs `podman compose up -d --build`.

---

## Prerequisites

Install these before running the script (the script fails fast with instructions if any are missing):

- **CachyOS** with Fish.
- **Git** and **openssl**: `sudo pacman -S --needed git openssl`.
- **Podman** with a compose provider: run `./podman.fish` and `./podman_compose.fish`. Docker with the Compose v2 plugin also works; Podman is preferred when both do.
- **uv**: run `./python_and_uv.fish`.
- **curl**: only needed for HTTP verification.

The script assumes these are already installed and does not auto-install them, matching the repository's other installers.

---

## Installation

From the root of this setup repository, run:

```fish
chmod +x auto_ontology.fish
./auto_ontology.fish
```

The installer will:

1. Verify the prerequisites above.
2. Clone NVIDIA Auto Ontology into `$HOME/auto-ontology` (or `AUTO_ONTOLOGY_DIR` if set), or fast-forward an existing checkout whose origin matches upstream and that has no local changes.
3. Create `.env` from `.env.example` if it does not already exist (an existing `.env` is preserved).
4. Generate `AUTH_SECRET` with `openssl` (only when it creates `.env`).
5. Prompt for the admin email, admin password, NVIDIA API key, Postgres password, and optional connection strings (in a TTY). Empty input keeps the placeholder; without a terminal all placeholders stay. The names still to edit are printed.
6. Run `podman compose up -d --build` (or `docker compose` when only Docker works).
7. Wait up to 30 seconds for `http://localhost:3000` to respond.
8. Print useful commands and a pointer to this guide.

To use a different checkout location:

```fish
AUTO_ONTOLOGY_DIR="$HOME/Developer/auto-ontology" ./auto_ontology.fish
```

Relative paths are normalised to absolute paths.

---

## Configuration

Configuration lives in the cloned checkout at `$HOME/auto-ontology/.env` (or `$AUTO_ONTOLOGY_DIR/.env`). The installer writes `.env` only when it does not exist, and reruns never edit an existing `.env`. `POSTGRES_PASSWORD` is fixed when the database volume is first created; changing it later means changing it in the database too.

| Key | Meaning |
|-----|---------|
| `AUTH_SECRET` | Secret used to sign/authenticate sessions. Generated automatically by the installer. |
| `APP_URL` | Public URL of the web UI. Defaults to `http://localhost:3000`. |
| `AUTO_ONTOLOGY_ADMIN_EMAIL` | Email for the initial admin account. |
| `AUTO_ONTOLOGY_ADMIN_PASSWORD` | Password for the initial admin account. |
| `DEFAULT_MODELS_API_KEY` | NVIDIA API key (`nvapi-...`) used for default models. |
| `POSTGRES_PASSWORD` | Password for the Postgres database used by the stack. |
| `CONNECTION_STRINGS` | Optional connection strings for additional data sources. |

Secrets are written only to `.env` and are never echoed. For the authoritative, up-to-date list of keys and defaults, see the upstream `.env.example` and `DEPLOYMENT.md`.

---

## Usage

After installation, the web UI is available at:

- UI: http://localhost:3000

Useful commands (run from the checkout directory):

```fish
cd "$HOME/auto-ontology"
podman compose ps
podman compose logs -f
podman compose down   # keep data
podman compose down -v # wipe data
```

To stop the stack without removing data, use `podman compose down`. To remove volumes as well, use `podman compose down -v`.

Re-running `./auto_ontology.fish` is safe: it fast-forwards the checkout (when its origin matches upstream and it has no local changes), never edits an existing `.env`, and starts the stack again.

---

## Troubleshooting

- **Missing prerequisite:** install the reported tool (git, openssl, uv, a compose provider) and re-run. The script does not install prerequisites automatically.
- **Checkout has local changes:** commit or discard them, then re-run; the installer never overwrites them.
- **Checkout origin differs:** the installer refuses to modify a checkout whose `origin` is not NVIDIA Auto Ontology. Point `AUTO_ONTOLOGY_DIR` at a path that does not exist yet, or remove the mismatched directory.
- **Install directory exists but is not a git checkout:** remove or rename the directory, then re-run.
- **`.env.example` not found:** the clone may be incomplete or on an unexpected branch; delete the checkout and re-run.
- **UI does not answer:** inspect logs with `cd "$HOME/auto-ontology"; and podman compose logs`. The frontend service may still be starting; wait and retry.
- **Non-interactive run leaves placeholders:** edit `.env` directly, then run `podman compose up -d` in the checkout.
- **Port 3000 already in use:** stop the conflicting process or adjust the compose/port configuration upstream, then re-run.

---

## Links

- Upstream repository: https://github.com/NVIDIA/auto-ontology
- Upstream deployment guide: `DEPLOYMENT.md` in the cloned checkout
- Upstream environment template: `.env.example` in the cloned checkout
- Installer script: `auto_ontology.fish`
- This guide: `docs/guide_auto_ontology.md`