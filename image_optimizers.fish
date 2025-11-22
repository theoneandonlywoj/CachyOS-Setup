#!/usr/bin/env fish
# === image_optimizers.fish ===
# Purpose: Install image optimization tools (gifsicle, oxipng, jpegoptim) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting image optimizer tools installation..."
echo
echo "💡 Installing image optimization tools:"
echo "   - gifsicle: Optimize and manipulate GIF files"
echo "   - oxipng: Fast PNG optimizer"
echo "   - jpegoptim: JPEG optimizer"
echo "   - Reduce file sizes while maintaining quality"
echo "   - Perfect for web optimization and storage savings"
echo

# === 1. Check if tools are already installed ===
set tools_installed false
if command -q gifsicle; and command -q oxipng; and command -q jpegoptim
    set tools_installed true
    echo "✅ Image optimizers are already installed."
    echo "   gifsicle: $(gifsicle --version 2>&1 | head -n 1)"
    echo "   oxipng: $(oxipng --version 2>&1 | head -n 1)"
    echo "   jpegoptim: $(jpegoptim --version 2>&1 | head -n 1)"
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping image optimizer installation."
        exit 0
    end
    echo "📦 Removing existing installations..."
    sudo pacman -R --noconfirm gifsicle oxipng jpegoptim 2>/dev/null
    echo "✅ Tools removed."
end

# === 2. Install image optimizers ===
echo "📦 Installing image optimization tools from official repository..."
sudo pacman -S --needed --noconfirm gifsicle oxipng jpegoptim
if test $status -ne 0
    echo "❌ Failed to install image optimizers."
    exit 1
end
echo "✅ Image optimizers installed."

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
set all_installed true

if command -q gifsicle
    echo "✅ gifsicle installed successfully"
    gifsicle --version 2>&1 | head -n 1
else
    echo "❌ gifsicle verification failed."
    set all_installed false
end

if command -q oxipng
    echo "✅ oxipng installed successfully"
    oxipng --version 2>&1 | head -n 1
else
    echo "❌ oxipng verification failed."
    set all_installed false
end

if command -q jpegoptim
    echo "✅ jpegoptim installed successfully"
    jpegoptim --version 2>&1 | head -n 1
else
    echo "❌ jpegoptim verification failed."
    set all_installed false
end

if not $all_installed
    echo "❌ Some image optimizers failed verification."
    exit 1
end

echo
echo "🎉 Image optimizer tools installation complete!"
echo
echo "💡 gifsicle - GIF optimization:"
echo "   # Optimize a GIF file"
echo "   gifsicle -O3 input.gif -o output.gif"
echo ""
echo "   # Optimize with lossy compression"
echo "   gifsicle --lossy=100 input.gif -o output.gif"
echo ""
echo "   # Resize GIF"
echo "   gifsicle --resize-width 800 input.gif -o output.gif"
echo ""
echo "   # Extract frames from GIF"
echo "   gifsicle --explode input.gif"
echo ""
echo "   # Combine multiple GIFs"
echo "   gifsicle frame1.gif frame2.gif -o combined.gif"
echo ""
echo "💡 oxipng - PNG optimization:"
echo "   # Optimize PNG file (in-place)"
echo "   oxipng -o 2 image.png"
echo ""
echo "   # Optimize with maximum compression"
echo "   oxipng -o max image.png"
echo ""
echo "   # Optimize and preserve file attributes"
echo "   oxipng -o 2 --preserve image.png"
echo ""
echo "   # Optimize directory of PNGs"
echo "   oxipng -o 2 -r images/"
echo ""
echo "   # Strip metadata"
echo "   oxipng --strip safe image.png"
echo ""
echo "💡 jpegoptim - JPEG optimization:"
echo "   # Optimize JPEG file (in-place)"
echo "   jpegoptim image.jpg"
echo ""
echo "   # Optimize with maximum quality"
echo "   jpegoptim --max=95 image.jpg"
echo ""
echo "   # Optimize with size limit"
echo "   jpegoptim --size=500k image.jpg"
echo ""
echo "   # Optimize directory of JPEGs"
echo "   jpegoptim *.jpg"
echo ""
echo "   # Strip metadata"
echo "   jpegoptim --strip-all image.jpg"
echo ""
echo "💡 Batch optimization examples:"
echo "   # Optimize all images in current directory"
echo "   for file in *.gif; gifsicle -O3 \"$file\" -o \"optimized_$file\"; end"
echo "   for file in *.png; oxipng -o 2 \"$file\"; end"
echo "   for file in *.jpg; jpegoptim --max=85 \"$file\"; end"
echo ""
echo "   # Optimize recursively"
echo "   find . -name '*.png' -exec oxipng -o 2 {} \\;"
echo "   find . -name '*.jpg' -exec jpegoptim --max=85 {} \\;"
echo ""
echo "💡 Optimization levels:"
echo "   # gifsicle: -O1 (fast) to -O3 (best compression)"
echo "   # oxipng: -o 0 (fast) to -o max (best compression)"
echo "   # jpegoptim: --max=quality (0-100, higher = better quality)"
echo ""
echo "💡 Tips:"
echo "   - Always backup files before optimization"
echo "   - Test optimization on copies first"
echo "   - Use lossy compression carefully (may reduce quality)"
echo "   - Combine with imagemagick for format conversion"
echo "   - Use for web optimization to reduce page load times"
echo ""
echo "💡 Resources:"
echo "   - gifsicle: https://www.lcdf.org/gifsicle/"
echo "   - oxipng: https://github.com/shssoichiro/oxipng"
echo "   - jpegoptim: https://github.com/tjko/jpegoptim"

