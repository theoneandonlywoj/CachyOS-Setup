#!/usr/bin/env fish
# === epub_reader.fish ===
# Purpose: Install a free epub reader on CachyOS (Arch Linux)
# Author: theoneandonlywoj
# License: GPL-3.0+

# === Reader selection ===
# Available options: foliate (recommended), calibre, zathura, readest
set READER foliate

echo "📚 Starting epub reader installation on CachyOS..."
echo "📌 Selected reader: $READER"
echo

switch $READER
    case foliate
        set package_name foliate
        set description "Simple and modern GTK ebook reader"
        set features "EPUB, MOBI, Kindle, FB2, CBZ, PDF support"
    case calibre
        set package_name calibre
        set description "Powerful ebook management suite"
        set features "Comprehensive ebook management and conversion"
    case zathura
        set package_name zathura zathura-pdf-poppler
        set description "Minimalist document viewer"
        set features "PDF and EPUB support via plugins"
    case readest
        set package_name readest
        set description "Modern, feature-rich ebook reader"
        set features "Modern UI with epub, PDF, MOBI support"
    case "*"
        echo "❌ Unknown reader: $READER"
        echo "Available options: foliate, calibre, zathura, readest"
        exit 1
end

echo "📖 Reader: $description"
echo "✨ Features: $features"
echo

# === Install the selected reader ===
echo "📦 Installing $package_name..."

if test (count $package_name) -eq 1
    sudo pacman -S --needed --noconfirm $package_name
else
    sudo pacman -S --needed --noconfirm $package_name[1] $package_name[2]
end

if test $status -ne 0
    echo "❌ Installation failed. Trying to refresh database..."
    sudo pacman -Sy --noconfirm
    if test (count $package_name) -eq 1
        sudo pacman -S --needed --noconfirm $package_name
    else
        sudo pacman -S --needed --noconfirm $package_name[1] $package_name[2]
    end
    if test $status -ne 0
        echo "❌ Installation failed. Please install manually:"
        echo "   sudo pacman -S $package_name"
        exit 1
    end
end

# === Verify installation ===
echo "🧪 Verifying installation..."

switch $READER
    case foliate
        if command -v foliate > /dev/null
            echo "✅ Foliate installed successfully!"
        else
            echo "❌ Verification failed."
            exit 1
        end
    case calibre
        if command -v calibre > /dev/null
            echo "✅ Calibre installed successfully!"
        else
            echo "❌ Verification failed."
            exit 1
        end
    case zathura
        if command -v zathura > /dev/null
            echo "✅ Zathura installed successfully!"
        else
            echo "❌ Verification failed."
            exit 1
        end
    case readest
        if command -v readest > /dev/null
            echo "✅ Readest installed successfully!"
        else
            echo "❌ Verification failed."
            exit 1
        end
end

echo
echo "🎉 Epub reader installation complete!"
echo
echo "💡 To open an epub file, run:"

switch $READER
    case foliate
        echo "   foliate /path/to/book.epub"
    case calibre
        echo "   calibre /path/to/book.epub"
    case zathura
        echo "   zathura /path/to/book.epub"
    case readest
        echo "   readest /path/to/book.epub"
end

echo
echo "📚 Installed reader: $READER"
