#!/usr/bin/env fish
# === models.fish ===
# Purpose: Install Models CLI (AI model browser & benchmark explorer) on CachyOS (Arch Linux)
# Installs via cargo (preferred) or GitHub releases
# Author: theoneandonlywoj

echo "🚀 Starting Models CLI installation..."
echo "📌 Models CLI lets you browse 2000+ AI models, benchmarks, and coding agents."
echo

# === 1. Check if Models CLI is already installed ===
if command -v models > /dev/null
    echo "✅ Models CLI is already installed."
    models --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Models CLI installation."
        exit 0
    end
    echo "📦 Removing existing Models CLI installation..."
    if command -v cargo > /dev/null
        cargo uninstall modelsdev 2>/dev/null
    end
    if test -f /usr/local/bin/models
        sudo rm -f /usr/local/bin/models
    end
    if test -f ~/.cargo/bin/models
        rm -f ~/.cargo/bin/models
    end
    echo "✅ Previous Models CLI installation removed."
end

# === 2. Install via cargo (preferred) ===
if command -v cargo > /dev/null
    echo "📦 Installing Models CLI via cargo..."
    cargo install modelsdev
    if test $status -eq 0
        echo "✅ Models CLI installed successfully via cargo."
        # Ensure ~/.cargo/bin is in PATH
        if not contains "$HOME/.cargo/bin" $fish_user_paths
            set -U fish_user_paths $HOME/.cargo/bin $fish_user_paths
            echo "🔧 Added ~/.cargo/bin to Fish PATH."
        end
        set models_installed true
    else
        echo "⚠ cargo install failed. Falling back to GitHub releases..."
    end
else
    echo "ℹ Cargo not found. Will install from GitHub releases."
    echo "💡 Tip: Install Rust and cargo with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
end

# === 3. Fallback: Install from GitHub releases ===
if not set -q models_installed
    echo "📥 Installing Models CLI from GitHub releases..."

    # Detect architecture
    set arch (uname -m)
    switch $arch
        case x86_64
            set MODELS_ARCH "x86_64-unknown-linux-gnu"
        case aarch64 arm64
            set MODELS_ARCH "aarch64-unknown-linux-gnu"
        case '*'
            echo "❌ Unsupported architecture: $arch"
            exit 1
    end

    # Get latest version from GitHub API
    echo "🔍 Fetching latest Models CLI version..."
    set MODELS_VERSION (curl -s https://api.github.com/repos/arimxyer/models/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if test -z "$MODELS_VERSION"
        echo "❌ Failed to fetch latest version. Aborting."
        exit 1
    end

    echo "📦 Downloading Models CLI $MODELS_VERSION..."
    set MODELS_FILENAME "models-$MODELS_ARCH.tar.gz"
    set MODELS_URL "https://github.com/arimxyer/models/releases/download/$MODELS_VERSION/$MODELS_FILENAME"
    set MODELS_TMP_DIR (mktemp -d)

    curl -L -o "$MODELS_TMP_DIR/models.tar.gz" "$MODELS_URL"
    if test $status -ne 0
        echo "❌ Failed to download Models CLI from GitHub."
        rm -rf $MODELS_TMP_DIR
        exit 1
    end

    # Extract and install
    echo "📦 Extracting..."
    tar -xzf "$MODELS_TMP_DIR/models.tar.gz" -C $MODELS_TMP_DIR
    if test $status -ne 0
        echo "❌ Failed to extract archive."
        rm -rf $MODELS_TMP_DIR
        exit 1
    end

    # Find and install the binary
    set MODELS_BIN (find $MODELS_TMP_DIR -name "models" -type f | head -n 1)
    if test -z "$MODELS_BIN"
        echo "❌ Binary not found in archive."
        rm -rf $MODELS_TMP_DIR
        exit 1
    end

    sudo install -m 755 "$MODELS_BIN" /usr/local/bin/models
    if test $status -ne 0
        echo "❌ Failed to install binary."
        rm -rf $MODELS_TMP_DIR
        exit 1
    end

    rm -rf $MODELS_TMP_DIR
    echo "✅ Models CLI installed from GitHub releases."
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -v models > /dev/null
    echo "✅ Models CLI installed successfully:"
    models --version 2>&1 | head -n 1
else
    echo "❌ Models CLI not found in PATH. Installation may have failed."
    exit 1
end

echo
echo "🎉 Models CLI installation complete!"
echo
echo "💡 Usage:"
echo "   models                          → Launch interactive TUI"
echo "   models list providers           → List all providers"
echo "   models list models              → List all models"
echo "   models list models anthropic    → List models from a provider"
echo "   models show claude-opus-4-5-20251101 → Show model details"
echo "   models search \"gpt-4\"           → Search for models"
echo
echo "💡 Agents commands:"
echo "   agents status                   → View release status and versions"
echo "   agents latest                   → Releases from last 24 hours"
echo "   agents list-sources             → Available agents"
echo
echo "📚 Resources:"
echo "   GitHub: https://github.com/arimxyer/models"
