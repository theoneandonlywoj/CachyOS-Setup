#!/usr/bin/env fish
# === llmfit.fish ===
# Purpose: Install LLMFit (hardware-aware LLM model finder) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting LLMFit installation..."
echo "📌 LLMFit detects your hardware and finds which LLMs will run on your machine."
echo

# === 1. Check if LLMFit is already installed ===
if command -v llmfit > /dev/null
    echo "✅ LLMFit is already installed."
    llmfit --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping LLMFit installation."
        exit 0
    end
    echo "📦 Removing existing LLMFit installation..."
    if test -f /usr/local/bin/llmfit
        sudo rm -f /usr/local/bin/llmfit
    end
    if test -f ~/.local/bin/llmfit
        rm -f ~/.local/bin/llmfit
    end
    echo "✅ Previous LLMFit installation removed."
end

# === 2. Install required dependencies ===
echo "📦 Installing required dependencies..."
sudo pacman -S --needed --noconfirm curl
if test $status -ne 0
    echo "❌ Failed to install dependencies. Aborting."
    exit 1
end

# === 3. Download and run LLMFit install script ===
echo "🔽 Downloading and installing LLMFit..."
curl -fsSL https://llmfit.axjns.dev/install.sh | sh
if test $status -ne 0
    echo "❌ LLMFit installation failed. Aborting."
    exit 1
end

# === 4. Ensure ~/.local/bin is in PATH ===
if test -f ~/.local/bin/llmfit
    if not contains "$HOME/.local/bin" $fish_user_paths
        set -U fish_user_paths $HOME/.local/bin $fish_user_paths
        echo "🔧 Added ~/.local/bin to Fish PATH."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -v llmfit > /dev/null
    echo "✅ LLMFit installed successfully:"
    llmfit --version 2>&1 | head -n 1
else
    echo "❌ LLMFit not found in PATH. Installation may have failed."
    echo "💡 Try restarting your terminal or run: set -U fish_user_paths ~/.local/bin \$fish_user_paths"
    exit 1
end

echo
echo "🎉 LLMFit installation complete!"
echo
echo "💡 Usage:"
echo "   llmfit          → Launch interactive TUI to explore models"
echo "   llmfit --cli    → Use classic CLI mode instead of TUI"
echo "   llmfit --help   → Show all available options"
echo
echo "📚 Resources:"
echo "   GitHub: https://github.com/AlexsJones/llmfit"
