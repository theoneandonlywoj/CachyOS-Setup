# Dokploy + Phoenix + PostgreSQL Local Deployment Guide

A practical guide for deploying an Elixir Phoenix app and a PostgreSQL database on a local Dokploy server.

---

## Table of Contents

1. [What This Guide Covers](#what-this-guide-covers)
2. [Target Setup](#target-setup)
3. [Prerequisites](#prerequisites)
4. [Prepare the Phoenix App](#prepare-the-phoenix-app)
5. [Build a Release Image](#build-a-release-image)
6. [Add a Release Migration Helper](#add-a-release-migration-helper)
7. [Create the PostgreSQL Database in Dokploy](#create-the-postgresql-database-in-dokploy)
8. [Create Shared Variables in Dokploy](#create-shared-variables-in-dokploy)
9. [Create the Phoenix Application in Dokploy](#create-the-phoenix-application-in-dokploy)
10. [Run Migrations](#run-migrations)
11. [Expose the App Locally](#expose-the-app-locally)
12. [Test the Deployment](#test-the-deployment)
13. [Troubleshooting](#troubleshooting)

---

## What This Guide Covers

This guide assumes:

- Dokploy is already installed on a local server or workstation.
- PostgreSQL will be created and managed by Dokploy.
- Phoenix will be deployed as an Application using a `Dockerfile`.
- You want a local or LAN deployment first, not a public internet production deployment.

If you are looking for the fastest and most predictable path, use a `Dockerfile` build instead of trying to make Phoenix fit a generic builder.

---

## Target Setup

The final setup looks like this:

```text
Browser
  -> Dokploy / Traefik
  -> Phoenix container
  -> Dokploy-managed PostgreSQL container
```

Phoenix connects to PostgreSQL using Dokploy's internal database connection URL, not an externally exposed database port.

---

## Prerequisites

You should have:

- A running Dokploy instance
- Access to the Dokploy dashboard at `http://<dokploy-host>:3000`
- A Phoenix project pushed to GitHub, Gitea, GitLab, or another Git source Dokploy can access
- A working `mix.exs`, `mix.lock`, and standard Phoenix project layout

Helpful local commands:

```bash
# Generate a Phoenix secret
mix phx.gen.secret

# Check the Dokploy services
docker service ls

# Check Dokploy logs
docker service logs dokploy --tail 100
```

---

## Prepare the Phoenix App

Phoenix should read its runtime configuration from environment variables.

Update `config/runtime.exs` so production reads the database URL, secret key, host, and port from the environment.

Example:

```elixir
import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise "DATABASE_URL is missing"

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "SECRET_KEY_BASE is missing"

  host = System.get_env("PHX_HOST") || "localhost"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :my_app, MyApp.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  config :my_app, MyAppWeb.Endpoint,
    server: true,
    url: [host: host, port: 80, scheme: "http"],
    http: [ip: {0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base
end
```

Replace:

- `my_app` with your OTP app name
- `MyApp.Repo` with your repo module
- `MyAppWeb.Endpoint` with your endpoint module

Notes:

- `server: true` matters for releases.
- Keep the container listening on `PORT`, usually `4000`.
- Do not hardcode database credentials in the repository.
- For a later public HTTPS deployment, change the external URL to `443` and `https`.

---

## Build a Release Image

Create a production `Dockerfile` at the project root.

Example:

```dockerfile
FROM hexpm/elixir:1.17.3-erlang-27.0.1-debian-bookworm-20240701 AS build

RUN apt-get update && apt-get install -y build-essential git curl nodejs npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config ./config
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

COPY priv ./priv
COPY assets ./assets
RUN npm --prefix assets ci

COPY lib ./lib

RUN mix assets.deploy
RUN mix compile
RUN mix release

FROM debian:bookworm-slim AS app

RUN apt-get update && apt-get install -y libstdc++6 openssl libncurses6 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/_build/prod/rel/my_app ./

ENV HOME=/app
ENV MIX_ENV=prod

EXPOSE 4000

CMD ["/app/bin/my_app", "start"]
```

Replace `my_app` with your release name.

If your project does not use Node-based assets, remove the `npm` lines.

If your project does not have a `mix assets.deploy` alias, replace that line with your actual production asset build steps.

Add a `.dockerignore` too:

```text
_build
deps
.elixir_ls
.git
node_modules
tmp
```

---

## Add a Release Migration Helper

Phoenix releases do not run `mix ecto.migrate` directly the same way your dev shell does. Add a release helper so migrations can be triggered inside the built release.

Create `lib/my_app/release.ex`:

```elixir
defmodule MyApp.Release do
  @app :my_app

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          Ecto.Migrator.run(repo, :up, all: true)
        end)
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
```

Replace:

- `MyApp.Release` with your module name
- `:my_app` with your OTP app name

Commit this before deploying.

---

## Create the PostgreSQL Database in Dokploy

In Dokploy:

1. Open your project.
2. Go to `Databases`.
3. Click `New Database`.
4. Choose `PostgreSQL`.
5. Give it a clear name such as `phoenix-db`.
6. Deploy the database.

After the database is ready:

1. Open the database entry.
2. Open the `Connection` tab.
3. Copy the `Internal Connection URL`.

Use the internal URL for Phoenix. That is the value your app should use for `DATABASE_URL`.

Do not use the external connection string unless you intentionally want the database reachable outside Dokploy.

---

## Create Shared Variables in Dokploy

Dokploy supports project-level shared variables and service-level variables.

For a Phoenix app, project-level variables are a good default because they are easy to reuse and rotate later.

In your Dokploy project, add shared variables like:

```text
DATABASE_URL=<paste internal connection URL from the database Connection tab>
SECRET_KEY_BASE=<output of mix phx.gen.secret>
PHX_HOST=phoenix.local
PORT=4000
POOL_SIZE=10
```

If you want to keep everything local to the service, you can also add these directly in the application's environment tab.

Dokploy variable references use this format:

```text
DATABASE_URL=${{project.DATABASE_URL}}
SECRET_KEY_BASE=${{project.SECRET_KEY_BASE}}
PHX_HOST=${{project.PHX_HOST}}
PORT=${{project.PORT}}
POOL_SIZE=${{project.POOL_SIZE}}
```

---

## Create the Phoenix Application in Dokploy

In Dokploy:

1. Open `Applications`.
2. Click `New Application`.
3. Connect your Git repository.
4. Pick the branch you want to deploy.

Recommended settings:

| Setting | Value |
|---------|-------|
| Build Type | `Dockerfile` |
| Dockerfile Path | `./Dockerfile` |
| Root Directory | repository root |
| Port | `4000` |

Then open the `Environment` tab and set either direct values or project references:

```text
DATABASE_URL=${{project.DATABASE_URL}}
SECRET_KEY_BASE=${{project.SECRET_KEY_BASE}}
PHX_HOST=${{project.PHX_HOST}}
PORT=${{project.PORT}}
POOL_SIZE=${{project.POOL_SIZE}}
```

Deploy the application once the settings are saved.

---

## Run Migrations

After the first successful deploy, run the database migrations.

Use Dokploy's `Run Command` feature for the application and run:

```bash
bin/my_app eval "MyApp.Release.migrate"
```

Replace the app and module names with your own.

Run this:

- after the first deploy
- after schema changes that add new migrations

If the command succeeds, your release image and database connection are wired correctly.

---

## Expose the App Locally

For a local or LAN setup, you have two realistic options.

### Option 1: Local DNS or Hosts Entry Through Traefik

Use a hostname that resolves to your Dokploy machine, such as:

```text
phoenix.local
```

Then create a matching domain in Dokploy for the application.

This is the cleanest setup if:

- your workstation can resolve the hostname
- you want to use Traefik routing instead of a raw app port

### Option 2: Temporary Direct Port Exposure

If you only want to prove the container works locally, expose the app port in Dokploy and test directly against the Dokploy host on port `4000`.

This is useful for the first smoke test before you spend time on domains.

For pure local deployment, direct HTTP is usually simpler than trying to force automatic HTTPS on a non-public hostname.

---

## Test the Deployment

### Check the build and runtime logs

```bash
docker service ls
docker service logs dokploy --tail 100
```

In Dokploy, also check the application's `Deployments` and `Logs` tabs.

### Test the app directly

If you exposed port `4000`:

```bash
curl -I http://<dokploy-host>:4000
```

If you routed the app through Traefik with a local hostname:

```bash
curl -I http://phoenix.local
```

### Test the database path

From the application logs, verify Phoenix booted cleanly and did not fail on database connection startup.

Common success indicators:

- the release starts without crashing
- Ecto connects successfully
- migrations run without errors
- the homepage responds with `200 OK` or a redirect you expect

---

## Troubleshooting

### The app builds but crashes on startup

Check:

- `DATABASE_URL`
- `SECRET_KEY_BASE`
- `PHX_HOST`
- whether `server: true` is set in `runtime.exs`

### Assets are missing in production

Check that:

- your Dockerfile copies `assets/`
- `npm --prefix assets ci` runs successfully
- `mix assets.deploy` exists and runs successfully

### Migrations fail

Check that:

- the database exists and is healthy
- the app uses the database's internal connection URL
- the release helper module is compiled into the image

### The domain does not resolve on your LAN

For local deployment, this is usually a DNS problem, not a Phoenix problem.

Fix one of these:

- add a DNS record on your local network
- add an `/etc/hosts` entry on the client machine
- temporarily use direct port exposure instead

### Dokploy can reach the repo, but Phoenix still fails

Check the application's `Deployments` tab first. Most problems show up there earlier than in the final container logs.

---

## Minimal Checklist

Use this when you want the short version.

1. Add correct production config in `config/runtime.exs`.
2. Add a release-ready `Dockerfile`.
3. Add `lib/my_app/release.ex` for migrations.
4. Create PostgreSQL in Dokploy.
5. Copy the database `Internal Connection URL` into `DATABASE_URL`.
6. Create the Phoenix application in Dokploy using `Dockerfile` build type.
7. Deploy.
8. Run `bin/my_app eval "MyApp.Release.migrate"`.
9. Test via local domain or exposed port.

---

## References

- Dokploy docs: `https://docs.dokploy.com`
- Applications: `https://docs.dokploy.com/docs/core/applications`
- Databases: `https://docs.dokploy.com/docs/core/databases`
- Database connection: `https://docs.dokploy.com/docs/core/databases/connection`
- Environment variables: `https://docs.dokploy.com/docs/core/variables`
