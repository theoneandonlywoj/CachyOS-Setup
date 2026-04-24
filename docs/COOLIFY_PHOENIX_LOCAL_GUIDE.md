# Coolify Local Guide: Deploy an Elixir Phoenix Umbrella App with PostgreSQL

This guide walks through a localhost-focused Coolify setup for a fresh Phoenix umbrella application backed by PostgreSQL.

Replace `my_umbrella` and `MyUmbrella` in the examples with your real app names.
Phoenix umbrella projects use a root directory named `<app>_umbrella`, so a command like `mix phx.new my_umbrella --umbrella` creates `my_umbrella_umbrella/`.

It assumes you want:

- Coolify running on the same machine as your app
- a Phoenix umbrella app built with a `Dockerfile`
- PostgreSQL managed by Coolify
- a local generated domain such as `http://your-app.127.0.0.1.sslip.io`

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Part A: Install Coolify](#part-a-install-coolify)
3. [Part B: Create the Phoenix Umbrella App](#part-b-create-the-phoenix-umbrella-app)
4. [Part C: Add a Health Endpoint](#part-c-add-a-health-endpoint)
5. [Part D: Fix Runtime Configuration for Coolify](#part-d-fix-runtime-configuration-for-coolify)
6. [Part E: Use a Root Dockerfile for the Umbrella](#part-e-use-a-root-dockerfile-for-the-umbrella)
7. [Part F: Push the App to Git](#part-f-push-the-app-to-git)
8. [Part G: Provision PostgreSQL in Coolify](#part-g-provision-postgresql-in-coolify)
9. [Part H: Add the Phoenix Application in Coolify](#part-h-add-the-phoenix-application-in-coolify)
10. [Part I: Deploy, Migrate, and Verify](#part-i-deploy-migrate-and-verify)
11. [Appendix A: Docker Compose Alternative](#appendix-a-docker-compose-alternative)
12. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Coolify installed locally with `./coolify.fish`
- Elixir and Erlang installed locally with `./elixir_and_erlang.fish`
- Git available locally
- A repository host Coolify can reach, or a public repository URL

If you want to verify the local Coolify install first:

```bash
curl -I http://127.0.0.1:8000
docker ps --filter name=coolify --format "table {{.Names}}\t{{.Status}}"
```

---

## Part A: Install Coolify

From this repository root:

```bash
./coolify.fish
```

Then open:

```text
http://127.0.0.1:8000
```

Complete the first-login flow in the browser and create your root user.

---

## Part B: Create the Phoenix Umbrella App

Generate a fresh umbrella app with PostgreSQL support:

```bash
mix phx.new my_umbrella --umbrella --database postgres
cd my_umbrella_umbrella
mix deps.get
```

Generate release files from the web app:

```bash
cd apps/my_umbrella_web
mix phx.gen.release --docker
cd ../..
```

Important umbrella-specific note:

- Phoenix requires `mix phx.gen.release --docker` to run inside the web app.
- That generates `rel/` files and `release.ex`, which you want to keep.
- For a fresh umbrella repo in Coolify, you should not use the generated `apps/my_umbrella_web/Dockerfile` as-is.
- Instead, keep the generated release files and use the root `Dockerfile` from this guide.

Why:

- the umbrella shares `config/`, `mix.lock`, `_build`, and dependencies at the repo root
- a Coolify Docker build needs a root-aware build context

---

## Part C: Add a Health Endpoint

Create a very small health controller.

File: `apps/my_umbrella_web/lib/my_umbrella_web/controllers/health_controller.ex`

```elixir
defmodule MyUmbrellaWeb.HealthController do
  use MyUmbrellaWeb, :controller

  def show(conn, _params) do
    text(conn, "ok")
  end
end
```

Then add a route.

File: `apps/my_umbrella_web/lib/my_umbrella_web/router.ex`

```elixir
scope "/", MyUmbrellaWeb do
  pipe_through :browser

  get "/health", HealthController, :show
  get "/", PageController, :home
end
```

Why this matters:

- Coolify can use `/health` as the health check path
- a plain `200 OK` response is enough

---

## Part D: Fix Runtime Configuration for Coolify

Phoenix will warn you after `mix phx.gen.release --docker` that `PHX_SERVER` and `PHX_HOST` should be added to `config/runtime.exs`.

In the umbrella root, update `config/runtime.exs` so it:

- starts the endpoint when `PHX_SERVER` is set
- reads `PHX_HOST` at runtime
- binds to `0.0.0.0`
- keeps the existing `DATABASE_URL` and `SECRET_KEY_BASE` runtime setup

At the top of `config/runtime.exs`, replace the initial endpoint config with:

```elixir
import Config

if System.get_env("PHX_SERVER") do
  config :my_umbrella_web, MyUmbrellaWeb.Endpoint, server: true
end

host = System.get_env("PHX_HOST") || "localhost"
port = String.to_integer(System.get_env("PORT", "4000"))

config :my_umbrella_web, MyUmbrellaWeb.Endpoint,
  url: [host: host, port: 80, scheme: "http"],
  http: [ip: {0, 0, 0, 0}, port: port]
```

Keep the existing `if config_env() == :prod do` section, including:

- `DATABASE_URL`
- `SECRET_KEY_BASE`
- repository config

Inside that `:prod` block, update the endpoint config so it keeps `secret_key_base` and uses IPv4 binding:

```elixir
config :my_umbrella_web, MyUmbrellaWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}],
  secret_key_base: secret_key_base
```

For localhost-only Coolify deployments, `scheme: "http"` and `port: 80` are fine because the local generated domain is usually plain HTTP.

If you later move to a real HTTPS domain, change the URL config to `scheme: "https"` and `port: 443`.

---

## Part E: Use a Root Dockerfile for the Umbrella

Create this file at the umbrella root.

File: `Dockerfile`

```dockerfile
ARG ELIXIR_VERSION=1.18.0
ARG OTP_VERSION=27.1
ARG DEBIAN_VERSION=trixie-20260421-slim

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="docker.io/debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV MIX_ENV=prod

RUN mix local.hex --force \
  && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config config
COPY apps/my_umbrella/mix.exs apps/my_umbrella/mix.exs
COPY apps/my_umbrella_web/mix.exs apps/my_umbrella_web/mix.exs

WORKDIR /app/apps/my_umbrella_web
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile
RUN mix assets.setup

WORKDIR /app
COPY apps/my_umbrella/lib apps/my_umbrella/lib
COPY apps/my_umbrella/priv apps/my_umbrella/priv
COPY apps/my_umbrella_web/assets apps/my_umbrella_web/assets
COPY apps/my_umbrella_web/lib apps/my_umbrella_web/lib
COPY apps/my_umbrella_web/priv apps/my_umbrella_web/priv
COPY apps/my_umbrella_web/rel apps/my_umbrella_web/rel

WORKDIR /app/apps/my_umbrella_web
RUN mix compile
RUN mix assets.deploy
RUN mix release

FROM ${RUNNER_IMAGE} AS runner

RUN apt-get update \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 locales ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen \
  && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV MIX_ENV=prod

WORKDIR /app
RUN chown nobody /app

COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/my_umbrella_web ./

USER nobody

CMD ["/app/bin/server"]
```

Why this version is better for Coolify:

- it builds from the umbrella root
- it copies the shared root `config/` and `mix.lock`
- it includes the generated release files from `apps/my_umbrella_web/rel`
- it installs `curl` in the final image so a `/health` check works cleanly

Add a root `.dockerignore` too.

File: `.dockerignore`

```dockerignore
.git
_build
deps
cover
doc
tmp
**/.elixir_ls
**/node_modules
**/priv/static/assets
**/priv/static/cache_manifest.json
erl_crash.dump
```

---

## Part F: Push the App to Git

Before adding the app to Coolify, commit and push it somewhere Coolify can read it.

Generate a secret for later:

```bash
mix phx.gen.secret
```

Then commit your app and push it to your repository host.

---

## Part G: Provision PostgreSQL in Coolify

In Coolify:

1. Open your project.
2. Create an environment if you do not already have one.
3. Click `Create New Resource`.
4. Choose `PostgreSQL`.
5. Deploy it.

After the database is ready:

1. Open the PostgreSQL resource.
2. Copy the generated connection string.

It will look roughly like this:

```text
ecto://username:password@host:5432/database
```

Use the exact connection string Coolify gives you. Do not replace it with `localhost`.

---

## Part H: Add the Phoenix Application in Coolify

Create the app resource:

1. Click `Create New Resource`.
2. Choose `Application`.
3. Connect your Git repository.
4. Select `Dockerfile` as the build pack.

Use these settings:

- Base Directory: `/`
- Dockerfile Location: `Dockerfile`
- Port Exposes: `4000`
- Health Check Path: `/health`

Set these environment variables as runtime variables:

| Variable | Value |
|---|---|
| `DATABASE_URL` | the connection string from the Coolify PostgreSQL resource |
| `SECRET_KEY_BASE` | output from `mix phx.gen.secret` |
| `PHX_HOST` | host portion of the generated Coolify domain |
| `PORT` | `4000` |

You do not need to add `PHX_SERVER` manually here because `CMD ["/app/bin/server"]` sets it for the release.

For a local generated domain, Coolify often gives you something like:

```text
http://abc123.127.0.0.1.sslip.io
```

In that case:

- use the whole URL in the domain field
- set `PHX_HOST=abc123.127.0.0.1.sslip.io`

If Coolify only shows the generated domain after the first save, save the app once, copy the host portion into `PHX_HOST`, then redeploy.

These variables do not need to be build-time variables for this Dockerfile.
Keeping them runtime-only is safer because they stay out of the image build.

---

## Part I: Deploy, Migrate, and Verify

Deploy the application from Coolify.

During the first deploy:

1. Watch the build logs.
2. Confirm the container becomes healthy.
3. Open the app terminal in Coolify.
4. Run the release migration command:

```bash
/app/bin/migrate
```

Then verify the app:

```bash
curl http://your-generated-domain/health
docker ps --format "table {{.Names}}\t{{.Status}}"
```

And open the generated application URL in your browser.

What success looks like:

- the build completes successfully
- the app passes the `/health` check
- `/app/bin/migrate` finishes without errors
- the generated `sslip.io` URL serves your Phoenix home page

---

## Appendix A: Docker Compose Alternative

If you prefer to keep the app and database together as a single stack, you can use a Docker Compose resource in Coolify instead of separate `Application` and `PostgreSQL` resources.

Example `docker-compose.yml`:

```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: my_umbrella
      POSTGRES_USER: my_umbrella
      POSTGRES_PASSWORD: change_me
    volumes:
      - postgres-data:/var/lib/postgresql/data

  web:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: ecto://my_umbrella:change_me@db:5432/my_umbrella
      SECRET_KEY_BASE: replace_me
      PHX_HOST: my-umbrella.127.0.0.1.sslip.io
      PORT: 4000
    expose:
      - "4000"
    depends_on:
      - db
    healthcheck:
      test: ["CMD", "curl", "-f", "http://127.0.0.1:4000/health"]
      interval: 10s
      timeout: 5s
      retries: 10

volumes:
  postgres-data:
```

In Coolify, import that file as a Docker Compose or Service Stack resource, then expose the `web` service on port `4000` through the stack configuration.

This approach is convenient for experiments, but the separate-resource setup is usually cleaner in Coolify because:

- database credentials are easier to rotate
- backups are easier to manage
- app and database lifecycles stay separate

---

## Troubleshooting

### `No Available Server`

Usually one of these is wrong:

- app is listening on `127.0.0.1` instead of `0.0.0.0`
- `Port Exposes` is not `4000`
- `/health` route is missing
- the final image does not include `curl`

### `DATABASE_URL` or `SECRET_KEY_BASE` missing

Check the Coolify app environment variables.

They should exist on the application resource, and for this Dockerfile they can stay runtime-only.

### Build fails after `mix phx.gen.release --docker`

For umbrella apps, this is the common mistake:

- using `apps/my_umbrella_web/Dockerfile` directly in Coolify

Use the root `Dockerfile` from this guide instead.

### Health check fails but the app booted

Open the Coolify terminal and test the endpoint manually:

```bash
curl -f http://127.0.0.1:4000/health
```

If this fails:

- verify the route exists
- verify the release started correctly
- check the application logs in Coolify

### Migrations were not run

Use the app terminal in Coolify and run:

```bash
/app/bin/migrate
```

If you want migrations automated later, wire that same command into your deployment workflow after you confirm the manual path works.
