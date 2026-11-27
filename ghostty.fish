#!/usr/bin/env fish
# === ghostty.fish ===
# Purpose: Install Ghostty (terminal emulator) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Ghostty installation..."

# === 1. Install Ghostty ===
sudo pacman -S --needed --noconfirm ghostty
if test $status -ne 0
    echo "❌ Failed to install Ghostty. Rerun: ./ghostty.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q ghostty
    echo "❌ Ghostty installation verification failed: ghostty is not on PATH."
    exit 1
end
pacman -Q ghostty

echo
echo "✅ Ghostty setup complete!"
echo "💡 Config file: ~/.config/ghostty/config (list options: ghostty +show-config --default --docs)"
