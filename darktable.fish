#!/usr/bin/env fish
# === darktable.fish ===
# Purpose: Install darktable (RAW photo workflow) on CachyOS
# Installs darktable from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting darktable installation..."

# === 1. Check if darktable is already installed ===
command -q darktable; and set -l darktable_installed "installed"
if test -n "$darktable_installed"
    echo "✅ darktable is already installed."
    darktable --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping darktable installation."
        exit 0
    end
    echo "📦 Removing existing darktable installation..."
    sudo pacman -R --noconfirm darktable
    if test $status -ne 0
        echo "❌ Failed to remove darktable."
        exit 1
    end
    echo "✅ darktable removed."
end

# === 2. Install darktable ===
echo "📦 Installing darktable..."
sudo pacman -S --needed --noconfirm darktable
if test $status -ne 0
    echo "❌ Failed to install darktable."
    exit 1
end
echo "✅ darktable installed."

# === 3. Note about darktable features ===
echo "📦 darktable features:"
echo "💡 Note: darktable-cli (command-line interface) is already included with darktable."
echo "💡 darktable can integrate with GIMP if you have it installed separately."

# === 4. Install recommended graphics dependencies ===
echo "📦 Installing recommended graphics dependencies..."
sudo pacman -S --needed --noconfirm libpng libjpeg-turbo lcms2
if test $status -ne 0
    echo "⚠ Warning: Failed to install some graphics dependencies."
else
    echo "✅ Graphics dependencies installed."
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
                echo "⚠ Failed to fix snapper, but darktable is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q darktable
if test $status -eq 0
    echo "✅ darktable installed successfully"
    darktable --version 2>&1 | head -n 1
else
    echo "❌ darktable installation verification failed."
end

echo
echo "✅ darktable installation complete!"
echo "💡 darktable is a professional RAW photo workflow application:"
echo "   - Non-destructive RAW photo editing"
echo "   - Professional color grading and correction"
echo "   - Advanced masking and retouching"
echo "   - Tethered shooting support"
echo "   - HDR and panorama merging"
echo "   - Film simulation and presets"
echo "💡 You can now launch darktable from:"
echo "   - Applications menu (Graphics category)"
echo "   - Command line: darktable"
echo "💡 darktable will be available system-wide for all users."
echo "💡 Basic workflow:"
echo "   1. Import: File → Import or drag & drop images"
echo "   2. Develop: Use modules in right panel to adjust images"
echo "   3. Export: File → Export to save processed images"
echo "💡 Key features:"
echo "   - Lighttable view: Organize and rate your photos"
echo "   - Darkroom view: Edit individual images"
echo "   - Map view: Geotag and organize by location"
echo "   - Tethering view: Control camera remotely"
echo "💡 Supported formats:"
echo "   - RAW: CR2, NEF, ARW, DNG, and 400+ more"
echo "   - JPEG, TIFF, PNG"
echo "   - Export to JPEG, TIFF, PNG, WebP, PPM"
echo "💡 Modules and tools:"
echo "   - Exposure, color balance, tone curve"
echo "   - Lens correction, perspective correction"
echo "   - Noise reduction, sharpening"
echo "   - Color grading, film simulation"
echo "   - Spot removal, retouching"
echo "💡 Command-line usage (darktable-cli is included):"
echo "   - darktable-cli input.raw output.jpg"
echo "   - darktable-cli --apply-preset preset.xmp input.raw output.jpg"
echo "   - darktable-cli --core --conf 'plugins/darkroom/export/format=jpg' input.raw output.jpg"
echo "💡 Tips:"
echo "   - Use keyboard shortcuts for faster workflow (press '?' for help)"
echo "   - Create and save presets for consistent processing"
echo "   - Use snapshots to compare different edits"
echo "   - Enable OpenCL for faster processing (if GPU available)"
echo "   - Organize photos using collections and tags"
echo "💡 Resources:"
echo "   - Official site: https://www.darktable.org/"
echo "   - Documentation: https://www.darktable.org/usermanual/"
echo "   - User manual: https://www.darktable.org/usermanual/en/"
echo "   - Forum: https://discuss.pixls.us/c/software/darktable/"

