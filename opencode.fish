#!/usr/bin/env fish
# === opencode.fish ===
# Purpose: Install Opencode AI CLI on CachyOS (Arch Linux)
# Includes: YOLO script, package managers, AUR helpers
# Author: theoneandonlywoj

echo "🤖 Starting Opencode installation..."

# === 1. YOLO install (curl | bash) ===
echo "📦 Trying YOLO install (curl | bash)..."
if curl -fsSL https://opencode.ai/install | bash
    echo "✅ Opencode installed via YOLO script."
else
    echo "⚠ YOLO install failed or was skipped. Trying alternatives..."
end

# === 2. Check if already installed ===
if command -v opencode > /dev/null
    echo "✅ Opencode is already installed: (opencode --version)"
    opencode --version 2>/dev/null
    exit 0
end

# === 3. Try npm/bun/pnpm/yarn ===
echo "📦 Trying npm install..."
if command -v npm > /dev/null
    npm i -g opencode-ai@latest
    if command -v opencode > /dev/null
        echo "✅ Opencode installed via npm."
        exit 0
    end
end

# === 4. Try pacman (Arch Linux stable) ===
echo "📦 Trying pacman (stable)..."
if command -v pacman > /dev/null
    if sudo pacman -S --noconfirm opencode
        echo "✅ Opencode installed via pacman."
        exit 0
    end
end

# === 5. Try paru (AUR latest) ===
echo "📦 Trying paru (AUR latest)..."
if command -v paru > /dev/null
    if paru -S --noconfirm opencode-bin
        echo "✅ Opencode installed via paru."
        exit 0
    end
end

# === 6. Try Homebrew (macOS/Linux) ===
echo "📦 Trying Homebrew..."
if command -v brew > /dev/null
    if brew install anomalyco/tap/opencode
        echo "✅ Opencode installed via Homebrew (anomalyco/tap)."
        exit 0
    end
end

# === 7. Try scoop (Windows) ===
echo "📦 Trying scoop (Windows)..."
if command -v scoop > /dev/null
    if scoop install opencode
        echo "✅ Opencode installed via scoop."
        exit 0
    end
end

# === 8. Try choco (Windows) ===
echo "📦 Trying chocolatey (Windows)..."
if command -v choco > /dev/null
    if choco install opencode -y
        echo "✅ Opencode installed via choco."
        exit 0
    end
end

# === 9. Try mise ===
echo "📦 Trying mise..."
if command -v mise > /dev/null
    if mise use -g opencode
        echo "✅ Opencode installed via mise."
        exit 0
    end
end

# === 10. Try nix ===
echo "📦 Trying nix..."
if command -v nix > /dev/null
    if nix run nixpkgs#opencode
        echo "✅ Opencode installed via nix."
        exit 0
    end
end

echo
echo "❌ All installation methods failed."
echo "💡 Please install manually: https://opencode.ai"
exit 1
