#!/usr/bin/env fish
# === watchman.fish ===
# Purpose: Install Watchman (file watching service) on CachyOS (Arch Linux)
# Installs Watchman via GitHub releases (preferred) or pacman/AUR
# Author: theoneandonlywoj

# === Version configuration ===
set WATCHMAN_VERSION "latest"  # Use "latest" or specific version like "2025.07.28.00"

echo "🚀 Starting Watchman installation..."
echo "📌 Target version: $WATCHMAN_VERSION"
echo
echo "💡 Watchman is a file watching service by Facebook"
echo "   - Efficient file system monitoring"
echo "   - Used by React Native, Jest, and other tools"
echo "   - Supports triggers and subscriptions"
echo "   - High-performance file change detection"
echo "   - Cross-platform support"
echo

# === 1. Check if Watchman is already installed ===
command -q watchman; and set -l watchman_installed "installed"
if test -n "$watchman_installed"
    echo "✅ Watchman is already installed."
    watchman --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Watchman installation."
        exit 0
    end
    echo "📦 Removing existing Watchman installation..."
    # Stop and disable service if running
    if systemctl is-active --quiet watchman 2>/dev/null
        echo "🛑 Stopping Watchman service..."
        sudo systemctl stop watchman
        sudo systemctl disable watchman
    end
    # Try to remove via pacman
    if pacman -Qq watchman > /dev/null 2>&1
        sudo pacman -R --noconfirm watchman
    end
    if pacman -Qq watchman-bin > /dev/null 2>&1
        sudo pacman -R --noconfirm watchman-bin
    end
    # Remove manually installed binaries
    if test -f /usr/local/bin/watchman
        sudo rm -f /usr/local/bin/watchman
    end
    if test -d /usr/local/lib/watchman
        sudo rm -rf /usr/local/lib/watchman
    end
    if test -f ~/.local/bin/watchman
        rm -f ~/.local/bin/watchman
    end
    echo "✅ Watchman removed."
end

# === 2. Install from GitHub releases (primary method) ===
echo "📥 Installing Watchman from GitHub releases..."

# Detect architecture
set arch (uname -m)
switch $arch
    case x86_64
        set WATCHMAN_ARCH "linux"
    case aarch64 arm64
        set WATCHMAN_ARCH "linux-arm64"
    case '*'
        echo "❌ Unsupported architecture: $arch"
        exit 1
end

