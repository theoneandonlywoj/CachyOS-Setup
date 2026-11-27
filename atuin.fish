#!/usr/bin/env fish
# === atuin.fish ===
# Purpose: Install Atuin (searchable shell history) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Atuin installation..."

# === 1. Install Atuin ===
sudo pacman -S --needed --noconfirm atuin
if test $status -ne 0
    echo "❌ Failed to install Atuin. Rerun: ./atuin.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q atuin
    echo "❌ Atuin installation verification failed: atuin is not on PATH."
    exit 1
end
atuin --version

# === 3. Add the Fish shell integration once ===
set -l fish_config ~/.config/fish/config.fish
if not test -f $fish_config
    mkdir -p (dirname $fish_config); and touch $fish_config
    if test $status -ne 0
        echo "❌ Failed to create $fish_config."
        exit 1
    end
end

if grep -q 'atuin init fish' $fish_config
    echo "✅ Atuin shell integration is already in $fish_config"
else
    printf '\n# === Atuin ===\natuin init fish | source\n' >> $fish_config
    if test $status -ne 0
        echo "❌ Failed to write $fish_config."
        exit 1
    end
    echo "✅ Atuin shell integration added to $fish_config"
end

echo
echo "✅ Atuin setup complete!"
echo "💡 Open a new terminal, then import the existing history once: atuin import auto"
echo "💡 atuin owns Ctrl+R when both atuin and fzf are installed: keep the atuin line"
echo "   after the fzf line in ~/.config/fish/config.fish (the last one loaded wins)."
