#!/usr/bin/env fish
# === handy.fish ===
# Purpose: Install Handy (offline speech-to-text) from AUR on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Handy (offline speech-to-text) installation from AUR..."

# === 1. Install Handy (offline speech-to-text) from AUR (never upgrade an installed package) ===
# handy (source build) conflicts with handy-bin, so it counts as installed.
set -l installed (pacman -Qq handy-bin handy 2>/dev/null)
if test -n "$installed"
    echo "✅ Handy (offline speech-to-text) is already installed ($installed); upgrades come from 'paru -Syu'."
else
    set -l aur_helper
    if command -q paru
        set aur_helper paru
    else if command -q yay
        set aur_helper yay
    else
        echo "❌ No AUR helper found: install paru first, then rerun: ./handy.fish"
        exit 1
    end

    echo "📦 Installing Handy (offline speech-to-text) from AUR using $aur_helper..."
    $aur_helper -S --needed --noconfirm handy-bin
    if test $status -ne 0
        echo "❌ Failed to install Handy (offline speech-to-text) from AUR. Rerun: ./handy.fish"
        exit 1
    end
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
set installed (pacman -Qq handy-bin handy 2>/dev/null)
if test -z "$installed"
    echo "❌ Handy (offline speech-to-text) installation verification failed."
    exit 1
end
pacman -Q $installed

echo
echo "✅ Handy (offline speech-to-text) setup complete!"
echo "💡 Start Handy from the applications menu, then download a model in its settings."
echo "💡 Text input needs wtype (Wayland) or xdotool (X11)."
