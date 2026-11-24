#!/usr/bin/env fish
# === vivaldi_install.fish ===
# Purpose: Install Vivaldi browser on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🌐 Starting Vivaldi installation..."

# === 1. Install Vivaldi ===
echo "📦 Installing Vivaldi..."
sudo pacman -S --needed --noconfirm vivaldi
if test $status -ne 0
    echo "❌ Failed to install Vivaldi."
    exit 1
end
echo "✅ Vivaldi installed successfully."

# === 2. Verify installation ===
echo
echo "🧪 Verifying Vivaldi installation..."
vivaldi --version
if test $status -eq 0
    echo "✅ Vivaldi is ready to use!"
else
    echo "❌ Verification failed."
end

echo
echo "💡 You can launch Vivaldi from your application menu or by typing 'vivaldi' in the terminal."

