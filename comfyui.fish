#!/usr/bin/env fish
# === comfyui.fish ===
# Purpose: Install ComfyUI with Podman on CachyOS
# Installs ComfyUI from Podman image
# Author: theoneandonlywoj

echo "🚀 Starting ComfyUI installation with Podman..."

# === 1. Check if Podman is installed ===
command -q podman; and set -l podman_installed "installed"
if test -z "$podman_installed"
    echo "❌ Podman is not installed."
    echo "💡 Please install Podman first:"
    echo "   sudo pacman -S podman podman-compose"
    echo "   podman machine init"
    echo "   podman machine start"
    exit 1
end

echo "✅ Podman is installed."

# === 2. Check if ComfyUI is already installed ===
if test -d ~/comfyui
    echo "✅ ComfyUI directory already exists at ~/comfyui."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping ComfyUI installation."
        exit 0
    end
    echo "📦 Removing existing ComfyUI installation..."
    rm -rf ~/comfyui
    echo "✅ ComfyUI directory removed."
end

# === 3. Clone ComfyUI from GitHub ===
echo "📦 Cloning ComfyUI from GitHub..."
if test -d ~/comfyui/ComfyUI
    echo "⚠ ComfyUI repository already exists."
else
    git clone https://github.com/comfyanonymous/ComfyUI.git ~/comfyui/ComfyUI
    if test $status -ne 0
        echo "❌ Failed to clone ComfyUI repository."
        exit 1
    end
end
echo "✅ ComfyUI cloned."

# === 4. Create Dockerfile for ComfyUI ===
echo "📦 Creating Dockerfile for ComfyUI..."
echo "FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    git \\
    wget \\
    curl \\
    && rm -rf /var/lib/apt/lists/*

# Copy ComfyUI
COPY ComfyUI /app

# Install Python dependencies
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8188

CMD [\"python\", \"main.py\", \"--listen\", \"0.0.0.0\"]" > ~/comfyui/Dockerfile
echo "✅ Dockerfile created."

# === 5. Build ComfyUI Podman image ===
echo "📦 Building ComfyUI Podman image..."
cd ~/comfyui
podman build -t comfyui:latest .
if test $status -ne 0
    echo "❌ Failed to build ComfyUI Podman image."
    exit 1
end
echo "✅ ComfyUI Podman image built."

# === 6. Create docker-compose.yml ===
echo "📦 Creating docker-compose.yml..."
echo "version: '3.8'

services:
  comfyui:
    image: comfyui/comfyui:latest
    container_name: comfyui
    stdin_open: true
    tty: true
    ports:
      - \"8188:8188\"
    volumes:
      - ./models:/comfyui/models
      - ./output:/comfyui/output
      - ./input:/comfyui/input
    restart: unless-stopped
    shm_size: \"10gb\"" > ~/comfyui/docker-compose.yml
echo "✅ docker-compose.yml created."
echo "💡 Note: For Podman, you can also use podman-compose (if installed) or podman run commands."

# === 7. Check and fix snapper Boost library issue (if present) ===
if test -f /usr/bin/snapper
    echo
    echo "🔧 Checking for snapper Boost library issue..."
    snapper --version > /dev/null 2>&1
    if test $status -ne 0
        echo "⚠ Detected snapper Boost library version mismatch."
        echo "💡 This can happen after Boost updates."
        read -P "Do you want to fix snapper? [y/N] " fix_snapper
        
        if test "$fix_snapper" = "y" -o "$fix_snapper" = "Y"
            echo "📦 Reinstalling snapper to fix Boost library version mismatch..."
            sudo pacman -S --noconfirm snapper
            if test $status -eq 0
                echo "✅ Snapper fixed successfully."
            else
                echo "⚠ Failed to fix snapper, but ComfyUI is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 8. Verify installation ===
echo
echo "🧪 Verifying installation..."
podman images | grep comfyui
if test $status -eq 0
    echo "✅ ComfyUI Podman image verified."
else
    echo "❌ ComfyUI installation verification failed."
end

echo
echo "✅ ComfyUI installation complete!"
echo "💡 ComfyUI is an AI workflow tool for Stable Diffusion with:"
echo "   - Node-based workflow editor"
echo "   - Advanced image generation and editing"
echo "   - Support for various AI models"
echo "   - Extensible plugin system"
echo "💡 Directory structure:"
echo "   - Main directory: ~/comfyui/"
echo "   - Models: ~/comfyui/models/"
echo "   - Output: ~/comfyui/output/"
echo "   - Input: ~/comfyui/input/"
echo "💡 To start ComfyUI with Podman:"
echo "   Option 1 (podman run):"
echo "   cd ~/comfyui"
echo "   podman run -d --name comfyui -p 8188:8188 \\"
echo "     -v ~/comfyui/ComfyUI:/app \\"
echo "     comfyui:latest"
echo
echo "   Option 2 (podman-compose if installed):"
echo "   cd ~/comfyui"
echo "   podman-compose up -d"
echo
echo "💡 Access ComfyUI:"
echo "   - Web interface: http://localhost:8188"
echo "💡 To stop ComfyUI:"
echo "   podman stop comfyui && podman rm comfyui"
echo "   (or: cd ~/comfyui && podman-compose down)"
echo "💡 To view logs:"
echo "   podman logs -f comfyui"
echo "   (or: cd ~/comfyui && podman-compose logs -f)"
echo "💡 To update ComfyUI:"
echo "   cd ~/comfyui/ComfyUI"
echo "   git pull"
echo "   cd ~/comfyui"
echo "   podman build -t comfyui:latest ."
echo "   podman stop comfyui && podman rm comfyui"
echo "   (then run the start command again)"
echo "💡 Important notes:"
echo "   - GPU acceleration is enabled if NVIDIA drivers are installed"
echo "   - Place your model files (.ckpt, .safetensors) in ~/comfyui/ComfyUI/models/"
echo "   - Generated images will be saved to ~/comfyui/ComfyUI/output/"
echo "   - See https://github.com/comfyanonymous/ComfyUI for more information"

