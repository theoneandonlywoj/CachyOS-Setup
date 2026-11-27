#!/usr/bin/env fish
# === websocat.fish ===
# Purpose: Install websocat (WebSocket command-line client) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting websocat installation..."

# === 1. Install websocat ===
sudo pacman -S --needed --noconfirm websocat
if test $status -ne 0
    echo "❌ Failed to install websocat. Rerun: ./websocat.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q websocat
    echo "❌ websocat installation verification failed: websocat is not on PATH."
    exit 1
end
websocat --version

echo
echo "✅ websocat setup complete!"
echo "💡 Connect: websocat wss://example.com/socket"
echo "💡 Listen:  websocat -s 1234"
