#!/usr/bin/env fish
# === openclaw-cli.fish ===
# Purpose: Install OpenClaw on CachyOS
# Installs OpenClaw via official installer (https://openclaw.ai/install.sh)
# Author: theoneandonlywoj

echo "🚀 Starting OpenClaw installation..."

# === 1. Check if OpenClaw is already installed ===
command -q openclaw; and set -l openclaw_installed "installed"
if test -n "$openclaw_installed"
    echo "✅ OpenClaw is already installed."
    openclaw --version 2>/dev/null | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping OpenClaw installation."
        exit 0
    end
    echo "📦 Removing existing OpenClaw installation..."
    rm -f "$HOME/.local/bin/openclaw"
    rm -rf "$HOME/.local/share/openclaw"
    if test $status -ne 0
        echo "❌ Failed to remove OpenClaw."
        exit 1
    end
    echo "✅ OpenClaw removed."
end

# === 2. Ensure ~/.local/bin exists (installer target) ===
echo "📁 Ensuring install directory exists..."
mkdir -p "$HOME/.local/bin"
if test $status -ne 0
    echo "❌ Failed to create ~/.local/bin."
    exit 1
end

# === 3. Install OpenClaw (official installer) ===
echo "📦 Installing OpenClaw..."
curl -fsSL https://openclaw.ai/install.sh | bash
if test $status -ne 0
    echo "❌ Failed to install OpenClaw."
    exit 1
end
echo "✅ OpenClaw installed."

# === 4. Ensure ~/.local/bin is in PATH for this session ===
set -q PATH; or set PATH ""
if not string match -q "*$HOME/.local/bin*" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
    echo "💡 Added ~/.local/bin to PATH for this session."
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
if not command -q openclaw
    echo "❌ OpenClaw installation verification failed."
    echo "💡 Try opening a new terminal or run: set -gx PATH \$HOME/.local/bin \$PATH"
    exit 1
end
echo "✅ OpenClaw installed successfully."
openclaw --version 2>&1 | head -n 1

# === 6. Next steps ===
echo
echo "✅ OpenClaw installation complete!"
echo "💡 OpenClaw is an AI-powered development gateway."
echo
echo "📋 Next steps:"
echo "   1. openclaw gateway install            # Install the Gateway"
echo "   2. openclaw onboard --install-daemon   # Onboard and install daemon"
echo "   3. openclaw gateway status             # Check if the gateway is running"
echo "   4. openclaw dashboard                  # Open the Control UI"
echo "   5. openclaw configure                  # Follow-up reconfiguration"
echo
echo "💡 Useful commands:"
echo "   - openclaw gateway start     # Start the gateway manually"
echo "   - openclaw gateway stop      # Stop the gateway"
echo "💡 Tips:"
echo "   - The daemon runs in the background and starts automatically"
echo "   - Use 'openclaw gateway status' to verify the service is healthy"
echo "   - See https://openclaw.ai/docs for full documentation"
