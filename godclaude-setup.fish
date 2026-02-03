#!/usr/bin/env fish
# === godclaude-setup.fish ===
# Purpose: Require Mise and Claude Code, ensure npx/gsd, add godclaude alias on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting godclaude / GSD setup..."

# === 1. Check Mise is installed ===
if not command -q mise
    echo "❌ Mise is required. Install it first (e.g. run mise.fish)."
    exit 1
end
echo "✅ Mise found."

# === 2. Check Claude Code CLI is installed ===
if not command -q claude
    echo "❌ Claude Code CLI is required. Install it first (e.g. run claude-code-cli.fish)."
    exit 1
end
echo "✅ Claude Code CLI found."

# === 3. Ensure npx is available (install Node via Mise if needed) ===
echo "📦 Checking for npx..."
if not command -q npx
    if not mise exec -- node --version > /dev/null 2>&1
        echo "⚠ npx not found. Installing Node.js (LTS) with mise..."
        mise install node@lts
        mise use -g node@lts
        if test $status -ne 0
            echo "❌ Failed to install Node.js. Aborting."
            exit 1
        end
        echo "✅ Node.js installed: $(mise exec -- node --version)"
    end
    mise exec -- npx --version > /dev/null 2>&1
    if test $status -ne 0
        echo "❌ npx still not available. Aborting."
        exit 1
    end
    echo "✅ npx available: $(mise exec -- npx --version)"
else
    echo "✅ npx already available."
end

# === 4. Ensure gsd is available ===
echo "📦 Checking for gsd..."
set -l fish_func_dir ~/.config/fish/functions
mkdir -p $fish_func_dir
if not command -q gsd
    echo "⚠ gsd not found. Caching get-shit-done-cc and adding gsd function..."
    mise exec -- npx get-shit-done-cc@latest > /dev/null 2>&1
    echo "function gsd; npx get-shit-done-cc \$argv; end" > $fish_func_dir/gsd.fish
    echo "✅ gsd function created at $fish_func_dir/gsd.fish"
else
    echo "✅ gsd already available."
end

# === 5. Add godclaude function if missing ===
echo "🔗 Ensuring godclaude alias..."
if not test -f $fish_func_dir/godclaude.fish
    echo "function godclaude; claude --dangerously-skip-permissions \$argv; end" > $fish_func_dir/godclaude.fish
    echo "✅ godclaude function created at $fish_func_dir/godclaude.fish"
else
    echo "ℹ godclaude function already exists."
end

# === 6. Verify and print tips ===
echo
echo "🧪 Verifying setup..."
command -q mise; and echo "✅ Mise: $(mise --version 2>&1 | head -n 1)"
command -q claude; and echo "✅ Claude Code: $(claude --version 2>&1 | head -n 1)"
test -f $fish_func_dir/gsd.fish; and echo "✅ gsd function installed"
test -f $fish_func_dir/godclaude.fish; and echo "✅ godclaude function installed"

echo
echo "✅ godclaude / GSD setup complete!"
echo "💡 Commands:"
echo "   - godclaude    Run Claude Code with --dangerously-skip-permissions"
echo "   - gsd          Set up GSD (get-shit-done) for your CLI / Claude Code"
echo "💡 Restart your terminal or run: source ~/.config/fish/config.fish"
echo "   so godclaude and gsd are available in this shell."
