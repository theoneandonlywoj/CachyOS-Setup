#!/usr/bin/env fish

echo "📜 Setting up Loki and Promtail via Docker/Podman..."

# 1) Pick container runtime
set -l DOCKER ""
if type -q docker
  set DOCKER docker
else if type -q podman
  set DOCKER podman
else
  echo "❌ Docker/Podman not found. Install docker or podman."
  exit 1
end

# Fully-qualified images to avoid short-name issues (esp. with podman)
set -l IMAGE_LOKI docker.io/grafana/loki:2.9.6
set -l IMAGE_PROMTAIL docker.io/grafana/promtail:2.9.6

# Podman on SELinux needs :Z on bind mounts
set -l VSUFFIX ""
if test $DOCKER = podman
  set VSUFFIX ":Z"
end

# 2) Ensure configs and data
set -l LOKI_CFG_DIR "$HOME/.config/loki"
set -l LOKI_DATA_DIR "$HOME/.local/state/loki"
set -l PROMTAIL_CFG_DIR "$HOME/.config/promtail"
mkdir -p $LOKI_CFG_DIR $LOKI_DATA_DIR $PROMTAIL_CFG_DIR

# Ensure Loki data subdirectories exist and are writable for container user
mkdir -p "$LOKI_DATA_DIR/chunks" "$LOKI_DATA_DIR/rules"
chmod 0777 "$LOKI_DATA_DIR" "$LOKI_DATA_DIR/chunks" "$LOKI_DATA_DIR/rules"

set -l LOKI_CFG "$LOKI_CFG_DIR/config.yml"
if not test -f $LOKI_CFG
  echo "📁 Bootstrapping Loki config at $LOKI_CFG"
  printf "auth_enabled: false\nserver:\n  http_listen_port: 3100\ncommon:\n  path_prefix: /loki\n  storage:\n    filesystem:\n      chunks_directory: /loki/chunks\n      rules_directory: /loki/rules\n  replication_factor: 1\n  ring:\n    instance_addr: 127.0.0.1\n    kvstore:\n      store: inmemory\nschema_config:\n  configs:\n  - from: 2020-10-24\n    store: boltdb-shipper\n    object_store: filesystem\n    schema: v11\n    index:\n      prefix: index_\n      period: 24h\nlimits_config:\n  ingestion_rate_mb: 8\n  ingestion_burst_size_mb: 16\n  reject_old_samples: true\n  reject_old_samples_max_age: 168h\n" > $LOKI_CFG
  echo "✅ Created default Loki config"
end

set -l PROMTAIL_CFG "$PROMTAIL_CFG_DIR/config.yml"
if not test -f $PROMTAIL_CFG
  echo "📁 Bootstrapping Promtail config at $PROMTAIL_CFG"
  printf "server:\n  http_listen_port: 9080\n  grpc_listen_port: 0\npositions:\n  filename: /tmp/positions.yaml\nclients:\n  - url: http://host.docker.internal:3100/loki/api/v1/push\nscrape_configs:\n  - job_name: system-logs\n    static_configs:\n      - targets: [localhost]\n        labels:\n          job: varlogs\n          __path__: /var/log/*.log\n" > $PROMTAIL_CFG
  echo "✅ Created default Promtail config"
end

# 3) Start Loki
echo "🚀 Starting Loki (3100)..."
$DOCKER inspect loki >/dev/null 2>&1; and set -l loki_exists yes; or set -l loki_exists no
if test $loki_exists = yes
  $DOCKER start loki >/dev/null 2>&1
  if test $status -eq 0
    echo "✅ Loki started"
  else
    echo "✅ Loki already running"
  end
else
  echo "📥 Pulling $IMAGE_LOKI..."
  $DOCKER pull $IMAGE_LOKI >/dev/null
  if test $status -ne 0
    echo "❌ Failed to pull $IMAGE_LOKI"
    exit 1
  end
  $DOCKER run -d \
    --name loki \
    --restart unless-stopped \
    -p 3100:3100 \
    -v "$LOKI_CFG:/etc/loki/config.yml:ro$VSUFFIX" \
    -v "$LOKI_DATA_DIR:/loki$VSUFFIX" \
    $IMAGE_LOKI \
    -config.file=/etc/loki/config.yml >/dev/null
  if test $status -ne 0
    echo "❌ Failed to create Loki container"
    exit 1
  end
  echo "✅ Loki container created"
end

# 3.1) Health check Loki metrics
echo "🧪 Checking Loki metrics endpoint..."
set -l tries 0
while test $tries -lt 10
  sleep 1
  if curl -fsS http://localhost:3100/metrics >/dev/null 2>&1
    echo "✅ Loki metrics reachable at http://localhost:3100/metrics"
    break
  end
  set tries (math $tries + 1)
end
if test $tries -ge 10
  echo "❌ Unable to reach Loki metrics on http://localhost:3100/metrics"
  echo "ℹ️  Showing recent Loki logs to help diagnose:"
  $DOCKER logs --tail 100 loki 2>&1 | sed -n '1,120p'
end

# 4) Start Promtail
echo "🚀 Starting Promtail (9080)..."
$DOCKER inspect promtail >/dev/null 2>&1; and set -l promtail_exists yes; or set -l promtail_exists no
if test $promtail_exists = yes
  $DOCKER start promtail >/dev/null 2>&1
  if test $status -eq 0
    echo "✅ Promtail started"
  else
    echo "✅ Promtail already running"
  end
else
  echo "📥 Pulling $IMAGE_PROMTAIL..."
  $DOCKER pull $IMAGE_PROMTAIL >/dev/null
  if test $status -ne 0
    echo "❌ Failed to pull $IMAGE_PROMTAIL"
    exit 1
  end
  $DOCKER run -d \
    --name promtail \
    --restart unless-stopped \
    -p 9080:9080 \
    -v "$PROMTAIL_CFG:/etc/promtail/config.yml:ro$VSUFFIX" \
    -v "/var/log:/var/log:ro$VSUFFIX" \
    $IMAGE_PROMTAIL \
    -config.file=/etc/promtail/config.yml >/dev/null
  if test $status -ne 0
    echo "❌ Failed to create Promtail container"
    exit 1
  end
  echo "✅ Promtail container created"
end

echo "📍 Loki metrics: http://localhost:3100/metrics | Promtail: http://localhost:9080"


