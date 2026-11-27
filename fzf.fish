#!/usr/bin/env fish
# === fzf.fish ===
# Purpose: Install fzf (fuzzy finder) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting fzf installation..."

# === 1. Install fzf ===
sudo pacman -S --needed --noconfirm fzf
if test $status -ne 0
    echo "❌ Failed to install fzf. Rerun: ./fzf.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q fzf
    echo "❌ fzf installation verification failed: fzf is not on PATH."
    exit 1
end
fzf --version
if not fzf --fish >/dev/null
    echo "❌ This fzf has no Fish integration (fzf --fish needs 0.48+); config.fish is unchanged. Upgrade it with 'paru -Syu', then rerun: ./fzf.fish"
    exit 1
end

# === 3. Add the Fish shell integration once ===
set -l fish_config ~/.config/fish/config.fish
if not test -f $fish_config
    mkdir -p (dirname $fish_config); and touch $fish_config
    if test $status -ne 0
        echo "❌ Failed to create $fish_config."
        exit 1
    end
end

if grep -q 'fzf --fish' $fish_config
    echo "✅ fzf shell integration is already in $fish_config"
else
    printf '\n# === fzf ===\nfzf --fish | source\n' >> $fish_config
    if test $status -ne 0
        echo "❌ Failed to write $fish_config."
        exit 1
    end
    echo "✅ fzf shell integration added to $fish_config"
end

echo
echo "✅ fzf setup complete!"
echo "💡 Open a new terminal: Ctrl+T finds files, Alt+C changes directory, Ctrl+R searches history"
echo "💡 atuin owns Ctrl+R when both atuin and fzf are installed: keep the atuin line"
echo "   after the fzf line in ~/.config/fish/config.fish (the last one loaded wins)."
