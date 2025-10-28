#!/usr/bin/env fish
# === exiftool.fish ===
# Purpose: Install ExifTool on CachyOS
# Installs ExifTool (perl-image-exiftool) from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting ExifTool installation..."

# === 1. Check if ExifTool is already installed ===
command -q exiftool; and set -l exiftool_installed "installed"
if test -n "$exiftool_installed"
    echo "✅ ExifTool is already installed."
    exiftool -ver
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping ExifTool installation."
        exit 0
    end
    echo "📦 Removing existing ExifTool installation..."
    sudo pacman -R --noconfirm perl-image-exiftool
    if test $status -ne 0
        echo "❌ Failed to remove ExifTool."
        exit 1
    end
    echo "✅ ExifTool removed."
end

# === 2. Install ExifTool ===
echo "📦 Installing ExifTool..."
sudo pacman -S --needed --noconfirm perl-image-exiftool
if test $status -ne 0
    echo "❌ Failed to install ExifTool."
    exit 1
end
echo "✅ ExifTool installed."

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
                echo "⚠ Failed to fix snapper, but ExifTool is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q exiftool
if test $status -eq 0
    echo "✅ ExifTool installed successfully"
    echo "📌 Version: $(exiftool -ver)"
    echo "✅ Location: $(which exiftool)"
else
    echo "❌ ExifTool installation verification failed."
end

echo
echo "✅ ExifTool installation complete!"
echo "💡 ExifTool is a metadata reader and writer:"
echo "   - Read EXIF data from images and media files"
echo "   - Remove or modify metadata"
echo "   - Batch process multiple files"
echo "   - Support for many file formats"
echo "💡 Basic usage:"
echo "   - View metadata: exiftool image.jpg"
echo "   - Extract all tags: exiftool -all image.jpg"
echo "   - Remove all metadata: exiftool -all= image.jpg"
echo "   - Remove specific tags: exiftool -GPS:all= image.jpg"
echo "   - Copy metadata: exiftool -tagsFromFile source.jpg dest.jpg"
echo "💡 Supported formats:"
echo "   - Image: JPEG, PNG, TIFF, RAW, WebP, HEIC"
echo "   - Audio: MP3, FLAC, WAV, M4A"
echo "   - Video: MP4, AVI, MOV, MKV"
echo "   - Documents: PDF, Office formats"
echo "💡 Common use cases:"
echo "   - Privacy: Remove location and camera info"
echo "   - Forensics: Extract metadata for investigation"
echo "   - Photography: View camera settings"
echo "   - Batch processing: Clean metadata from multiple files"
echo "💡 Useful commands:"
echo "   - exiftool image.jpg: Show all metadata"
echo "   - exiftool -GPS*: Show only GPS data"
echo "   - exiftool -T -c \"%.6f\" image.jpg: Tab-separated output"
echo "   - exiftool -m -exif:all= -r folder/: Remove all EXIF recursively"
echo "💡 Privacy tips:"
echo "   - Remove GPS data: exiftool -GPS:all= file.jpg"
echo "   - Remove all metadata: exiftool -all= file.jpg"
echo "   - Remove EXIF only: exiftool -EXIF:all= file.jpg"
echo "   - Overwrite original: exiftool -overwrite_original file.jpg"
echo "💡 Batch operations:"
echo "   - Process folder: exiftool -r folder/"
echo "   - Filter by extension: exiftool -ext jpg folder/"
echo "   - Remove from all JPG: exiftool -all= -ext jpg folder/"

