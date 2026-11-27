#!/usr/bin/env fish
# === toktrack.fish ===
# Purpose: Install or update toktrack (AI coding token and cost tracker) via cargo on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting toktrack setup via cargo..."

# === 1. Check prerequisites ===
# The repository's .tool-versions must not decide which tools mise activates.
cd "$HOME"; or exit 1

if not command -q mise; or not mise which cargo >/dev/null 2>&1
    echo "❌ cargo via Mise not found. Run ./rust.fish first, then rerun ./toktrack.fish."
    exit 1
end

# === 2. Install or update toktrack ===
# A git install only updates with --force; cargo keeps the old binary until the build succeeds.
mise exec -- cargo install --git https://github.com/mag123c/toktrack --force
if test $status -ne 0
    echo "❌ toktrack install/update failed; an existing binary is untouched. Rerun: ./toktrack.fish"
    exit 1
end

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q toktrack; and not test -x ~/.cargo/bin/toktrack
    echo "❌ toktrack installation verification failed."
    exit 1
end
mise exec -- cargo install --list | grep '^toktrack '

echo
echo "✅ toktrack setup complete!"
echo "💡 Dashboard: toktrack"
echo "💡 Reports:   toktrack daily, toktrack weekly, toktrack monthly, toktrack stats --json"
echo "💡 Not on PATH? Run ./rust.fish (it adds ~/.cargo/bin), then open a new terminal."
