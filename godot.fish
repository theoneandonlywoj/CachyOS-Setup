#!/usr/bin/env fish
# === godot.fish ===
# Purpose: Install the Godot game engine on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Godot installation..."

# === 1. Install Godot ===
sudo pacman -S --needed --noconfirm godot
if test $status -ne 0
    echo "❌ Failed to install Godot. Rerun: ./godot.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q godot
    echo "❌ Godot installation verification failed: godot is not on PATH."
    exit 1
end
godot --version

# === 3. Offer the C#/.NET build ===
if pacman -Qq godot-mono >/dev/null 2>&1
    echo "✅ godot-mono is already installed; upgrades come from 'paru -Syu'."
else if test -t 0
    read -P "Install godot-mono (C#/.NET build) too? [y/N] " install_mono
    if test "$install_mono" = y -o "$install_mono" = Y
        sudo pacman -S --needed --noconfirm godot-mono
        if test $status -ne 0
            echo "❌ Failed to install godot-mono; godot is installed. Rerun: ./godot.fish"
            exit 1
        end
    end
end

echo
echo "✅ Godot setup complete!"
echo "💡 Run: godot (project manager), or godot -e --path <project>"
