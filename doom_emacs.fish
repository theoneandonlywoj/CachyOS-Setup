#!/usr/bin/env fish
# === doom_emacs_full.fish ===
# Purpose: Full Doom Emacs setup on CachyOS (Arch Linux)
# Includes: backup, install Doom, Markdown, ShellCheck
# Author: theoneandonlywoj

echo "🧠 Starting Doom Emacs full setup..."

# === 1. Backup existing ~/.emacs.d if it exists ===
if test -d ~/.emacs.d
    set timestamp (date "+%Y_%m_%d_%H_%M_%S")
    set backup_dir ~/.emacs.d.backup_$timestamp
    echo "⚠ Existing ~/.emacs.d found. Backing up to $backup_dir..."
    mv ~/.emacs.d $backup_dir
    if test $status -ne 0
        echo "❌ Failed to move ~/.emacs.d. Aborting."
        exit 1
    end
end

# === 2. Clone Doom Emacs ===
echo "📦 Cloning Doom Emacs repository..."
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
if test $status -ne 0
    echo "❌ Failed to clone Doom Emacs. Aborting."
    exit 1
end

# === 3. Make doom script executable ===
chmod +x ~/.emacs.d/bin/doom
if test $status -ne 0
    echo "❌ Failed to make doom script executable. Aborting."
    exit 1
end

# === 4. Preserve existing Doom config if present ===
if test -d ~/.doom.d
    echo "✅ Existing ~/.doom.d configuration detected. It will NOT be replaced."
else
    echo "📁 Creating new ~/.doom.d folder..."
    mkdir -p ~/.doom.d
end

# === 5. Run Doom installer ===
echo "⚙ Running Doom Emacs installer..."
~/.emacs.d/bin/doom install
if test $status -ne 0
    echo "❌ Doom installer failed."
    exit 1
end

# === 6. Add Doom to PATH ===
set -U fish_user_paths $HOME/.emacs.d/bin $fish_user_paths
echo "✅ Doom Emacs installed and added to PATH."

# === 7. Doom sync ===
echo "🔄 Running 'doom sync'..."
doom sync
if test $status -ne 0
    echo "❌ Doom sync failed. Please run manually."
else
    echo "✅ Doom sync completed successfully."
end

# === 8. Install Markdown CLI and ShellCheck ===
echo "📚 Installing Markdown CLI and ShellCheck..."
sudo pacman -S --noconfirm python-markdown shellcheck

# Symlink markdown_py → markdown
if not test -f /usr/local/bin/markdown
    sudo ln -s /usr/bin/markdown_py /usr/local/bin/markdown
    echo "🔗 Created symlink: /usr/local/bin/markdown → /usr/bin/markdown_py"
end

# === 9. Reminder for Nerd Fonts ===
echo
echo "🎨 Nerd Fonts installation is not automated in this script."
echo "   To remove Doom doctor warnings about missing fonts, please:"
echo "   1. Open Doom Emacs: emacs"
echo "   2. Run: M-x nerd-icons-install-fonts"
echo "   3. Restart Emacs after installation"
echo "💡 This will install the necessary Nerd Fonts for icons and UI."

echo
echo "🚀 Doom Emacs setup complete!"
echo "📚 Your existing configuration in ~/.doom.d has been preserved."
echo "📦 Backup of previous ~/.emacs.d: $backup_dir"

