#!/usr/bin/env fish
# === mdbook.fish ===
# Purpose: Install mdbook (create books with Markdown) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting mdbook installation..."
echo
echo "💡 mdbook is a utility for creating modern online books from Markdown:"
echo "   - Create beautiful documentation and books"
echo "   - Generate static HTML websites"
echo "   - Support for search, themes, and plugins"
echo "   - Great for technical documentation"
echo "   - Used by Rust Book, The Book, and many others"
echo

# === 1. Check if mdbook is already installed ===
command -q mdbook; and set -l mdbook_installed "installed"
if test -n "$mdbook_installed"
    echo "✅ mdbook is already installed."
    mdbook --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping mdbook installation."
        exit 0
    end
    echo "📦 Removing existing mdbook installation..."
    # Try to remove via cargo
    if command -v cargo > /dev/null
        cargo uninstall mdbook 2>/dev/null
    end
    # Try to remove via pacman
    if pacman -Qq mdbook > /dev/null 2>&1
        sudo pacman -R --noconfirm mdbook
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/mdbook
        sudo rm -f /usr/local/bin/mdbook
    end
    if test -f ~/.local/bin/mdbook
        rm -f ~/.local/bin/mdbook
    end
    if test -f ~/.cargo/bin/mdbook
        rm -f ~/.cargo/bin/mdbook
    end
    echo "✅ mdbook removed."
end

# === 2. Install from official repository (preferred) ===
echo "📦 Checking official repository for mdbook..."
if pacman -Si mdbook > /dev/null 2>&1
    echo "📦 Installing mdbook from official Arch repository..."
    sudo pacman -S --needed --noconfirm mdbook
    if test $status -eq 0
        echo "✅ mdbook installed from official repository."
        set mdbook_installed_via_pacman true
    else
        echo "❌ Failed to install mdbook from official repository."
    end
else
    echo "ℹ mdbook not found in official repository."
end

# === 3. Fallback: Install via cargo (Rust package manager) ===
if not set -q mdbook_installed_via_pacman
    if command -v cargo > /dev/null
        echo "📦 Installing mdbook via cargo..."
        cargo install mdbook
        if test $status -eq 0
            echo "✅ mdbook installed successfully via cargo"
            set mdbook_installed_via_cargo true
            # Ensure ~/.cargo/bin is in PATH
            if not contains "$HOME/.cargo/bin" $fish_user_paths
                set -U fish_user_paths $HOME/.cargo/bin $fish_user_paths
                echo "🔧 Added ~/.cargo/bin to PATH"
            end
        else
            echo "⚠ Failed to install mdbook via cargo. Trying GitHub releases..."
        end
    else
        echo "ℹ Cargo not found. Will try GitHub releases."
        echo "💡 Tip: Install Rust and Cargo for better installation:"
        echo "   sudo pacman -S --needed rust"
    end
end

