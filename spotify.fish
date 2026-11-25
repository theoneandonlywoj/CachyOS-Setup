#!/usr/bin/env fish
# === spotify.fish ===
# Purpose: Install Spotify (spotify-launcher) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Spotify installation..."

# === 1. Install Spotify ===
sudo pacman -S --needed --noconfirm spotify-launcher
if test $status -ne 0
    echo "❌ Failed to install Spotify. Rerun: ./spotify.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q spotify-launcher
    echo "❌ Spotify installation verification failed: spotify-launcher is not on PATH."
    exit 1
end
pacman -Q spotify-launcher

echo
echo "✅ Spotify setup complete!"
echo "💡 Run: spotify-launcher (it downloads and updates the Spotify client on start)"
