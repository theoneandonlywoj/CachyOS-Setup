#!/usr/bin/env fish
# === claude-code-cli.fish ===
# Purpose: Install Claude Code CLI on CachyOS
# Installs Claude Code via official native installer (https://claude.ai/install.sh)
# Author: theoneandonlywoj

echo "🚀 Starting Claude Code CLI installation..."

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

# === 2. Install or update Claude Code CLI (official native installer) ===
# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

if command -q claude
    echo "🔄 Updating Claude Code CLI in place..."
    claude update; or run_installer https://claude.ai/install.sh
else
    echo "📦 Installing Claude Code CLI (native installer)..."
    run_installer https://claude.ai/install.sh
end
if test $status -ne 0
    echo "❌ Claude Code update failed; the existing install is untouched. Rerun: ./claude-code-cli.fish"
    exit 1
end

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q claude
    echo "✅ Claude Code CLI installed successfully."
    claude --version 2>&1 | head -n 1
    echo
    echo "🔧 Running 'claude doctor' to check setup..."
    echo "" | claude doctor 2>&1
else
    echo "❌ Claude Code CLI installation verification failed."
    echo "💡 Try opening a new terminal or run: set -gx PATH \$HOME/.local/bin \$PATH"
    exit 1
end

echo
echo "✅ Claude Code CLI installation complete!"
echo "💡 Claude Code is an AI-powered coding assistant for the terminal."
echo "💡 You can now run:"
echo "   - claude          # Start Claude Code in your project"
echo "   - claude doctor   # Check installation and dependencies"
echo "   - claude update   # Update to latest version"
echo "💡 Getting started:"
echo "   - cd into your project directory"
echo "   - Run 'claude' to start a session"
echo "   - Claude Code works best in Bash or Zsh; Fish is supported"
echo "💡 Authentication:"
echo "   - Claude Pro/Max: log in with your Claude.ai account"
echo "   - Claude Console: connect via console.anthropic.com (OAuth)"
echo "💡 Tips:"
echo "   - Native install auto-updates in the background"
echo "   - Use 'claude doctor' if something seems broken"
echo "   - See https://code.claude.com/docs for full docs"
