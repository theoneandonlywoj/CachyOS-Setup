#!/usr/bin/env fish
# === coolify.fish ===
# Purpose: Install Coolify (self-hosted PaaS) on CachyOS (Arch Linux)
# Uses the official Coolify installer and verifies the local stack
# Author: theoneandonlywoj

# === Version configuration ===
set COOLIFY_VERSION "latest"  # Use "latest" or a specific version like "4.0.0-beta.394"

echo "🚀 Starting Coolify installation..."
echo "📌 Target version: $COOLIFY_VERSION"
echo
echo "💡 Coolify is a self-hosted platform for local and remote deployments"
echo "   - Docker-based application deployments"
echo "   - Automatic reverse proxy and domains"
echo "   - One-click PostgreSQL, Redis, and more"
echo "   - Git-driven app builds with Dockerfile or Nixpacks"
echo

# === 0. Preflight checks ===
echo "🔍 Running preflight checks..."

if not command -q curl
    echo "❌ curl is required but not installed."
    echo "   Install it first with: sudo pacman -S curl"
    exit 1
end

echo "🔐 Validating sudo access..."
sudo -v
if test $status -ne 0
    echo "❌ sudo access is required. Aborting."
    exit 1
end

function real_docker_bin
    for candidate in /usr/bin/docker /usr/local/bin/docker
        if test -x $candidate
            echo $candidate
            return 0
        end
    end

    return 1
end

function docker_engine
    set -l docker_bin (real_docker_bin)
    if test -z "$docker_bin"
        return 127
    end

    sudo $docker_bin $argv
end

set arch (uname -m)
switch $arch
    case x86_64
        set COOLIFY_ARCH "amd64"
    case aarch64 arm64
        set COOLIFY_ARCH "arm64"
    case '*'
        echo "❌ Unsupported architecture: $arch"
        exit 1
end

echo "✅ Architecture supported: $arch ($COOLIFY_ARCH)"

set total_ram_mb (free -m | awk '/^Mem:/ {print $2}')
if test -n "$total_ram_mb"
    echo "💾 Detected RAM: $total_ram_mb MB"
    if test $total_ram_mb -lt 2048
        echo "⚠ Coolify works best with at least 2 GB of RAM."
        read -P "Do you want to continue anyway? [y/N] " continue_low_ram
        if test "$continue_low_ram" != "y" -a "$continue_low_ram" != "Y"
            echo "⚠ Aborting due to low RAM."
            exit 1
        end
    end
end

set total_disk_gb (df -BG / | awk 'NR==2 {gsub("G", "", $2); print $2}')
set available_disk_gb (df -BG / | awk 'NR==2 {gsub("G", "", $4); print $4}')
if test -n "$total_disk_gb" -a -n "$available_disk_gb"
    echo "💽 Disk space: $available_disk_gb GB free / $total_disk_gb GB total"
    if test $total_disk_gb -lt 30 -o $available_disk_gb -lt 20
        echo "⚠ Coolify recommends at least 30 GB total and 20 GB free disk space."
        read -P "Do you want to continue anyway? [y/N] " continue_low_disk
        if test "$continue_low_disk" != "y" -a "$continue_low_disk" != "Y"
            echo "⚠ Aborting due to low disk space."
            exit 1
        end
    end
end

set port_8000_in_use false
if command -q ss
    set port_8000_check (ss -tln 2>/dev/null | grep ':8000 ')
    if test -n "$port_8000_check"
        set port_8000_in_use true
    end
end

# === 1. Check for existing Coolify installation ===
set coolify_installed false
if test -d /data/coolify
    set coolify_installed true
end

set real_docker (real_docker_bin 2>/dev/null)
if test -n "$real_docker"
    set existing_coolify_container (docker_engine ps -a --format '{{.Names}}' 2>/dev/null | grep '^coolify$')
    if test -n "$existing_coolify_container"
        set coolify_installed true
    end
end

if test "$port_8000_in_use" = "true"
    if test "$coolify_installed" = "true"
        echo "ℹ Port 8000 is already in use by an existing Coolify or local service."
    else
        echo "❌ Port 8000 is already in use. Coolify needs this port for the dashboard."
        echo "💡 Inspect it with: sudo ss -tlnp | grep ':8000 '"
        exit 1
    end
else
    echo "✅ Port 8000 is available."
end

if test "$coolify_installed" = "true"
    echo "✅ Existing Coolify installation detected."
    set real_docker (real_docker_bin 2>/dev/null)
    if test -n "$real_docker"
        docker_engine ps -a --filter name=coolify --format 'table {{.Names}}\t{{.Status}}'
    end
    read -P "Do you want to reinstall / re-run the official installer? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Coolify installation."
        exit 0
    end
end

# === 2. Check container runtime expectations ===
echo
echo "🐳 Checking container runtime setup..."

set podman_present false
set docker_package_installed false
set podman_docker_installed false

command -q podman; and set podman_present true
pacman -Qq docker > /dev/null 2>&1; and set docker_package_installed true
pacman -Qq podman-docker > /dev/null 2>&1; and set podman_docker_installed true

