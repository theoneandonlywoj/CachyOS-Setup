#!/usr/bin/env fish
# === inkscape.fish ===
# Purpose: Install Inkscape vector graphics editor on CachyOS
# Installs Inkscape from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Inkscape installation..."

# === 1. Check if Inkscape is already installed ===
command -q inkscape; and set -l inkscape_installed "installed"
if test -n "$inkscape_installed"
    echo "ℹ Inkscape is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "ℹ Skipping Inkscape installation."
        exit 0
    end
    echo "📦 Removing existing Inkscape installation..."
    sudo pacman -R --noconfirm inkscape
    if test $status -ne 0
        echo "❌ Failed to remove Inkscape."
        exit 1
    end
    echo "✅ Inkscape removed."
end

# === 2. Install Inkscape and recommended packages ===
echo "📦 Installing Inkscape..."
sudo pacman -S --needed --noconfirm inkscape
if test $status -ne 0
    echo "❌ Failed to install Inkscape."
    exit 1
end
echo "✅ Inkscape installed."

# === 3. Install Boost libraries (required dependency) ===
echo "📦 Installing Boost libraries..."
sudo pacman -S --needed --noconfirm boost boost-libs
if test $status -ne 0
    echo "⚠ Warning: Failed to install Boost libraries. Inkscape may not work properly."
else
    echo "✅ Boost libraries installed."
end

# === 4. Install Python scripting support (optional) ===
echo "🔧 Checking for Python support..."
command -q python; and set -l python_installed "installed"
if test -n "$python_installed"
    read -P "Do you want to install Python scripting support for Inkscape? [y/N] " python_support
    if test "$python_support" = "y" -o "$python_support" = "Y"
        echo "📦 Installing Inkscape Python scripting support..."
        sudo pacman -S --needed --noconfirm python-lxml python-numpy
        if test $status -ne 0
            echo "⚠ Failed to install Python support for Inkscape."
        else
            echo "✅ Python scripting support installed."
        end
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q inkscape
if test $status -eq 0
    echo "✅ Inkscape installed successfully"
    if inkscape --version 2>&1 | head -n 1
        echo "✅ Version check passed"
    else
        echo "⚠ Inkscape is installed but version check failed"
    end
else
    echo "❌ Inkscape installation verification failed."
end

echo
echo "✅ Inkscape installation complete!"
echo "💡 You can now launch Inkscape from:"
echo "   - Applications menu (Graphics category)"
echo "   - Command line: inkscape"
echo "💡 Inkscape will be available system-wide for all users."
echo "💡 Useful commands: inkscape --version, inkscape --help"

