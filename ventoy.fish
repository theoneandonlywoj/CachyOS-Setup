#!/usr/bin/env fish
# === ventoy.fish ===
# Purpose: Install Ventoy on CachyOS
# Installs Ventoy bootable USB solution from AUR
# Author: theoneandonlywoj

echo "🚀 Starting Ventoy installation..."

# === 1. Check if Ventoy is already installed ===
command -q ventoy; and set -l ventoy_installed "installed"
if test -n "$ventoy_installed"
    echo "✅ Ventoy is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Ventoy installation."
        exit 0
    end
    echo "📦 Removing existing Ventoy installation..."
    paru -R --noconfirm ventoy-bin
    if test $status -ne 0
        echo "❌ Failed to remove Ventoy."
        exit 1
    end
    echo "✅ Ventoy removed."
end

# === 2. Check for AUR helper ===
if not command -q paru
    echo "❌ paru (AUR helper) is not installed."
    echo "💡 Please install paru first: sudo pacman -S paru"
    exit 1
end

# === 3. Install Ventoy ===
echo "📦 Installing Ventoy from AUR..."
paru -S --needed --noconfirm ventoy-bin
if test $status -ne 0
    echo "❌ Failed to install Ventoy."
    exit 1
end
echo "✅ Ventoy installed."

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q ventoy
if test $status -eq 0
    echo "✅ Ventoy installed successfully"
    ventoy --version 2>&1 | head -n 1
else
    echo "❌ Ventoy installation verification failed."
end

echo
echo "✅ Ventoy installation complete!"
echo "💡 Ventoy is a bootable USB solution:"
echo "   - Create multiboot USB drives"
echo "   - Boot ISO/WIM/IMG/VHD(x)/EFI files directly"
echo "   - No need to reformat for new ISOs"
echo "   - Supports Secure Boot"
echo "💡 Launch Ventoy:"
echo "   - GUI: sudo ventoygui"
echo "   - Web UI: sudo ventoyweb (browser-based)"
echo "   - CLI: sudo ventoy -i /dev/sdX (install to USB)"
echo "   - CLI: sudo ventoy -u /dev/sdX (update existing)"
echo "💡 Find and mount USB (CachyOS / Fish):"
echo "   - List block devices: lsblk"
echo "   - USB is usually /dev/sdb or /dev/sdc (first partition: /dev/sdb1)"
echo "   - Mount (no sudo): udisksctl mount -b /dev/sdX1"
echo "   - Unmount: udisksctl unmount -b /dev/sdX1"
echo "   - Auto-mounted USBs appear under: /run/media/\$USER/"
echo "   - Eject safely: udisksctl power-off -b /dev/sdX"
echo "💡 Tips:"
echo "   - Insert USB drive before running Ventoy"
echo "   - All data on USB will be erased during initial install"
echo "   - After install, just copy ISO files to the USB"
echo "   - Supports 900+ ISO files (Linux, Windows, etc.)"
