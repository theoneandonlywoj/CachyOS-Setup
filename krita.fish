#!/usr/bin/env fish
# === krita.fish ===
# Purpose: Install Krita digital painting application on CachyOS
# Installs Krita from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Krita installation..."

# === 1. Check if Krita is already installed ===
command -q krita; and set -l krita_installed "installed"
if test -n "$krita_installed"
    echo "✅ Krita is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Krita installation."
        exit 0
    end
    echo "📦 Removing existing Krita installation..."
    sudo pacman -R --noconfirm krita
    if test $status -ne 0
        echo "❌ Failed to remove Krita."
        exit 1
    end
    echo "✅ Krita removed."
end

# === 2. Install Krita ===
echo "📦 Installing Krita..."
sudo pacman -S --needed --noconfirm krita
if test $status -ne 0
    echo "❌ Failed to install Krita."
    exit 1
end
echo "✅ Krita installed."

# === 3. Install optional Krita features ===
echo "📦 Installing recommended Krita features..."
echo "💡 The following optional packages enhance Krita capabilities:"
echo "   - krita-plugin-gmic: G'MIC image processing filters"
echo "   - python-pykrita: Python scripting support for Krita"
read -P "Do you want to install additional features? [y/N] " install_features

if test "$install_features" = "y" -o "$install_features" = "Y"
    echo "📦 Installing additional Krita features..."
    sudo pacman -S --needed --noconfirm krita-plugin-gmic python-pykrita
    if test $status -ne 0
        echo "⚠ Failed to install some features, but Krita is still installed."
    else
        echo "✅ Additional Krita features installed."
    end
end

# === 4. Install recommended graphics dependencies ===
echo "📦 Installing recommended graphics dependencies..."
sudo pacman -S --needed --noconfirm libpng libjpeg-turbo
if test $status -ne 0
    echo "⚠ Warning: Failed to install some graphics dependencies."
else
    echo "✅ Graphics dependencies installed."
end

# === 5. Check and fix snapper Boost library issue (if present) ===
if test -f /usr/bin/snapper
    echo
    echo "🔧 Checking for snapper Boost library issue..."
    snapper --version > /dev/null 2>&1
    if test $status -ne 0
        echo "⚠ Detected snapper Boost library version mismatch."
        echo "💡 This can happen after Boost updates."
        read -P "Do you want to fix snapper? [y/N] " fix_snapper
        
        if test "$fix_snapper" = "y" -o "$fix_snapper" = "Y"
            echo "📦 Reinstalling snapper to fix Boost library version mismatch..."
            sudo pacman -S --noconfirm snapper
            if test $status -eq 0
                echo "✅ Snapper fixed successfully."
            else
                echo "⚠ Failed to fix snapper, but Krita is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q krita
if test $status -eq 0
    echo "✅ Krita installed successfully"
    krita --version 2>&1 | head -n 1
else
    echo "❌ Krita installation verification failed."
end

echo
echo "✅ Krita installation complete!"
echo "💡 You can now launch Krita from:"
echo "   - Applications menu (Graphics category)"
echo "   - Command line: krita"
echo "💡 Krita will be available system-wide for all users."
echo "💡 Krita is a powerful digital painting and illustration application."
echo "💡 Useful features:"
echo "   - Professional digital painting tools"
echo "   - Advanced brush engines"
echo "   - Vector and raster graphics"
echo "   - Animation support"
echo "   - Color management and PSD support"

