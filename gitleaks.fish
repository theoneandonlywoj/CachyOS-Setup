#!/usr/bin/env fish
# === gitleaks.fish ===
# Purpose: Install gitleaks (secret detection tool) on CachyOS (Arch Linux)
# Installs gitleaks via Mise (preferred), GitHub releases, AUR, or Go
# Author: theoneandonlywoj

# === Version configuration ===
set GITLEAKS_VERSION "latest"  # Use "latest" or specific version like "8.18.0"

echo "🚀 Starting gitleaks installation..."
echo "📌 Target version: $GITLEAKS_VERSION"
echo
echo "💡 gitleaks is a tool for detecting hardcoded secrets in git repositories"
echo "   - Detects passwords, API keys, tokens, and other secrets"
echo "   - Scans git repositories and history"
echo "   - Supports multiple output formats"
echo "   - CI/CD integration ready"
echo

# === 1. Check if gitleaks is already installed ===
command -q gitleaks; and set -l gitleaks_installed "installed"
if test -n "$gitleaks_installed"
    echo "✅ gitleaks is already installed."
    gitleaks version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping gitleaks installation."
        exit 0
    end
    echo "📦 Removing existing gitleaks installation..."
    # Try to remove via mise first
    if command -v mise > /dev/null
        mise uninstall gitleaks 2>/dev/null
    end
    # Try to remove via pacman
    if pacman -Qq gitleaks > /dev/null 2>&1
        sudo pacman -R --noconfirm gitleaks
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/gitleaks
        sudo rm -f /usr/local/bin/gitleaks
    end
    if test -f ~/.local/bin/gitleaks
        rm -f ~/.local/bin/gitleaks
    end
    echo "✅ gitleaks removed."
end

# === 2. Check for Mise and prefer mise installation ===
set use_mise false
if command -v mise > /dev/null
    echo "✅ Mise found. Preferring mise installation method."
    set use_mise true
    
    # Load Mise environment in current shell
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
    
    # Check if gitleaks is available via mise
    echo "🔍 Checking if gitleaks is available via mise..."
    if test "$GITLEAKS_VERSION" = "latest"
        mise install gitleaks@latest
    else
        mise install gitleaks@$GITLEAKS_VERSION
    end
    
    if test $status -eq 0
        if test "$GITLEAKS_VERSION" = "latest"
            mise use -g gitleaks@latest
        else
            mise use -g gitleaks@$GITLEAKS_VERSION
        end
        
        if test $status -eq 0
            echo "✅ gitleaks installed successfully via mise"
            set gitleaks_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        else
            echo "⚠ Failed to set gitleaks as global via mise, but installation succeeded."
            set gitleaks_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        end
    else
        echo "⚠ gitleaks installation via mise failed. Falling back to other methods..."
        set use_mise false
    end
else
    echo "ℹ Mise not found. Will install via GitHub releases, AUR, or Go."
    echo "💡 Tip: Install mise first (./mise.fish) for better version management."
end

# === 3. Fallback: Install via pacman/AUR ===
if not set -q gitleaks_installed_via_mise
    echo "📦 Installing gitleaks via package manager..."
    
    # Check if available in official repos
    if pacman -Si gitleaks > /dev/null 2>&1
        echo "📦 Installing gitleaks from official Arch repository..."
        sudo pacman -S --needed --noconfirm gitleaks
        if test $status -eq 0
            echo "✅ gitleaks installed from official repository."
            set gitleaks_installed_via_pacman true
        else
            echo "❌ Failed to install gitleaks from official repository."
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
            echo "📦 Installing gitleaks from AUR using $AUR_HELPER..."
            $AUR_HELPER -S --needed --noconfirm gitleaks
            if test $status -eq 0
                echo "✅ gitleaks installed from AUR."
                set gitleaks_installed_via_pacman true
            else
                echo "⚠ Failed to install gitleaks from AUR."
            end
        end
    end
end

