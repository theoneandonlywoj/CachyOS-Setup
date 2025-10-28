#!/usr/bin/env fish
# === imagemagick.fish ===
# Purpose: Install ImageMagick image manipulation library on CachyOS
# Installs ImageMagick from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting ImageMagick installation..."

# === 1. Check if ImageMagick is already installed ===
command -q convert; and set -l imagemagick_installed "installed"
if test -n "$imagemagick_installed"
    echo "✅ ImageMagick is already installed."
    echo "⚠ Skipping installation. If you need to reinstall, run manually: sudo pacman -S --noconfirm imagemagick"
    echo "💡 If reinstall fails due to dependencies, you may need to update instead: sudo pacman -Syu imagemagick"
    exit 0
end

# === 2. Install ImageMagick ===
echo "📦 Installing ImageMagick..."
sudo pacman -S --needed --noconfirm imagemagick
if test $status -ne 0
    echo "❌ Failed to install ImageMagick."
    exit 1
end
echo "✅ ImageMagick installed."

# === 3. Install optional ImageMagick features ===
echo "📦 Installing recommended ImageMagick features..."
echo "💡 The following optional packages enhance ImageMagick capabilities:"
echo "   - ghostscript: PDF support"
echo "   - libheif: HEIF/HEIC support"
echo "   - libjxl: JPEG XL support"
echo "   - libjpeg-turbo: Fast JPEG support"
echo "   - libpng: PNG support"
read -P "Do you want to install recommended features? [y/N] " install_features

if test "$install_features" = "y" -o "$install_features" = "Y"
    echo "📦 Installing additional features..."
    sudo pacman -S --needed --noconfirm ghostscript libheif libjxl libjpeg-turbo libpng
    if test $status -ne 0
        echo "⚠ Failed to install some features, but ImageMagick is still installed."
    else
        echo "✅ Additional features installed."
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q convert
if test $status -eq 0
    echo "✅ ImageMagick installed successfully"
    echo "✅ Version info:"
    identify --version | head -n 1
    echo "✅ Available convert command:"
    convert -version | head -n 2
else
    echo "❌ ImageMagick installation verification failed."
end

echo
echo "✅ ImageMagick installation complete!"
echo "💡 ImageMagick is now available system-wide for all users."
echo "💡 Available commands:"
echo "   - convert: Image conversion and manipulation"
echo "   - identify: Image information"
echo "   - montage: Creating image montages"
echo "   - mogrify: Batch image processing"
echo "💡 Examples:"
echo "   convert input.jpg -resize 800x600 output.jpg"
echo "   identify image.png"

