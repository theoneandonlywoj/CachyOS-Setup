#!/usr/bin/env fish
# === dokploy.fish ===
# Purpose: Install Dokploy (self-hostable PaaS) on Linux
# Installs Dokploy via the official Dokploy installer
# Author: theoneandonlywoj

if not set -q DOKPLOY_VERSION
    set -gx DOKPLOY_VERSION "latest"
end

function get_script_path
    set -l script_path (status filename)
    if command -q realpath
        set script_path (realpath $script_path 2>/dev/null)
    end
    printf '%s\n' $script_path
end

function get_private_ip
    ip -4 addr show 2>/dev/null | grep -E 'inet (192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' | head -n 1 | awk '{print $2}' | cut -d/ -f1
end

function ensure_root
    if test (id -u) -eq 0
        return 0
    end

    echo "🔐 This script requires root privileges..."
    echo "   Please enter your password when prompted."
    echo
    exec sudo --preserve-env=DOKPLOY_VERSION,ADVERTISE_ADDR fish (get_script_path) $argv
end

function ensure_docker_engine
    echo
    echo "🐳 Setting up Docker..."

    set -l docker_ready false
    set -l docker_version ""

    if command -q docker
        set docker_version (docker --version 2>&1 | head -n 1)
        if test -n "$docker_version"
            echo "$docker_version"
        end
    end

    if command -q docker; and not echo "$docker_version" | grep -qi podman; and command -q dockerd
        if docker info > /dev/null 2>&1
            set docker_ready true
            echo "✅ Docker Engine is already installed"
        end
    end

    if not $docker_ready
        if test -n "$docker_version"; and echo "$docker_version" | grep -qi podman
            echo "⚠️  Podman docker shim detected"
        end

        if command -q pacman
            if pacman -Qq podman-docker > /dev/null 2>&1
                echo "📦 Removing podman-docker shim..."
                pacman -R --noconfirm podman-docker
                if test $status -ne 0
                    echo "❌ Failed to remove podman-docker"
                    exit 1
                end
            end

            echo "📥 Installing Docker packages via pacman..."
            pacman -S --needed --noconfirm docker docker-compose
            if test $status -ne 0
                echo "❌ Failed to install Docker packages"
                exit 1
            end
        else
            echo "📥 Installing Docker Engine..."
            curl -fsSL https://get.docker.com | sh
            if test $status -ne 0
                echo "❌ Failed to install Docker Engine"
                exit 1
            end
        end
    end

    if test -L /var/run/docker.sock
        set -l docker_sock_target (readlink /var/run/docker.sock 2>/dev/null)
        if test "$docker_sock_target" = "/run/podman/podman.sock"
            echo "⚠️  Removing Podman docker.sock shim..."
            rm -f /var/run/docker.sock
        end
    end

    systemctl disable --now podman.socket > /dev/null 2>&1
    systemctl enable --now docker > /dev/null 2>&1

    if test $status -ne 0
        echo "❌ Failed to start Docker service"
        exit 1
    end

    if not docker info > /dev/null 2>&1
        echo "❌ Docker daemon is not running"
        exit 1
    end

    if not docker swarm --help > /dev/null 2>&1
        echo "❌ Docker Swarm is unavailable"
        exit 1
    end

    echo "✅ Docker is running with Swarm support"
end

function maybe_remove_existing_dokploy
    set -l existing_service (docker service ls --format '{{.Name}}' 2>/dev/null | string match -r '^dokploy$')
    set -l existing_traefik (docker ps -a --format '{{.Names}}' 2>/dev/null | string match -r '^dokploy-traefik$')

    if test -n "$existing_service" -o -n "$existing_traefik" -o -d /etc/dokploy
        echo
        echo "✅ Existing Dokploy installation detected."
        read -P "Do you want to reinstall? [y/N] " reinstall

        if test "$reinstall" != "y" -a "$reinstall" != "Y"
            echo "⚠️  Skipping Dokploy installation."
            exit 0
        end

        echo "📦 Removing existing Dokploy installation..."
        docker service rm dokploy dokploy-postgres dokploy-redis 2>/dev/null
        docker rm -f dokploy-traefik 2>/dev/null
        docker secret rm dokploy_postgres_password 2>/dev/null
        docker network rm dokploy-network 2>/dev/null
        sleep 3
        echo "✅ Existing Dokploy installation removed."
    end
end

function ensure_required_ports
    for port in 80 443 3000
        if ss -tulnp 2>/dev/null | grep -q ":$port "
            echo "❌ Port $port is already in use"
            ss -tulnp 2>/dev/null | grep ":$port " | head -n 1
            exit 1
        end
    end
end

ensure_root $argv

