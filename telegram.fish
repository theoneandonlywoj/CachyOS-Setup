#!/usr/bin/env fish
# === telegram.fish ===
# Purpose: Install Telegram Desktop on CachyOS
# Installs Telegram Desktop via pacman (official Arch package)
# Author: theoneandonlywoj

echo "🚀 Starting Telegram Desktop installation..."

# === 1. Check if Telegram Desktop is already installed ===
command -q Telegram; and set -l telegram_installed "installed"
if test -n "$telegram_installed"
    echo "✅ Telegram Desktop is already installed."
    pacman -Q telegram-desktop 2>/dev/null
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Telegram Desktop installation."
        exit 0
    end
    echo "📦 Removing existing Telegram Desktop installation..."
    sudo pacman -Rns --noconfirm telegram-desktop
    if test $status -ne 0
        echo "❌ Failed to remove Telegram Desktop."
        exit 1
    end
    echo "✅ Telegram Desktop removed."
end

# === 2. Update package database ===
echo "📦 Updating package database..."
sudo pacman -Sy
if test $status -ne 0
    echo "❌ Failed to update package database."
    exit 1
end

# === 3. Install Telegram Desktop ===
echo "📦 Installing Telegram Desktop..."
sudo pacman -S --noconfirm telegram-desktop
if test $status -ne 0
    echo "❌ Failed to install Telegram Desktop."
    exit 1
end
echo "✅ Telegram Desktop installed."

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
# Rehash PATH to pick up newly installed binaries
hash -r 2>/dev/null
if test -x /usr/bin/Telegram; or command -q Telegram
    echo "✅ Telegram Desktop installed successfully."
    pacman -Q telegram-desktop 2>/dev/null
else
    echo "❌ Telegram Desktop installation verification failed."
    exit 1
end

echo
echo "✅ Telegram Desktop installation complete!"
echo "💡 Telegram Desktop is a fast and secure messaging app."
echo "💡 You can now run:"
echo "   - Telegram    # Launch Telegram Desktop"
echo "💡 Getting started:"
echo "   - Launch Telegram Desktop from your application menu"
echo "   - Or run 'Telegram' in the terminal"
echo "   - Log in with your phone number"
echo "💡 Features:"
echo "   - End-to-end encrypted secret chats"
echo "   - Cloud-based message syncing across devices"
echo "   - Large file sharing (up to 2GB)"
echo "   - Group chats, channels, and bots"
echo "💡 Tips:"
echo "   - Enable 2FA in Settings > Privacy and Security"
echo "   - Use Ctrl+K to quickly search chats"
echo "   - See https://telegram.org for more info"
