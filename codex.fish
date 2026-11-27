#!/usr/bin/env fish
# === codex.fish ===
# Purpose: Install or update the OpenAI Codex CLI on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Codex CLI installation..."

# === 1. Check for another owner ===
# The vendor installer owns $CODEX_INSTALL_DIR/codex (default ~/.local/bin); never add a second owner.
set -l bin_dir "$HOME/.local/bin"
if set -q CODEX_INSTALL_DIR; and test -n "$CODEX_INSTALL_DIR"
    set bin_dir "$CODEX_INSTALL_DIR"
end
set -l existing (command -s codex)
if test -n "$existing"; and test "$existing" != "$bin_dir/codex"
    echo "❌ Codex is already installed by another owner: $existing"
    echo "💡 Update it there, or remove it first, then rerun: ./codex.fish"
    exit 1
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

# === 3. Install or update Codex CLI (official installer) ===
# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

# No prompts: not "Start Codex now?", and not the offer to uninstall another Codex.
set -lx CODEX_NON_INTERACTIVE 1
run_installer https://chatgpt.com/codex/install.sh
if test $status -ne 0
    echo "❌ Codex install/update failed; an existing install is untouched. Rerun: ./codex.fish"
    exit 1
end

# === 4. Verify installation ===
echo "🧪 Verifying installation..."
"$bin_dir/codex" --version
if test $status -ne 0
    echo "❌ Codex installation verification failed."
    exit 1
end

echo
echo "✅ Codex setup complete!"
echo "💡 Sign in:     codex login"
echo "💡 First use:   cd ~/my-project; and codex"
echo "💡 Config file: ~/.codex/config.toml"
