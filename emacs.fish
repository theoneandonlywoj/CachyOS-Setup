#!/usr/bin/env fish
# === emacs.fish ===
# Purpose: Install Emacs 30 on CachyOS (KDE Plasma, Fish shell)
# Author: theoneandonlywoj

echo "🧠 Welcome to Emacs 30 installer for CachyOS"
echo

# === 1. Update system safely ===
read -l -P "Would you like to update your system before installing Emacs? (Y/n) " update_choice
if test -z "$update_choice" -o (string lower $update_choice) = "y"
    echo "🔄 Updating package databases and system..."
    sudo pacman -Syu --noconfirm
    if test $status -ne 0
        echo "❌ System update failed. Please check your internet or mirrors."
        exit 1
    end
else
    echo "⚠️ Skipping system update."
end

# === 2. Check if Emacs is already installed ===
if type -q emacs
    set version (emacs --version | head -n 1)
    echo "✅ $version is already installed."
    read -l -P "Do you want to reinstall or upgrade to Emacs 30? (y/N) " reinstall
    if test (string lower $reinstall) != "y"
        echo "➡️  Keeping current Emacs installation."
        exit 0
    end
end

# === 3. Install Emacs 30 ===
echo "⚙️ Installing Emacs 30..."

# CachyOS usually provides emacs >=30 in the repos.
# If not found, offer the 'emacs-git' AUR package as fallback.
if pacman -Si emacs | grep -q "Version.*30"
    sudo pacman -S --noconfirm emacs
else
    echo "📦 Emacs 30 not found in main repos. Installing emacs-git (AUR) instead..."
    if not type -q yay
        echo "🔧 Installing yay (AUR helper)..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd -
    end
    yay -S --noconfirm emacs-git
end

if test $status -ne 0
    echo "❌ Emacs installation failed."
    exit 1
end

# === 4. Offer optional extras ===
echo
echo "✨ Optional tools that supercharge Emacs:"
echo "   - git       → version control integration"
echo "   - ripgrep   → ultra-fast search inside projects"
echo "   - fd        → better file finding"

read -l -P "Do you want to install these recommended tools? (Y/n) " extras
if test -z "$extras" -o (string lower $extras) = "y"
    sudo pacman -S --noconfirm git ripgrep fd
end

# === 5. Confirm success ===
echo
if type -q emacs
    set version (emacs --version | head -n 1)
    echo "✅ Installation successful! $version is now available."
    echo
    echo "🚀 You can start Emacs with: emacs"
    echo "📚 Docs: https://www.gnu.org/software/emacs/"
else
    echo "⚠️ Emacs installation completed but command not found. Try restarting your shell."
end

