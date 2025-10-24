#!/usr/bin/env fish
# === act.fish ===
# Purpose: act (GitHub Actions runner) installation and setup on CachyOS (Arch Linux)
# Includes: act binary, Docker support, configuration setup
# Author: theoneandonlywoj

echo "⚡ Starting act (GitHub Actions runner) installation..."

# === 1. Check if running on Arch/CachyOS ===
if not test -f /etc/arch-release
    echo "❌ This script is designed for Arch-based systems like CachyOS."
    exit 1
end

# === 2. Update package database ===
echo "📦 Updating package database..."
sudo pacman -Sy --noconfirm

# === 3. Install act from official repositories ===
echo "📥 Installing act from official repositories..."
sudo pacman -S --noconfirm --needed act
if test $status -ne 0
    echo "❌ Failed to install act from official repositories."
    exit 1
end

# === 4. Install Docker (required for act) ===
echo "🐳 Installing Docker for act container support..."
if not command -v docker >/dev/null
    echo "📦 Installing Docker..."
    sudo pacman -S --noconfirm --needed docker docker-compose
    if test $status -ne 0
        echo "❌ Failed to install Docker."
        exit 1
    end
    
    # Enable and start Docker service
    echo "🔧 Enabling Docker service..."
    sudo systemctl enable docker
    sudo systemctl start docker
    
    # Add user to docker group
    echo "👤 Adding user to docker group..."
    sudo usermod -aG docker $USER
    echo "⚠️  Please log out and log back in for docker group changes to take effect."
else
    echo "✅ Docker is already installed."
end

# === 5. Verify installation ===
echo "🧪 Verifying act installation..."
if command -v act >/dev/null
    echo "✅ act installed successfully!"
    act --version
else
    echo "❌ act installation failed. Please check for errors."
    exit 1
end

# === 6. Create act configuration directory ===
echo "📁 Setting up act configuration directory..."
mkdir -p ~/.act
if test $status -ne 0
    echo "❌ Failed to create act config directory."
    exit 1
end

# === 7. Create sample act configuration ===
echo "⚙️ Creating sample act configuration..."
printf '%s\n' \
'# act configuration file' \
'# See: https://github.com/nektos/act#configuration' \
'' \
'# Default platform (linux/amd64, linux/arm64, etc.)' \
'-P ubuntu-latest=catthehacker/ubuntu:act-latest' \
'' \
'# Default container image' \
'-P ubuntu-20.04=catthehacker/ubuntu:act-20.04' \
'-P ubuntu-18.04=catthehacker/ubuntu:act-18.04' \
'' \
'# Enable verbose output' \
'--verbose' \
'' \
'# Enable artifact server' \
'--artifact-server-path /tmp/artifacts' > ~/.actrc

echo "✅ Created sample configuration at ~/.actrc"

# === 8. Display usage instructions ===
echo
echo "🎉 act installation complete!"
echo "📝 To get started with act:"
echo "   1. Navigate to a repository with GitHub Actions: cd /path/to/repo"
echo "   2. List available workflows: act -l"
echo "   3. Run a specific workflow: act -W .github/workflows/workflow.yml"
echo "   4. Run all workflows: act"
echo
echo "💡 Configuration files:"
echo "   - Global config: ~/.actrc"
echo "   - Local config: .actrc in your repository"
echo
echo "🐳 Docker requirements:"
echo "   - Make sure Docker is running: sudo systemctl status docker"
echo "   - If you added yourself to docker group, log out and back in"
echo
echo "🔗 For more info: https://github.com/nektos/act"