# === 4. Fallback: Install from GitHub releases ===
if not set -q mdbook_installed_via_pacman -a not set -q mdbook_installed_via_cargo
    echo "📥 Installing mdbook from GitHub releases..."
    
    # Detect architecture
    set arch (uname -m)
    switch $arch
        case x86_64
            set MDBOOK_ARCH "x86_64-unknown-linux-gnu"
        case aarch64 arm64
            set MDBOOK_ARCH "aarch64-unknown-linux-gnu"
        case '*'
            echo "❌ Unsupported architecture: $arch"
            exit 1
    end
    
    # Get latest version from GitHub API
    echo "🔍 Fetching latest mdbook version..."
    set MDBOOK_VERSION (curl -s https://api.github.com/repos/rust-lang/mdBook/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    
    if test -z "$MDBOOK_VERSION"
        echo "⚠ Failed to fetch latest version. Using fallback method..."
        set MDBOOK_VERSION "0.4.36"
    end
    
    echo "📦 Downloading mdbook v$MDBOOK_VERSION..."
    set MDBOOK_FILENAME "mdbook-v$MDBOOK_VERSION-$MDBOOK_ARCH.tar.gz"
    set MDBOOK_URL "https://github.com/rust-lang/mdBook/releases/download/v$MDBOOK_VERSION/$MDBOOK_FILENAME"
    set MDBOOK_TMP_DIR (mktemp -d)
    set MDBOOK_TAR "$MDBOOK_TMP_DIR/mdbook.tar.gz"
    
    curl -L -o $MDBOOK_TAR $MDBOOK_URL
    if test $status -ne 0
        echo "❌ Failed to download mdbook from GitHub."
        rm -rf $MDBOOK_TMP_DIR
        exit 1
    end
    
    # Extract and install
    echo "📦 Extracting mdbook..."
    cd $MDBOOK_TMP_DIR
    tar -xzf $MDBOOK_TAR
    if test $status -ne 0
        echo "❌ Failed to extract mdbook archive."
        rm -rf $MDBOOK_TMP_DIR
        exit 1
    end
    
    # Find the mdbook binary
    set mdbook_bin (find . -name "mdbook" -type f | head -n1)
    
    if test -n "$mdbook_bin" -a -f "$mdbook_bin"
        # Make executable and install
        chmod +x $mdbook_bin
        sudo mkdir -p /usr/local/bin
        sudo cp $mdbook_bin /usr/local/bin/mdbook
        
        # Cleanup
        cd -
        rm -rf $MDBOOK_TMP_DIR
        
        echo "✅ mdbook installed from GitHub releases."
    else
        echo "❌ Could not find mdbook binary in archive."
        cd -
        rm -rf $MDBOOK_TMP_DIR
        exit 1
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
set mdbook_verified false

# Ensure cargo bin is in PATH for verification if installed via cargo
if set -q mdbook_installed_via_cargo
    set -x PATH $HOME/.cargo/bin $PATH
end

if command -q mdbook
    set mdbook_verified true
    echo "✅ mdbook installed successfully"
    mdbook --version 2>&1
else
    echo "❌ mdbook verification failed."
    if set -q mdbook_installed_via_cargo
        echo "💡 If installed via cargo, ensure ~/.cargo/bin is in your PATH"
        echo "   Or restart your terminal."
    end
    exit 1
end

echo
echo "🎉 mdbook installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Initialize a new book"
echo "   mdbook init my-book"
echo ""
echo "   # Build the book"
echo "   mdbook build"
echo ""
echo "   # Serve the book locally (with auto-reload)"
echo "   mdbook serve"
echo ""
echo "   # Watch for changes and rebuild"
echo "   mdbook watch"
echo ""
echo "   # Test the book"
echo "   mdbook test"
echo ""
echo "💡 Project structure:"
echo "   book/"
echo "   ├── book.toml          # Configuration file"
echo "   ├── src/               # Source Markdown files"
echo "   │   ├── SUMMARY.md     # Table of contents"
echo "   │   └── chapter_1.md"
echo "   └── book/              # Generated HTML (after build)"
echo ""
echo "💡 Common commands:"
echo "   mdbook init [dir]      # Initialize a new book"
echo "   mdbook build           # Build the book"
echo "   mdbook serve [dir]     # Serve on http://localhost:3000"
echo "   mdbook watch           # Watch for changes"
echo "   mdbook clean           # Remove generated files"
echo "   mdbook test            # Run tests"
echo "   mdbook completions     # Generate shell completions"
echo ""
echo "💡 Configuration (book.toml):"
echo "   [book]"
echo "   title = \"My Book\""
echo "   authors = [\"Author Name\"]"
echo "   description = \"A book description\""
echo ""
echo "   [build]"
echo "   create-missing = true"
echo ""
echo "💡 Themes and plugins:"
echo "   # Install a theme"
echo "   mdbook init --theme"
echo ""
echo "   # Use plugins (via book.toml)"
echo "   [output.html.search]"
echo "   enable = true"
echo ""
echo "💡 SUMMARY.md format:"
echo "   # Summary"
echo "   [Introduction](intro.md)"
echo "   [Chapter 1](chapter1.md)"
echo "   [Chapter 2](chapter2.md)"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://rust-lang.github.io/mdBook/"
echo "   - User Guide: https://rust-lang.github.io/mdBook/guide/"
echo "   - GitHub: https://github.com/rust-lang/mdBook"
echo "   - Format Guide: https://rust-lang.github.io/mdBook/format/"

