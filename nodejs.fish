#!/usr/bin/env fish
# === nodejs.fish ===
# Purpose: Install Node.js 22+ via Mise on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set NODEJS_VERSION 22

echo "🚀 Starting Node.js setup via Mise..."
echo "📌 Target version:"
echo "   Node.js → $NODEJS_VERSION (latest LTS)"
echo

# === 1. Check Mise installation ===
if not command -v mise > /dev/null
    echo "❌ Mise is not installed. Please install it first using:"
    echo "   curl https://mise.run | sh"
    echo "Then re-run this script."
    exit 1
end

# === 2. Load Mise environment in current shell for script execution ===
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source

# === 3. Install required build dependencies ===
echo "📦 Installing required build dependencies (without system update)..."
sudo pacman -S --needed --noconfirm base-devel git curl
if test $status -ne 0
    echo "❌ Failed to install required dependencies. Aborting."
    exit 1
end

# === 4. Install Node.js via Mise ===
echo "🔧 Installing Node.js $NODEJS_VERSION via Mise..."
mise install node@$NODEJS_VERSION
mise use -g node@$NODEJS_VERSION
if test $status -ne 0
    echo "❌ Node.js installation failed. Aborting."
    exit 1
end

# Reload PATH again to be safe
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source

# === 5. Add automatic activation to Fish config if not already present ===
set fish_config_file ~/.config/fish/config.fish
set activation_line "mise activate fish | source"

if not grep -Fxq "$activation_line" $fish_config_file
    echo "$activation_line" >> $fish_config_file
    echo "🔧 Added automatic Mise activation to $fish_config_file"
end

# === 6. Verify installations ===
echo "🧪 Verifying installations..."
set node_version (command node --version 2>/dev/null)
set npm_version (command npm --version 2>/dev/null)

if test -n "$node_version"
    echo "✅ Node.js installed successfully: $node_version"
else
    echo "❌ Node.js verification failed."
end

if test -n "$npm_version"
    echo "✅ npm installed successfully: v$npm_version"
else
    echo "❌ npm verification failed."
end

echo
echo "🎉 Node.js setup complete via Mise!"
echo
echo "💡 Important:"
echo "   To use 'node', 'npm', and 'npx' in this terminal immediately,"
echo "   run the following command in your current shell:"
echo "       mise activate fish | source"
echo "   In future terminals, this will happen automatically thanks to the config file update."
echo
echo "📚 Installed versions:"
echo "   Node.js → $node_version"
echo "   npm     → v$npm_version"
echo
echo "💡 Quick start:"
echo "   node --version        # Check Node.js version"
echo "   npm init -y           # Create a new project"
echo "   npx create-next-app   # Create a Next.js app"