# === 4. Fallback: Install from GitHub releases ===
if not set -q gitleaks_installed_via_mise -a not set -q gitleaks_installed_via_pacman
    echo "📥 Installing gitleaks from GitHub releases..."
    
    # Detect architecture
    set arch (uname -m)
    switch $arch
        case x86_64
            set GITLEAKS_ARCH "x64"
        case aarch64 arm64
            set GITLEAKS_ARCH "arm64"
        case '*'
            echo "❌ Unsupported architecture: $arch"
            exit 1
    end
    
    # Get latest version from GitHub API if needed
    if test "$GITLEAKS_VERSION" = "latest"
        echo "🔍 Fetching latest gitleaks version..."
        set GITLEAKS_VERSION (curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
        
        if test -z "$GITLEAKS_VERSION"
            echo "⚠ Failed to fetch latest version. Using fallback method..."
            set GITLEAKS_VERSION "8.18.0"
        end
    end
    
    echo "📦 Downloading gitleaks v$GITLEAKS_VERSION..."
    set GITLEAKS_FILENAME "gitleaks_$GITLEAKS_VERSION""_linux_$GITLEAKS_ARCH.tar.gz"
    set GITLEAKS_URL "https://github.com/gitleaks/gitleaks/releases/download/v$GITLEAKS_VERSION/$GITLEAKS_FILENAME"
    set GITLEAKS_TMP_DIR (mktemp -d)
    set GITLEAKS_TAR "$GITLEAKS_TMP_DIR/gitleaks.tar.gz"
    
    curl -L -o $GITLEAKS_TAR $GITLEAKS_URL
    if test $status -ne 0
        echo "❌ Failed to download gitleaks from GitHub."
        rm -rf $GITLEAKS_TMP_DIR
        exit 1
    end
    
    # Extract and install
    echo "📦 Extracting gitleaks..."
    cd $GITLEAKS_TMP_DIR
    tar -xzf $GITLEAKS_TAR
    if test $status -ne 0
        echo "❌ Failed to extract gitleaks archive."
        rm -rf $GITLEAKS_TMP_DIR
        exit 1
    end
    
    # Install binary
    sudo mkdir -p /usr/local/bin
    sudo cp gitleaks /usr/local/bin/gitleaks
    sudo chmod +x /usr/local/bin/gitleaks
    
    # Cleanup
    cd -
    rm -rf $GITLEAKS_TMP_DIR
    
    if test $status -eq 0
        echo "✅ gitleaks installed from GitHub releases."
        set gitleaks_installed_via_github true
    else
        echo "❌ Failed to install gitleaks binary."
        exit 1
    end
end

# === 5. Ensure mise environment is active for verification ===
if set -q gitleaks_installed_via_mise
    # Ensure mise shims are in PATH
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
set gitleaks_verified false
if set -q gitleaks_installed_via_mise
    # Verify via mise
    if mise exec -- gitleaks version > /dev/null 2>&1
        set gitleaks_verified true
        echo "✅ gitleaks installed successfully via mise"
        mise exec -- gitleaks version 2>&1
    end
else if command -q gitleaks
    set gitleaks_verified true
    echo "✅ gitleaks installed successfully"
    gitleaks version 2>&1
end

if not $gitleaks_verified
    echo "❌ gitleaks installation verification failed."
    if set -q gitleaks_installed_via_mise
        echo "💡 gitleaks was installed via mise. Try running: mise reshim"
        echo "💡 Or restart your terminal to ensure mise shims are in PATH."
    end
    exit 1
end

# === 7. Add automatic activation to Fish config if using mise ===
if set -q gitleaks_installed_via_mise
    set fish_config_file ~/.config/fish/config.fish
    set activation_line "mise activate fish | source"

    if not grep -Fxq "$activation_line" $fish_config_file
        echo "$activation_line" >> $fish_config_file
        echo "🔧 Added automatic Mise activation to $fish_config_file"
    end
end

echo
echo "🎉 gitleaks installation complete!"
echo
echo "💡 Important:"
if set -q gitleaks_installed_via_mise
    echo "   To use 'gitleaks' in this terminal immediately,"
    echo "   run the following command in your current shell:"
    echo "       mise activate fish | source"
    echo "   In future terminals, this will happen automatically thanks to the config file update."
end
echo
echo "📚 Installed version: $GITLEAKS_VERSION"
echo
echo "💡 Basic usage:"
echo "   # Scan current repository"
echo "   gitleaks detect --no-banner"
echo ""
echo "   # Scan specific path"
echo "   gitleaks detect --path /path/to/repo --no-banner"
echo ""
echo "   # Scan with verbose output"
echo "   gitleaks detect --verbose --no-banner"
echo ""
echo "   # Generate configuration file"
echo "   gitleaks generate config > .gitleaks.toml"
echo ""
echo "   # Scan with custom config"
echo "   gitleaks detect --config .gitleaks.toml --no-banner"
echo ""
echo "💡 Common commands:"
echo "   # Detect secrets in current directory"
echo "   gitleaks detect --no-banner"
echo ""
echo "   # Detect secrets and output to file"
echo "   gitleaks detect --report-path report.json --no-banner"
echo ""
echo "   # Detect secrets with specific format"
echo "   gitleaks detect --format json --no-banner"
echo ""
echo "   # Scan git history"
echo "   gitleaks detect --log-opts=\"--all\" --no-banner"
echo ""
echo "💡 CI/CD Integration:"
echo "   # Exit with non-zero code if secrets found"
echo "   gitleaks detect --exit-code 1 --no-banner"
echo ""
echo "   # Example GitHub Actions step:"
echo "   - name: Run gitleaks"
echo "     uses: gitleaks/gitleaks-action@v2"
echo ""
echo "💡 Resources:"
echo "   - GitHub: https://github.com/gitleaks/gitleaks"
echo "   - Documentation: https://github.com/gitleaks/gitleaks#usage"
echo "   - Configuration: https://github.com/gitleaks/gitleaks#configuration"

