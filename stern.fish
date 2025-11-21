#!/usr/bin/env fish
# === stern.fish ===
# Purpose: Install Stern (Kubernetes log tailing tool) on CachyOS
# Installs Stern via mise (preferred) or falls back to GitHub releases/AUR
# Author: theoneandonlywoj

echo "🚀 Starting Stern installation..."

# === 1. Check if Stern is already installed ===
command -q stern; and set -l stern_installed "installed"
if test -n "$stern_installed"
    echo "✅ Stern is already installed."
    stern --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Stern installation."
        exit 0
    end
    echo "📦 Removing existing Stern installation..."
    # Try to remove via mise first
    if command -v mise > /dev/null
        mise uninstall stern 2>/dev/null
    end
    # Try to remove via pacman
    if pacman -Qq stern > /dev/null 2>&1
        sudo pacman -R --noconfirm stern
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/stern
        sudo rm -f /usr/local/bin/stern
    end
    if test -f ~/.local/bin/stern
        rm -f ~/.local/bin/stern
    end
    echo "✅ Stern removed."
end

# === 2. Check for Mise and prefer mise installation ===
set use_mise false
if command -v mise > /dev/null
    echo "✅ Mise found. Preferring mise installation method."
    set use_mise true
    
    # Load Mise environment in current shell
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
    
    # Check if Stern is available via mise
    echo "🔍 Checking if Stern is available via mise..."
    mise install stern@latest
    if test $status -eq 0
        mise use -g stern@latest
        if test $status -eq 0
            echo "✅ Stern installed successfully via mise"
            set stern_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        else
            echo "⚠ Failed to set Stern as global via mise, but installation succeeded."
            set stern_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        end
    else
        echo "⚠ Stern installation via mise failed. Falling back to other methods..."
        set use_mise false
    end
else
    echo "ℹ Mise not found. Will install via GitHub releases or AUR."
    echo "💡 Tip: Install mise first (./mise.fish) for better version management."
end

