#!/usr/bin/env fish
# === gmic.fish ===
# Purpose: Install G'MIC (GREYC's Magic Image Converter) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting G'MIC installation..."
echo

# === 1. Check if gmic is already installed ===
command -q gmic; and set -l gmic_installed "installed"
if test -n "$gmic_installed"
    echo "✅ G'MIC is already installed."
    gmic --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping G'MIC installation."
        exit 0
    end
    echo "📦 Removing existing G'MIC installation..."
    sudo pacman -R --noconfirm gmic
    if test $status -ne 0
        echo "❌ Failed to remove G'MIC."
        exit 1
    end
    echo "✅ G'MIC removed."
end

# === 2. Install G'MIC ===
echo "📦 Installing G'MIC from official repository..."
sudo pacman -S --needed --noconfirm gmic
if test $status -ne 0
    echo "❌ Failed to install G'MIC."
    exit 1
end
echo "✅ G'MIC installed."

# === 3. Check for GIMP and install GIMP plugin if available ===
if command -q gimp
    echo "🎨 GIMP detected. Installing G'MIC plugin for GIMP..."
    sudo pacman -S --needed --noconfirm gimp-plugin-gmic
    if test $status -eq 0
        echo "✅ G'MIC plugin for GIMP installed."
    else
        echo "⚠ Warning: Failed to install G'MIC plugin for GIMP."
        echo "   G'MIC CLI is still fully functional."
    end
else
    echo "💡 GIMP not detected. G'MIC CLI will be installed."
    echo "   To use G'MIC with GIMP, install GIMP first, then run:"
    echo "   sudo pacman -S --needed gimp-plugin-gmic"
end

# === 4. Install recommended dependencies ===
echo "📦 Installing recommended image processing dependencies..."
sudo pacman -S --needed --noconfirm libpng libjpeg-turbo libtiff openexr fftw
if test $status -ne 0
    echo "⚠ Warning: Failed to install some dependencies."
    echo "   G'MIC may have limited functionality."
else
    echo "✅ Image processing dependencies installed."
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q gmic
if test $status -eq 0
    echo "✅ G'MIC installed successfully"
    gmic --version 2>&1 | head -n 1
else
    echo "❌ G'MIC installation verification failed."
    exit 1
end

echo
echo "🎉 G'MIC installation complete!"
echo
echo "💡 G'MIC is a powerful image processing framework:"
echo "   - Command-line image processing tool"
echo "   - 500+ filters and effects"
echo "   - Batch processing capabilities"
echo "   - Support for 100+ image formats"
echo "   - GIMP plugin integration (if GIMP is installed)"
echo
echo "💡 You can now use G'MIC from:"
echo "   - Command line: gmic"
echo "   - GIMP: Filters → G'MIC-Qt (if GIMP plugin is installed)"
echo
echo "💡 Basic command-line usage:"
echo "   - Process single image:"
echo "     gmic input.jpg -filter_name -o output.jpg"
echo "   - Batch process:"
echo "     gmic *.jpg -filter_name -o output_%f.jpg"
echo "   - List available filters:"
echo "     gmic -h filters"
echo "   - Apply specific filter:"
echo "     gmic input.jpg -gaussian_blur 5 -o output.jpg"
echo "   - Interactive mode:"
echo "     gmic input.jpg"
echo
echo "💡 Popular filters and effects:"
echo "   - Artistic: -cartoon, -watercolor, -oilify"
echo "   - Enhancement: -sharpen, -denoise, -enhance"
echo "   - Color: -colorize, -gradient_map, -vibrance"
echo "   - Distortion: -warp, -twirl, -ripple"
echo "   - Texture: -texturize, -emboss, -relief"
echo
echo "💡 GIMP integration (if plugin installed):"
echo "   - Launch GIMP"
echo "   - Open an image"
echo "   - Go to: Filters → G'MIC-Qt"
echo "   - Browse and apply filters interactively"
echo
echo "💡 Supported formats:"
echo "   - Input: JPEG, PNG, TIFF, GIF, BMP, WebP, RAW, and 100+ more"
echo "   - Output: JPEG, PNG, TIFF, GIF, BMP, WebP, and more"
echo
echo "💡 Resources:"
echo "   - Official site: https://gmic.eu/"
echo "   - Documentation: https://gmic.eu/reference.shtml"
echo "   - Filter reference: https://gmic.eu/reference/filters.html"
echo "   - Examples: https://gmic.eu/gallery/index.html"
echo "   - Forum: https://discuss.pixls.us/c/software/gmic/"

