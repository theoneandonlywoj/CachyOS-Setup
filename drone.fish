#!/usr/bin/env fish
# === drone.fish ===
# Purpose: Install Drone CLI (CI/CD command-line tool) on CachyOS (Arch Linux)
# Installs Drone CLI via GitHub releases (preferred) or pacman/AUR
# Author: theoneandonlywoj

# === Version configuration ===
set DRONE_VERSION "latest"  # Use "latest" or specific version like "1.6.1"

echo "🚀 Starting Drone CLI installation..."
echo "📌 Target version: $DRONE_VERSION"
echo
echo "💡 Drone is a modern CI/CD platform:"
echo "   - Cloud-native continuous integration"
echo "   - Native Docker support"
echo "   - YAML-based pipeline configuration"
echo "   - Integrates with Git providers (GitHub, GitLab, Bitbucket, Gitea)"
echo "   - Lightweight and fast"
echo

# === 1. Check if Drone CLI is already installed ===
command -q drone; and set -l drone_installed "installed"
if test -n "$drone_installed"
    echo "✅ Drone CLI is already installed."
    drone --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Drone CLI installation."
        exit 0
    end
    echo "📦 Removing existing Drone CLI installation..."
    # Try to remove via pacman
    if pacman -Qq drone-cli > /dev/null 2>&1
        sudo pacman -R --noconfirm drone-cli
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/drone
        sudo rm -f /usr/local/bin/drone
    end
    if test -f ~/.local/bin/drone
        rm -f ~/.local/bin/drone
    end
    echo "✅ Drone CLI removed."
end

# === 2. Install from GitHub releases (primary method) ===
echo "📥 Installing Drone CLI from GitHub releases..."

# Detect architecture
set arch (uname -m)
switch $arch
    case x86_64
        set DRONE_ARCH "amd64"
    case aarch64 arm64
        set DRONE_ARCH "arm64"
    case armv7l
        set DRONE_ARCH "arm"
    case '*'
        echo "❌ Unsupported architecture: $arch"
        exit 1
end

