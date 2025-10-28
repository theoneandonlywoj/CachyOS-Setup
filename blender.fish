#!/usr/bin/env fish
# === blender.fish ===
# Purpose: Install Blender 3D creation suite on CachyOS
# Installs Blender from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Blender installation..."

# === 1. Check if Blender is already installed ===
command -q blender; and set -l blender_installed "installed"
if test -n "$blender_installed"
    echo "✅ Blender is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Blender installation."
        exit 0
    end
    echo "📦 Removing existing Blender installation..."
    sudo pacman -R --noconfirm blender
    if test $status -ne 0
        echo "❌ Failed to remove Blender."
        exit 1
    end
    echo "✅ Blender removed."
end

# === 2. Install Blender ===
echo "📦 Installing Blender..."
sudo pacman -S --needed --noconfirm blender
if test $status -ne 0
    echo "❌ Failed to install Blender."
    exit 1
end
echo "✅ Blender installed."

# === 3. Install recommended multimedia codecs ===
echo "📦 Installing recommended multimedia codecs..."
echo "💡 The following packages enable video encoding/decoding support:"
echo "   - ffmpeg: Video and audio codec library"
echo "   - opencl-mesa: OpenCL for GPU acceleration"
read -P "Do you want to install codec support? [y/N] " install_codecs

if test "$install_codecs" = "y" -o "$install_codecs" = "Y"
    echo "📦 Installing multimedia codecs..."
    sudo pacman -S --needed --noconfirm ffmpeg opencl-mesa
    if test $status -ne 0
        echo "⚠ Failed to install some codecs, but Blender is still installed."
    else
        echo "✅ Multimedia codecs installed."
    end
end

# === 4. Install optional additional features ===
echo "📦 Checking for additional Blender features..."
echo "💡 Optional packages for enhanced 3D workflow:"
echo "   - python-requests: For accessing external content"
echo "   - optipng: PNG optimization"
read -P "Do you want to install additional features? [y/N] " install_features

if test "$install_features" = "y" -o "$install_features" = "Y"
    echo "📦 Installing additional features..."
    sudo pacman -S --needed --noconfirm python-requests optipng
    if test $status -ne 0
        echo "⚠ Failed to install some features, but Blender is still installed."
    else
        echo "✅ Additional features installed."
    end
end

# === 5. Install Python dependencies (Blender uses Python 3) ===
echo "📦 Checking for Python support..."
command -q python; and set -l python_installed "installed"
if test -n "$python_installed"
    echo "✅ Python is installed."
    echo "💡 Blender uses Python for scripting and add-ons."
else
    echo "⚠ Python is strongly recommended for Blender (scripting, add-ons, etc.)."
    read -P "Do you want to install Python? [Y/n] " install_python
    if test "$install_python" != "n" -a "$install_python" != "N"
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
                echo "⚠ Failed to fix snapper, but Blender is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 7. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q blender
if test $status -eq 0
    echo "✅ Blender installed successfully"
    blender --version 2>&1 | head -n 3
else
    echo "❌ Blender installation verification failed."
end

echo
echo "✅ Blender installation complete!"
echo "💡 You can now launch Blender from:"
echo "   - Applications menu (Graphics/3D category)"
echo "   - Command line: blender"
echo "💡 Blender will be available system-wide for all users."
echo "💡 Blender is a comprehensive 3D creation suite with:"
echo "   - 3D modeling and sculpting"
echo "   - UV mapping and texturing"
echo "   - Animation and rigging"
echo "   - Rendering (Cycles and Eevee)"
echo "   - Video editing"
echo "   - VFX and compositing"
echo "💡 Tips for getting started:"
echo "   - Press spacebar to open the quick search menu"
echo "   - Right-click to select objects (keymap: Blender)"
echo "   - Press Tab to toggle between Object and Edit mode"
echo "   - Visit blender.org for tutorials and documentation"
echo "💡 Keyboard shortcuts:"
echo "   - G: Grab/Move, R: Rotate, S: Scale"
echo "   - X: Delete, Z: Viewport shading menu"

