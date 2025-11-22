#!/usr/bin/env fish
# === mkcert.fish ===
# Purpose: Install mkcert (local SSL certificates) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting mkcert installation..."
echo
echo "💡 mkcert is a simple tool for making locally-trusted development certificates:"
echo "   - Create SSL certificates for local development"
echo "   - No configuration required"
echo "   - Works with all browsers and tools"
echo "   - Automatically trusted by your system"
echo "   - Perfect for localhost development"
echo

# === 1. Check if mkcert is already installed ===
command -q mkcert; and set -l mkcert_installed "installed"
if test -n "$mkcert_installed"
    echo "✅ mkcert is already installed."
    mkcert -version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping mkcert installation."
        exit 0
    end
    echo "📦 Removing existing mkcert installation..."
    # Try to remove via pacman
    if pacman -Qq mkcert > /dev/null 2>&1
        sudo pacman -R --noconfirm mkcert
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/mkcert
        sudo rm -f /usr/local/bin/mkcert
    end
    if test -f ~/.local/bin/mkcert
        rm -f ~/.local/bin/mkcert
    end
    echo "✅ mkcert removed."
end

# === 2. Install from official repository (preferred) ===
echo "📦 Checking official repository for mkcert..."
if pacman -Si mkcert > /dev/null 2>&1
    echo "📦 Installing mkcert from official Arch repository..."
    sudo pacman -S --needed --noconfirm mkcert
    if test $status -eq 0
        echo "✅ mkcert installed from official repository."
        set mkcert_installed_via_pacman true
    else
        echo "❌ Failed to install mkcert from official repository."
    end
else
    echo "ℹ mkcert not found in official repository."
end

# === 3. Fallback: Install from GitHub releases ===
if not set -q mkcert_installed_via_pacman
    echo "📥 Installing mkcert from GitHub releases..."
    
    # Detect architecture
    set arch (uname -m)
    switch $arch
        case x86_64
            set MKCERT_ARCH "amd64"
        case aarch64 arm64
            set MKCERT_ARCH "arm64"
        case '*'
            echo "❌ Unsupported architecture: $arch"
            exit 1
    end
    
    # Get latest version from GitHub API
    echo "🔍 Fetching latest mkcert version..."
    set MKCERT_VERSION (curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    
    if test -z "$MKCERT_VERSION"
        echo "⚠ Failed to fetch latest version. Using fallback method..."
        set MKCERT_VERSION "1.4.4"
    end
    
    echo "📦 Downloading mkcert v$MKCERT_VERSION..."
    set MKCERT_FILENAME "mkcert-v$MKCERT_VERSION-linux-$MKCERT_ARCH"
    set MKCERT_URL "https://github.com/FiloSottile/mkcert/releases/download/v$MKCERT_VERSION/$MKCERT_FILENAME"
    set MKCERT_TMP_DIR (mktemp -d)
    set MKCERT_BIN "$MKCERT_TMP_DIR/mkcert"
    
    curl -L -o $MKCERT_BIN $MKCERT_URL
    if test $status -ne 0
        echo "❌ Failed to download mkcert from GitHub."
        rm -rf $MKCERT_TMP_DIR
        exit 1
    end
    
    # Make executable and install
    chmod +x $MKCERT_BIN
    sudo mkdir -p /usr/local/bin
    sudo cp $MKCERT_BIN /usr/local/bin/mkcert
    
    # Cleanup
    rm -rf $MKCERT_TMP_DIR
    
    echo "✅ mkcert installed from GitHub releases."
end

# === 4. Install nss (for Firefox support) ===
echo "📦 Installing nss for Firefox support..."
sudo pacman -S --needed --noconfirm nss
if test $status -ne 0
    echo "⚠ Warning: Failed to install nss."
    echo "   mkcert will still work, but Firefox may not trust certificates."
else
    echo "✅ nss installed."
end

# === 5. Install local CA ===
echo
echo "🔐 Installing local CA (Certificate Authority)..."
echo "💡 This will install mkcert's root certificate so browsers trust your local certificates."
read -P "Do you want to install the local CA? [Y/n] " install_ca

if test "$install_ca" != "n" -a "$install_ca" != "N"
    mkcert -install
    if test $status -eq 0
        echo "✅ Local CA installed successfully."
        echo "💡 Your browsers will now trust certificates created by mkcert."
    else
        echo "⚠ Warning: Failed to install local CA."
        echo "   You can run 'mkcert -install' manually later."
    end
else
    echo "ℹ Skipping local CA installation."
    echo "💡 You can install it later with: mkcert -install"
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q mkcert
    echo "✅ mkcert installed successfully"
    mkcert -version 2>&1
else
    echo "❌ mkcert installation verification failed."
    exit 1
end

echo
echo "🎉 mkcert installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Create a certificate for localhost"
echo "   mkcert localhost"
echo ""
echo "   # Create certificate for multiple domains"
echo "   mkcert localhost 127.0.0.1 ::1 example.test"
echo ""
echo "   # Create certificate for wildcard domain"
echo "   mkcert '*.example.test'"
echo ""
echo "   # Create certificate with custom name"
echo "   mkcert -cert-file cert.pem -key-file key.pem example.com"
echo ""
echo "💡 Common use cases:"
echo "   # Local development server"
echo "   mkcert localhost 127.0.0.1"
echo "   # Then use cert.pem and key.pem in your server"
echo ""
echo "   # Multiple local domains"
echo "   mkcert localhost example.test api.example.test"
echo ""
echo "   # Docker/container development"
echo "   mkcert -install"
echo "   mkcert docker.localhost"
echo ""
echo "💡 Server examples:"
echo "   # Node.js/Express"
echo "   const https = require('https');"
echo "   const fs = require('fs');"
echo "   const options = {"
echo "     key: fs.readFileSync('key.pem'),"
echo "     cert: fs.readFileSync('cert.pem')"
echo "   };"
echo "   https.createServer(options, app).listen(443);"
echo ""
echo "   # Python/Flask"
echo "   app.run(ssl_context=('cert.pem', 'key.pem'))"
echo ""
echo "   # Caddy"
echo "   localhost {"
echo "       tls cert.pem key.pem"
echo "   }"
echo ""
echo "   # Nginx"
echo "   ssl_certificate cert.pem;"
echo "   ssl_certificate_key key.pem;"
echo ""
echo "💡 Certificate management:"
echo "   # List installed certificates"
echo "   mkcert -CAROOT"
echo ""
echo "   # Uninstall local CA"
echo "   mkcert -uninstall"
echo ""
echo "   # Show CA location"
echo "   mkcert -CAROOT"
echo ""
echo "💡 Advanced options:"
echo "   -cert-file FILE     Custom certificate file name"
echo "   -key-file FILE      Custom key file name"
echo "   -client             Generate client certificate"
echo "   -ecdsa              Use ECDSA instead of RSA"
echo "   -pkcs12             Generate PKCS#12 bundle"
echo "   -csr FILE           Generate certificate from CSR"
echo ""
echo "💡 Tips:"
echo "   - Certificates are valid for 825 days by default"
echo "   - Works with all browsers (Chrome, Firefox, Safari, Edge)"
echo "   - Works with curl, wget, and other tools"
echo "   - No need to restart browsers after installing CA"
echo "   - Certificates work immediately after creation"
echo ""
echo "💡 Resources:"
echo "   - GitHub: https://github.com/FiloSottile/mkcert"
echo "   - Documentation: https://github.com/FiloSottile/mkcert#readme"

