#!/usr/bin/env fish
# === slack.fish ===
# Purpose: Install Slack from AUR on CachyOS
# Installs Slack from AUR
# Author: theoneandonlywoj

echo "🚀 Starting Slack installation from AUR..."

# === 1. Install Slack from AUR (never upgrade an installed package) ===
if pacman -Qq slack-desktop >/dev/null 2>&1
    echo "✅ Slack is already installed; upgrades come from 'paru -Syu'."
else
    set -l aur_helper
    if command -q paru
        set aur_helper paru
    else if command -q yay
        set aur_helper yay
    else if test -t 0
        echo "⚠ No AUR helper found."
        read -l -P "Do you want to install yay (AUR helper)? [Y/n] " install_helper
        if test "$install_helper" = "n" -o "$install_helper" = "N"
            echo "❌ An AUR helper is required to install Slack."
            exit 1
        end
        set -l build_dir (mktemp -d)
        git clone https://aur.archlinux.org/yay-bin.git $build_dir/yay-bin
        and cd $build_dir/yay-bin
        and makepkg -si --noconfirm
        if test $status -ne 0
            echo "❌ Failed to install yay. Rerun: ./slack.fish"
            exit 1
        end
        cd -
        rm -rf $build_dir
        set aur_helper yay
    else
        echo "❌ No AUR helper found: install paru first"
        exit 1
    end

    echo "📦 Installing Slack from AUR using $aur_helper..."
    $aur_helper -S --needed --noconfirm slack-desktop
    or begin; echo "❌ Failed to install Slack from AUR. Rerun: ./slack.fish"; exit 1; end
end

# === 2. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q slack
if test $status -eq 0
    echo "✅ Slack installed successfully"
    slack --version 2>&1 | head -n 1
else
    echo "❌ Slack installation verification failed."
end

echo
echo "✅ Slack installation complete!"
echo "💡 Slack is a team communication platform:"
echo "   - Team messaging and collaboration"
echo "   - Channels and direct messages"
echo "   - File sharing and integrations"
echo "   - Voice and video calls"
echo "   - Workspace management"
echo "💡 You can now launch Slack from:"
echo "   - Applications menu (Network category)"
echo "   - Command line: slack"
echo "💡 Getting started:"
echo "   1. Sign in to your Slack workspace"
echo "   2. Join channels or create your own"
echo "   3. Message team members"
echo "   4. Set up integrations and bots"
echo "💡 Features:"
echo "   - Multiple workspaces support"
echo "   - Rich text formatting"
echo "   - File sharing and preview"
echo "   - Search across messages and files"
echo "   - Custom emoji and reactions"
echo "💡 Tips:"
echo "   - Use / commands for quick actions"
echo "   - Press Ctrl+K to jump to channels"
echo "   - Set do-not-disturb hours"
echo "   - Customize notifications"

