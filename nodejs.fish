#!/usr/bin/env fish
# === nodejs.fish ===
# Purpose: Install Node.js 24+ via Mise on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set NODEJS_VERSION 24

echo "🚀 Starting Node.js setup via Mise..."
echo "📌 Target version:"
echo "   Node.js → $NODEJS_VERSION (latest LTS)"
echo

# === 1. Check Mise installation ===
# The repository's .tool-versions must not pick the Node: use the global one.
cd "$HOME"; or exit 1

if not command -v mise > /dev/null
    echo "❌ Mise is not installed. Please install it first using:"
    echo "   ./mise.fish"
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
mise use -g node@$NODEJS_VERSION
if test $status -ne 0
    echo "❌ Node.js installation failed. Rerun: ./nodejs.fish"
    exit 1
end
mise upgrade node
if test $status -ne 0
    echo "❌ Node.js update failed; the installed version is untouched. Rerun: ./nodejs.fish"
    exit 1
end

# Reload PATH again to be safe
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source

# === 5. Add automatic activation to Fish config if not already present ===
set fish_config_file ~/.config/fish/config.fish
set activation_line "mise activate fish | source"

if not grep -Fxq "$activation_line" $fish_config_file 2>/dev/null
    echo "$activation_line" >> $fish_config_file
    echo "🔧 Added automatic Mise activation to $fish_config_file"
end

# A script cannot change the PATH of the shell that started it, and that shell
# only runs config.fish at startup. Universal fish variables reach every running
# fish session at once, so putting the Mise shims on fish_user_paths makes
# 'node' work in the current terminal without opening a new one.
set mise_shims "$HOME/.local/share/mise/shims"
mise reshim
if not contains -- "$mise_shims" $fish_user_paths
    fish_add_path -U "$mise_shims"
    if test $status -ne 0
        echo "❌ Failed to add $mise_shims to the Fish PATH."
        exit 1
    end
    echo "🔧 Added Mise shims to the Fish PATH (applies to open terminals too)"
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
echo "💡 'node', 'npm' and 'npx' work in this terminal now, and in new ones."
echo
echo "📚 Installed versions:"
echo "   Node.js → $node_version"
echo "   npm     → v$npm_version"
echo
echo "💡 Quick start:"
echo "   node --version        # Check Node.js version"
echo "   npm init -y           # Create a new project"
echo "   npx create-next-app   # Create a Next.js app"
