#!/usr/bin/env fish
# === opencode.fish ===
# Purpose: Install OpenCode CLI on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting OpenCode CLI installation..."

# === 1. Check if OpenCode CLI is already installed ===
command -q opencode; and set -l opencode_installed "installed"
if test -n "$opencode_installed"
    echo "✅ OpenCode CLI is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping OpenCode CLI installation."
        exit 0
    end
    echo "📦 Removing existing OpenCode CLI installation..."
    rm -f "$HOME/.local/bin/opencode"
    if test $status -ne 0
        echo "❌ Failed to remove OpenCode CLI."
        exit 1
    end
    echo "✅ OpenCode CLI removed."
end

# === 2. Ensure ~/.local/bin exists (installer target) ===
echo "📁 Ensuring install directory exists..."
mkdir -p "$HOME/.local/bin"
if test $status -ne 0
    echo "❌ Failed to create ~/.local/bin."
    exit 1
end

# === 3. Install OpenCode CLI (official installer) ===
echo "📦 Installing OpenCode CLI..."
curl -fsSL https://opencode.ai/install | bash
if test $status -ne 0
    echo "❌ Failed to install OpenCode CLI."
    exit 1
end
echo "✅ OpenCode CLI installed."

# === 4. Ensure ~/.local/bin is in PATH for this session ===
set -q PATH; or set PATH ""
if not string match -q "*$HOME/.local/bin*" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
    echo "💡 Added ~/.local/bin to PATH for this session."
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q opencode
    echo "✅ OpenCode CLI installed successfully."
else
    echo "❌ OpenCode CLI installation verification failed."
    echo "💡 Try opening a new terminal or run: set -gx PATH \$HOME/.local/bin \$PATH"
    exit 1
end

echo
echo "🎉 OpenCode CLI installation complete!"
echo
echo "💡 Getting started:"
echo "   1. Launch OpenCode by running: opencode"
echo "   2. After launch, run the /connect command to configure your AI provider"
echo "      (e.g., Anthropic API key, OpenAI key, or other supported backends)"
echo
echo "💡 Tips:"
echo "   - Use /help within OpenCode to see available commands"
echo "   - See https://opencode.ai/docs for full documentation"
