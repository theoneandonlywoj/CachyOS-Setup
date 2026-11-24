#!/usr/bin/env fish
# === livediff.fish ===
# Purpose: Install Livediff (live terminal diff TUI) via cargo on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Livediff setup via cargo..."

# === 1. Check prerequisites ===
# The repository's .tool-versions must not decide which tools mise activates.
cd "$HOME"; or exit 1

if not command -q mise; or not mise which cargo >/dev/null 2>&1
    echo "❌ cargo via Mise not found. Run ./rust.fish first, then rerun ./livediff.fish."
    exit 1
end

# === 2. Install or update Livediff ===
# cargo install also updates when a newer version exists.
mise exec -- cargo install livediff --locked
if test $status -ne 0
    echo "❌ Livediff install/update failed; an existing binary is untouched. Rerun: ./livediff.fish"
    exit 1
end

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q livediff; and not test -x ~/.cargo/bin/livediff
    echo "❌ Livediff installation verification failed."
    exit 1
end
mise exec -- cargo install --list | grep '^livediff '

echo
echo "✅ Livediff setup complete!"
echo "💡 Watch a directory:  livediff ."
echo "💡 Ignore files:       livediff . --ignore 'target/' --ignore '*.tmp'"
echo "💡 Not on PATH? Run ./rust.fish (it adds ~/.cargo/bin), then open a new terminal."
