#!/usr/bin/env fish
# === google_chrome.fish ===
# Purpose: Install Google Chrome from AUR on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Google Chrome installation from AUR..."

# === 1. Install Google Chrome from AUR (never upgrade an installed package) ===
set -l installed (pacman -Qq google-chrome 2>/dev/null)
if test -n "$installed"
    echo "✅ Google Chrome is already installed ($installed); upgrades come from 'paru -Syu'."
else
    set -l aur_helper
    if command -q paru
        set aur_helper paru
    else if command -q yay
        set aur_helper yay
    else
        echo "❌ No AUR helper found: install paru first, then rerun: ./google_chrome.fish"
        exit 1
    end

    echo "📦 Installing Google Chrome from AUR using $aur_helper..."
    $aur_helper -S --needed --noconfirm google-chrome
    if test $status -ne 0
        echo "❌ Failed to install Google Chrome from AUR. Rerun: ./google_chrome.fish"
        exit 1
    end
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
set installed (pacman -Qq google-chrome 2>/dev/null)
if test -z "$installed"
    echo "❌ Google Chrome installation verification failed."
    exit 1
end
pacman -Q $installed

echo
echo "✅ Google Chrome setup complete!"
echo "💡 Run: google-chrome-stable"
