#!/usr/bin/env fish

echo "🚨 Setting up Alertmanager via Docker/Podman..."

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

# Fully-qualified image to avoid short-name resolution issues (especially with podman)
set -l IMAGE docker.io/prom/alertmanager:latest

# 2) Ensure config
set -l CFG_DIR "$HOME/.config/alertmanager"
mkdir -p $CFG_DIR
set -l CFG_FILE "$CFG_DIR/config.yml"
if not test -f $CFG_FILE
  echo "📁 Bootstrapping Alertmanager config at $CFG_FILE"
  printf "route:\n  receiver: 'default'\nreceivers:\n  - name: 'default'\n    webhook_configs:\n      - url: 'http://localhost:8080/'\n" > $CFG_FILE
  echo "✅ Created default Alertmanager config"
end

# 3) Create or start container
echo "🚀 Starting Alertmanager (9093)..."
$DOCKER inspect alertmanager >/dev/null 2>&1; and set -l exists yes; or set -l exists no
if test $exists = yes
  $DOCKER start alertmanager >/dev/null 2>&1
  if test $status -eq 0
    echo "✅ Alertmanager started"
  else
    echo "✅ Alertmanager already running"
  end
else
  echo "📥 Pulling $IMAGE..."
  $DOCKER pull $IMAGE >/dev/null
  if test $status -ne 0
    echo "❌ Failed to pull $IMAGE"
    exit 1
  end
  $DOCKER run -d \
    --name alertmanager \
    --restart unless-stopped \
    -p 9093:9093 \
    -v "$CFG_DIR:/etc/alertmanager" \
    $IMAGE \
    --config.file=/etc/alertmanager/config.yml >/dev/null
  if test $status -ne 0
    echo "❌ Failed to create Alertmanager container"
    exit 1
  end
  echo "✅ Alertmanager container created"
end

echo "📍 Alertmanager at http://localhost:9093"
echo "ℹ️  Add to Prometheus to enable alerting:"
echo "alerting:\n  alertmanagers:\n    - static_configs:\n        - targets: ['localhost:9093']"


