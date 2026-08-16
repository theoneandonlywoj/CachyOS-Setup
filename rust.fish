#!/usr/bin/env fish
# === rust.fish ===
# Purpose: Install a specific version of Rust via Mise on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set RUST_VERSION stable

echo "🚀 Starting Rust setup via Mise..."
echo "📌 Target versions:"
echo "   Rust  → $RUST_VERSION"
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

# === 4. Install Rust via Mise ===
echo "🔧 Installing Rust $RUST_VERSION via Mise..."
mise install rust@$RUST_VERSION
mise use -g rust@$RUST_VERSION
if test $status -ne 0
    echo "❌ Rust installation failed. Aborting."
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

# === 6. Verify installation ===
echo "🧪 Verifying installations..."
set rust_version (command rustc --version 2>/dev/null)
set cargo_version (command cargo --version 2>/dev/null)

if test -n "$rust_version"
    echo "✅ Rust installed successfully: $rust_version"
else
    echo "❌ Rust verification failed."
end

if test -n "$cargo_version"
    echo "✅ Cargo installed successfully: $cargo_version"
else
    echo "❌ Cargo verification failed."
end

echo
echo "🎉 Rust setup complete via Mise!"
echo
echo "💡 Important:"
echo "   To use 'rustc', 'cargo', and 'rustup' in this terminal immediately,"
echo "   run the following command in your current shell:"
echo "       mise activate fish | source"
echo "   In future terminals, this will happen automatically thanks to the config file update."
echo
echo "📚 Installed versions:"
echo "   Rust  → $RUST_VERSION"
echo
echo "💡 To start a new Rust project:"
echo "   cargo new my_app"
