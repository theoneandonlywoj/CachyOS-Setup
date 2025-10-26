#!/usr/bin/env fish
# === vlc.fish ===
# Purpose: Install VLC media player on CachyOS
# Installs VLC from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting VLC installation..."

# === 1. Check if VLC is already installed ===
command -q vlc; and set -l vlc_installed "installed"
if test -n "$vlc_installed"
    echo "✅ VLC is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping VLC installation."
        exit 0
    end
    echo "📦 Removing existing VLC installation..."
    sudo pacman -R --noconfirm vlc
    if test $status -ne 0
        echo "❌ Failed to remove VLC."
        exit 1
    end
    echo "✅ VLC removed."
end

# === 2. Install VLC ===
echo "📦 Installing VLC..."
sudo pacman -S --needed --noconfirm vlc
if test $status -ne 0
    echo "❌ Failed to install VLC."
    exit 1
end
echo "✅ VLC installed."

# === 3. Install VLC plugins (optional) ===
echo "📦 Installing optional VLC plugins..."
echo "💡 VLC supports many media formats by default."
echo "💡 Optional plugins enhance VLC capabilities:"
echo "   - vlc-plugins-extra: Additional format support"
echo "   - vlc-plugin-libsecret: Integration with desktop keyrings"
echo "   - vlc-plugin-notify: Desktop notifications"
read -P "Do you want to install additional plugins? [y/N] " install_plugins

if test "$install_plugins" = "y" -o "$install_plugins" = "Y"
    echo "📦 Installing VLC plugins..."
    sudo pacman -S --needed --noconfirm vlc-plugins-extra vlc-plugin-libsecret vlc-plugin-notify
    if test $status -ne 0
        echo "⚠ Failed to install some plugins, but VLC is still installed."
    else
        echo "✅ VLC plugins installed."
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
                echo "⚠ Failed to fix snapper, but VLC is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q vlc
if test $status -eq 0
    echo "✅ VLC installed successfully"
    vlc --version 2>&1 | head -n 1
else
    echo "❌ VLC installation verification failed."
end

echo
echo "✅ VLC installation complete!"
echo "💡 VLC is a versatile media player:"
echo "   - Play almost any audio/video format"
echo "   - DVD and Blu-ray playback"
echo "   - Network streaming"
echo "   - Video and audio conversion"
echo "   - Screenshot and recording features"
echo "💡 You can now launch VLC from:"
echo "   - Applications menu (Multimedia category)"
echo "   - Command line: vlc"
echo "💡 VLC supports these formats:"
echo "   - Audio: MP3, FLAC, AAC, OGG, WAV, M4A, and more"
echo "   - Video: MP4, MKV, AVI, WebM, MOV, and more"
echo "   - Disc: DVD, Blu-ray, Audio CD"
echo "   - Network: HTTP, RTSP, MMS streaming"
echo "💡 Basic VLC commands:"
echo "   - Play file: vlc filename"
echo "   - Play from URL: vlc http://example.com/stream"
echo "   - Play DVD: vlc dvd://"
echo "   - Minimal interface: vlc -I ncurses"
echo "💡 Tips:"
echo "   - Use Convert/Save tool for media conversion"
echo "   - Enable hardware acceleration in Tools → Preferences"
echo "   - Install browser extensions for video playback"
echo "   - Use VLC as server for streaming to other devices"
echo "💡 Keyboard shortcuts:"
echo "   - Space: Play/Pause"
echo "   - Ctrl+Up/Down: Volume"
echo "   - Left/Right: Skip backward/forward"
echo "   - F: Fullscreen"
echo "   - S: Stop"
echo "   - J: Subtitle delay decrease"
echo "   - K: Subtitle delay increase"

