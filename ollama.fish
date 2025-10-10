#!/usr/bin/env fish
# === install_ollama_clean.fish ===
# Purpose: Clean install or update of Ollama on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting clean Ollama installation/update..."

# === 1. Uninstall previous Ollama installation if present ===
if command -v ollama > /dev/null
    echo "⚠ Previous Ollama installation detected. Removing..."
    # Stop and disable service if exists
    if sudo systemctl list-units --full -all | grep -q ollama.service
        sudo systemctl stop ollama
        sudo systemctl disable ollama
        sudo rm /etc/systemd/system/ollama.service
    end

    # Remove binary
    sudo rm -f /usr/local/bin/ollama

    # Remove Ollama user/group if exist
    sudo id -u ollama >/dev/null 2>&1; and sudo userdel ollama
    sudo getent group ollama >/dev/null 2>&1; and sudo groupdel ollama

    # Remove installation directory
    sudo rm -rf /usr/share/ollama
    echo "✅ Previous Ollama installation removed."
end

# === 2. Update system and install dependencies ===
echo "📦 Installing required dependencies..."
sudo pacman -S --noconfirm curl git
if test $status -ne 0
    echo "❌ Failed to install dependencies. Aborting."
    exit 1
end

# === 3. Download and run Ollama installer script ===
echo "🔽 Downloading and running Ollama install script..."
curl -fsSL https://ollama.com/install.sh | sh
if test $status -ne 0
    echo "❌ Failed to install Ollama. Aborting."
    exit 1
end

# === 4. Optional: Install NVIDIA GPU support ===
echo "⚡ Checking for NVIDIA GPU..."
if command -v nvidia-smi > /dev/null
    echo "🔧 NVIDIA GPU detected, installing nvidia-container-toolkit..."
    sudo pacman -S --noconfirm nvidia-container-toolkit
    if test $status -ne 0
        echo "❌ Failed to install NVIDIA container toolkit. GPU support may not work."
    else
        echo "🔄 Restarting Docker service..."
        sudo systemctl restart docker
    end
else
    echo "ℹ No NVIDIA GPU detected. Skipping GPU setup."
end

# === 5. Verify Ollama installation ===
echo "🧪 Verifying Ollama installation..."
if command -v ollama > /dev/null
    echo "✅ Ollama installed successfully: $(ollama --version)"
else
    echo "❌ Ollama not found in PATH. Installation may have failed."
end

echo "🎉 Ollama clean installation/update complete!"
echo "💡 You can test Ollama by running: ollama run gemma3:270m"

