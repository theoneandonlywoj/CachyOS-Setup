#!/usr/bin/env fish
# === comfyui_cli.fish ===
# Purpose: Install ComfyUI CLI on CachyOS (Arch Linux)
# Includes: Python dependencies, ComfyUI CLI installation, ComfyUI setup
# Author: theoneandonlywoj

echo "🚀 Starting ComfyUI CLI installation..."

# === 1. Check if running on Arch/CachyOS ===
if not test -f /etc/arch-release
    echo "❌ This script is designed for Arch-based systems like CachyOS."
    exit 1
end

# === 2. Check for Python 3 ===
echo "🐍 Checking for Python 3..."
if not command -q python3
    echo "📦 Installing Python 3..."
    sudo pacman -S --noconfirm --needed python
    if test $status -ne 0
        echo "❌ Failed to install Python 3. Aborting."
        exit 1
    end
else
    echo "✅ Python 3 is installed: $(python3 --version)"
end

# === 2.5. Check for pipx (recommended for CLI apps on Arch) ===
echo "📦 Checking for pipx..."
if not command -q pipx
    echo "📦 Installing pipx (recommended for Python CLI apps on Arch)..."
    sudo pacman -S --noconfirm --needed python-pipx
    if test $status -ne 0
        echo "❌ Failed to install pipx. Aborting."
        exit 1
    end
else
    echo "✅ pipx is installed: $(pipx --version)"
end

# === 3. Check for Git ===
echo "📦 Checking for Git..."
if not command -q git
    echo "📦 Installing Git..."
    sudo pacman -S --noconfirm --needed git
    if test $status -ne 0
        echo "❌ Failed to install Git. Aborting."
        exit 1
    end
else
    echo "✅ Git is installed: $(git --version | cut -d' ' -f3)"
end

# === 3.5. Check for huggingface_hub (for downloading models) ===
echo "📦 Checking for huggingface_hub..."
if not pacman -Qq python-huggingface-hub >/dev/null 2>&1
    echo "📦 Installing huggingface_hub (for downloading models from Hugging Face)..."
    sudo pacman -S --noconfirm --needed python-huggingface-hub
    if test $status -ne 0
        echo "⚠ Failed to install huggingface_hub. Continuing anyway..."
        echo "💡 You can install it manually later: sudo pacman -S python-huggingface-hub"
    else
        echo "✅ huggingface_hub installed successfully."
    end
else
    echo "✅ huggingface_hub is installed: $(huggingface-cli --version 2>/dev/null || echo 'installed')"
end

# === 4. Check if ComfyUI CLI is already installed ===
if command -q comfy
    echo "⚠ ComfyUI CLI is already installed: $(comfy --version 2>/dev/null || echo 'unknown version')"
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping ComfyUI CLI installation."
        exit 0
    end
    echo "🧹 Removing existing ComfyUI CLI..."
    pipx uninstall comfy-cli > /dev/null 2>&1
end

# === 5. Install ComfyUI CLI using pipx ===
echo "📦 Installing ComfyUI CLI using pipx..."
pipx install comfy-cli
if test $status -ne 0
    echo "❌ Failed to install ComfyUI CLI. Aborting."
    exit 1
end
echo "✅ ComfyUI CLI installed successfully via pipx."

# === 6. Ensure pipx bin directory is in PATH ===
set pipx_bin ~/.local/bin
if not contains "$pipx_bin" $fish_user_paths
    echo "➕ Adding pipx bin directory to PATH: $pipx_bin"
    set -U fish_user_paths $pipx_bin $fish_user_paths
else
    echo "✅ pipx bin directory already in PATH."
end

# === 7. Verify ComfyUI CLI installation ===
echo "🧪 Verifying ComfyUI CLI installation..."
if command -q comfy
    set cli_version (comfy --version 2>/dev/null || echo "installed")
    echo "✅ ComfyUI CLI verified: $cli_version"
else
    echo "⚠ ComfyUI CLI not found in PATH. Trying direct path..."
    if test -f ~/.local/bin/comfy
        ~/.local/bin/comfy --version > /dev/null 2>&1
        if test $status -eq 0
            echo "✅ ComfyUI CLI is installed but not in current shell PATH."
            echo "💡 Please restart your terminal or run: source ~/.config/fish/config.fish"
        else
            echo "❌ ComfyUI CLI verification failed. Please check manually."
        end
    else
        echo "❌ ComfyUI CLI verification failed. Please check manually."
    end
end

# === 8. Install ComfyUI using CLI (optional) ===
echo
read -P "Do you want to install ComfyUI now using the CLI? [y/N] " install_comfyui
if test "$install_comfyui" = "y" -o "$install_comfyui" = "Y"
    echo "📦 Installing ComfyUI using ComfyUI CLI..."
    comfy install
    if test $status -eq 0
        echo "✅ ComfyUI installed successfully via CLI."
    else
        echo "⚠ ComfyUI installation via CLI encountered issues."
        echo "💡 You can run 'comfy install' manually later."
    end
else
    echo "ℹ Skipping ComfyUI installation. You can run 'comfy install' manually later."
end

# === 9. Install Fish shell autocompletion (optional) ===
echo
read -P "Do you want to install Fish shell autocompletion for ComfyUI CLI? [y/N] " install_completion
if test "$install_completion" = "y" -o "$install_completion" = "Y"
    echo "📦 Installing Fish shell autocompletion..."
    if command -q comfy
        comfy --install-completion 2>/dev/null
        if test $status -eq 0
            echo "✅ Fish shell autocompletion installed."
        else
            echo "⚠ Autocompletion installation may have failed (some versions don't support Fish)."
        end
    else
        echo "⚠ ComfyUI CLI not available in PATH. Skipping autocompletion."
        echo "💡 Please restart terminal and run: comfy --install-completion"
    end
else
    echo "ℹ Skipping autocompletion installation."
end

# === 10. Display usage information ===
echo
echo "✅ ComfyUI CLI installation complete!"
echo
echo "💡 Usage:"
echo "   - Install ComfyUI: comfy install"
echo "   - List installed instances: comfy list"
echo "   - Start ComfyUI: comfy start"
echo "   - Stop ComfyUI: comfy stop"
echo "   - Update ComfyUI: comfy update"
echo "   - Show help: comfy --help"
echo
echo "💡 Important notes:"
echo "   - ComfyUI CLI is installed via pipx in isolated environment"
echo "   - Binary location: ~/.local/bin/comfy"
echo "   - If 'comfy' command is not found, restart your terminal"
echo "   - Or manually add to PATH: set -U fish_user_paths ~/.local/bin \$fish_user_paths"
echo "   - To update: pipx upgrade comfy-cli"
echo "   - To uninstall: pipx uninstall comfy-cli"
echo "   - See https://github.com/Comfy-Org/comfy-cli for more information"

