#!/usr/bin/env fish
# === prime_agent.fish ===
# Purpose: Install or update Prime Agent (Prime Intellect) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Prime Agent installation..."

# === 1. Refuse when the npm package is present ===
# The repository's .tool-versions must not pick the Node: use the global one.
cd "$HOME"; or exit 1

# The installer runs "npm uninstall -g prime-agent" when it finds that package.
set -l npm_roots
if command -q npm
    set -a npm_roots (npm root -g 2>/dev/null)
end
if command -q mise; and mise which npm >/dev/null 2>&1
    set -a npm_roots (mise exec -- npm root -g 2>/dev/null)
end
if test -x /usr/bin/npm
    # With its own node: mise's node would make it report mise's root.
    set -a npm_roots (env PATH=/usr/bin:/bin /usr/bin/npm root -g 2>/dev/null)
end
for root in $npm_roots
    if test -f "$root/prime-agent/package.json"
        echo "❌ The npm package prime-agent is installed in $root, and the installer would remove it."
        echo "💡 Uninstall it first (npm uninstall -g prime-agent), then rerun: ./prime_agent.fish"
        exit 1
    end
end

# === 2. Ensure ~/.local/bin exists and is in PATH (installer target) ===
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

# === 3. Install or update Prime Agent (official installer) ===
# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

echo "⚠️  The installer stops running prime-agent daemons (sessions stay on disk)."
echo "💡 It also installs uv into ~/.local/bin when uv is missing."
run_installer https://app.primeintellect.ai/prime-agent/install.sh
if test $status -ne 0
    echo "❌ Prime Agent install/update failed. Rerun: ./prime_agent.fish"
    exit 1
end

# === 4. Verify installation ===
echo "🧪 Verifying installation..."
command -q prime-agent; and prime-agent --version
if test $status -ne 0
    echo "❌ Prime Agent installation verification failed."
    exit 1
end

echo
echo "✅ Prime Agent setup complete!"
echo "💡 First use: cd ~/my-project; and prime-agent"
echo "💡 Roll back: prime-agent update --rollback"
