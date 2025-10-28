#!/usr/bin/env fish
# === gimp.fish ===
# Purpose: Install GIMP image editor on CachyOS
# Installs GIMP from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting GIMP installation..."

# === 1. Check if GIMP is already installed ===
set -l gimp_check (pacman -Qq gimp 2>/dev/null)
if test -n "$gimp_check"
    echo "ℹ GIMP is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "ℹ Skipping GIMP installation."
        exit 0
    end
    echo "📦 Removing existing GIMP installation..."
    sudo pacman -R --noconfirm gimp
    if test $status -ne 0
        echo "❌ Failed to remove GIMP."
        exit 1
    end
    echo "✅ GIMP removed."
end

# === 2. Install GIMP and recommended packages ===
echo "📦 Installing GIMP..."
sudo pacman -S --needed --noconfirm gimp
if test $status -ne 0
    echo "❌ Failed to install GIMP."
    exit 1
end
echo "✅ GIMP installed."

# === 3. Install optional GIMP plugins and extras ===
echo "📦 Installing GIMP plugins and extras..."
set -l install_extras "false"
read -P "Do you want to install GIMP plugins and extras (gimp-plugin-heal, gimp-plugin-gmic)? [y/N] " install_extras_choice

if test "$install_extras_choice" = "y" -o "$install_extras_choice" = "Y"
    echo "📦 Installing additional plugins..."
    sudo pacman -S --needed --noconfirm gimp-plugin-heal gimp-plugin-gmic
    if test $status -ne 0
        echo "⚠ Failed to install some plugins, but GIMP is still installed."
    else
        echo "✅ GIMP plugins installed."
    end
end

# === 4. Install Python scripting support (optional) ===
echo "🔧 Checking for Python support..."
set -l python_check (pacman -Qq python 2>/dev/null)
if test -n "$python_check"
    echo "📦 Installing GIMP Python scripting support..."
    sudo pacman -S --needed --noconfirm gimp-python
    if test $status -ne 0
        echo "⚠ Failed to install Python support for GIMP."
    else
        echo "✅ Python scripting support installed."
    end
else
    echo "ℹ Python not found. Skipping GIMP Python support."
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
set -l gimp_verify (pacman -Qq gimp 2>/dev/null)
if test -n "$gimp_verify"
    echo "✅ GIMP installed successfully"
    gimp --version | head -n 1
else
    echo "❌ GIMP installation verification failed."
end

echo
echo "✅ GIMP installation complete!"
echo "💡 You can now launch GIMP from:"
echo "   - Applications menu (Graphics category)"
echo "   - Command line: gimp"
echo "💡 GIMP will be available system-wide for all users."
echo "💡 Optional: Install additional plugins with: gimp-plugin-heal, gimp-plugin-gmic"

