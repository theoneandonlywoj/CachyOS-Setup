#!/usr/bin/env fish
# === 1password.fish ===
# Purpose: Install 1Password from AUR on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting 1Password installation from AUR..."

# === 1. Install 1Password from AUR (never upgrade an installed package) ===
# The PKGBUILD checks the download against its validpgpkeys signing key.
set -l installed (pacman -Qq 1password 1password-beta 1password-beta-bin 2>/dev/null)
if test -n "$installed"
    echo "✅ 1Password is already installed ($installed); upgrades come from 'paru -Syu'."
else
    set -l aur_helper
    if command -q paru
        set aur_helper paru
    else if command -q yay
        set aur_helper yay
    else
        echo "❌ No AUR helper found: install paru first, then rerun: ./1password.fish"
        exit 1
    end

    echo "📦 Installing 1Password from AUR using $aur_helper..."
    $aur_helper -S --needed --noconfirm 1password
    if test $status -ne 0
        echo "❌ Failed to install 1Password from AUR. Rerun: ./1password.fish"
        echo "💡 If it asked for the signing key, import it and rerun:"
        echo "   gpg --recv-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22"
        exit 1
    end
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
set installed (pacman -Qq 1password 1password-beta 1password-beta-bin 2>/dev/null)
if test -z "$installed"
    echo "❌ 1Password installation verification failed."
    exit 1
end
pacman -Q $installed

echo
echo "✅ 1Password setup complete!"
echo "💡 Run: 1password"
