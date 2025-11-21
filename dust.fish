#!/usr/bin/env fish
# === dust.fish ===
# Purpose: Install dust (disk usage analyzer) on CachyOS
# Installs dust via mise (preferred), cargo, pacman/AUR, or GitHub releases
# Author: theoneandonlywoj

echo "🚀 Starting dust installation..."

# === 1. Check if dust is already installed ===
command -q dust; and set -l dust_installed "installed"
if test -n "$dust_installed"
    echo "✅ dust is already installed."
    dust --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping dust installation."
        exit 0
    end
    echo "📦 Removing existing dust installation..."
    # Try to remove via mise first
    if command -v mise > /dev/null
        mise uninstall dust 2>/dev/null
    end
    # Try to remove via cargo
    if command -v cargo > /dev/null
        cargo uninstall dust 2>/dev/null
    end
    # Try to remove via pacman
    if pacman -Qq dust > /dev/null 2>&1
        sudo pacman -R --noconfirm dust
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/dust
        sudo rm -f /usr/local/bin/dust
    end
    if test -f ~/.local/bin/dust
        rm -f ~/.local/bin/dust
    end
    if test -f ~/.cargo/bin/dust
        rm -f ~/.cargo/bin/dust
    end
    echo "✅ dust removed."
end

# === 2. Check for Mise and prefer mise installation ===
set use_mise false
if command -v mise > /dev/null
    echo "✅ Mise found. Preferring mise installation method."
    set use_mise true
    
    # Load Mise environment in current shell
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
    
    # Check if dust is available via mise
    echo "🔍 Checking if dust is available via mise..."
    mise install dust@latest
    if test $status -eq 0
        mise use -g dust@latest
        if test $status -eq 0
            echo "✅ dust installed successfully via mise"
            set dust_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        else
            echo "⚠ Failed to set dust as global via mise, but installation succeeded."
            set dust_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        end
    else
        echo "⚠ dust installation via mise failed. Falling back to other methods..."
        set use_mise false
    end
else
    echo "ℹ Mise not found. Will install via cargo, pacman/AUR, or GitHub releases."
    echo "💡 Tip: Install mise first (./mise.fish) for better version management."
end

# === 3. Fallback: Install via cargo (Rust package manager) ===
if not set -q dust_installed_via_mise
    # Check for cargo
    if command -v cargo > /dev/null
        echo "📦 Installing dust via cargo..."
        cargo install dust
        if test $status -eq 0
            echo "✅ dust installed successfully via cargo"
            set dust_installed_via_cargo true
            # Ensure ~/.cargo/bin is in PATH
            if not contains "$HOME/.cargo/bin" $fish_user_paths
                set -U fish_user_paths $HOME/.cargo/bin $fish_user_paths
            end
        else
            echo "⚠ Failed to install dust via cargo. Trying other methods..."
        end
    else
        echo "ℹ Cargo not found. Will try other installation methods."
        echo "💡 You can install Rust and cargo with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    end
end

# === 4. Fallback: Install via pacman/AUR if cargo failed or not available ===
if not set -q dust_installed_via_mise -a not set -q dust_installed_via_cargo
    echo "📦 Installing dust via package manager..."
    
    # Check if available in official repos
    if pacman -Si dust > /dev/null 2>&1
        echo "📦 Installing dust from official Arch repository..."
        sudo pacman -S --needed --noconfirm dust
        if test $status -eq 0
            echo "✅ dust installed from official repository."
            set dust_installed_via_pacman true
        else
            echo "❌ Failed to install dust from official repository."
        end
    else
        # Try AUR helper
        set AUR_HELPER ""
        for helper in yay paru trizen pikaur
            if command -v $helper > /dev/null
                set AUR_HELPER $helper
                break
            end
        end
        
        if test -n "$AUR_HELPER"
            echo "📦 Installing dust from AUR using $AUR_HELPER..."
            $AUR_HELPER -S --needed --noconfirm dust
            if test $status -eq 0
                echo "✅ dust installed from AUR."
                set dust_installed_via_pacman true
            else
                echo "⚠ Failed to install dust from AUR."
            end
        end
    end
end