if test "$podman_docker_installed" = "true" -a "$docker_package_installed" != "true"
    echo "⚠ podman-docker is installed and it conflicts with the Docker Engine package Coolify needs."
    read -P "Do you want to remove podman-docker now? [y/N] " remove_podman_docker
    if test "$remove_podman_docker" = "y" -o "$remove_podman_docker" = "Y"
        sudo pacman -R --noconfirm podman-docker
        if test $status -ne 0
            echo "❌ Failed to remove podman-docker. Aborting."
            exit 1
        end
        echo "✅ Removed podman-docker so Docker Engine can be installed."
    else
        echo "⚠ Aborting because Coolify requires Docker Engine, not the podman-docker wrapper."
        exit 1
    end
end

if test "$podman_present" = "true" -a "$docker_package_installed" != "true"
    echo "⚠ Podman is installed, but Docker is not currently available."
    echo "   Coolify requires Docker Engine and the official installer will install/configure it."
    echo "   Keep using ./podman.fish for Podman-specific workflows if you need both tools."
else if test "$podman_present" = "true" -a "$docker_package_installed" = "true"
    echo "ℹ Both Podman and Docker are present. Coolify will use Docker Engine."
else if test "$docker_package_installed" = "true"
    echo "✅ Docker Engine is already installed."
else
    echo "ℹ Docker is not installed yet. The Coolify installer will set it up."
end

# === 3. Install Coolify using the official installer ===
echo
echo "📥 Downloading the official Coolify installer..."
set COOLIFY_INSTALL_SCRIPT (mktemp)
curl -fsSL https://cdn.coollabs.io/coolify/install.sh -o $COOLIFY_INSTALL_SCRIPT
if test $status -ne 0
    echo "❌ Failed to download the Coolify installer."
    rm -f $COOLIFY_INSTALL_SCRIPT
    exit 1
end

echo "🚀 Running the official Coolify installer..."
sudo bash $COOLIFY_INSTALL_SCRIPT $COOLIFY_VERSION
set install_status $status
rm -f $COOLIFY_INSTALL_SCRIPT

if test $install_status -ne 0
    echo "❌ Coolify installation failed."
    echo "💡 For a verbose retry, run:"
    echo "   curl -fsSL https://cdn.coollabs.io/coolify/install.sh -o install.sh"
    echo "   bash -x install.sh 2>&1 | tee installation-debug.log"
    exit 1
end

# Refresh sudo timestamp because the official installer can run for several minutes.
sudo -v

# === 4. Wait for Coolify to become healthy ===
echo
echo "⏳ Waiting for Coolify to become ready..."
set coolify_wait_seconds 120
set coolify_elapsed 0
set coolify_health ""

while test $coolify_elapsed -lt $coolify_wait_seconds
    set real_docker (real_docker_bin 2>/dev/null)
    if test -n "$real_docker"
        set coolify_health (docker_engine inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' coolify 2>/dev/null)
        if test "$coolify_health" = "healthy" -o "$coolify_health" = "running"
            break
        end
    end

    sleep 2
    set coolify_elapsed (math "$coolify_elapsed + 2")
end

if test "$coolify_health" != "healthy" -a "$coolify_health" != "running"
    echo "❌ Coolify did not become ready within $coolify_wait_seconds seconds."
    echo "💡 Check logs with: sudo /usr/bin/docker logs coolify --tail 50"
    exit 1
end

echo "✅ Coolify container status: $coolify_health"

# === 5. Verify the local Coolify stack ===
echo
echo "🧪 Verifying the Coolify stack..."
set expected_containers coolify coolify-db coolify-redis coolify-realtime
set verification_failed false

for container in $expected_containers
    set container_status (docker_engine inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' $container 2>/dev/null)

    if test -z "$container_status"
        echo "❌ $container is missing."
        set verification_failed true
    else
        switch $container_status
            case healthy running
                echo "✅ $container -> $container_status"
            case '*'
                echo "⚠ $container -> $container_status"
                set verification_failed true
        end
    end
end

if test "$verification_failed" = "true"
    echo "❌ Coolify stack verification failed."
    echo "💡 Inspect all containers with: sudo /usr/bin/docker ps -a --filter name=coolify"
    exit 1
end

echo
echo "🎉 Coolify installation complete!"
echo
echo "🌐 Local dashboard: http://127.0.0.1:8000"
echo "📁 Coolify data directory: /data/coolify"
echo
echo "🧪 Basic local setup testing:"
echo "   # Check the dashboard responds locally"
echo "   curl -I http://127.0.0.1:8000"
echo
echo "   # Inspect Coolify containers"
echo "   sudo /usr/bin/docker ps --filter name=coolify --format 'table {{.Names}}\t{{.Status}}'"
echo
echo "   # Review recent application logs"
echo "   sudo /usr/bin/docker logs coolify --tail 30"
echo
echo "💡 First login: open http://127.0.0.1:8000 and create your root account in the browser."
echo "💡 Firewall note: local testing uses port 8000 now; deployed apps commonly use ports 80 and 443 via the proxy."
echo "💡 If you use Podman aliases or the Fish docker function, prefer /usr/bin/docker for Coolify host commands."
echo "💡 Next step: follow docs/COOLIFY_PHOENIX_LOCAL_GUIDE.md to deploy a local Phoenix umbrella app with PostgreSQL."
