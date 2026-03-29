#!/usr/bin/env fish
# === zoxide.fish ===
# Purpose: Install zoxide (smarter cd command) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "Starting zoxide setup..."
echo

# === 1. Check if zoxide is already installed ===
if command -v zoxide > /dev/null
    echo "zoxide is already installed."
    zoxide --version 2>&1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "Skipping zoxide installation."
        exit 0
    end
    echo "Removing existing zoxide installation..."
    sudo pacman -R --noconfirm zoxide
    if test $status -ne 0
        echo "Failed to remove zoxide. Aborting."
        exit 1
    end
    echo "zoxide removed."
end

# === 2. Install zoxide via pacman ===
echo "Installing zoxide from official repository..."
sudo pacman -S --needed --noconfirm zoxide
if test $status -ne 0
    echo "zoxide installation failed. Aborting."
    exit 1
end

# === 3. Verify zoxide installation ===
if not command -v zoxide > /dev/null
    echo "zoxide binary not found in PATH after installation. Aborting."
    exit 1
end

set zoxide_version (zoxide --version 2>/dev/null)
echo "zoxide installed successfully: $zoxide_version"

# === 4. Configure fish shell integration ===
echo "Configuring fish shell integration..."

set fish_config ~/.config/fish/config.fish

if not test -f $fish_config
    echo "Fish config not found. Creating $fish_config..."
    mkdir -p (dirname $fish_config)
    touch $fish_config
end

if grep -q "zoxide init fish" $fish_config
    echo "zoxide shell integration already configured in $fish_config"
else
    echo "" >> $fish_config
    echo "# === Zoxide (smarter cd) ===" >> $fish_config
    echo "zoxide init fish | source" >> $fish_config
    echo "zoxide shell integration added to $fish_config"
end

# Load zoxide into current shell
zoxide init fish | source

# === 5. Verify shell integration ===
echo "Verifying shell integration..."

if type -q z
    echo "Shell integration verified: 'z' command is available."
else
    echo "Shell integration could not be verified in the current session."
    echo "Restart your terminal or run: source $fish_config"
end

echo
echo "zoxide setup complete!"
echo
echo "Important:"
echo "   zoxide learns your most-used directories over time."
echo "   The more you use it, the smarter it gets."
echo
echo "Quick start:"
echo "   z foo        -> Jump to the highest-ranked directory matching 'foo'"
echo "   z foo bar    -> Jump to the highest-ranked directory matching 'foo' and 'bar'"
echo "   zi foo       -> Interactive selection with fzf (if installed)"
echo
echo "Useful commands:"
echo "   z ~          -> Go to home directory"
echo "   z -          -> Go to previous directory"
echo "   zoxide query -> Show the current database entries"
echo "   zoxide edit  -> Edit the database"
echo
