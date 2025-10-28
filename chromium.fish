#!/usr/bin/env fish
# === chromium.fish ===
# Purpose: Install Chromium browser on CachyOS
# Installs Chromium from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Chromium installation..."

# === 1. Check if Chromium is already installed ===
command -q chromium; and set -l chromium_installed "installed"
if test -n "$chromium_installed"
    echo "✅ Chromium is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Chromium installation."
        exit 0
    end
    echo "📦 Removing existing Chromium installation..."
    sudo pacman -R --noconfirm chromium
    if test $status -ne 0
        echo "❌ Failed to remove Chromium."
        exit 1
    end
    echo "✅ Chromium removed."
end

# === 2. Install Chromium ===
echo "📦 Installing Chromium..."
sudo pacman -S --needed --noconfirm chromium
if test $status -ne 0
    echo "❌ Failed to install Chromium."
    exit 1
end
echo "✅ Chromium installed."

# === 3. Install optional Chromium extensions ===
echo "📦 Installing optional Chromium extensions..."
echo "💡 Install Chromium web store extension support for accessing Chrome extensions"
read -P "Do you want to install Chromium web store extension support? [y/N] " install_webstore

if test "$install_webstore" = "y" -o "$install_webstore" = "Y"
    echo "📦 Installing Chromium web store extension..."
    sudo pacman -S --needed --noconfirm chromium-extension-web-store
    if test $status -eq 0
        echo "✅ Chromium web store extension installed."
    else
        echo "⚠ Failed to install web store extension."
    end
end

# === 4. Check and fix snapper Boost library issue (if present) ===
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
                echo "⚠ Failed to fix snapper, but Chromium is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q chromium
if test $status -eq 0
    echo "✅ Chromium installed successfully"
    chromium --version 2>&1 | head -n 1
else
    echo "❌ Chromium installation verification failed."
end

echo
echo "✅ Chromium installation complete!"
echo "💡 Chromium is an open-source web browser:"
echo "   - Fast and secure browsing"
echo "   - Built on Chromium/Blink engine"
echo "   - Privacy-focused"
echo "   - Regular security updates"
echo "💡 Launch Chromium:"
echo "   - Command line: chromium"
echo "   - Applications menu (Network/Web category)"
echo "💡 Tips:"
echo "   - Install extensions from Chrome Web Store (with web store extension)"
echo "   - Sync bookmarks and settings (requires Google account)"
echo "   - Private browsing: chromium --incognito"