# Get latest version from GitHub API if needed
if test "$WATCHMAN_VERSION" = "latest"
    echo "🔍 Fetching latest Watchman version..."
    set WATCHMAN_VERSION (curl -s https://api.github.com/repos/facebook/watchman/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    
    if test -z "$WATCHMAN_VERSION"
        echo "⚠ Failed to fetch latest version. Using fallback method..."
        set WATCHMAN_VERSION "2025.07.28.00"
    end
end

echo "📦 Downloading Watchman v$WATCHMAN_VERSION..."
set WATCHMAN_FILENAME "watchman-v$WATCHMAN_VERSION-$WATCHMAN_ARCH.zip"
set WATCHMAN_URL "https://github.com/facebook/watchman/releases/download/v$WATCHMAN_VERSION/$WATCHMAN_FILENAME"
set WATCHMAN_TMP_DIR (mktemp -d)
set WATCHMAN_ZIP "$WATCHMAN_TMP_DIR/watchman.zip"

curl -L -o $WATCHMAN_ZIP $WATCHMAN_URL
if test $status -ne 0
    echo "❌ Failed to download Watchman from GitHub."
    rm -rf $WATCHMAN_TMP_DIR
    set watchman_github_failed true
end

if not set -q watchman_github_failed
    # Extract and install
    echo "📦 Extracting Watchman..."
    cd $WATCHMAN_TMP_DIR
    unzip -q $WATCHMAN_ZIP
    if test $status -ne 0
        echo "❌ Failed to extract Watchman archive."
        echo "💡 Installing unzip if missing..."
        sudo pacman -S --needed --noconfirm unzip
        unzip -q $WATCHMAN_ZIP
        if test $status -ne 0
            rm -rf $WATCHMAN_TMP_DIR
            set watchman_github_failed true
        end
    end
end

if not set -q watchman_github_failed
    # Find the extracted directory
    set -l extracted_dir ""
    for dir in watchman-v* watchman-*
        if test -d $dir
            set extracted_dir $dir
            break
        end
    end
    
    if test -z "$extracted_dir"; or not test -d "$extracted_dir"
        echo "❌ Could not find extracted Watchman directory."
        rm -rf $WATCHMAN_TMP_DIR
        set watchman_github_failed true
    else
        # Install binaries and libraries
        echo "📦 Installing Watchman binaries..."
        sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/var/run/watchman
        
        if test -d "$extracted_dir/bin"
            sudo cp -r $extracted_dir/bin/* /usr/local/bin/
            sudo chmod +x /usr/local/bin/watchman
        else if test -f "$extracted_dir/watchman"
            sudo cp $extracted_dir/watchman /usr/local/bin/
            sudo chmod +x /usr/local/bin/watchman
        else
            echo "❌ Could not find watchman binary in archive."
            rm -rf $WATCHMAN_TMP_DIR
            set watchman_github_failed true
        end
        
        if not set -q watchman_github_failed
            if test -d "$extracted_dir/lib"
                sudo cp -r $extracted_dir/lib/* /usr/local/lib/
            end
            
            # Set permissions for watchman socket directory
            sudo chmod 2777 /usr/local/var/run/watchman
            
            # Cleanup
            cd -
            rm -rf $WATCHMAN_TMP_DIR
            
            if test $status -eq 0
                echo "✅ Watchman installed from GitHub releases."
                set watchman_installed_via_github true
            else
                echo "❌ Failed to install Watchman binary."
                echo "⚠ Falling back to package manager..."
                set watchman_github_failed true
            end
        end
    end
end

# === 3. Fallback: Install via pacman/AUR ===
if set -q watchman_github_failed -o not set -q watchman_installed_via_github
    echo "📦 Installing Watchman via package manager..."
    
    # Check if available in official repos
    if pacman -Si watchman > /dev/null 2>&1
        echo "📦 Installing Watchman from official Arch repository..."
        sudo pacman -S --needed --noconfirm watchman
        if test $status -eq 0
            echo "✅ Watchman installed from official repository."
            set watchman_installed_via_pacman true
        else
            echo "❌ Failed to install Watchman from official repository."
        end
    else
        # Try AUR helper (watchman-bin is the preferred AUR package)
        set AUR_HELPER ""
        for helper in yay paru trizen pikaur
            if command -v $helper > /dev/null
                set AUR_HELPER $helper
                break
            end
        end
        
        if test -n "$AUR_HELPER"
            echo "📦 Installing Watchman from AUR using $AUR_HELPER..."
            # Try watchman-bin first (prebuilt binaries)
            $AUR_HELPER -S --needed --noconfirm watchman-bin
            if test $status -eq 0
                echo "✅ Watchman installed from AUR (watchman-bin)."
                set watchman_installed_via_pacman true
            else
                # Fallback to watchman (source build)
                echo "📦 Trying watchman (source) from AUR..."
                $AUR_HELPER -S --needed --noconfirm watchman
                if test $status -eq 0
                    echo "✅ Watchman installed from AUR (watchman)."
                    set watchman_installed_via_pacman true
                else
                    echo "❌ Failed to install Watchman from AUR."
                end
            end
        else
            echo "❌ No AUR helper found. Please install yay, paru, trizen, or pikaur."
        end
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
set watchman_verified false
if command -q watchman
    set watchman_verified true
    echo "✅ Watchman installed successfully"
    watchman --version 2>&1
end

if not $watchman_verified
    echo "❌ Watchman installation verification failed."
    exit 1
end

# === 5. Setup Watchman service (optional) ===
echo
echo "⚙️  Setting up Watchman..."

# Create watchman state directory
sudo mkdir -p /usr/local/var/run/watchman
sudo chmod 2777 /usr/local/var/run/watchman

# Create systemd service file if not present
if not test -f /etc/systemd/system/watchman.service
    echo "📦 Creating systemd service file..."
    sudo mkdir -p /etc/systemd/system
    printf '[Unit]\nDescription=Watchman file watching service\nDocumentation=https://facebook.github.io/watchman/\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=/usr/local/bin/watchman watch-server\nRestart=on-failure\nRestartSec=5\nUser=root\n\n[Install]\nWantedBy=multi-user.target\n' | sudo tee /etc/systemd/system/watchman.service > /dev/null
    sudo systemctl daemon-reload
    echo "✅ Systemd service file created."
end

# Enable and start service (optional)
echo "💡 Watchman can run as a service or be started on-demand"
echo "   To enable and start Watchman service, run:"
echo "   sudo systemctl enable watchman"
echo "   sudo systemctl start watchman"
echo
read -P "Do you want to enable and start Watchman service now? [y/N] " enable_service

if test "$enable_service" = "y" -o "$enable_service" = "Y"
    sudo systemctl daemon-reload
    sudo systemctl enable watchman
    sudo systemctl start watchman
    if test $status -eq 0
        echo "✅ Watchman service enabled and started."
        echo "💡 Check status with: sudo systemctl status watchman"
    else
        echo "⚠ Failed to start Watchman service. You can start it manually when needed."
    end
end

echo
echo "🎉 Watchman installation complete!"
echo
echo "📚 Installed version: $WATCHMAN_VERSION"
echo
echo "💡 Basic usage:"
echo "   # Start watchman (if not running as service)"
echo "   watchman watch-server &"
echo ""
echo "   # Watch a directory"
echo "   watchman watch /path/to/directory"
echo ""
echo "   # List watched directories"
echo "   watchman watch-list"
echo ""
echo "   # Stop watching a directory"
echo "   watchman watch-del /path/to/directory"
echo ""
echo "   # Get information about a watched directory"
echo "   watchman watch-project /path/to/directory"
echo ""
echo "💡 Common use cases:"
echo "   # React Native development"
echo "   watchman watch ~/my-react-native-app"
echo ""
echo "   # Jest file watching"
echo "   watchman watch ."
echo ""
echo "   # Set up a trigger (run command on file change)"
echo "   watchman -- trigger /path/to/dir build '*.js' -- npm run build"
echo ""
echo "💡 Advanced usage:"
echo "   # Query for file changes"
echo "   watchman find /path/to/dir -name '*.js' -mtime -1"
echo ""
echo "   # Subscribe to file changes"
echo "   watchman -j <<< '[\"subscribe\", \"/path/to/dir\", \"mysub\", {\"expression\": [\"match\", \"*.js\"]}]'"
echo ""
echo "   # Get watchman version and capabilities"
echo "   watchman version"
echo ""
echo "💡 Service management:"
echo "   # Start Watchman service"
echo "   sudo systemctl start watchman"
echo ""
echo "   # Stop Watchman service"
echo "   sudo systemctl stop watchman"
echo ""
echo "   # Restart Watchman service"
echo "   sudo systemctl restart watchman"
echo ""
echo "   # Check status"
echo "   sudo systemctl status watchman"
echo ""
echo "   # View logs"
echo "   sudo journalctl -u watchman -f"
echo ""
echo "💡 Troubleshooting:"
echo "   # Check if watchman is running"
echo "   watchman version"
echo ""
echo "   # Shutdown watchman"
echo "   watchman shutdown-server"
echo ""
echo "   # Clear all watches"
echo "   watchman shutdown-server"
echo "   watchman watch-server"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://facebook.github.io/watchman"
echo "   - Documentation: https://facebook.github.io/watchman/docs"
echo "   - GitHub: https://github.com/facebook/watchman"
