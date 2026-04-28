#!/usr/bin/env fish
# === fwup.fish ===
# Purpose: Install fwup (firmware update tool) from source on CachyOS (Arch Linux)
# Includes: clone, build, verification
# Author: theoneandonlywoj

echo "🔧 Starting fwup installation from source..."

# === 1. Install build dependencies ===
echo "📦 Installing build dependencies..."
sudo pacman -S --noconfirm git rust autoconf automake libtool pkg-config
if test $status -ne 0
    echo "❌ Failed to install build dependencies. Aborting."
    exit 1
end

# === 2. Clone fwup repository ===
if test -d ~/fwup
    echo "⚠ Existing ~/fwup found. Removing to ensure clean install..."
    rm -rf ~/fwup
    if test $status -ne 0
        echo "❌ Failed to remove existing ~/fwup. Aborting."
        exit 1
    end
end

echo "📥 Cloning fwup repository..."
git clone https://github.com/fwup-home/fwup ~/fwup
if test $status -ne 0
    echo "❌ Failed to clone fwup repository. Aborting."
    exit 1
end

# === 3. Build fwup ===
echo "🔨 Building fwup (this may take a few minutes)..."
cd ~/fwup
./autogen.sh
./configure
make
if test $status -ne 0
    echo "❌ Build failed. Aborting."
    exit 1
end

# === 4. Install fwup ===
echo "📦 Installing fwup..."
sudo make install
if test $status -ne 0
    echo "❌ Installation failed. Aborting."
    exit 1
end

# === 5. Cleanup ===
echo "🧹 Cleaning up build artifacts..."
rm -rf ~/fwup

# === 6. Verify installation ===
echo "✅ Verifying fwup installation..."
fwup --version
if test $status -ne 0
    echo "❌ fwup verification failed. Please install manually."
    exit 1
end

echo
echo "🚀 fwup installed successfully!"
echo "📖 Usage: fwup --help"
