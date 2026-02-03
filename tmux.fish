#!/usr/bin/env fish
# === tmux.fish ===
# Purpose: Install tmux terminal multiplexer on CachyOS
# Installs tmux from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting tmux installation..."

# === 1. Check if tmux is already installed ===
command -q tmux; and set -l tmux_installed "installed"
if test -n "$tmux_installed"
    echo "✅ tmux is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping tmux installation."
        exit 0
    end
    echo "📦 Removing existing tmux installation..."
    sudo pacman -R --noconfirm tmux
    if test $status -ne 0
        echo "❌ Failed to remove tmux."
        exit 1
    end
    echo "✅ tmux removed."
end

# === 2. Install tmux ===
echo "📦 Installing tmux..."
sudo pacman -S --needed --noconfirm tmux
if test $status -ne 0
    echo "❌ Failed to install tmux."
    exit 1
end
echo "✅ tmux installed."

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q tmux
if test $status -eq 0
    echo "✅ tmux installed successfully"
    tmux -V
else
    echo "❌ tmux installation verification failed."
end

echo
echo "✅ tmux installation complete!"
echo "💡 tmux is a terminal multiplexer: run multiple sessions in one window."
echo "💡 Launch: tmux"
echo "💡 Essential key bindings (default prefix: Ctrl+b):"
echo "   - Ctrl+b d     Detach (session keeps running)"
echo "   - tmux attach  Reattach to a session"
echo "   - Ctrl+b c     New window"
echo "   - Ctrl+b n/p   Next/previous window"
echo "   - Ctrl+b %     Split pane vertically"
echo "   - Ctrl+b \"     Split pane horizontally"
echo "   - Ctrl+b arrow Navigate between panes"
echo "💡 Tips:"
echo "   - Use tmux for long-running tasks (survives disconnects)"
echo "   - Configure ~/.tmux.conf for custom key bindings and themes"
