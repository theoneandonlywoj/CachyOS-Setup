#!/usr/bin/env fish
# === zed.fish ===
# Purpose: Install Zed editor on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Zed editor setup..."
echo

# === 1. Check for required dependencies ===
if not command -v curl > /dev/null
    echo "📦 Installing curl (required for Zed installation)..."
    sudo pacman -S --needed --noconfirm curl
    if test $status -ne 0
        echo "❌ Failed to install curl. Aborting."
        exit 1
    end
end

# === 2. Install Zed via official installation script ===
echo "🔧 Installing Zed editor via official installation script..."
echo "   This will download and run the official Zed installer from zed.dev"
echo

# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

run_installer https://zed.dev/install.sh
if test $status -ne 0
    echo "❌ Zed install/update failed. Rerun: ./zed.fish"
    exit 1
end

# === 3. Add Zed to PATH if not already present ===
set zed_bin_path ~/.local/bin
if not string match -q "*$zed_bin_path*" $PATH
    echo "🔧 Adding Zed to PATH in current session..."
    set -x PATH $zed_bin_path $PATH
end

# === 4. Add PATH update to Fish config if not already present ===
set fish_config_file ~/.config/fish/config.fish
set path_line "set -x PATH ~/.local/bin \$PATH"

if not grep -Fxq "$path_line" $fish_config_file
    echo "$path_line" >> $fish_config_file
    echo "🔧 Added Zed binary path to $fish_config_file"
end

# === 5. Verify installation ===
echo "🧪 Verifying installation..."
# Reload PATH to ensure zed is available
set -x PATH ~/.local/bin $PATH

set zed_version (command zed --version 2>/dev/null)

if test -n "$zed_version"
    echo "✅ Zed installed successfully: $zed_version"
else
    echo "⚠️  Zed installation completed, but version check failed."
    echo "   This may be normal if Zed needs a shell restart to be available."
    echo "   Try running 'zed --version' in a new terminal."
end

echo
echo "🎉 Zed editor setup complete!"
echo
echo "💡 Important:"
echo "   To use 'zed' in this terminal immediately, run:"
echo "       set -x PATH ~/.local/bin \$PATH"
echo "   Or simply open a new terminal - it will be available automatically."
echo
echo "📚 Usage:"
echo "   zed                    # Open Zed editor"
echo "   zed .                  # Open current directory in Zed"
echo "   zed /path/to/file      # Open a specific file"
echo "   zed --version          # Check installed version"
echo

