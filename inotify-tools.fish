#!/usr/bin/env fish
# === inotify-tools.fish ===
# Purpose: Install inotify-tools for file system monitoring on CachyOS
# Installs inotify-tools from official repositories
# Required for Elixir/Phoenix file system watchers and other applications
# Author: theoneandonlywoj

echo "🚀 Starting inotify-tools installation..."

# === 1. Check if inotify-tools is already installed ===
command -q inotifywait; and set -l inotify_installed "installed"
if test -n "$inotify_installed"
    echo "✅ inotify-tools is already installed."
    echo "💡 inotify-tools provides file system monitoring capabilities"
    echo "   Required for Elixir/Phoenix file watchers and other development tools"
    read -P "Do you want to update inotify-tools? [y/N] " update_inotify
    if test "$update_inotify" != "y" -a "$update_inotify" != "Y"
        echo "⚠ Skipping inotify-tools update."
        exit 0
    end
end

# === 2. Install/Update inotify-tools ===
echo "📦 Installing/updating inotify-tools..."
sudo pacman -S --needed --noconfirm inotify-tools
if test $status -ne 0
    echo "❌ Failed to install/update inotify-tools."
    exit 1
end
if test -n "$inotify_installed"
    echo "✅ inotify-tools updated."
else
    echo "✅ inotify-tools installed."
end

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q inotifywait
if test $status -eq 0
    echo "✅ inotify-tools installed successfully"
    echo "📌 Version information:"
    inotifywait --version 2>&1 | head -n 1
    echo
    echo "📌 Available commands:"
    echo "   - inotifywait: Monitor file system events"
    echo "   - inotifywatch: Gather statistics about file system events"
else
    echo "❌ inotify-tools installation verification failed."
    echo "💡 Try running: which inotifywait"
    exit 1
end

# === 4. Check executable location (for Elixir/Phoenix configuration) ===
echo
echo "🔍 Checking executable location..."
set -l inotifywait_path (which inotifywait)
if test -n "$inotifywait_path"
    echo "✅ Found inotifywait at: $inotifywait_path"
    echo "💡 If you need to configure this path in Elixir/Phoenix:"
    echo "   Set in config.exs:"
    echo "   config :file_system, :fsinotify_executable_file, \"$inotifywait_path\""
    echo "   Or set environment variable:"
    echo "   export FILESYSTEM_FSINOTIFY_EXECUTABLE_FILE=\"$inotifywait_path\""
else
    echo "⚠ Could not find inotifywait executable path."
    echo "💡 Try running: which inotifywait"
end

echo
echo "✅ inotify-tools installation complete!"
echo "💡 inotify-tools provides file system monitoring for:"
echo "   - Elixir/Phoenix file watchers (live reload, asset compilation)"
echo "   - Development tools that watch for file changes"
echo "   - Scripts that monitor directory changes"
echo "💡 Common use cases:"
echo "   - Phoenix development: Automatic code reloading"
echo "   - Asset pipelines: Rebuild on file changes"
echo "   - Backup scripts: Monitor directories for changes"
echo "💡 For more information:"
echo "   - man inotifywait"
echo "   - man inotifywatch"
echo "   - https://github.com/rvoicilas/inotify-tools/wiki"
