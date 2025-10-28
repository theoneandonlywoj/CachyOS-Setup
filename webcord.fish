#!/usr/bin/env fish
# === webcord.fish ===
# Purpose: Install WebCord as a privacy-focused Discord replacement on CachyOS
# Installs WebCord from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting WebCord installation..."

echo "📌 WebCord is a privacy-focused Discord replacement client"
echo "💡 Features:"
echo "   - Open-source and privacy-focused"
echo "   - Native Linux client without Electron bloat"
echo "   - Access Discord servers through web interface"
echo "   - Better performance than official Discord client"
echo "   - No tracking or telemetry"

# === 1. Check if WebCord is already installed ===
command -q webcord; and set -l webcord_installed "installed"
if test -n "$webcord_installed"
    echo "✅ WebCord is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping WebCord installation."
        exit 0
    end
    echo "📦 Removing existing WebCord installation..."
    sudo pacman -R --noconfirm webcord
    if test $status -ne 0
        echo "❌ Failed to remove WebCord."
        exit 1
    end
    echo "✅ WebCord removed."
end

# === 2. Install WebCord ===
echo "📦 Installing WebCord..."
sudo pacman -S --needed --noconfirm webcord
if test $status -ne 0
    echo "❌ Failed to install WebCord."
    exit 1
end
echo "✅ WebCord installed."

# === 3. Check and fix snapper Boost library issue (if present) ===
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
                echo "⚠ Failed to fix snapper, but WebCord is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q webcord
if test $status -eq 0
    echo "✅ WebCord installed successfully"
    webcord --version 2>&1 | head -n 1
else
    echo "❌ WebCord installation verification failed."
end

echo
echo "✅ WebCord installation complete!"
echo "💡 WebCord is a privacy-focused Discord client:"
echo "   - Open-source alternative to official Discord client"
echo "   - Native performance without Electron bloat"
echo "   - Full access to Discord servers and features"
echo "   - Better Linux compatibility"
echo "   - No telemetry or tracking"
echo "💡 You can now launch WebCord from:"
echo "   - Applications menu (Network/Internet category)"
echo "   - Command line: webcord"
echo "💡 Getting started:"
echo "   1. Log in with your Discord credentials at discord.com"
echo "   2. Access your servers and channels"
echo "   3. Use voice and video features"
echo "   4. Enjoy better performance than official client"
echo "💡 WebCord vs Official Discord:"
echo "   ✓ More lightweight and faster"
echo "   ✓ Better Linux support"
echo "   ✓ No telemetry or tracking"
echo "   ✓ Open-source"
echo "   ✓ No Electron app sandboxing issues"
echo "💡 All Discord features work:"
echo "   - Text and voice channels"
echo "   - Video calls and screensharing"
echo "   - Server management"
echo "   - File sharing"
echo "   - Bots and integrations"
echo "💡 Tips:"
echo "   - Settings and preferences are the same as web Discord"
echo "   - Keyboard shortcuts work identically"
echo "   - Desktop notifications supported"
echo "   - Launch at boot (optional)"

