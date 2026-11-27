#!/usr/bin/env fish
# === dexter.fish ===
# Purpose: Install Dexter (Elixir LSP by Remote) via Mise on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Dexter setup via Mise..."

# === 1. Check prerequisites ===
# The repository's .tool-versions must not decide which tools mise activates.
cd "$HOME"; or exit 1

if not command -q mise
    echo "❌ Mise is not installed. Run ./mise.fish first, then rerun ./dexter.fish."
    exit 1
end

# === 2. Install or update Dexter ===
mise use -g aqua:remoteoss/dexter@latest; and mise upgrade aqua:remoteoss/dexter
if test $status -ne 0
    echo "❌ Dexter install/update failed: no network, or the aqua backend has no Linux asset for this machine."
    echo "   An existing install is untouched. Rerun: ./dexter.fish"
    exit 1
end

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
if not mise which dexter >/dev/null 2>&1
    echo "❌ Dexter installation verification failed."
    exit 1
end
mise ls aqua:remoteoss/dexter

echo
echo "✅ Dexter setup complete!"
echo "💡 Index a project:     dexter init ."
echo "💡 Run as LSP (stdio):  dexter lsp"
echo "💡 Look up a module:    dexter lookup MyApp.Accounts"
echo "💡 Find references:     dexter references MyApp.Accounts fetch_user"
