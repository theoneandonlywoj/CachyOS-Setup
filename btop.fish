#!/usr/bin/env fish
# === btop.fish ===
# Purpose: Install btop (resource monitor) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting btop installation..."

# === 1. Install btop ===
sudo pacman -S --needed --noconfirm btop
if test $status -ne 0
    echo "❌ Failed to install btop. Rerun: ./btop.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q btop
    echo "❌ btop installation verification failed: btop is not on PATH."
    exit 1
end
btop --version

echo
echo "✅ btop setup complete!"
echo "💡 Run: btop (Esc or m opens the menu, q quits)"
