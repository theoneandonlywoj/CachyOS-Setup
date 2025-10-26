#!/usr/bin/env fish
# === obs_studio.fish ===
# Purpose: Install OBS Studio on CachyOS
# Installs OBS Studio from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting OBS Studio installation..."

# === 1. Check if OBS Studio is already installed ===
command -q obs; and set -l obs_installed "installed"
if test -n "$obs_installed"
    echo "✅ OBS Studio is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping OBS Studio installation."
        exit 0
    end
    echo "📦 Removing existing OBS Studio installation..."
    sudo pacman -R --noconfirm obs-studio
    if test $status -ne 0
        echo "❌ Failed to remove OBS Studio."
        exit 1
    end
    echo "✅ OBS Studio removed."
end

# === 2. Install OBS Studio ===
echo "📦 Installing OBS Studio..."
sudo pacman -S --needed --noconfirm obs-studio
if test $status -ne 0
    echo "❌ Failed to install OBS Studio."
    exit 1
end
echo "✅ OBS Studio installed."

# === 3. Install optional audio/video codecs ===
echo "📦 Installing optional audio/video codecs..."
echo "💡 The following packages enhance OBS Studio capabilities:"
echo "   - ffmpeg: Video and audio codec library"
echo "   - alsa-utils: ALSA utilities for audio"
echo "   - pipewire-pulse: PulseAudio support via PipeWire"
read -P "Do you want to install audio/video codecs? [y/N] " install_codecs

if test "$install_codecs" = "y" -o "$install_codecs" = "Y"
    echo "📦 Installing audio/video codecs..."
    sudo pacman -S --needed --noconfirm ffmpeg alsa-utils
    if test $status -ne 0
        echo "⚠ Failed to install some codecs, but OBS Studio is still installed."
    else
        echo "✅ Audio/video codecs installed."
    end
end

# === 4. Install optional streaming tools ===
echo "📦 Checking for additional streaming tools..."
echo "💡 Optional packages for enhanced streaming:"
echo "   - v4l2loopback-dkms: Virtual video device for multiple sources"
echo "   - obs-backgroundremoval: AI background removal plugin"
read -P "Do you want to install additional streaming tools? [y/N] " install_tools

if test "$install_tools" = "y" -o "$install_tools" = "Y"
    echo "📦 Installing additional streaming tools..."
    sudo pacman -S --needed --noconfirm v4l2loopback-dkms
    if test $status -eq 0
        echo "✅ Additional streaming tools installed."
    else
        echo "⚠ Failed to install some tools, but OBS Studio is still installed."
    end
end

# === 5. Check for GPU encoder support ===
echo "📦 Checking for GPU encoder support..."
if command -q nvidia-smi
    echo "✅ NVIDIA GPU detected - OBS Studio will use NVENC encoder."
else
    echo "ℹ No NVIDIA GPU detected. OBS will use software encoding."
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
                echo "⚠ Failed to fix snapper, but OBS Studio is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 7. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q obs
if test $status -eq 0
    echo "✅ OBS Studio installed successfully"
    obs --version 2>&1 | head -n 1
else
    echo "❌ OBS Studio installation verification failed."
end

echo
echo "✅ OBS Studio installation complete!"
echo "💡 OBS Studio is a powerful tool for:"
echo "   - Live streaming to Twitch, YouTube, Facebook, etc."
echo "   - Recording high-quality videos"
echo "   - Screen capture and compositing"
echo "   - Video mixing with multiple sources"
echo "💡 You can now launch OBS Studio from:"
echo "   - Applications menu (Multimedia category)"
echo "   - Command line: obs"
echo "💡 OBS Studio features:"
echo "   - Multiple video/audio sources"
echo "   - Scene switching and transitions"
echo "   - Custom filters and effects"
echo "   - Real-time audio mixing"
echo "   - Browser source for overlays"
echo "💡 Tips for getting started:"
echo "   1. Add sources (Display Capture, Window Capture, etc.)"
echo "   2. Configure audio devices in Settings → Audio"
echo "   3. Set up streaming: Settings → Stream"
echo "   4. Choose encoding (x264 for CPU, NVENC for NVIDIA GPU)"
echo "   5. Test your stream before going live"
echo "💡 Recommended settings:"
echo "   - Output mode: Advanced"
echo "   - Encoder: NVENC (if NVIDIA GPU) or x264"
echo "   - Canvas resolution: Your display resolution"
echo "   - Output resolution: 1920x1080 (Full HD)"
echo "   - FPS: 60 for gaming, 30 for general use"

