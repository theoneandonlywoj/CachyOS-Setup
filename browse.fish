#!/usr/bin/env fish
# === browse.fish ===
# Purpose: Install or update browse (browser control for coding agents) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting browse installation..."

# === 1. Ensure ~/.local/bin exists and is in PATH (installer target) ===
mkdir -p "$HOME/.local/bin"
if test $status -ne 0
    echo "❌ Failed to create ~/.local/bin."
    exit 1
end

# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if not contains -- "$HOME/.local/bin" $PATH
    fish_add_path -U "$HOME/.local/bin"
    if test $status -ne 0
        echo "❌ Failed to add ~/.local/bin to the Fish PATH."
        exit 1
    end
end

# === 2. Install or update browse (official installer) ===
# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

# --no-setup: without it the installer ends by running "browse install", even without a terminal.
run_installer https://opencode.ai/browse/install --no-setup
if test $status -ne 0
    echo "❌ browse install/update failed; an existing install is untouched. Rerun: ./browse.fish"
    exit 1
end

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
command -q browse; and browse --version
if test $status -ne 0
    echo "❌ browse installation verification failed."
    exit 1
end

# === 4. Optional agent setup (terminal only) ===
if test -t 0
    read -l -P "Run 'browse install' to add browse to your agents and pair a browser? [y/N] " reply
    if test "$reply" = "y" -o "$reply" = "Y"
        browse install
        if test $status -ne 0
            echo "⚠️  Agent setup failed. Retry: browse install"
        end
    end
end

echo
echo "✅ browse setup complete!"
echo "💡 Set up agents: browse install   (check with: browse doctor)"
exit 0
