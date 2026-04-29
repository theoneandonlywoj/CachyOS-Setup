#!/usr/bin/env fish
# Install squashfs-tools required by Nerves tooling

echo "Installing squashfs-tools for Nerves..."
sudo pacman -S --noconfirm squashfs-tools

if test $status -eq 0
    echo "✅ squashfs-tools installed successfully."
else
    echo "❌ Failed to install squashfs-tools."
    exit 1
end
