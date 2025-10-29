#!/usr/bin/env fish

echo "🧠 Setting up Redis and redis-commander via Docker/Podman..."

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

# 2) Ensure network and data
set -l NET dev-net
set -l REDIS_DATA "$HOME/.local/state/redis"
mkdir -p $REDIS_DATA

$DOCKER network inspect $NET >/dev/null 2>&1; or begin
  echo "🔧 Creating network $NET..."
  $DOCKER network create $NET >/dev/null
  if test $status -eq 0
    echo "✅ Network $NET created"
  else
    echo "❌ Failed to create network $NET"
  end
end

# 3) Start Redis
echo "🚀 Starting Redis (6379)..."
$DOCKER inspect redis >/dev/null 2>&1; and set -l redis_exists yes; or set -l redis_exists no
if test $redis_exists = yes
  $DOCKER start redis >/dev/null 2>&1
  if test $status -eq 0
    echo "✅ Redis started"
  else
    echo "✅ Redis already running"
  end
else
  $DOCKER run -d \
    --name redis \
    --restart unless-stopped \
    --network $NET \
    -p 6379:6379 \
    -v "$REDIS_DATA:/data" \
    docker.io/library/redis:7-alpine \
    redis-server --save 60 1 --loglevel warning >/dev/null
  if test $status -ne 0
    echo "❌ Failed to create Redis container"
    exit 1
  end
  echo "✅ Redis container created"
end

# 4) Start redis-commander
echo "🚀 Starting redis-commander (8081)..."
$DOCKER inspect redis-commander >/dev/null 2>&1; and set -l rc_exists yes; or set -l rc_exists no
if test $rc_exists = yes
  $DOCKER start redis-commander >/dev/null 2>&1
  if test $status -eq 0
    echo "✅ redis-commander started"
  else
    echo "✅ redis-commander already running"
  end
else
  $DOCKER run -d \
    --name redis-commander \
    --restart unless-stopped \
    --network $NET \
    -p 8081:8081 \
    -e REDIS_HOSTS="local:redis:6379" \
    ghcr.io/joeferner/redis-commander:latest >/dev/null
  if test $status -ne 0
    echo "❌ Failed to create redis-commander container"
    exit 1
  end
  echo "✅ redis-commander container created"
end

echo "📍 Redis: localhost:6379 | redis-commander: http://localhost:8081"


