#!/usr/bin/env fish
# === cuda.fish ===
# Purpose: Install CUDA toolkit on CachyOS
# Installs CUDA from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting CUDA installation..."

# === 1. Check if NVIDIA GPU is present ===
echo "🔍 Checking for NVIDIA GPU..."
if not test -d /sys/class/drm/*/device/vendor
    echo "⚠ NVIDIA GPU detection failed."
    read -P "Continue anyway? [y/N] " continue_anyway
    if test "$continue_anyway" != "y" -a "$continue_anyway" != "Y"
        exit 0
    end
else
    echo "✅ Checking GPU vendor..."
end

# Check if NVIDIA driver is installed
if test -f /usr/bin/nvidia-smi
    echo "✅ NVIDIA drivers detected."
    nvidia-smi --version 2>&1 | head -n 1
else
    echo "⚠ NVIDIA drivers not detected."
    read -P "Do you have NVIDIA drivers installed? [y/N] " has_drivers
    if test "$has_drivers" != "y" -a "$has_drivers" != "Y"
        echo "⚠ CUDA requires NVIDIA drivers. Please install them first."
        echo "💡 For CachyOS, install with: sudo pacman -S nvidia-dkms"
        echo "⚠ Continuing anyway..."
    end
end

# === 2. Set CUDA version (default to available version) ===
set CUDA_VERSION "13.0.2-1"
echo "📌 Target CUDA version: $CUDA_VERSION"

# === 3. Check if CUDA is already installed ===
command -q nvcc; and set -l cuda_installed "installed"
if test -n "$cuda_installed"
    echo "✅ CUDA is already installed."
    nvcc --version 2>&1 | head -n 1
    read -P "Do you want to reinstall/update? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping CUDA installation."
        exit 0
    end
end

# === 4. Install CUDA ===
echo "📦 Installing CUDA $CUDA_VERSION..."
sudo pacman -S --needed --noconfirm cuda
if test $status -ne 0
    echo "❌ Failed to install CUDA."
    exit 1
end
echo "✅ CUDA installed."

# === 5. Install optional CUDA tools ===
echo "📦 Installing optional CUDA development tools..."
echo "💡 The following tools enhance CUDA development:"
echo "   - cuda-tools: Extra tools (nsight, compute-sanitizer)"
echo "   - cudnn: Deep Neural Network library"
echo "   - python-pycuda: Python wrapper for CUDA"
read -P "Do you want to install CUDA development tools? [y/N] " install_tools

if test "$install_tools" = "y" -o "$install_tools" = "Y"
    echo "📦 Installing CUDA development tools..."
    sudo pacman -S --needed --noconfirm cuda-tools cudnn python-pycuda
    if test $status -ne 0
        echo "⚠ Failed to install some tools, but CUDA is still installed."
    else
        echo "✅ CUDA development tools installed."
    end
end

# === 6. Setup CUDA environment ===
echo "📦 Setting up CUDA environment..."
echo "💡 Adding CUDA paths to environment..."

# Check if CUDA paths are already in .bashrc or .zshrc
set cuda_path_added "false"

# Add to fish config
if not grep -q "CUDA_HOME" ~/.config/fish/config.fish 2>/dev/null
    echo "
# CUDA Environment Variables
set -x CUDA_HOME /opt/cuda
set -x PATH \$CUDA_HOME/bin \$PATH
set -x LD_LIBRARY_PATH \$CUDA_HOME/lib64 \$LD_LIBRARY_PATH" >> ~/.config/fish/config.fish
    set cuda_path_added "true"
    echo "✅ Added CUDA paths to fish config."
else
    echo "✅ CUDA paths already configured in fish."
end

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
                echo "⚠ Failed to fix snapper, but CUDA is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 8. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q nvcc
if test $status -eq 0
    echo "✅ CUDA installed successfully"
    nvcc --version 2>&1 | head -n 2
else
    echo "❌ CUDA installation verification failed."
end

# Check if GPU is recognized
if command -q nvidia-smi
    echo "📊 GPU Information:"
    nvidia-smi --query-gpu=name,driver_version,cuda_version --format=csv,noheader 2>&1 | head -n 1
end

echo
echo "✅ CUDA installation complete!"
echo "💡 CUDA is NVIDIA's parallel computing platform for:"
echo "   - GPU-accelerated applications"
echo "   - Deep learning and AI development"
echo "   - High-performance computing"
echo "   - Scientific computing"
echo "💡 Environment setup:"
if test "$cuda_path_added" = "true"
    echo "   - Added CUDA paths to fish config"
    echo "   - Please restart your terminal or run: source ~/.config/fish/config.fish"
else
    echo "   - CUDA paths already configured"
end
echo "💡 CUDA directories:"
echo "   - CUDA_HOME: /opt/cuda"
echo "   - Binaries: /opt/cuda/bin"
echo "   - Libraries: /opt/cuda/lib64"
echo "💡 Testing CUDA installation:"
echo "   - Check version: nvcc --version"
echo "   - List GPU: nvidia-smi"
echo "   - Compile CUDA: nvcc test.cu"
echo "💡 Using CUDA with Python:"
echo "   - pip install pycuda"
echo "   - import pycuda.driver as cuda"
echo "💡 For more information:"
echo "   - CUDA Toolkit Documentation: https://docs.nvidia.com/cuda/"
echo "   - CUDA Samples: /opt/cuda/samples"

