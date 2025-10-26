#!/usr/bin/env fish
# === openshot.fish ===
# Purpose: Install OpenShot video editor on CachyOS
# Installs OpenShot from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting OpenShot installation..."

# === 1. Check if OpenShot is already installed ===
command -q openshot-qt; and set -l openshot_installed "installed"
if test -n "$openshot_installed"
    echo "✅ OpenShot is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping OpenShot installation."
        exit 0
    end
    echo "📦 Removing existing OpenShot installation..."
    sudo pacman -R --noconfirm openshot
    if test $status -ne 0
        echo "❌ Failed to remove OpenShot."
        exit 1
    end
    echo "✅ OpenShot removed."
end

# === 2. Install OpenShot ===
echo "📦 Installing OpenShot..."
sudo pacman -S --needed --noconfirm openshot
if test $status -ne 0
    echo "❌ Failed to install OpenShot."
    exit 1
end
echo "✅ OpenShot installed."

# === 3. Install recommended multimedia codecs ===
echo "📦 Installing recommended multimedia codecs..."
echo "💡 The following packages enable support for various video formats:"
echo "   - ffmpeg: Video and audio codec library"
echo "   - gst-libav: GStreamer libav plugin (FFmpeg integration)"
echo "   - gst-plugins-good: Additional GStreamer plugins"
echo "   - gst-plugins-bad: Extra GStreamer plugins (multimedia codecs)"
echo "   - gst-plugins-ugly: More GStreamer plugins (patented codecs)"
read -P "Do you want to install codec support? [y/N] " install_codecs

if test "$install_codecs" = "y" -o "$install_codecs" = "Y"
    echo "📦 Installing multimedia codecs..."
    sudo pacman -S --needed --noconfirm ffmpeg gst-libav gst-plugins-good gst-plugins-bad gst-plugins-ugly
    if test $status -ne 0
        echo "⚠ Failed to install some codecs, but OpenShot is still installed."
    else
        echo "✅ Multimedia codecs installed."
    end
end

# === 4. Install optional additional features ===
echo "📦 Checking for additional OpenShot features..."
echo "💡 Optional packages for enhanced video editing:"
echo "   - melt: MLT (Media Lovin' Toolkit) for video processing"
echo "   - frei0r-plugins: Collection of video effect plugins"
read -P "Do you want to install additional video processing tools? [y/N] " install_features

if test "$install_features" = "y" -o "$install_features" = "Y"
    echo "📦 Installing additional video processing tools..."
    sudo pacman -S --needed --noconfirm melt frei0r-plugins
    if test $status -ne 0
        echo "⚠ Failed to install some features, but OpenShot is still installed."
    else
        echo "✅ Additional video processing tools installed."
    end
end

# === 5. Install Python dependencies (if needed) ===
echo "📦 Checking for Python support..."
command -q python; and set -l python_installed "installed"
if test -n "$python_installed"
    echo "✅ Python is installed."
    echo "💡 OpenShot uses Python for scripting and extensibility."
else
    echo "ℹ Python is recommended for OpenShot scripting support."
    read -P "Do you want to install Python? [y/N] " install_python
    if test "$install_python" = "y" -o "$install_python" = "Y"
        sudo pacman -S --needed --noconfirm python
        echo "✅ Python installed."
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
                echo "⚠ Failed to fix snapper, but OpenShot is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 7. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q openshot-qt
if test $status -eq 0
    echo "✅ OpenShot installed successfully"
    openshot-qt --version 2>&1 | head -n 1
else
    echo "❌ OpenShot installation verification failed."
end

echo
echo "✅ OpenShot installation complete!"
echo "💡 You can now launch OpenShot from:"
echo "   - Applications menu (Multimedia category)"
echo "   - Command line: openshot-qt"
echo "💡 OpenShot will be available system-wide for all users."
echo "💡 OpenShot is a simple yet powerful video editor with:"
echo "   - Intuitive timeline-based editing"
echo "   - Rich video effects and transitions"
echo "   - Title editor and 3D animations"
echo "   - Audio editing and mixing"
echo "   - YouTube 1080p, 2K, and 4K export"
echo "💡 Tips for getting started:"
echo "   - Import media files by dragging them into the project"
echo "   - Drag clips from the Project Files to the Timeline"
echo "   - Use the Preview window to see your edits"
echo "   - Export your project when done: File → Export Video"

