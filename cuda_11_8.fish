#!/usr/bin/env fish
# === cuda.fish ===
# Purpose: Install CUDA toolkit 11.8.0 on CachyOS for GTX 970 compatibility
# Installs CUDA from Arch Linux package archive
# Author: theoneandonlywoj

echo "🚀 Starting CUDA installation..."

# === 1. Check if NVIDIA GPU is present ===
echo "🔍 Checking for NVIDIA GPU..."
set nvidia_detected false
for vendor_file in /sys/class/drm/*/device/vendor
    if test -f "$vendor_file"
        set vendor_id (cat "$vendor_file" 2>/dev/null)
        # NVIDIA vendor ID is 0x10de (decimal: 4094)
        if test "$vendor_id" = "0x10de" -o "$vendor_id" = "4094"
            set nvidia_detected true
            break
        end
    end
end

if not test "$nvidia_detected" = "true"
    echo "⚠ NVIDIA GPU detection failed."
    read -P "Continue anyway? [y/N] " continue_anyway
    if test "$continue_anyway" != "y" -a "$continue_anyway" != "Y"
        exit 0
    end
else
    echo "✅ NVIDIA GPU detected."
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

# === 2. Check if CUDA is already installed ===
command -q nvcc; and set -l cuda_installed "installed"
if test -n "$cuda_installed"
    echo "✅ CUDA is already installed."
    nvcc --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping CUDA installation."
        exit 0
    end
    echo "📦 Removing existing CUDA packages..."
    sudo pacman -Rns --noconfirm cuda cuda-tools cudnn 2>/dev/null
end

# === 3. Install CUDA 11.8.0 from Arch archive ===
echo "📦 Installing CUDA 11.8.0 from Arch Linux package archive..."
echo "💡 This version is compatible with GTX 970 (compute capability 5.2)"

# CUDA 11.8.0 requires gcc11 and gcc11-libs, install all together
echo "📦 Installing gcc11, gcc11-libs, and CUDA 11.8.0 from archive..."
echo "💡 CUDA 11.8.0 requires gcc11 which is no longer in current repositories"
echo "💡 gcc11 requires gcc11-libs, installing all packages together..."

# Package URLs from archive
set gcc11_url https://archive.archlinux.org/packages/g/gcc11/gcc11-11.3.0-2-x86_64.pkg.tar.zst
set gcc11_libs_url https://archive.archlinux.org/packages/g/gcc11-libs/gcc11-libs-11.3.0-2-x86_64.pkg.tar.zst
set cuda_url https://archive.archlinux.org/packages/c/cuda/cuda-11.8.0-1-x86_64.pkg.tar.zst

# Install all three packages together
echo "📦 Installing gcc11-libs, gcc11, and CUDA 11.8.0..."
sudo pacman -U --noconfirm $gcc11_libs_url $gcc11_url $cuda_url 2>&1
if test $status -ne 0
    echo "❌ Failed to install CUDA with dependencies."
    echo "💡 Error details above. Possible issues:"
    echo "   - Package URLs may have changed"
    echo "   - Missing additional dependencies"
    echo "   - Network connectivity issues"
    echo "💡 You may need to install manually:"
    echo "   sudo pacman -U --noconfirm $gcc11_libs_url $gcc11_url $cuda_url"
    exit 1
else
    echo "✅ CUDA 11.8.0, gcc11, and gcc11-libs installed successfully."
end

# === 4. Install cuDNN 8.6.0.163 from Arch archive ===
echo "📦 Installing cuDNN 8.6.0.163 from Arch Linux package archive..."
echo "💡 Package URL: https://archive.archlinux.org/packages/c/cudnn/cudnn-8.6.0.163-1-x86_64.pkg.tar.zst"

sudo pacman -U --noconfirm https://archive.archlinux.org/packages/c/cudnn/cudnn-8.6.0.163-1-x86_64.pkg.tar.zst
if test $status -ne 0
    echo "⚠ Failed to install cuDNN (this is optional, CUDA will still work)."
else
    echo "✅ cuDNN installed successfully."
end

# === 4.5. Install optional CUDA dependencies ===
echo "📦 Installing optional CUDA development dependencies..."
echo "💡 The following packages enhance CUDA development tools:"
echo "   - gdb: Required for cuda-gdb debugger"
echo "   - glu: Required for some profiling tools in CUPTI"
read -P "Install optional dependencies? [y/N] " install_opt_deps

if test "$install_opt_deps" = "y" -o "$install_opt_deps" = "Y"
    echo "📦 Installing gdb and glu..."
    sudo pacman -S --needed --noconfirm gdb glu
    if test $status -eq 0
        echo "✅ Optional dependencies installed successfully."
    else
        echo "⚠ Some optional dependencies failed to install (CUDA will still work)."
    end
else
    echo "⚠ Skipping optional dependencies."
    echo "💡 You can install them later with: sudo pacman -S gdb glu"
end

# === 5. Setup CUDA environment in /etc/profile.d/cuda.sh ===
echo "📦 Setting up CUDA environment variables..."
echo "💡 Adding CUDA paths to /etc/profile.d/cuda.sh..."

# Create CUDA environment file for all shells
set cuda_env_file /tmp/cuda.sh
echo "# CUDA Environment Variables" > $cuda_env_file
echo "# Added by cuda.fish installation script" >> $cuda_env_file
echo "" >> $cuda_env_file
echo "export CUDA_HOME=/opt/cuda" >> $cuda_env_file
echo "export PATH=\$CUDA_HOME/bin:\$PATH" >> $cuda_env_file
echo "export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH" >> $cuda_env_file

sudo cp $cuda_env_file /etc/profile.d/cuda.sh
set copy_status $status
rm -f $cuda_env_file

if test $copy_status -eq 0
    echo "✅ Created /etc/profile.d/cuda.sh"
    echo "💡 This will be sourced by all shells on login"
    
    # Set environment variables for current fish session
    set -x CUDA_HOME /opt/cuda
    set -x PATH $CUDA_HOME/bin $PATH
    set -x LD_LIBRARY_PATH $CUDA_HOME/lib64 $LD_LIBRARY_PATH
    echo "✅ CUDA paths added to current fish session"
else
    echo "⚠ Failed to create /etc/profile.d/cuda.sh"
    echo "💡 You may need to manually add CUDA paths to your shell configuration"
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q nvcc
if test $status -eq 0
    echo "✅ CUDA installed successfully"
    echo "📌 Installed CUDA version:"
    nvcc --version 2>&1 | head -n 2
else
    echo "❌ CUDA installation verification failed."
    echo "💡 You may need to restart your terminal or run: source /etc/profile.d/cuda.sh"
end

# Check if GPU is recognized
if command -q nvidia-smi
    echo "📊 GPU Information:"
    nvidia-smi --query-gpu=name,driver_version,cuda_version --format=csv,noheader 2>&1 | head -n 1
    echo "💡 Note: nvidia-smi shows the CUDA version supported by your driver"
    echo "💡 This may differ from the installed CUDA toolkit version (11.8.0)"
end

echo
echo "✅ CUDA installation complete!"
echo "💡 CUDA 11.8.0 is installed and compatible with GTX 970"
echo "💡 Environment setup:"
echo "   - CUDA paths added to /etc/profile.d/cuda.sh"
echo "   - Available for all users and all shells"
echo "💡 CUDA directories:"
echo "   - CUDA_HOME: /opt/cuda"
echo "   - Binaries: /opt/cuda/bin"
echo "   - Libraries: /opt/cuda/lib64"
echo "💡 Testing CUDA installation:"
echo "   - Check version: nvcc --version"
echo "   - List GPU: nvidia-smi"
echo "   - Compile CUDA: nvcc test.cu"
echo "💡 Note: You may need to restart your terminal or run:"
echo "   source /etc/profile.d/cuda.sh"
echo "💡 For more information:"
echo "   - CUDA Toolkit Documentation: https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html"
echo "   - CUDA Samples: /opt/cuda/samples"

