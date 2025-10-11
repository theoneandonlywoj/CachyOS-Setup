#!/usr/bin/env fish
# === install_mise.fish ===
# Purpose: Install Mise (environment/version manager) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Mise installation..."

# === 1. Remove any existing Mise installation (optional clean-up) ===
if command -v mise > /dev/null
    echo "⚠ Existing Mise installation detected."
    read -l -P "Do you want to remove it and reinstall? (y/N): " confirm
    switch $confirm
        case y Y
            echo "🧹 Removing existing Mise installation..."
            sudo rm -rf ~/.local/bin/mise ~/.local/share/mise ~/.config/mise
            sudo rm -f /usr/local/bin/mise
        case '*'
            echo "ℹ Skipping removal."
    end
end

# === 2. Update system and install dependencies ===
echo "📦 Installing required dependencies (git, curl)..."
sudo pacman -S --noconfirm git curl
if test $status -ne 0
    echo "❌ Failed to install dependencies. Aborting."
    exit 1
end

# === 3. Install Mise using official install script ===
echo "🔽 Downloading and running Mise installer..."
curl https://mise.run | sh
if test $status -ne 0
    echo "❌ Mise installation failed. Aborting."
    exit 1
end

# === 4. Add Mise to PATH for Fish shell ===
if not contains "$HOME/.local/bin" $fish_user_paths
    echo "➕ Adding ~/.local/bin to your Fish PATH..."
    set -U fish_user_paths $HOME/.local/bin $fish_user_paths
end

# === 5. Initialize Mise in Fish ===
echo "⚙ Initializing Mise in Fish shell..."
if not grep -q "mise activate fish" ~/.config/fish/config.fish 2>/dev/null
    echo -e "\n# Initialize Mise\nmise activate fish | source" >> ~/.config/fish/config.fish
    echo "✅ Added Mise initialization to ~/.config/fish/config.fish"
else
    echo "ℹ Mise initialization already present in Fish config."
end

# === 6. Verify installation ===
echo "🧪 Verifying Mise installation..."
if command -v mise > /dev/null
    echo "✅ Mise installed successfully: $(mise --version)"
else
    echo "❌ Mise not found in PATH. You may need to restart your terminal."
end

echo
echo "🎉 Mise installation complete!"
echo "💡 You can now install runtimes, e.g.:"
echo "   mise use -g node@lts python@3.12"
echo "   mise install"