# === 3. Fallback: Install via pacman/AUR if mise failed or not available ===
if not set -q stern_installed_via_mise
    echo "📦 Installing Stern via package manager or GitHub releases..."
    
    # Check if available in official repos
    if pacman -Si stern > /dev/null 2>&1
        echo "📦 Installing Stern from official Arch repository..."
        sudo pacman -S --needed --noconfirm stern
        if test $status -ne 0
            echo "❌ Failed to install Stern from official repository."
            exit 1
        end
        echo "✅ Stern installed from official repository."
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
            echo "📦 Installing Stern from AUR using $AUR_HELPER..."
            $AUR_HELPER -S --needed --noconfirm stern-bin
            if test $status -ne 0
                echo "⚠ Failed to install Stern from AUR. Trying GitHub releases..."
                set AUR_HELPER ""
            else
                echo "✅ Stern installed from AUR."
            end
        end
        
        # Fallback to GitHub releases if AUR failed or not available
        if test -z "$AUR_HELPER"
            echo "📥 Installing Stern from GitHub releases..."
            
            # Detect architecture
            set arch (uname -m)
            switch $arch
                case x86_64
                    set STERN_ARCH "amd64"
                case aarch64 arm64
                    set STERN_ARCH "arm64"
                case '*'
                    echo "❌ Unsupported architecture: $arch"
                    exit 1
            end
            
            # Get latest version from GitHub API
            echo "🔍 Fetching latest Stern version..."
            set STERN_VERSION (curl -s https://api.github.com/repos/stern/stern/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
            
            if test -z "$STERN_VERSION"
                echo "⚠ Failed to fetch latest version. Using fallback method..."
                set STERN_VERSION "1.28.0"
            end
            
            echo "📦 Downloading Stern v$STERN_VERSION..."
            set STERN_FILENAME "stern_$STERN_VERSION"_linux_"$STERN_ARCH.tar.gz"
            set STERN_URL "https://github.com/stern/stern/releases/download/v$STERN_VERSION/$STERN_FILENAME"
            set STERN_TMP_DIR (mktemp -d)
            set STERN_TAR "$STERN_TMP_DIR/stern.tar.gz"
            
            curl -L -o $STERN_TAR $STERN_URL
            if test $status -ne 0
                echo "❌ Failed to download Stern from GitHub."
                rm -rf $STERN_TMP_DIR
                exit 1
            end
            
            # Extract and install
            echo "📦 Extracting Stern..."
            cd $STERN_TMP_DIR
            tar -xzf $STERN_TAR
            if test $status -ne 0
                echo "❌ Failed to extract Stern archive."
                rm -rf $STERN_TMP_DIR
                exit 1
            end
            
            # Install binary
            sudo mkdir -p /usr/local/bin
            sudo cp stern /usr/local/bin/stern
            sudo chmod +x /usr/local/bin/stern
            
            # Cleanup
            cd -
            rm -rf $STERN_TMP_DIR
            
            if test $status -eq 0
                echo "✅ Stern installed from GitHub releases."
            else
                echo "❌ Failed to install Stern binary."
                exit 1
            end
        end
    end
end

# === 4. Ensure mise environment is active for verification ===
if set -q stern_installed_via_mise
    # Ensure mise shims are in PATH
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
set stern_verified false
if set -q stern_installed_via_mise
    # Verify via mise
    if mise exec -- stern --version > /dev/null 2>&1
        set stern_verified true
        echo "✅ Stern installed successfully via mise"
        mise exec -- stern --version 2>&1
    end
else if command -q stern
    set stern_verified true
    echo "✅ Stern installed successfully"
    stern --version 2>&1
end

if not $stern_verified
    echo "❌ Stern installation verification failed."
    if set -q stern_installed_via_mise
        echo "💡 Stern was installed via mise. Try running: mise reshim"
        echo "💡 Or restart your terminal to ensure mise shims are in PATH."
    end
    exit 1
end

echo
echo "✅ Stern installation complete!"
echo "💡 Stern is a tool for tailing logs from multiple Kubernetes pods:"
echo "   - Tail logs from multiple pods simultaneously"
echo "   - Filter pods by label selectors"
echo "   - Color-coded output for different pods"
echo "   - Real-time log streaming"
echo "💡 Basic usage:"
echo "   - stern <pod-name-pattern>: Tail logs from matching pods"
echo "   - stern .: Tail logs from all pods in current namespace"
echo "   - stern -n <namespace>: Specify namespace"
echo "   - stern -l app=nginx: Filter by label selector"
echo "💡 Common commands:"
echo "   - stern nginx: Tail logs from all pods with 'nginx' in name"
echo "   - stern -l app=web: Tail logs from pods with label app=web"
echo "   - stern -n production .: Tail all pods in production namespace"
echo "   - stern -l app=api --tail 100: Show last 100 lines"
echo "   - stern -l app=api --since 10m: Show logs from last 10 minutes"
echo "💡 Options:"
echo "   - -n, --namespace: Kubernetes namespace"
echo "   - -l, --selector: Label selector (e.g., app=nginx)"
echo "   - --tail: Number of lines to show from end of logs"
echo "   - --since: Show logs since duration (e.g., 10m, 1h)"
echo "   - --timestamps: Include timestamps in output"
echo "   - --color: Enable/disable color output (auto|always|never)"
echo "   - --context: Kubernetes context to use"
echo "💡 Examples:"
echo "   # Tail all pods in default namespace"
echo "   stern ."
echo ""
echo "   # Tail pods matching 'api' in production namespace"
echo "   stern -n production api"
echo ""
echo "   # Tail pods with specific label"
echo "   stern -l app=backend,env=prod"
echo ""
echo "   # Show last 50 lines from matching pods"
echo "   stern -l app=web --tail 50"
echo ""
echo "   # Tail with timestamps"
echo "   stern -l app=api --timestamps"
echo ""
echo "   # Tail from specific context"
echo "   stern --context my-cluster -l app=nginx"
echo "💡 Tips:"
echo "   - Use label selectors to filter pods efficiently"
echo "   - Combine with kubectl for powerful debugging workflows"
echo "   - Color coding helps distinguish logs from different pods"
echo "   - Use --tail to see recent logs without waiting"
echo "💡 Resources:"
echo "   - GitHub: https://github.com/stern/stern"
echo "   - Documentation: https://github.com/stern/stern#usage"

