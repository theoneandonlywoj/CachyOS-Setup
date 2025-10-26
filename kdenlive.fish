#!/usr/bin/env fish
# === kdenlive.fish ===
# Purpose: Install Kdenlive video editor on CachyOS
# Installs Kdenlive from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Kdenlive installation..."

# === 1. Check if Kdenlive is already installed ===
command -q kdenlive; and set -l kdenlive_installed "installed"
if test -n "$kdenlive_installed"
    echo "✅ Kdenlive is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Kdenlive installation."
        exit 0
    end
    echo "📦 Removing existing Kdenlive installation..."
    sudo pacman -R --noconfirm kdenlive
    if test $status -ne 0
        echo "❌ Failed to remove Kdenlive."
        exit 1
    end
    echo "✅ Kdenlive removed."
end

# === 2. Install Kdenlive ===
echo "📦 Installing Kdenlive..."
sudo pacman -S --needed --noconfirm kdenlive
if test $status -ne 0
    echo "❌ Failed to install Kdenlive."
    exit 1
end
echo "✅ Kdenlive installed."

# === 3. Install recommended codec support ===
echo "📦 Installing recommended multimedia codecs..."
echo "💡 The following packages enable support for various video formats:"
echo "   - gst-plugins-good: Additional GStreamer plugins"
echo "   - gst-plugins-bad: Extra GStreamer plugins (multimedia codecs)"
echo "   - gst-plugins-ugly: More GStreamer plugins (patented codecs)"
echo "   - ffmpeg: Video and audio codec library"
read -P "Do you want to install codec support? [y/N] " install_codecs

if test "$install_codecs" = "y" -o "$install_codecs" = "Y"
    echo "📦 Installing multimedia codecs..."
    sudo pacman -S --needed --noconfirm gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg
    if test $status -ne 0
        echo "⚠ Failed to install some codecs, but Kdenlive is still installed."
    else
        echo "✅ Multimedia codecs installed."
    end
end

# === 4. Install optional additional plugins ===
echo "📦 Checking for additional Kdenlive features..."
echo "💡 Optional packages for enhanced video editing:"
echo "   - dvdauthor: DVD authoring support"
echo "   - dvdstyler: DVD menu creation"
read -P "Do you want to install DVD authoring support? [y/N] " install_dvd

if test "$install_dvd" = "y" -o "$install_dvd" = "Y"
    echo "📦 Installing DVD authoring support..."
    sudo pacman -S --needed --noconfirm dvdauthor dvdstyler
    if test $status -ne 0
        echo "⚠ Failed to install some DVD tools, but Kdenlive is still installed."
    else
        echo "✅ DVD authoring support installed."
    end
end

# === 4a. Fix KDE framework version mismatches ===
echo
echo "🔧 Checking for KDE framework compatibility..."
echo "💡 Kdenlive requires specific KDE framework versions."

# Test if kdenlive has symbol errors
kdenlive --version > /dev/null 2>&1
if test $status -ne 0
    echo "⚠ Detected KDE framework version mismatch (symbol errors)."
    read -P "Do you want to fix this by reinstalling KDE frameworks? [y/N] " fix_kde
    
    if test "$fix_kde" = "y" -o "$fix_kde" = "Y"
        echo "📦 Reinstalling KDE frameworks and Kdenlive to fix version mismatch..."
        sudo pacman -S --noconfirm kio-extras kio5 kguiaddons kde-runtime
        if test $status -eq 0
            echo "📦 Reinstalling Kdenlive..."
            sudo pacman -S --noconfirm kdenlive
            if test $status -eq 0
                echo "✅ KDE frameworks and Kdenlive fixed successfully."
            else
                echo "⚠ Failed to reinstall Kdenlive, but frameworks were updated."
            end
        else
            echo "⚠ Failed to fix KDE frameworks."
        end
    end
else
    echo "✅ KDE frameworks are working correctly."
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
                echo "⚠ Failed to fix snapper, but Kdenlive is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q kdenlive
if test $status -eq 0
    echo "✅ Kdenlive installed successfully"
    kdenlive --version 2>&1 | head -n 1
else
    echo "❌ Kdenlive installation verification failed."
end

echo
echo "✅ Kdenlive installation complete!"
echo "💡 You can now launch Kdenlive from:"
echo "   - Applications menu (Multimedia category)"
echo "   - Command line: kdenlive"
echo "💡 Kdenlive will be available system-wide for all users."
echo "💡 Kdenlive is a powerful non-linear video editor with:"
echo "   - Professional video editing tools"
echo "   - Multi-track timeline"
echo "   - Color correction and effects"
echo "   - Keyframe animation"
echo "   - Audio mixing and filters"
echo "   - Title editing and text overlays"
echo "💡 Tips for getting started:"
echo "   - Import media: File → Add Clip"
echo "   - Drag clips to timeline to start editing"
echo "   - Use K key for a Razor tool to cut clips"

