#!/usr/bin/env fish
# === podman_docker_compose.fish ===
# Purpose: Install Podman, Docker Compose, and Docker CLI alias on CachyOS
# Handles Docker conflicts and aliases 'docker' commands to Podman
# Author: theoneandonlywoj

echo "🚀 Starting Podman and Docker Compose installation..."

# === 0. Check if Docker is installed ===
set -l docker_installed (pacman -Qq docker ^/dev/null)
if test -n "$docker_installed"
    echo "⚠ Docker is currently installed. podman-docker will conflict with it."
    echo "   You must remove Docker to install podman-docker for docker CLI replacement."
    read -P "Do you want to remove Docker? [y/N] " remove_docker
    if test "$remove_docker" = "y" -o "$remove_docker" = "Y"
        sudo pacman -R --noconfirm docker
        if test $status -ne 0
            echo "❌ Failed to remove Docker. Aborting."
            exit 1
        end
        echo "✅ Docker removed."
    else
        echo "ℹ Skipping podman-docker installation. You can still use Podman, but 'docker' CLI will not point to Podman."
    end
end

# === 1. Install Podman ===
echo "📦 Installing Podman..."
sudo pacman -S --needed --noconfirm podman
if test $status -ne 0
    echo "❌ Failed to install Podman."
    exit 1
end
echo "✅ Podman installed."

# === 2. Install podman-docker if Docker was removed ===
if not test -n "$docker_installed" -o "$remove_docker" = "y"
    echo "📦 Installing podman-docker wrapper..."
    sudo pacman -S --needed --noconfirm podman-docker
    if test $status -ne 0
        echo "❌ Failed to install podman-docker."
        exit 1
    end
    echo "✅ podman-docker installed."
end

# === 3. Enable Podman socket for rootless containers ===
echo "⚙ Enabling Podman socket for user..."
systemctl --user enable --now podman.socket
if test $status -ne 0
    echo "⚠ Failed to enable Podman socket. You may need to start it manually."
end

# === 4. Enable systemd linger for automatic socket start ===
echo "⚙ Enabling systemd linger to start Podman socket at login..."
sudo loginctl enable-linger (whoami)
if test $status -ne 0
    echo "⚠ Failed to enable systemd linger. You may need to enable it manually."
end

# === 5. Install Docker Compose ===
set -l COMPOSE_VERSION "v2.24.1"
set -l COMPOSE_BIN "/usr/local/bin/docker-compose"

echo "📦 Installing Docker Compose $COMPOSE_VERSION..."
if not test -f $COMPOSE_BIN
    sudo curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o $COMPOSE_BIN
    sudo chmod +x $COMPOSE_BIN
    if test $status -ne 0
        echo "❌ Failed to install Docker Compose."
        exit 1
    end
else
    echo "✅ Docker Compose already installed at $COMPOSE_BIN"
end

# === 6. Add alias/function for Docker commands to Podman (Fish shell) ===
echo "🔗 Creating 'docker' function to alias Podman in Fish..."
set -l fish_func_dir ~/.config/fish/functions
mkdir -p $fish_func_dir

set -l docker_func_file $fish_func_dir/docker.fish
if not test -f $docker_func_file
    echo "function docker; podman \$argv; end" > $docker_func_file
    echo "✅ 'docker' function created: all docker commands now use Podman."
else
    echo "ℹ 'docker' function already exists."
end

# === 7. Verify installations ===
echo
echo "🧪 Verifying installations..."
podman --version
if type docker >/dev/null 2>&1
    docker --version
end
docker-compose version

echo
echo "✅ Podman and Docker Compose installation complete!"
if test -n "$docker_installed" -a "$remove_docker" != "y"
    echo "💡 Docker CLI still points to Docker. podman-docker was skipped due to conflict."
else
    echo "💡 Docker CLI now points to Podman via function alias."
end
echo "💡 Rootless Podman socket will start automatically at login."
echo "💡 Restart your terminal or run 'source ~/.config/fish/config.fish' to apply the 'docker' function."