echo "🚀 Starting Dokploy installation..."
echo "📌 Target version: $DOKPLOY_VERSION"
echo
echo "💡 Dokploy is a self-hostable Platform as a Service (PaaS)"
echo "   - Deploy any application type (Node.js, Python, Go, Ruby, etc.)"
echo "   - Manage databases (PostgreSQL, MySQL, MongoDB, Redis, etc.)"
echo "   - Docker Compose support"
echo "   - Traefik integration with automatic HTTPS"
echo "   - Real-time monitoring"
echo "   - Multi-server support"
echo "   - CI/CD pipelines"
echo

if set -q SUDO_USER
    echo "✅ Root privileges acquired"
end

echo "🔍 Checking prerequisites..."

if test (uname) != "Linux"
    echo "❌ Dokploy must be installed on Linux"
    exit 1
end

if test -f /.dockerenv
    echo "❌ Cannot install Dokploy inside a Docker container"
    exit 1
end

echo "✅ Prerequisites passed"

ensure_docker_engine
maybe_remove_existing_dokploy

echo
echo "🌐 Detecting server IP address..."

set -l advertise_addr ""
if set -q ADVERTISE_ADDR; and test -n "$ADVERTISE_ADDR"
    set advertise_addr "$ADVERTISE_ADDR"
    echo "📍 Using environment IP: $advertise_addr"
else
    set advertise_addr (get_private_ip)
    if test -z "$advertise_addr"
        echo "❌ Could not detect a private IP address"
        echo "   Please set ADVERTISE_ADDR manually and run again."
        echo "   Example: ADVERTISE_ADDR=192.168.1.104 ./dokploy.fish"
        exit 1
    end
    echo "📍 Private IP detected: $advertise_addr"
end

set -gx ADVERTISE_ADDR $advertise_addr

echo
echo "🔍 Checking required ports..."
ensure_required_ports
echo "✅ Required ports are available"

echo
echo "📥 Installing Dokploy via the official installer..."
curl -fsSL https://dokploy.com/install.sh | bash

if test $status -ne 0
    echo "❌ Dokploy installation failed"
    exit 1
end

echo
echo "⏳ Waiting for Dokploy services to settle..."
sleep 15

echo
echo "🧪 Verifying installation..."
set -l dokploy_service (docker service ls --format '{{.Name}}' 2>/dev/null | string match -r '^dokploy$')
set -l dokploy_traefik (docker ps --format '{{.Names}}' 2>/dev/null | string match -r '^dokploy-traefik$')

if test -n "$dokploy_service"
    echo "✅ Dokploy service is running"
else
    echo "⚠️  Dokploy service is not visible yet. Check logs below."
end

if test -n "$dokploy_traefik"
    echo "✅ Traefik container is running"
else
    echo "⚠️  Traefik container is not visible yet. Check logs below."
end

echo
echo "📋 Running services:"
docker service ls 2>/dev/null
echo
docker ps --filter name=dokploy 2>/dev/null

echo
echo "═══════════════════════════════════════════════════════════"
echo "🧪 LOCAL SETUP TESTING INFORMATION"
echo "═══════════════════════════════════════════════════════════"
echo
echo "📍 Access the Dokploy dashboard:"
echo "   🌐 URL: http://$advertise_addr:3000"
echo
echo "⏱️  Wait 15-30 seconds for the UI to fully initialize"
echo
echo "🔧 Basic local testing checklist:"
echo ""
echo "   1. Docker daemon test:"
echo "      docker info"
echo "      docker service ls"
echo "      docker ps"
echo ""
echo "   2. Dokploy API/UI test:"
echo "      curl -I http://127.0.0.1:3000"
echo "      curl -I http://$advertise_addr:3000"
echo ""
echo "   3. Dokploy service logs:"
echo "      docker service logs dokploy --tail 100"
echo "      docker service logs dokploy-postgres --tail 100"
echo "      docker service logs dokploy-redis --tail 100"
echo "      docker logs dokploy-traefik --tail 100"
echo ""
echo "   4. Reverse proxy test:"
echo "      curl -I http://127.0.0.1"
echo "      docker ps --filter name=dokploy-traefik"
echo ""
echo "   5. Swarm test:"
echo "      docker node ls"
echo "      docker network ls | grep dokploy"
echo ""
echo "💡 Service management:"
echo "   docker service ls"
echo "   docker service logs dokploy -f"
echo "   docker logs dokploy-traefik -f"
echo ""
echo "💡 Reinstall / cleanup:"
echo "   docker service rm dokploy dokploy-postgres dokploy-redis"
echo "   docker rm -f dokploy-traefik"
echo "   docker secret rm dokploy_postgres_password"
echo ""
echo "💡 Next steps:"
echo "   - Open Dokploy: http://$advertise_addr:3000"
echo "   - Follow the local Phoenix guide: ./docs/DOKPLOY_PHOENIX_GUIDE.md"
echo ""
echo "📦 Documentation: https://docs.dokploy.com"
echo "💬 Discord: https://discord.gg/2tBnJ3jDJc"
