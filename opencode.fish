#!/usr/bin/env fish
# === opencode.fish ===
# Purpose: Install OpenCode CLI on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting OpenCode CLI installation..."

# === 1. Install or update OpenCode CLI (official installer, target ~/.opencode/bin) ===
# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

if command -q opencode
    echo "🔄 Updating OpenCode CLI in place..."
    opencode upgrade; or run_installer https://opencode.ai/install
else
    echo "📦 Installing OpenCode CLI..."
    run_installer https://opencode.ai/install
end
if test $status -ne 0
    echo "❌ OpenCode update failed; the existing install is untouched. Rerun: ./opencode.fish"
    exit 1
end

# === 2. Ensure the installer's directory is in PATH ===
# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if test -d "$HOME/.opencode/bin"; and not contains -- "$HOME/.opencode/bin" $PATH
    fish_add_path -U "$HOME/.opencode/bin"
    if test $status -ne 0
        echo "❌ Failed to add ~/.opencode/bin to the Fish PATH."
        exit 1
    end
end

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q opencode
    echo "✅ OpenCode CLI installed successfully: "(opencode --version 2>/dev/null)
else
    echo "❌ OpenCode CLI installation verification failed."
    echo "💡 Try opening a new terminal or run: set -gx PATH \$HOME/.opencode/bin \$PATH"
    exit 1
end

echo
echo "🎉 OpenCode CLI installation complete!"
echo
echo "💡 Getting started:"
echo "   1. Launch OpenCode by running: opencode"
echo "   2. After launch, run the /connect command to configure your AI provider"
echo "      (e.g., Anthropic API key, OpenAI key, or other supported backends)"
echo
echo "💡 Tips:"
echo "   - Use /help within OpenCode to see available commands"
echo "   - See https://opencode.ai/docs for full documentation"