# === 5. Final fallback: Install from GitHub releases ===
if not set -q dust_installed_via_mise -a not set -q dust_installed_via_cargo -a not set -q dust_installed_via_pacman
    echo "📥 Installing dust from GitHub releases..."
    
    # Detect architecture
    set arch (uname -m)
    switch $arch
        case x86_64
            set DUST_ARCH "x86_64-unknown-linux-musl"
        case aarch64 arm64
            set DUST_ARCH "aarch64-unknown-linux-musl"
        case '*'
            echo "❌ Unsupported architecture: $arch"
            exit 1
    end
    
    # Get latest version from GitHub API
    echo "🔍 Fetching latest dust version..."
    set DUST_VERSION (curl -s https://api.github.com/repos/bootandy/dust/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    
    if test -z "$DUST_VERSION"
        echo "⚠ Failed to fetch latest version. Using fallback method..."
        set DUST_VERSION "0.9.0"
    end
    
    echo "📦 Downloading dust v$DUST_VERSION..."
    set DUST_FILENAME "dust-v$DUST_VERSION-$DUST_ARCH.tar.gz"
    set DUST_URL "https://github.com/bootandy/dust/releases/download/v$DUST_VERSION/$DUST_FILENAME"
    set DUST_TMP_DIR (mktemp -d)
    set DUST_TAR "$DUST_TMP_DIR/dust.tar.gz"
    
    curl -L -o $DUST_TAR $DUST_URL
    if test $status -ne 0
        echo "❌ Failed to download dust from GitHub."
        rm -rf $DUST_TMP_DIR
        exit 1
    end
    
    # Extract and install
    echo "📦 Extracting dust..."
    cd $DUST_TMP_DIR
    tar -xzf $DUST_TAR
    if test $status -ne 0
        echo "❌ Failed to extract dust archive."
        rm -rf $DUST_TMP_DIR
        exit 1
    end
    
    # Install binary
    sudo mkdir -p /usr/local/bin
    sudo cp dust /usr/local/bin/dust
    sudo chmod +x /usr/local/bin/dust
    
    # Cleanup
    cd -
    rm -rf $DUST_TMP_DIR
    
    if test $status -eq 0
        echo "✅ dust installed from GitHub releases."
    else
        echo "❌ Failed to install dust binary."
        exit 1
    end
end

# === 6. Ensure mise environment is active for verification ===
if set -q dust_installed_via_mise
    # Ensure mise shims are in PATH
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
end

# === 7. Verify installation ===
echo
echo "🧪 Verifying installation..."
set dust_verified false
if set -q dust_installed_via_mise
    # Verify via mise
    if mise exec -- dust --version > /dev/null 2>&1
        set dust_verified true
        echo "✅ dust installed successfully via mise"
        mise exec -- dust --version 2>&1
    end
else if command -q dust
    set dust_verified true
    echo "✅ dust installed successfully"
    dust --version 2>&1
end

if not $dust_verified
    echo "❌ dust installation verification failed."
    if set -q dust_installed_via_mise
        echo "💡 dust was installed via mise. Try running: mise reshim"
        echo "💡 Or restart your terminal to ensure mise shims are in PATH."
    else if set -q dust_installed_via_cargo
        echo "💡 dust was installed via cargo. Ensure ~/.cargo/bin is in your PATH."
        echo "💡 Or restart your terminal to apply PATH changes."
    end
    exit 1
end

echo
echo "✅ dust installation complete!"
echo "💡 dust is a modern disk usage analyzer (alternative to du):"
echo "   - Interactive tree view of disk usage"
echo "   - Color-coded output"
echo "   - Faster than traditional du"
echo "   - Shows largest directories first"
echo "   - Easy to navigate and understand"
echo "💡 Basic usage:"
echo "   - dust: Analyze current directory"
echo "   - dust <path>: Analyze specific directory"
echo "   - dust -d <depth>: Limit directory depth"
echo "   - dust -n <number>: Show top N items"
echo "💡 Common commands:"
echo "   # Analyze current directory"
echo "   dust"
echo ""
echo "   # Analyze specific directory"
echo "   dust ~/Downloads"
echo ""
echo "   # Limit depth to 2 levels"
echo "   dust -d 2"
echo ""
echo "   # Show top 10 largest items"
echo "   dust -n 10"
echo ""
echo "   # Analyze root directory (requires sudo)"
echo "   sudo dust /"
echo ""
echo "   # Show hidden files"
echo "   dust -a"
echo "💡 Options:"
echo "   - -d, --depth: Maximum depth to show"
echo "   - -n, --number-of-lines: Number of lines to show"
echo "   - -a, --all: Show hidden files"
echo "   - -r, --reverse: Reverse sort order"
echo "   - -x, --only-dir: Only show directories"
echo "   - -X, --only-file: Only show files"
echo "   - -p, --full-paths: Show full paths"
echo "   - -s, --apparent-size: Show apparent size instead of disk usage"
echo "💡 Navigation:"
echo "   - Use arrow keys to navigate"
echo "   - Press Enter to enter a directory"
echo "   - Press 'q' to quit"
echo "   - Press '?' for help"
echo "💡 Examples:"
echo "   # Find large files in home directory"
echo "   dust -n 20 ~"
echo ""
echo "   # Analyze Downloads folder with depth limit"
echo "   dust -d 3 ~/Downloads"
echo ""
echo "   # Show only directories"
echo "   dust -x /var"
echo ""
echo "   # Full paths for easier copying"
echo "   dust -p ~/Documents"
echo "💡 Comparison with du:"
echo "   - dust: Interactive, visual, faster"
echo "   - du: Traditional, scriptable, standard"
echo "   - Use dust for exploration, du for scripting"
echo "💡 Tips:"
echo "   - Use -n to limit output for large directories"
echo "   - Use -d to focus on specific depth levels"
echo "   - Combine with other tools: dust | grep pattern"
echo "   - Use sudo for system directories: sudo dust /var"
echo "💡 Resources:"
echo "   - GitHub: https://github.com/bootandy/dust"
echo "   - Documentation: https://github.com/bootandy/dust#usage"

