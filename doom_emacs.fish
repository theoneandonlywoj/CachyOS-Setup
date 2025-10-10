#!/usr/bin/env fish
# === doom_emacs.fish ===
# Purpose: Install Doom Emacs safely on CachyOS (or any Arch-based Linux)
# Author: theoneandonlywoj

echo "🧠 Starting Doom Emacs setup..."

# === 1. Backup existing ~/.emacs.d if it exists ===
if test -d ~/.emacs.d
    set timestamp (date "+%Y_%m_%d_%H_%M_%S")
    set backup_dir ~/.emacs.d.backup_$timestamp
    echo "⚠️  Existing ~/.emacs.d found. Backing up to $backup_dir..."
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

# === 3. Ensure the Doom script is executable ===
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

# === 5. Run Doom Emacs installer ===
echo "⚙️ Running Doom Emacs installer..."
~/.emacs.d/bin/doom install
if test $status -ne 0
    echo "❌ Doom installer failed."
    exit 1
end

# === 6. Add Doom to PATH for Fish shell ===
set -U fish_user_paths $HOME/.emacs.d/bin $fish_user_paths
echo "✅ Doom Emacs installed and added to PATH."

# === 7. Automatically run doom sync ===
echo "🔄 Running 'doom sync' to install packages and compile configs..."
doom sync
if test $status -ne 0
    echo "❌ Doom sync failed. Please try running manually: doom sync"
else
    echo "✅ Doom sync completed successfully."
end

echo
# Markdown and Shellcheck
sudo pacman -S --noconfirm python-markdown shellcheck
# Markdown symlink to markdown_py
sudo ln -s /usr/bin/markdown_py /usr/local/bin/markdown
echo "🚀 Doom Emacs is ready to use!"
echo "📚 Your existing configuration in ~/.doom.d has been preserved."
echo "📦 Your previous ~/.emacs.d backup is located at: $backup_dir"

