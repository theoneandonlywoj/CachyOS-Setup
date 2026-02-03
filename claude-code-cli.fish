#!/usr/bin/env fish
# === claude-code-cli.fish ===
# Purpose: Install Claude Code CLI on CachyOS
# Installs Claude Code via official native installer (https://claude.ai/install.sh)
# Author: theoneandonlywoj

echo "🚀 Starting Claude Code CLI installation..."

# === 1. Check if Claude Code CLI is already installed ===
command -q claude; and set -l claude_installed "installed"
if test -n "$claude_installed"
    echo "✅ Claude Code CLI is already installed."
    claude --version 2>/dev/null | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Claude Code CLI installation."
        exit 0
    end
    echo "📦 Removing existing Claude Code CLI installation..."
    rm -f "$HOME/.local/bin/claude"
    rm -rf "$HOME/.local/share/claude"
    if test $status -ne 0
        echo "❌ Failed to remove Claude Code CLI."
        exit 1
    end
    echo "✅ Claude Code CLI removed."
end

# === 2. Ensure ~/.local/bin exists (installer target) ===
echo "📁 Ensuring install directory exists..."
mkdir -p "$HOME/.local/bin"
if test $status -ne 0
    echo "❌ Failed to create ~/.local/bin."
    exit 1
end

# === 3. Install Claude Code CLI (official native installer) ===
echo "📦 Installing Claude Code CLI (native installer)..."
curl -fsSL https://claude.ai/install.sh | bash
if test $status -ne 0
    echo "❌ Failed to install Claude Code CLI."
    exit 1
end
echo "✅ Claude Code CLI installed."

# === 4. Ensure ~/.local/bin is in PATH for this session ===
set -q PATH; or set PATH ""
if not string match -q "*$HOME/.local/bin*" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
    echo "💡 Added ~/.local/bin to PATH for this session."
end

# === 5. Verify installation ===
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
