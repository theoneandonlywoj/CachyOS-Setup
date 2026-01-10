#!/usr/bin/env fish
# === tidewave.fish ===
# Purpose: Install Tidewave CLI (coding agent for full-stack web development) on CachyOS
# Installs Tidewave CLI from official releases
# Reference: https://hexdocs.pm/tidewave/installation.html#cli
# Author: theoneandonlywoj

echo "🚀 Starting Tidewave CLI installation..."

echo "💡 Tidewave is a coding agent for full-stack web app development:"
echo "   - Integrates Claude Code, OpenAI Codex, and other agents"
echo "   - Works with web frameworks (Django, FastAPI, Flask, Next.js, Phoenix, Rails, etc.)"
echo "   - Provides file system monitoring and development tools"
echo "   - Runs on http://localhost:9832 by default"

# === 1. Check if Tidewave CLI is already installed ===
command -q tidewave; and set -l tidewave_installed "installed"
if test -n "$tidewave_installed"
    echo "✅ Tidewave CLI is already installed."
    ./tidewave --version 2>&1 | head -n 1 2>/dev/null; or tidewave --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Tidewave CLI installation."
        exit 0
    end
    echo "📦 Removing existing Tidewave CLI installation..."
    # Remove manually installed binary
    if test -f /usr/local/bin/tidewave
        sudo rm -f /usr/local/bin/tidewave
    end
    if test -f ~/.local/bin/tidewave
        rm -f ~/.local/bin/tidewave
    end
    if test -f ./tidewave
        rm -f ./tidewave
    end
    echo "✅ Tidewave CLI removed."
end

# === 2. Detect architecture and select variant ===
echo "🔍 Detecting system architecture..."
set arch (uname -m)
set libc_variant "gnu"  # CachyOS uses glibc, so default to gnu

switch $arch
    case x86_64
        set TIDEWAVE_ARCH "x86_64-gnu"
    case aarch64 arm64
        set TIDEWAVE_ARCH "aarch64-gnu"
    case '*'
        echo "❌ Unsupported architecture: $arch"
        echo "💡 Supported architectures: x86_64, aarch64"
        exit 1
end

echo "📌 Detected architecture: $arch"
echo "📌 Using variant: $TIDEWAVE_ARCH (gnu for glibc-based systems)"

# === 3. Download Tidewave CLI ===
echo "📥 Downloading Tidewave CLI..."

# Try to find the download URL from Tidewave releases
# The CLI is available from their releases page
set TIDEWAVE_TMP_DIR (mktemp -d)
set TIDEWAVE_BIN "$TIDEWAVE_TMP_DIR/tidewave"
set tidewave_downloaded false

# Try to get latest version and assets from GitHub API
# The CLI is available from tidewave-ai/tidewave_app repository
echo "🔍 Fetching latest Tidewave CLI version and assets..."
set TIDEWAVE_VERSION ""
set TIDEWAVE_ASSET_URL ""

