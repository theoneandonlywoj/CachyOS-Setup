#!/usr/bin/env fish
# === calibre.fish ===
# Purpose: Install Calibre (e-book management and viewer) on CachyOS (Arch Linux)
# Installs Calibre via pacman/AUR for viewing .pub files and managing e-books
# Author: theoneandonlywoj

echo "🚀 Starting Calibre installation..."
echo
echo "💡 Calibre is a powerful e-book management application"
echo "   - View and manage e-books in various formats"
echo "   - View .pub files (Microsoft Publisher documents)"
echo "   - Convert between e-book formats"
echo "   - Organize and catalog your digital library"
echo "   - E-book reader with customizable interface"
echo "   - Download news and convert to e-books"
echo

# === 1. Check if Calibre is already installed ===
command -q calibre; and set -l calibre_installed "installed"
if test -n "$calibre_installed"
    echo "✅ Calibre is already installed."
    calibre --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Calibre installation."
        exit 0
    end
    echo "📦 Removing existing Calibre installation..."
    # Try to remove via pacman
    if pacman -Qq calibre > /dev/null 2>&1
        sudo pacman -R --noconfirm calibre
    end
    # Try to remove via AUR helper
    set AUR_HELPER ""
    for helper in yay paru trizen pikaur
        if command -v $helper > /dev/null
            set AUR_HELPER $helper
            break
        end
    end
    if test -n "$AUR_HELPER"
        if pacman -Qq calibre-bin > /dev/null 2>&1
            $AUR_HELPER -R --noconfirm calibre-bin
        end
    end
    echo "✅ Calibre removed."
end

# === 2. Install via pacman/AUR ===
echo "📦 Installing Calibre via package manager..."

# Check if available in official repos
if pacman -Si calibre > /dev/null 2>&1
    echo "📦 Installing Calibre from official Arch repository..."
    sudo pacman -S --needed --noconfirm calibre
    if test $status -eq 0
        echo "✅ Calibre installed from official repository."
        set calibre_installed_via_pacman true
    else
        echo "❌ Failed to install Calibre from official repository."
        set calibre_install_failed true
    end
else
    echo "⚠ Calibre not found in official repository."
    set calibre_install_failed true
end

# === 3. Fallback: Try AUR ===
if set -q calibre_install_failed -o not set -q calibre_installed_via_pacman
    # Try AUR helper
    set AUR_HELPER ""
    for helper in yay paru trizen pikaur
        if command -v $helper > /dev/null
            set AUR_HELPER $helper
            break
        end
    end
    
    if test -n "$AUR_HELPER"
        echo "📦 Installing Calibre from AUR using $AUR_HELPER..."
        # Try calibre-bin first (pre-built binary, faster)
        if $AUR_HELPER -Si calibre-bin > /dev/null 2>&1
            echo "📦 Installing calibre-bin from AUR (pre-built binary)..."
            $AUR_HELPER -S --needed --noconfirm calibre-bin
            if test $status -eq 0
                echo "✅ Calibre installed from AUR (calibre-bin)."
                set calibre_installed_via_aur true
            else
                echo "⚠ Failed to install calibre-bin. Trying calibre..."
                set calibre_aur_failed true
            end
        else
            set calibre_aur_failed true
        end
        
        # Fallback to calibre (build from source)
        if set -q calibre_aur_failed -o not set -q calibre_installed_via_aur
            if $AUR_HELPER -Si calibre > /dev/null 2>&1
                echo "📦 Installing calibre from AUR (build from source)..."
                echo "⚠ This may take a while as it builds from source..."
                $AUR_HELPER -S --needed --noconfirm calibre
                if test $status -eq 0
                    echo "✅ Calibre installed from AUR."
                    set calibre_installed_via_aur true
                else
                    echo "❌ Failed to install Calibre from AUR."
                end
            else
                echo "❌ Calibre not found in AUR."
            end
        end
    else
        echo "❌ No AUR helper found. Please install yay, paru, trizen, or pikaur."
        echo "   Or install Calibre manually from: https://calibre-ebook.com/download"
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
set calibre_verified false
if command -q calibre
    set calibre_verified true
    echo "✅ Calibre installed successfully"
    calibre --version 2>&1 | head -n 1
end

if not $calibre_verified
    echo "❌ Calibre installation verification failed."
    exit 1
end

# === 5. Check for optional dependencies ===
echo
echo "🔍 Checking for optional dependencies..."

# Check for Python (required for some Calibre features)
if not command -q python3
    echo "⚠ Python 3 not found. Some Calibre features may not work."
    echo "   Install with: sudo pacman -S python"
end

# Check for GUI libraries (usually installed with Calibre)
if not test -f /usr/lib/libQt5Core.so* -a -f /usr/lib/libQt5Gui.so*
    echo "💡 Qt5 libraries should be installed with Calibre."
    echo "   If GUI doesn't work, install: sudo pacman -S qt5-base"
end

echo
echo "🎉 Calibre installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Launch Calibre GUI"
echo "   calibre"
echo ""
echo "   # Launch Calibre e-book viewer"
echo "   calibre-viewer"
echo ""
echo "   # Launch Calibre e-book editor"
echo "   calibre-ebook-edit"
echo ""
echo "   # View a .pub file"
echo "   calibre file.pub"
echo ""
echo "   # Convert e-book format"
echo "   ebook-convert input.epub output.pdf"
echo ""
echo "   # Add e-book to library"
echo "   calibredb add /path/to/book.epub"
echo ""
echo "💡 Command-line tools:"
echo "   # E-book converter"
echo "   ebook-convert input.epub output.mobi"
echo ""
echo "   # E-book metadata editor"
echo "   ebook-meta book.epub --title \"New Title\" --author \"Author Name\""
echo ""
echo "   # E-book viewer"
echo "   ebook-viewer book.epub"
echo ""
echo "   # Library management"
echo "   calibredb list"
echo "   calibredb add /path/to/book"
echo "   calibredb remove <id>"
echo ""
echo "💡 Supported formats:"
echo "   - Input: EPUB, MOBI, PDF, AZW, AZW3, FB2, LIT, PRC, RTF, TXT, HTML, DOCX, PUB"
echo "   - Output: EPUB, MOBI, PDF, AZW3, FB2, LIT, RTF, TXT, HTML, DOCX"
echo ""
echo "💡 Tips:"
echo "   - Default library location: ~/Calibre Library"
echo "   - You can change library location in Preferences > Library"
echo "   - Calibre can download news and convert to e-books"
echo "   - Use the Content Server to access your library from other devices"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://calibre-ebook.com"
echo "   - User Manual: https://manual.calibre-ebook.com"
echo "   - Forum: https://www.mobileread.com/forums/forumdisplay.php?f=166"
echo "   - GitHub: https://github.com/kovidgoyal/calibre"

