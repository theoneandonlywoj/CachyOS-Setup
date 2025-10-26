#!/usr/bin/env fish
# === audacity.fish ===
# Purpose: Install Audacity audio editor on CachyOS
# Installs Audacity from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Audacity installation..."

# === 1. Check if Audacity is already installed ===
command -q audacity; and set -l audacity_installed "installed"
if test -n "$audacity_installed"
    echo "✅ Audacity is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Audacity installation."
        exit 0
    end
    echo "📦 Removing existing Audacity installation..."
    sudo pacman -R --noconfirm audacity
    if test $status -ne 0
        echo "❌ Failed to remove Audacity."
        exit 1
    end
    echo "✅ Audacity removed."
end

# === 2. Install Audacity ===
echo "📦 Installing Audacity..."
sudo pacman -S --needed --noconfirm audacity
if test $status -ne 0
    echo "❌ Failed to install Audacity."
    exit 1
end
echo "✅ Audacity installed."

# === 3. Install optional documentation ===
echo "📦 Installing Audacity documentation..."
read -P "Do you want to install Audacity documentation? [y/N] " install_docs

if test "$install_docs" = "y" -o "$install_docs" = "Y"
    echo "📦 Installing Audacity documentation..."
    sudo pacman -S --needed --noconfirm audacity-docs
    if test $status -ne 0
        echo "⚠ Failed to install documentation, but Audacity is still installed."
    else
        echo "✅ Documentation installed."
    end
end

# === 4. Install recommended audio codecs and libraries ===
echo "📦 Installing recommended audio codecs and libraries..."
echo "💡 The following packages enable support for various audio formats:"
echo "   - ffmpeg: Video and audio codec library"
echo "   - libvorbis: Vorbis audio codec library"
echo "   - libmad: MPEG audio decoder library"
echo "   - libid3tag: ID3 tag library"
read -P "Do you want to install audio codec support? [y/N] " install_codecs

if test "$install_codecs" = "y" -o "$install_codecs" = "Y"
    echo "📦 Installing audio codecs..."
    sudo pacman -S --needed --noconfirm ffmpeg libvorbis libmad libid3tag
    if test $status -ne 0
        echo "⚠ Failed to install some codecs, but Audacity is still installed."
    else
        echo "✅ Audio codecs installed."
    end
end

# === 5. Install optional LADSPA plugins ===
echo "📦 Checking for additional audio processing plugins..."
echo "💡 The following packages provide additional audio effects:"
echo "   - ladspa: Linux Audio Developer's Simple Plugin API"
read -P "Do you want to install LADSPA plugins for audio effects? [y/N] " install_ladspa

if test "$install_ladspa" = "y" -o "$install_ladspa" = "Y"
    echo "📦 Installing LADSPA plugins..."
    sudo pacman -S --needed --noconfirm ladspa
    if test $status -ne 0
        echo "⚠ Failed to install LADSPA plugins, but Audacity is still installed."
    else
        echo "✅ LADSPA plugins installed."
    end
end

# === 6. Check and fix snapper Boost library issue (if present) ===
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
                echo "⚠ Failed to fix snapper, but Audacity is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 7. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q audacity
if test $status -eq 0
    echo "✅ Audacity installed successfully"
    audacity --version 2>&1 | head -n 1
else
    echo "❌ Audacity installation verification failed."
end

echo
echo "✅ Audacity installation complete!"
echo "💡 You can now launch Audacity from:"
echo "   - Applications menu (Multimedia/Audio category)"
echo "   - Command line: audacity"
echo "💡 Audacity will be available system-wide for all users."
echo "💡 Audacity is a powerful multi-track audio editor with:"
echo "   - Record and edit audio files"
echo "   - Support for multiple audio formats"
echo "   - Audio effects and filters"
echo "   - Noise removal and enhancement tools"
echo "   - Support for VST, AU, and LADSPA plugins"
echo "💡 Tips for getting started:"
echo "   - File → Import to import audio files"
echo "   - Click the red Record button to start recording"
echo "   - Select audio and use Effects menu for processing"
echo "   - File → Export to save your edited audio"

