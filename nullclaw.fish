#!/usr/bin/env fish
# === nullclaw.fish ===
# Purpose: Install Zig 0.15.2 via Mise and build Nullclaw from source on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set ZIG_VERSION 0.15.2
set NULLCLAW_REPO "https://github.com/nullclaw/nullclaw.git"
set NULLCLAW_BUILD_DIR /tmp/nullclaw-build

echo "🚀 Starting Nullclaw setup via Mise..."
echo "📌 Target versions:"
echo "   Zig       → $ZIG_VERSION"
echo "   Nullclaw  → latest (from source)"
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

# === 3. Install Zig via Mise (skip if already installed) ===
if mise list zig 2>/dev/null | grep -q "$ZIG_VERSION"
    echo "✅ Zig $ZIG_VERSION is already installed via Mise. Skipping."
else
    echo "🔧 Installing Zig $ZIG_VERSION via Mise..."
    mise install zig@$ZIG_VERSION
    if test $status -ne 0
        echo "❌ Zig installation failed. Aborting."
        exit 1
    end
end

mise use -g zig@$ZIG_VERSION
if test $status -ne 0
    echo "❌ Failed to set Zig $ZIG_VERSION as global version. Aborting."
    exit 1
end

# Reload PATH to pick up Zig
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source

# === 4. Clone and build Nullclaw from source ===
echo "📦 Cloning Nullclaw repository..."
rm -rf $NULLCLAW_BUILD_DIR
git clone $NULLCLAW_REPO $NULLCLAW_BUILD_DIR
if test $status -ne 0
    echo "❌ Failed to clone Nullclaw repository. Aborting."
    exit 1
end

echo "🔧 Building Nullclaw..."
cd $NULLCLAW_BUILD_DIR
zig build -Doptimize=ReleaseSmall
if test $status -ne 0
    echo "❌ Nullclaw build failed. Aborting."
    exit 1
end

# === 5. Install Nullclaw to ~/.local/bin ===
echo "📦 Installing Nullclaw to ~/.local..."
zig build -Doptimize=ReleaseSmall -p "$HOME/.local"
if test $status -ne 0
    echo "❌ Nullclaw installation failed. Aborting."
    exit 1
end

# === 6. Ensure ~/.local/bin is in Fish PATH if not already ===
set fish_config_file ~/.config/fish/config.fish
set path_line "fish_add_path ~/.local/bin"

if not grep -Fxq "$path_line" $fish_config_file
    echo "$path_line" >> $fish_config_file
    echo "🔧 Added ~/.local/bin to PATH in $fish_config_file"
end

# Ensure it's available now
fish_add_path ~/.local/bin

# === 7. Clean up build directory ===
echo "🧹 Cleaning up build directory..."
rm -rf $NULLCLAW_BUILD_DIR

# === 8. Verify installations ===
echo "🧪 Verifying installations..."
set zig_ver (command zig version 2>/dev/null)
set nullclaw_ver (command nullclaw --version 2>/dev/null)

if test -n "$zig_ver"
    echo "✅ Zig installed successfully: v$zig_ver"
else
    echo "❌ Zig verification failed."
end

if test -n "$nullclaw_ver"
    echo "✅ Nullclaw installed successfully: $nullclaw_ver"
else
    echo "❌ Nullclaw verification failed."
end

echo
echo "🎉 Nullclaw setup complete!"
echo
echo "💡 Usage:"
echo "   nullclaw --help"
echo
echo "📚 Installed versions:"
echo "   Zig       → $ZIG_VERSION"
echo "   Nullclaw  → $nullclaw_ver"
