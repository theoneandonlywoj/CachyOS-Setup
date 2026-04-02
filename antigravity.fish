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

if test (count $missing_deps) -gt 0
    echo "📦 Installing missing dependencies: $missing_deps"
    sudo pacman -S --needed --noconfirm $missing_deps
    if test $status -ne 0
        echo "❌ Failed to install dependencies."
        exit 1
    end
end

# === 3. Install Antigravity from AUR ===
echo "📦 Installing Antigravity from AUR..."

# Check for AUR helper
command -q paru; or command -q yay; or begin
    echo "❌ Neither paru nor yay is installed. Please install an AUR helper first."
    echo "💡 Install paru: sudo pacman -S --needed base-devel git && cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si"
    exit 1
end

# Handle gcc-libs split package transition (libgcc/libstdc++ replace gcc-libs)
if pacman -Q gcc-libs &>/dev/null
    echo "🔧 Handling gcc-libs package split (libgcc/libstdc++)..."
    sudo pacman -Syu --noconfirm \
        --overwrite '/usr/lib/libgcc_s*' \
        --overwrite '/usr/lib/libstdc++*' \
        --overwrite '/usr/share/licenses/gcc-libs/*' \
        --overwrite '/usr/share/locale/*/LC_MESSAGES/libstdc++.mo'
end

if command -q paru
    echo "📦 Installing Antigravity from AUR using paru..."
    paru -S --needed --noconfirm antigravity
else if command -q yay
    echo "📦 Installing Antigravity from AUR using yay..."
    yay -S --needed --noconfirm antigravity
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

