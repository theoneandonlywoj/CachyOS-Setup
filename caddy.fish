#!/usr/bin/env fish
# === caddy.fish ===
# Purpose: Install Caddy (web server with automatic HTTPS) on CachyOS (Arch Linux)
# Installs Caddy via GitHub releases (preferred) or pacman/AUR
# Author: theoneandonlywoj

# === Version configuration ===
set CADDY_VERSION "latest"  # Use "latest" or specific version like "2.7.6"

echo "🚀 Starting Caddy installation..."
echo "📌 Target version: $CADDY_VERSION"
echo
echo "💡 Caddy is a powerful web server with automatic HTTPS"
echo "   - Automatic HTTPS with Let's Encrypt"
echo "   - HTTP/2 and HTTP/3 support"
echo "   - Reverse proxy capabilities"
echo "   - Load balancing"
echo "   - Easy configuration with Caddyfile"
echo

# === 1. Check if Caddy is already installed ===
command -q caddy; and set -l caddy_installed "installed"
if test -n "$caddy_installed"
    echo "✅ Caddy is already installed."
    caddy version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Caddy installation."
        exit 0
    end
    echo "📦 Removing existing Caddy installation..."
    # Stop and disable service if running
    if systemctl is-active --quiet caddy 2>/dev/null
        echo "🛑 Stopping Caddy service..."
        sudo systemctl stop caddy
        sudo systemctl disable caddy
    end
    # Try to remove via pacman
    if pacman -Qq caddy > /dev/null 2>&1
        sudo pacman -R --noconfirm caddy
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/caddy
        sudo rm -f /usr/local/bin/caddy
    end
    if test -f ~/.local/bin/caddy
        rm -f ~/.local/bin/caddy
    end
    echo "✅ Caddy removed."
end

# === 2. Install from GitHub releases (primary method) ===
echo "📥 Installing Caddy from GitHub releases..."

# Detect architecture
set arch (uname -m)
switch $arch
    case x86_64
        set CADDY_ARCH "amd64"
    case aarch64 arm64
        set CADDY_ARCH "arm64"
    case '*'
        echo "❌ Unsupported architecture: $arch"
        exit 1
end

