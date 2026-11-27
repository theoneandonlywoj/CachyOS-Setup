#!/usr/bin/env fish
# === lazygit.fish ===
# Purpose: Install lazygit (terminal UI for Git) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting lazygit installation..."

# === 1. Install lazygit ===
sudo pacman -S --needed --noconfirm lazygit
if test $status -ne 0
    echo "❌ Failed to install lazygit. Rerun: ./lazygit.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q lazygit
    echo "❌ lazygit installation verification failed: lazygit is not on PATH."
    exit 1
end
lazygit --version

echo
echo "✅ lazygit setup complete!"
echo "💡 Run lazygit inside any Git repository."
echo "💡 Guide: docs/guide_lazygit.md"