# Get latest version from GitHub API if needed
if test "$DRONE_VERSION" = "latest"
    echo "🔍 Fetching latest Drone CLI version..."
    set DRONE_VERSION (curl -s https://api.github.com/repos/harness/drone-cli/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    
    if test -z "$DRONE_VERSION"
        echo "⚠ Failed to fetch latest version. Using fallback method..."
        set DRONE_VERSION "1.6.1"
    end
end

echo "📦 Downloading Drone CLI v$DRONE_VERSION..."
set DRONE_FILENAME "drone_linux_$DRONE_ARCH.tar.gz"
set DRONE_URL "https://github.com/harness/drone-cli/releases/download/v$DRONE_VERSION/$DRONE_FILENAME"
set DRONE_TMP_DIR (mktemp -d)
set DRONE_TAR "$DRONE_TMP_DIR/drone.tar.gz"

curl -L -o $DRONE_TAR $DRONE_URL
if test $status -ne 0
    echo "❌ Failed to download Drone CLI from GitHub."
    rm -rf $DRONE_TMP_DIR
    set drone_github_failed true
end

if not set -q drone_github_failed
    # Extract and install
    echo "📦 Extracting Drone CLI..."
    cd $DRONE_TMP_DIR
    tar -xzf $DRONE_TAR
    if test $status -ne 0
        echo "❌ Failed to extract Drone CLI archive."
        rm -rf $DRONE_TMP_DIR
        set drone_github_failed true
    end
end

if not set -q drone_github_failed
    # Install binary
    sudo mkdir -p /usr/local/bin
    sudo cp drone /usr/local/bin/drone
    sudo chmod +x /usr/local/bin/drone
    
    # Cleanup
    cd -
    rm -rf $DRONE_TMP_DIR
    
    if test $status -eq 0
        echo "✅ Drone CLI installed from GitHub releases."
        set drone_installed_via_github true
    else
        echo "❌ Failed to install Drone CLI binary."
        echo "⚠ Falling back to package manager..."
        set drone_github_failed true
    end
end

# === 3. Fallback: Install via pacman/AUR ===
if set -q drone_github_failed -o not set -q drone_installed_via_github
    echo "📦 Installing Drone CLI via package manager..."
    
    # Check if available in official repos
    if pacman -Si drone-cli > /dev/null 2>&1
        echo "📦 Installing Drone CLI from official Arch repository..."
        sudo pacman -S --needed --noconfirm drone-cli
        if test $status -eq 0
            echo "✅ Drone CLI installed from official repository."
            set drone_installed_via_pacman true
        else
            echo "❌ Failed to install Drone CLI from official repository."
        end
    else
        # Try AUR helper
        set AUR_HELPER ""
        for helper in yay paru trizen pikaur
            if command -v $helper > /dev/null
                set AUR_HELPER $helper
                break
            end
        end
        
        if test -n "$AUR_HELPER"
            echo "📦 Installing Drone CLI from AUR using $AUR_HELPER..."
            $AUR_HELPER -S --needed --noconfirm drone-cli
            if test $status -eq 0
                echo "✅ Drone CLI installed from AUR."
                set drone_installed_via_pacman true
            else
                echo "❌ Failed to install Drone CLI from AUR."
            end
        else
            echo "❌ No AUR helper found. Please install yay, paru, trizen, or pikaur."
        end
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
set drone_verified false
if command -q drone
    set drone_verified true
    echo "✅ Drone CLI installed successfully"
    drone --version 2>&1
end

if not $drone_verified
    echo "❌ Drone CLI installation verification failed."
    exit 1
end

echo
echo "🎉 Drone CLI installation complete!"
echo
echo "📚 Installed version: $DRONE_VERSION"
echo
echo "💡 Basic usage:"
echo "   # Authenticate with Drone server"
echo "   export DRONE_SERVER=https://drone.example.com"
echo "   export DRONE_TOKEN=your_token_here"
echo ""
echo "   # Or use drone login"
echo "   drone login https://drone.example.com"
echo ""
echo "   # List repositories"
echo "   drone repo ls"
echo ""
echo "   # Trigger a build"
echo "   drone build start <owner>/<repo> <branch>"
echo ""
echo "   # View build logs"
echo "   drone build logs <owner>/<repo> <build_number>"
echo ""
echo "   # View build info"
echo "   drone build info <owner>/<repo> <build_number>"
echo ""
echo "💡 Configuration:"
echo "   # Set server URL"
echo "   export DRONE_SERVER=https://drone.example.com"
echo ""
echo "   # Set authentication token"
echo "   export DRONE_TOKEN=your_token_here"
echo ""
echo "   # Or use config file: ~/.drone/config"
echo ""
echo "💡 Common commands:"
echo "   # Repository management"
echo "   drone repo ls                    # List repositories"
echo "   drone repo info <owner>/<repo>   # Show repository info"
echo "   drone repo enable <owner>/<repo> # Enable repository"
echo "   drone repo disable <owner>/<repo> # Disable repository"
echo ""
echo "   # Build management"
echo "   drone build ls <owner>/<repo>    # List builds"
echo "   drone build start <owner>/<repo> <branch> # Start build"
echo "   drone build stop <owner>/<repo> <build> # Stop build"
echo "   drone build approve <owner>/<repo> <build> <stage> # Approve build"
echo ""
echo "   # Secret management"
echo "   drone secret ls <owner>/<repo>   # List secrets"
echo "   drone secret add <owner>/<repo> <name> <value> # Add secret"
echo "   drone secret rm <owner>/<repo> <name> # Remove secret"
echo ""
echo "💡 Pipeline configuration (.drone.yml example):"
echo "   kind: pipeline"
echo "   type: docker"
echo "   name: default"
echo ""
echo "   steps:"
echo "   - name: test"
echo "     image: node:18"
echo "     commands:"
echo "       - npm install"
echo "       - npm test"
echo ""
echo "💡 Drone Server:"
echo "   This script installs the Drone CLI (client)."
echo "   To run a full Drone CI/CD setup, you also need:"
echo "   - Drone Server (drone/drone)"
echo "   - Drone Runner (drone/drone-runner-docker, drone-runner-exec, etc.)"
echo "   - A Git provider (GitHub, GitLab, Bitbucket, or Gitea)"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://www.drone.io/"
echo "   - Documentation: https://docs.drone.io/"
echo "   - CLI reference: https://docs.drone.io/cli/install/"
echo "   - GitHub: https://github.com/harness/drone-cli"
echo "   - Examples: https://github.com/drone/drone/tree/master/examples"