set api_response (curl -s "https://api.github.com/repos/tidewave-ai/tidewave_app/releases/latest" 2>/dev/null)
if test -n "$api_response"
    set TIDEWAVE_VERSION (echo $api_response | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    if test -n "$TIDEWAVE_VERSION"
        echo "✅ Found version $TIDEWAVE_VERSION from tidewave-ai/tidewave_app"
        # Try to find matching asset URL from the API response
        # Look for assets that match our architecture
        # The naming pattern is: tidewave-cli-{arch}-unknown-linux-{libc}
        set asset_urls (echo $api_response | grep -o '"browser_download_url":"[^"]*"' | sed 's/"browser_download_url":"//' | sed 's/"//')
        for asset_url in $asset_urls
            # Check if URL contains our architecture pattern
            # For x86_64-gnu, look for x86_64-unknown-linux-gnu
            # For aarch64-gnu, look for aarch64-unknown-linux-gnu
            if string match -q "*tidewave-cli-*unknown-linux-*" $asset_url
                if test "$TIDEWAVE_ARCH" = "x86_64-gnu"
                    if string match -q "*x86_64-unknown-linux-gnu*" $asset_url
                        set TIDEWAVE_ASSET_URL $asset_url
                        echo "✅ Found matching asset: $TIDEWAVE_ASSET_URL"
                        break
                    end
                else if test "$TIDEWAVE_ARCH" = "x86_64-musl"
                    if string match -q "*x86_64-unknown-linux-musl*" $asset_url
                        set TIDEWAVE_ASSET_URL $asset_url
                        echo "✅ Found matching asset: $TIDEWAVE_ASSET_URL"
                        break
                    end
                else if test "$TIDEWAVE_ARCH" = "aarch64-gnu"
                    if string match -q "*aarch64-unknown-linux-gnu*" $asset_url
                        set TIDEWAVE_ASSET_URL $asset_url
                        echo "✅ Found matching asset: $TIDEWAVE_ASSET_URL"
                        break
                    end
                else if test "$TIDEWAVE_ARCH" = "aarch64-musl"
                    if string match -q "*aarch64-unknown-linux-musl*" $asset_url
                        set TIDEWAVE_ASSET_URL $asset_url
                        echo "✅ Found matching asset: $TIDEWAVE_ASSET_URL"
                        break
                    end
                end
            end
        end
    end
end

if test -z "$TIDEWAVE_VERSION"
    echo "⚠ Could not fetch version from GitHub API, trying direct download..."
end

# Try multiple download URL patterns
set download_urls

# Pattern 0: Use asset URL from API if found (most reliable)
if test -n "$TIDEWAVE_ASSET_URL"
    set download_urls $download_urls $TIDEWAVE_ASSET_URL
end

# Pattern 1: Construct URL based on architecture
# The correct naming pattern is: tidewave-cli-{arch}-unknown-linux-{libc}
switch $TIDEWAVE_ARCH
    case x86_64-gnu
        set CLI_NAME "tidewave-cli-x86_64-unknown-linux-gnu"
    case x86_64-musl
        set CLI_NAME "tidewave-cli-x86_64-unknown-linux-musl"
    case aarch64-gnu
        set CLI_NAME "tidewave-cli-aarch64-unknown-linux-gnu"
    case aarch64-musl
        set CLI_NAME "tidewave-cli-aarch64-unknown-linux-musl"
end

# Pattern 2: Latest release redirects (most reliable fallback)
set download_urls $download_urls "https://github.com/tidewave-ai/tidewave_app/releases/latest/download/$CLI_NAME"

# Pattern 3: With version tag if available
if test -n "$TIDEWAVE_VERSION"
    set download_urls $download_urls "https://github.com/tidewave-ai/tidewave_app/releases/download/$TIDEWAVE_VERSION/$CLI_NAME"
    set download_urls $download_urls "https://github.com/tidewave-ai/tidewave_app/releases/download/v$TIDEWAVE_VERSION/$CLI_NAME"
end

# Try each URL pattern
set url_count (count $download_urls)
set url_index 0
for url in $download_urls
    set url_index (math "$url_index + 1")
    # Only show every 5th attempt or first/last to reduce noise
    if test $url_index -eq 1 -o $url_index -eq $url_count -o (math "$url_index % 5") -eq 0
        echo "🔍 Trying URL $url_index/$url_count: $url"
    end
    
    # Check if it's a tar.gz archive
    if string match -q "*.tar.gz" $url
        set TIDEWAVE_TAR "$TIDEWAVE_TMP_DIR/tidewave.tar.gz"
        curl -L -f -o $TIDEWAVE_TAR $url 2>/dev/null
        if test $status -eq 0
            echo "✅ Downloaded archive, extracting..."
            cd $TIDEWAVE_TMP_DIR
            tar -xzf $TIDEWAVE_TAR 2>/dev/null
            if test $status -eq 0
                # Find the tidewave binary
                set found_bin (find . -name "tidewave" -type f | head -n1)
                if test -n "$found_bin" -a -f "$found_bin"
                    cp $found_bin $TIDEWAVE_BIN
                    chmod +x $TIDEWAVE_BIN
                    set tidewave_downloaded true
                    cd -
                    break
                end
            end
            cd -
        end
    else
        # Direct binary download
        curl -L -f -o $TIDEWAVE_BIN $url 2>/dev/null
        if test $status -eq 0
            chmod +x $TIDEWAVE_BIN
            # Verify it's actually a binary (not HTML error page)
            if file $TIDEWAVE_BIN | grep -q "ELF\|executable" 2>/dev/null; or test -x $TIDEWAVE_BIN
                set tidewave_downloaded true
                break
            end
        end
    end
end

if not $tidewave_downloaded
    echo "❌ Failed to download Tidewave CLI from all attempted sources."
    echo "💡 Please download manually from: https://hexdocs.pm/tidewave/installation.html#cli"
    echo "💡 Available variants for Linux:"
    echo "   - x86_64-gnu"
    echo "   - x86_64-musl"
    echo "   - aarch64-gnu"
    echo "   - aarch64-musl"
    echo ""
    echo "💡 You can also check the GitHub releases page for the correct download URL."
    rm -rf $TIDEWAVE_TMP_DIR
    exit 1
end

# === 4. Verify downloaded binary ===
echo "🧪 Verifying downloaded binary..."
if test -f $TIDEWAVE_BIN -a -x $TIDEWAVE_BIN
    echo "✅ Binary downloaded and is executable"
    # Try to get version
    $TIDEWAVE_BIN --version > /dev/null 2>&1
    if test $status -eq 0
        echo "📌 Version information:"
        $TIDEWAVE_BIN --version 2>&1 | head -n 1
    end
else
    echo "❌ Downloaded binary is not executable or missing."
    rm -rf $TIDEWAVE_TMP_DIR
    exit 1
end

# === 5. Install binary ===
echo "📦 Installing Tidewave CLI..."

# Ask where to install
read -P "Install to /usr/local/bin (system-wide, requires sudo) or ~/.local/bin (user-only)? [S/u] " install_location

if test "$install_location" = "u" -o "$install_location" = "U"
    set INSTALL_DIR ~/.local/bin
    mkdir -p $INSTALL_DIR
    cp $TIDEWAVE_BIN $INSTALL_DIR/tidewave
    chmod +x $INSTALL_DIR/tidewave
    
    # Check if ~/.local/bin is in PATH
    if not string match -q "*$HOME/.local/bin*" $PATH
        echo "⚠ ~/.local/bin is not in your PATH."
        echo "💡 Add this to your ~/.config/fish/config.fish:"
        echo "   set -gx PATH ~/.local/bin \$PATH"
        read -P "Do you want to add it now? [y/N] " add_to_path
        if test "$add_to_path" = "y" -o "$add_to_path" = "Y"
            echo "set -gx PATH ~/.local/bin \$PATH" >> ~/.config/fish/config.fish
            set -gx PATH ~/.local/bin $PATH
            echo "✅ Added ~/.local/bin to PATH"
        end
    end
    
    set TIDEWAVE_PATH "$INSTALL_DIR/tidewave"
else
    set INSTALL_DIR /usr/local/bin
    sudo mkdir -p $INSTALL_DIR
    sudo cp $TIDEWAVE_BIN $INSTALL_DIR/tidewave
    sudo chmod +x $INSTALL_DIR/tidewave
    set TIDEWAVE_PATH "$INSTALL_DIR/tidewave"
end

# Cleanup
rm -rf $TIDEWAVE_TMP_DIR

if test $status -eq 0
    echo "✅ Tidewave CLI installed to $INSTALL_DIR"
else
    echo "❌ Failed to install Tidewave CLI binary."
    exit 1
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q tidewave
if test $status -eq 0
    echo "✅ Tidewave CLI installed successfully"
    echo "📌 Installation path: $TIDEWAVE_PATH"
    echo "📌 Version information:"
    tidewave --version 2>&1 | head -n 1
else
    echo "⚠ Tidewave CLI command not found in PATH."
    echo "💡 Try running: $TIDEWAVE_PATH --help"
    echo "💡 Or add the installation directory to your PATH"
end

echo
echo "✅ Tidewave CLI installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Run Tidewave CLI (starts service on http://localhost:9832)"
echo "   tidewave"
echo ""
echo "   # Or if installed to custom location:"
echo "   $TIDEWAVE_PATH"
echo ""
echo "   # View help"
echo "   tidewave --help"
echo ""
echo "💡 Configuration:"
echo "   # By default, Tidewave runs on http://localhost:9832"
echo "   # Access it from your browser to configure your web application"
echo ""
echo "   # For remote access (not recommended for security):"
echo "   tidewave --allow-remote-access --allowed-origins=https://your-hostname:port"
echo ""
echo "💡 Security notes:"
echo "   - CLI only allows access from localhost/127.0.0.1 by default"
echo "   - For remote servers, use --allow-remote-access flag"
echo "   - You can enable HTTPS certificates for both App and CLI"
echo ""
echo "💡 Supported frameworks:"
echo "   - Django (Python)"
echo "   - FastAPI (Python)"
echo "   - Flask (Python)"
echo "   - Next.js (JavaScript/TypeScript)"
echo "   - Phoenix (Elixir)"
echo "   - Ruby on Rails (Ruby)"
echo "   - TanStack Start"
echo "   - Vite"
echo ""
echo "💡 Resources:"
echo "   - Documentation: https://hexdocs.pm/tidewave/installation.html#cli"
echo "   - Website: https://tidewave.ai"
echo "   - Framework guides available in documentation"