# Get latest version from GitHub API if needed
if test "$CADDY_VERSION" = "latest"
    echo "🔍 Fetching latest Caddy version..."
    set CADDY_VERSION (curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    
    if test -z "$CADDY_VERSION"
        echo "⚠ Failed to fetch latest version. Using fallback method..."
        set CADDY_VERSION "2.7.6"
    end
end

echo "📦 Downloading Caddy v$CADDY_VERSION..."
set CADDY_FILENAME "caddy_$CADDY_VERSION""_linux_$CADDY_ARCH.tar.gz"
set CADDY_URL "https://github.com/caddyserver/caddy/releases/download/v$CADDY_VERSION/$CADDY_FILENAME"
set CADDY_TMP_DIR (mktemp -d)
set CADDY_TAR "$CADDY_TMP_DIR/caddy.tar.gz"

curl -L -o $CADDY_TAR $CADDY_URL
if test $status -ne 0
    echo "❌ Failed to download Caddy from GitHub."
    rm -rf $CADDY_TMP_DIR
    set caddy_github_failed true
end

if not set -q caddy_github_failed
    # Extract and install
    echo "📦 Extracting Caddy..."
    cd $CADDY_TMP_DIR
    tar -xzf $CADDY_TAR
    if test $status -ne 0
        echo "❌ Failed to extract Caddy archive."
        rm -rf $CADDY_TMP_DIR
        set caddy_github_failed true
    end
end

if not set -q caddy_github_failed
    # Install binary
    sudo mkdir -p /usr/local/bin
    sudo cp caddy /usr/local/bin/caddy
    sudo chmod +x /usr/local/bin/caddy
    
    # Install systemd service file if not present
    if not test -f /etc/systemd/system/caddy.service
        echo "📦 Installing systemd service file..."
        sudo mkdir -p /etc/systemd/system
        printf '[Unit]\nDescription=Caddy\nDocumentation=https://caddyserver.com/docs/\nAfter=network.target network-online.target\nRequires=network-online.target\n\n[Service]\nType=notify\nUser=caddy\nGroup=caddy\nExecStart=/usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile\nExecReload=/usr/local/bin/caddy reload --config /etc/caddy/Caddyfile --force\nTimeoutStopSec=5s\nLimitNOFILE=1048576\nLimitNPROC=512\nPrivateTmp=true\nProtectSystem=full\nAmbientCapabilities=CAP_NET_BIND_SERVICE\n\n[Install]\nWantedBy=multi-user.target\n' | sudo tee /etc/systemd/system/caddy.service > /dev/null
        sudo systemctl daemon-reload
    end
    
    # Create caddy user if it doesn't exist
    if not id caddy > /dev/null 2>&1
        echo "👤 Creating caddy user..."
        sudo useradd -r -s /usr/bin/nologin -d /var/lib/caddy -m caddy
    end
    
    # Create configuration directory
    sudo mkdir -p /etc/caddy
    sudo mkdir -p /var/www/html
    sudo chown -R caddy:caddy /var/www/html
    
    # Cleanup
    cd -
    rm -rf $CADDY_TMP_DIR
    
    if test $status -eq 0
        echo "✅ Caddy installed from GitHub releases."
        set caddy_installed_via_github true
    else
        echo "❌ Failed to install Caddy binary."
        echo "⚠ Falling back to package manager..."
        set caddy_github_failed true
    end
end

# === 3. Fallback: Install via pacman/AUR ===
if set -q caddy_github_failed -o not set -q caddy_installed_via_github
    echo "📦 Installing Caddy via package manager..."
    
    # Check if available in official repos
    if pacman -Si caddy > /dev/null 2>&1
        echo "📦 Installing Caddy from official Arch repository..."
        sudo pacman -S --needed --noconfirm caddy
        if test $status -eq 0
            echo "✅ Caddy installed from official repository."
            set caddy_installed_via_pacman true
        else
            echo "❌ Failed to install Caddy from official repository."
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
            echo "📦 Installing Caddy from AUR using $AUR_HELPER..."
            $AUR_HELPER -S --needed --noconfirm caddy
            if test $status -eq 0
                echo "✅ Caddy installed from AUR."
                set caddy_installed_via_pacman true
            else
                echo "❌ Failed to install Caddy from AUR."
            end
        else
            echo "❌ No AUR helper found. Please install yay, paru, trizen, or pikaur."
        end
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
set caddy_verified false
if command -q caddy
    set caddy_verified true
    echo "✅ Caddy installed successfully"
    caddy version 2>&1
end

if not $caddy_verified
    echo "❌ Caddy installation verification failed."
    exit 1
end

# === 5. Setup systemd service ===
echo
echo "⚙️  Setting up Caddy service..."

# Create default Caddyfile if it doesn't exist
if not test -f /etc/caddy/Caddyfile
    echo "📝 Creating default Caddyfile..."
    sudo mkdir -p /etc/caddy
    printf '# Default Caddyfile\n# Replace with your domain and configuration\n\n:80 {\n    respond "Hello, World!"\n}\n' | sudo tee /etc/caddy/Caddyfile > /dev/null
    echo "✅ Default Caddyfile created at /etc/caddy/Caddyfile"
end

# Enable and start service (optional)
echo "💡 To enable and start Caddy service, run:"
echo "   sudo systemctl enable caddy"
echo "   sudo systemctl start caddy"
echo
read -P "Do you want to enable and start Caddy service now? [y/N] " enable_service

if test "$enable_service" = "y" -o "$enable_service" = "Y"
    sudo systemctl daemon-reload
    sudo systemctl enable caddy
    sudo systemctl start caddy
    if test $status -eq 0
        echo "✅ Caddy service enabled and started."
        echo "💡 Check status with: sudo systemctl status caddy"
    else
        echo "⚠ Failed to start Caddy service. Check configuration."
    end
end

echo
echo "🎉 Caddy installation complete!"
echo
echo "📚 Installed version: $CADDY_VERSION"
echo
echo "💡 Basic usage:"
echo "   # Run Caddy in foreground (for testing)"
echo "   caddy run"
echo ""
echo "   # Run with specific Caddyfile"
echo "   caddy run --config /path/to/Caddyfile"
echo ""
echo "   # Validate Caddyfile"
echo "   caddy validate --config /etc/caddy/Caddyfile"
echo ""
echo "   # Reload configuration (if running as service)"
echo "   sudo systemctl reload caddy"
echo ""
echo "💡 Service management:"
echo "   # Start Caddy service"
echo "   sudo systemctl start caddy"
echo ""
echo "   # Stop Caddy service"
echo "   sudo systemctl stop caddy"
echo ""
echo "   # Restart Caddy service"
echo "   sudo systemctl restart caddy"
echo ""
echo "   # Check status"
echo "   sudo systemctl status caddy"
echo ""
echo "   # View logs"
echo "   sudo journalctl -u caddy -f"
echo ""
echo "💡 Configuration:"
echo "   # Main config file: /etc/caddy/Caddyfile"
echo "   # Example Caddyfile:"
echo "   example.com {"
echo "       root * /var/www/html"
echo "       file_server"
echo "   }"
echo ""
echo "💡 Common use cases:"
echo "   # Static file server"
echo "   example.com {"
echo "       root * /var/www/html"
echo "       file_server"
echo "   }"
echo ""
echo "   # Reverse proxy"
echo "   example.com {"
echo "       reverse_proxy localhost:8080"
echo "   }"
echo ""
echo "   # Multiple sites"
echo "   example.com {"
echo "       root * /var/www/example"
echo "       file_server"
echo "   }"
echo "   "
echo "   subdomain.example.com {"
echo "       reverse_proxy localhost:3000"
echo "   }"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://caddyserver.com"
echo "   - Documentation: https://caddyserver.com/docs"
echo "   - Caddyfile syntax: https://caddyserver.com/docs/caddyfile"
echo "   - GitHub: https://github.com/caddyserver/caddy"

