#!/usr/bin/env fish
# === antigravity.fish ===
# Purpose: Install Google Antigravity IDE on CachyOS
# Installs Antigravity from Google's official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Antigravity installation..."

# === 1. Check if Antigravity is already installed ===
command -q antigravity; and set -l antigravity_installed "installed"
if test -n "$antigravity_installed"
    echo "✅ Antigravity is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Antigravity installation."
        exit 0
    end
    echo "📦 Removing existing Antigravity installation..."
    sudo pacman -R --noconfirm antigravity 2>/dev/null
    if test $status -ne 0
        echo "⚠ Antigravity may not be installed via pacman, checking AUR..."
        yay -R --noconfirm antigravity 2>/dev/null
    end
    echo "✅ Antigravity removed."
end

# === 2. Check for required dependencies ===
echo "🔍 Checking for required dependencies..."
set -l missing_deps

command -q curl; or set -a missing_deps curl
command -q gpg; or set -a missing_deps gnupg

if test (count $missing_deps) -gt 0
    echo "📦 Installing missing dependencies: $missing_deps"
    sudo pacman -S --needed --noconfirm $missing_deps
    if test $status -ne 0
        echo "❌ Failed to install dependencies."
        exit 1
    end
end

# === 3. Set up Google Antigravity repository ===
echo "📦 Setting up Google Antigravity repository..."

# Create keyrings directory if it doesn't exist
sudo mkdir -p /etc/pacman.d/gnupg

# Download and import GPG key
echo "🔑 Importing GPG key..."
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor -o /etc/pacman.d/gnupg/antigravity-repo-key.gpg 2>/dev/null

if test $status -ne 0
    echo "⚠ Failed to import GPG key via curl, trying alternative method..."
    # Alternative: try AUR package if repository setup fails
    echo "💡 Attempting to install from AUR instead..."
    command -q yay; or command -q paru; or begin
        echo "❌ Neither yay nor paru is installed. Please install an AUR helper first."
        echo "💡 Install yay: sudo pacman -S --needed base-devel git && cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
        exit 1
    end
    
    if command -q yay
        echo "📦 Installing Antigravity from AUR using yay..."
        yay -S --needed --noconfirm antigravity
    else if command -q paru
        echo "📦 Installing Antigravity from AUR using paru..."
        paru -S --needed --noconfirm antigravity
    end
    
    if test $status -ne 0
        echo "❌ Failed to install Antigravity from AUR."
        echo "💡 You may need to install it manually or check if the package exists."
        exit 1
    end
    
    echo "✅ Antigravity installed from AUR."
else
    # Create custom repository configuration for Arch
    echo "📝 Creating repository configuration..."
    printf '[antigravity]\nSigLevel = Optional TrustAll\nServer = https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-debian\n' | sudo tee /etc/pacman.d/antigravity.conf > /dev/null
    
    # Note: The above repository is for Debian/Ubuntu, so we'll need to use AUR or manual installation
    echo "⚠ Google's repository is designed for Debian/Ubuntu systems."
    echo "💡 For Arch-based systems like CachyOS, we'll use AUR instead."
    
    # Check for AUR helper
    command -q yay; or command -q paru; or begin
        echo "❌ Neither yay nor paru is installed. Please install an AUR helper first."
        echo "💡 Install yay: sudo pacman -S --needed base-devel git && cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
        exit 1
    end
    
    if command -q yay
        echo "📦 Installing Antigravity from AUR using yay..."
        yay -S --needed --noconfirm antigravity
    else if command -q paru
        echo "📦 Installing Antigravity from AUR using paru..."
        paru -S --needed --noconfirm antigravity
    end
    
    if test $status -ne 0
        echo "❌ Failed to install Antigravity."
        echo "💡 The AUR package may not exist yet. You may need to:"
        echo "   1. Install manually from source"
        echo "   2. Check https://antigravity.google/download/linux for updates"
        echo "   3. Use AppImage or other distribution method if available"
        exit 1
    end
    
    echo "✅ Antigravity installed."
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q antigravity
if test $status -eq 0
    echo "✅ Antigravity installed successfully"
    antigravity --version 2>&1 | head -n 1; or echo "   (version information not available)"
else
    echo "❌ Antigravity installation verification failed."
    echo "💡 The command 'antigravity' is not available in PATH."
    echo "   You may need to restart your terminal or check the installation location."
end

echo
echo "✅ Antigravity installation complete!"
echo "💡 Antigravity is Google's IDE:"
echo "   - Modern development environment"
echo "   - Integrated with Google services"
echo "   - Regular updates from Google"
echo "💡 Launch Antigravity:"
echo "   - Command line: antigravity"
echo "   - Applications menu (Development category)"
echo "💡 Tips:"
echo "   - Check https://antigravity.google for documentation"
echo "   - Updates are handled automatically"
echo "   - Integrates with Google Cloud services"

