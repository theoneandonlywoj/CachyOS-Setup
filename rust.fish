#!/usr/bin/env fish
# === rust.fish ===
# Purpose: Install Rust (rustc and cargo) via Mise on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Rust setup via Mise..."

# === 1. Check prerequisites ===
# The repository's .tool-versions must not decide which tools mise activates.
cd "$HOME"; or exit 1

if not command -q mise
    echo "❌ Mise is not installed. Run ./mise.fish first, then rerun ./rust.fish."
    exit 1
end

# === 2. Install or update Rust ===
# mise drives rustup internally; no pacman rust and no separate rustup.
mise use -g rust@stable; and mise upgrade rust
if test $status -ne 0
    echo "❌ Rust install/update failed; an existing install is untouched. Rerun: ./rust.fish"
    exit 1
end

# === 3. Ensure ~/.cargo/bin exists and is in PATH ===
mkdir -p "$HOME/.cargo/bin"
if test $status -ne 0
    echo "❌ Failed to create ~/.cargo/bin."
    exit 1
end

# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if not contains -- "$HOME/.cargo/bin" $PATH
    fish_add_path -U "$HOME/.cargo/bin"
    if test $status -ne 0
        echo "❌ Failed to add ~/.cargo/bin to the Fish PATH."
        exit 1
    end
end

# === 4. Verify installation ===
echo "🧪 Verifying installation..."
mise exec -- rustc --version; and mise exec -- cargo --version
if test $status -ne 0
    echo "❌ Rust installation verification failed."
    exit 1
end

echo
echo "✅ Rust setup complete!"
echo "💡 First use: cargo new hello; cd hello; cargo run"
