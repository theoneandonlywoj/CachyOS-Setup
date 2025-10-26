#!/usr/bin/env fish
# === slack.fish ===
# Purpose: Install Slack from AUR on CachyOS
# Installs Slack from AUR
# Author: theoneandonlywoj

echo "🚀 Starting Slack installation from AUR..."

# === 1. Check if Slack is already installed ===
command -q slack; and set -l slack_installed "installed"
if test -n "$slack_installed"
    echo "✅ Slack is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Slack installation."
        exit 0
    end
    echo "📦 Removing existing Slack installation..."
    sudo pacman -R --noconfirm slack-desktop
    if test $status -ne 0
        echo "❌ Failed to remove Slack."
        exit 1
    end
    echo "✅ Slack removed."
end

# === 2. Check for AUR helper ===
command -q yay; and set -l yay_installed "installed"
command -q paru; and set -l paru_installed "installed"

if test -z "$yay_installed" -a -z "$paru_installed"
    echo "⚠ No AUR helper found."
    read -P "Do you want to install yay (AUR helper)? [Y/n] " install_helper
    
    if test "$install_helper" != "n" -a "$install_helper" != "N"
        echo "📦 Installing yay..."
        cd /tmp
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin
        makepkg -si --noconfirm
        if test $status -ne 0
            echo "❌ Failed to install yay."
            exit 1
        end
        echo "✅ yay installed."
    else
        echo "❌ yay is required to install Slack from AUR."
        exit 1
    end
else
    echo "✅ AUR helper found."
end

# === 3. Install Slack from AUR ===
set aur_helper "yay"
if test -n "$paru_installed"
    set aur_helper "paru"
end

echo "📦 Installing Slack from AUR using $aur_helper..."
$aur_helper -S --noconfirm slack-desktop
if test $status -ne 0
    echo "❌ Failed to install Slack from AUR."
    exit 1
end
echo "✅ Slack installed."

# === 4. Check and fix snapper Boost library issue (if present) ===
if test -f /usr/bin/snapper
    echo
    echo "🔧 Checking for snapper Boost library issue..."
    snapper --version > /dev/null 2>&1
    if test $status -ne 0
        echo "⚠ Detected snapper Boost library version mismatch."
        echo "💡 This can happen after Boost updates."
        read -P "Do you want to fix snapper? [y/N] " fix_snapper
        
        if test "$fix_snapper" = "y" -o "$fix_snapper" = "Y"
            echo "📦 Reinstalling snapper to fix Boost library version mismatch..."
            sudo pacman -S --noconfirm snapper
            if test $status -eq 0
                echo "✅ Snapper fixed successfully."
            else
                echo "⚠ Failed to fix snapper, but Slack is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
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

