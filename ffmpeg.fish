#!/usr/bin/env fish
# === ffmpeg.fish ===
# Purpose: Install FFmpeg multimedia framework on CachyOS
# Installs FFmpeg from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting FFmpeg installation..."

# === 1. Check if FFmpeg is already installed ===
command -q ffmpeg; and set -l ffmpeg_installed "installed"
if test -n "$ffmpeg_installed"
    echo "✅ FFmpeg is already installed."
    echo "💡 FFmpeg is a dependency for many applications (Kdenlive, Krita, OpenShot, etc.)"
    read -P "Do you want to update FFmpeg? [y/N] " update_ffmpeg
    if test "$update_ffmpeg" != "y" -a "$update_ffmpeg" != "Y"
        echo "⚠ Skipping FFmpeg update."
        exit 0
    end
end

# === 2. Install/Update FFmpeg ===
echo "📦 Installing/updating FFmpeg..."
sudo pacman -S --needed --noconfirm ffmpeg
if test $status -ne 0
    echo "❌ Failed to install/update FFmpeg."
    exit 1
end
if test -n "$ffmpeg_installed"
    echo "✅ FFmpeg updated."
else
    echo "✅ FFmpeg installed."
end

# === 3. Install optional FFmpeg-related tools ===
echo "📦 Installing optional FFmpeg-related tools..."
echo "💡 The following tools enhance FFmpeg capabilities:"
echo "   - ffmpegthumbnailer: Generate video thumbnails"
echo "   - ffnvcodec-headers: NVIDIA codec support for hardware acceleration"
read -P "Do you want to install additional FFmpeg tools? [y/N] " install_tools

if test "$install_tools" = "y" -o "$install_tools" = "Y"
    echo "📦 Installing additional FFmpeg tools..."
    sudo pacman -S --needed --noconfirm ffmpegthumbnailer ffnvcodec-headers
    if test $status -ne 0
        echo "⚠ Failed to install some tools, but FFmpeg is still installed."
    else
        echo "✅ Additional FFmpeg tools installed."
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
                echo "⚠ Failed to fix snapper, but FFmpeg is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q ffmpeg
if test $status -eq 0
    echo "✅ FFmpeg installed successfully"
    echo "📌 Version information:"
    ffmpeg -version 2>&1 | head -n 1
    echo
    echo "📌 Supported formats:"
    ffmpeg -codecs 2>&1 | head -n 3
else
    echo "❌ FFmpeg installation verification failed."
end

echo
echo "✅ FFmpeg installation complete!"
echo "💡 FFmpeg is a powerful multimedia framework for:"
echo "   - Converting audio and video formats"
echo "   - Recording audio/video streams"
echo "   - Encoding and decoding multimedia files"
echo "   - Extracting frames and metadata"
echo "💡 Common FFmpeg commands:"
echo "   - Convert video: ffmpeg -i input.mp4 output.mkv"
echo "   - Extract audio: ffmpeg -i video.mp4 audio.mp3"
echo "   - Resize video: ffmpeg -i input.mp4 -vf scale=1280:720 output.mp4"
echo "   - Get video info: ffmpeg -i video.mp4"
echo "   - Record screen: ffmpeg -f x11grab -i :0.0 output.mp4"
echo "💡 For more information and examples:"
echo "   - man ffmpeg"
echo "   - ffmpeg -help"

