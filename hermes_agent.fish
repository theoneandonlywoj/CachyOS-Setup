#!/usr/bin/env fish
# === hermes_agent.fish ===
# Purpose: Install Hermes Agent via official install script
# Author: theoneandonlywoj

echo "🚀 Starting Hermes Agent installation..."
echo

# === 1. Check if Hermes is already installed ===
if command -v hermes > /dev/null
    echo "✅ Hermes is already installed!"
    echo "📌 Current version:"
    hermes -h 2>/dev/null | head -5
    echo
    echo "💡 To update Hermes, run:"
    echo "   curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
    exit 0
end

echo "📦 Installing Hermes Agent..."

# === 2. Install Hermes Agent via official script ===
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
if test $status -ne 0
    echo "❌ Hermes Agent installation failed. Aborting."
    exit 1
end

# === 3. Reload PATH to ensure hermes is available ===
set -gx PATH $HOME/.local/bin $PATH

# === 4. Verify installation ===
echo "🧪 Verifying installation..."
if command -v hermes > /dev/null
    echo "✅ Hermes Agent installed successfully!"
    echo "📌 Version info:"
    hermes -h 2>/dev/null | head -10
else
    echo "❌ Hermes verification failed. It may require a shell restart."
    echo "💡 Try restarting your terminal or running:"
    echo "   source ~/.config/fish/config.fish"
    exit 1
end

echo
echo "🎉 Hermes Agent installation complete!"
echo
echo "💡 To use Hermes in this terminal, you may need to restart or run:"
echo "   source ~/.config/fish/config.fish"
echo
echo "📚 Next steps:"
echo "   hermes doctor    - Verify setup"
echo "   hermes --help    - View available commands"