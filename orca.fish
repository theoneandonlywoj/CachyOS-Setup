#!/usr/bin/env fish
# === orca.fish ===
# Purpose: Install Stably Orca (agentic coding IDE) from AUR on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Stably Orca (agentic coding IDE) installation from AUR..."

# === 1. Install Stably Orca (agentic coding IDE) from AUR (never upgrade an installed package) ===
# Detect by package name only: /usr/bin/orca is the GNOME screen reader.
# stably-orca and stably-orca-git conflict with stably-orca-bin, so they count as installed.
set -l installed (pacman -Qq stably-orca-bin stably-orca stably-orca-git 2>/dev/null)
if test -n "$installed"
    echo "✅ Stably Orca (agentic coding IDE) is already installed ($installed); upgrades come from 'paru -Syu'."
else
    set -l aur_helper
    if command -q paru
        set aur_helper paru
    else if command -q yay
        set aur_helper yay
    else
        echo "❌ No AUR helper found: install paru first, then rerun: ./orca.fish"
        exit 1
    end

    echo "📦 Installing Stably Orca (agentic coding IDE) from AUR using $aur_helper..."
    $aur_helper -S --needed --noconfirm stably-orca-bin
    if test $status -ne 0
        echo "❌ Failed to install Stably Orca (agentic coding IDE) from AUR. Rerun: ./orca.fish"
        exit 1
    end
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
set installed (pacman -Qq stably-orca-bin stably-orca stably-orca-git 2>/dev/null)
if test -z "$installed"
    echo "❌ Stably Orca (agentic coding IDE) installation verification failed."
    exit 1
end
pacman -Q $installed

echo
echo "✅ Stably Orca (agentic coding IDE) setup complete!"
echo "💡 Run: stably-orca (the orca command is the GNOME screen reader)"
