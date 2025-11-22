#!/usr/bin/env fish
# === podman_compose.fish ===
# Purpose: Install podman-compose (docker-compose alternative for Podman) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting podman-compose installation..."
echo
echo "💡 podman-compose is a docker-compose alternative for Podman:"
echo "   - Run docker-compose.yml files with Podman"
echo "   - Drop-in replacement for docker-compose"
echo "   - Works with existing docker-compose files"
echo "   - Rootless container support"
echo "   - Great for Podman users"
echo

# === 1. Check if podman-compose is already installed ===
command -q podman-compose; and set -l podman_compose_installed "installed"
if test -n "$podman_compose_installed"
    echo "✅ podman-compose is already installed."
    podman-compose --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping podman-compose installation."
        exit 0
    end
    echo "📦 Removing existing podman-compose installation..."
    # Try to remove via pacman
    if pacman -Qq podman-compose > /dev/null 2>&1
        sudo pacman -R --noconfirm podman-compose
    end
    # Try to remove via pip
    if command -v pip > /dev/null
        pip uninstall -y podman-compose 2>/dev/null
    end
    if command -v pip3 > /dev/null
        pip3 uninstall -y podman-compose 2>/dev/null
    end
    # Remove manually installed script
    if test -f /usr/local/bin/podman-compose
        sudo rm -f /usr/local/bin/podman-compose
    end
    if test -f ~/.local/bin/podman-compose
        rm -f ~/.local/bin/podman-compose
    end
    echo "✅ podman-compose removed."
end

# === 2. Check if Podman is installed ===
if not command -q podman
    echo "⚠ Podman is not installed."
    echo "💡 podman-compose requires Podman to function."
    read -P "Do you want to install Podman first? [Y/n] " install_podman
    if test "$install_podman" != "n" -a "$install_podman" != "N"
        echo "📦 Installing Podman..."
        sudo pacman -S --needed --noconfirm podman
        if test $status -ne 0
            echo "❌ Failed to install Podman."
            exit 1
        end
        echo "✅ Podman installed."
    else
        echo "❌ Podman is required for podman-compose."
        exit 1
    end
else
    echo "✅ Podman is already installed."
end

# === 3. Install from official repository (preferred) ===
echo "📦 Checking official repository for podman-compose..."
if pacman -Si podman-compose > /dev/null 2>&1
    echo "📦 Installing podman-compose from official Arch repository..."
    sudo pacman -S --needed --noconfirm podman-compose
    if test $status -eq 0
        echo "✅ podman-compose installed from official repository."
        set podman_compose_installed_via_pacman true
    else
        echo "❌ Failed to install podman-compose from official repository."
    end
else
    echo "ℹ podman-compose not found in official repository."
end

# === 4. Fallback: Install via pip ===
if not set -q podman_compose_installed_via_pacman
    if command -q pip3
        echo "📦 Installing podman-compose via pip3..."
        pip3 install --user podman-compose
        if test $status -eq 0
            echo "✅ podman-compose installed via pip3."
            set podman_compose_installed_via_pip true
            # Ensure ~/.local/bin is in PATH
            if not contains "$HOME/.local/bin" $fish_user_paths
                set -U fish_user_paths $HOME/.local/bin $fish_user_paths
                echo "🔧 Added ~/.local/bin to PATH"
            end
        else
            echo "⚠ Failed to install podman-compose via pip3."
        end
    else if command -q pip
        echo "📦 Installing podman-compose via pip..."
        pip install --user podman-compose
        if test $status -eq 0
            echo "✅ podman-compose installed via pip."
            set podman_compose_installed_via_pip true
            # Ensure ~/.local/bin is in PATH
            if not contains "$HOME/.local/bin" $fish_user_paths
                set -U fish_user_paths $HOME/.local/bin $fish_user_paths
                echo "🔧 Added ~/.local/bin to PATH"
            end
        else
            echo "⚠ Failed to install podman-compose via pip."
        end
    else
        echo "ℹ pip/pip3 not found. Will try GitHub installation."
    end
end

# === 5. Fallback: Install from GitHub ===
if not set -q podman_compose_installed_via_pacman -a not set -q podman_compose_installed_via_pip
    echo "📥 Installing podman-compose from GitHub..."
    
    echo "📦 Downloading podman-compose script..."
    sudo mkdir -p /usr/local/bin
    sudo curl -L -o /usr/local/bin/podman-compose https://raw.githubusercontent.com/containers/podman-compose/devel/podman_compose.py
    if test $status -eq 0
        sudo chmod +x /usr/local/bin/podman-compose
        echo "✅ podman-compose installed from GitHub."
    else
        echo "❌ Failed to download podman-compose from GitHub."
        exit 1
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."

# Ensure ~/.local/bin is in PATH for verification if installed via pip
if set -q podman_compose_installed_via_pip
    set -x PATH $HOME/.local/bin $PATH
end

if command -q podman-compose
    echo "✅ podman-compose installed successfully"
    podman-compose --version 2>&1 | head -n 1
else
    echo "❌ podman-compose verification failed."
    if set -q podman_compose_installed_via_pip
        echo "💡 If installed via pip, ensure ~/.local/bin is in your PATH"
        echo "   Or restart your terminal."
    end
    exit 1
end

echo
echo "🎉 podman-compose installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Start services from docker-compose.yml"
echo "   podman-compose up"
echo ""
echo "   # Start in detached mode"
echo "   podman-compose up -d"
echo ""
echo "   # Stop services"
echo "   podman-compose down"
echo ""
echo "   # Build images"
echo "   podman-compose build"
echo ""
echo "   # View logs"
echo "   podman-compose logs"
echo ""
echo "💡 Common commands:"
echo "   # Start services"
echo "   podman-compose up"
echo "   podman-compose up -d          # Detached mode"
echo ""
echo "   # Stop services"
echo "   podman-compose down"
echo "   podman-compose down -v        # Remove volumes"
echo ""
echo "   # Build and start"
echo "   podman-compose up --build"
echo ""
echo "   # View logs"
echo "   podman-compose logs"
echo "   podman-compose logs -f        # Follow logs"
echo "   podman-compose logs service   # Specific service"
echo ""
echo "   # Execute commands in containers"
echo "   podman-compose exec service command"
echo ""
echo "   # Run one-off commands"
echo "   podman-compose run service command"
echo ""
echo "💡 docker-compose.yml compatibility:"
echo "   # podman-compose works with standard docker-compose.yml files"
echo "   # Most docker-compose features are supported"
echo "   # Some Docker-specific features may not work"
echo ""
echo "💡 Example docker-compose.yml:"
echo "   version: '3.8'"
echo "   services:"
echo "     web:"
echo "       image: nginx:alpine"
echo "       ports:"
echo "         - '8080:80'"
echo "     db:"
echo "       image: postgres:15"
echo "       environment:"
echo "         POSTGRES_PASSWORD: password"
echo ""
echo "💡 Podman-specific features:"
echo "   # Rootless containers (default)"
echo "   # No daemon required"
echo "   # Better security isolation"
echo "   # Compatible with systemd services"
echo ""
echo "💡 Tips:"
echo "   - Works with existing docker-compose.yml files"
echo "   - Use podman-compose instead of docker-compose"
echo "   - Containers run rootless by default"
echo "   - No need for Docker daemon"
echo "   - Great for development and production"
echo ""
echo "💡 Resources:"
echo "   - GitHub: https://github.com/containers/podman-compose"
echo "   - Documentation: https://github.com/containers/podman-compose#readme"

