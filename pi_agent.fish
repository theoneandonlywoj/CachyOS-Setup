#!/usr/bin/env fish
# === pi_agent.fish ===
# Purpose: Install or update the Pi coding agent via npm and Mise on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Pi Agent setup via Mise..."

# === 1. Require Node.js 22.19+ via Mise ===
# The repository's .tool-versions must not pick the Node: use the global one.
cd "$HOME"; or exit 1

if not command -q mise
    echo "❌ Mise is not installed. Run ./mise.fish first, then rerun ./pi_agent.fish."
    exit 1
end

# mise first on PATH, so a leftover pacman /usr/bin/node cannot shadow it.
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source
if not mise which node >/dev/null 2>&1
    echo "❌ Node.js via Mise not found. Run ./nodejs.fish first, then rerun ./pi_agent.fish."
    exit 1
end

set -l node_version (mise exec -- node --version 2>/dev/null | string trim)
if not string match -qr '^v\d+\.\d+\.\d+' -- "$node_version"
    echo "❌ Could not determine the Node.js version: $node_version"
    exit 1
end
set -l node_parts (string replace -r '^v' '' -- $node_version | string split '.')
if test $node_parts[1] -lt 22; or test $node_parts[1] -eq 22 -a $node_parts[2] -lt 19
    echo "❌ Node.js 22.19+ required (mise use -g node@24). Found: $node_version"
    exit 1
end
echo "✅ Node.js: $node_version"

# === 2. Install or update Pi ===
# npm only: the vendor installer prompts on /dev/tty and can start pi.
mise exec -- npm install -g --ignore-scripts @earendil-works/pi-coding-agent@latest
if test $status -ne 0
    echo "❌ Pi install/update failed. Rerun: ./pi_agent.fish"
    exit 1
end
mise reshim

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
mise exec -- pi --version
if test $status -ne 0
    echo "❌ Pi installation verification failed."
    exit 1
end

echo
echo "✅ Pi setup complete!"
echo "💡 First use:   cd ~/my-project; and pi   (then /login, /model)"
echo "💡 API keys:    set -Ux GEMINI_API_KEY your_key   (also GROQ_API_KEY, OPENROUTER_API_KEY, CEREBRAS_API_KEY)"
echo "💡 Local model: ./ollama.fish, then pick ollama in /model"
echo "💡 Config dir:  ~/.pi/agent/"
echo "💡 Update:      rerun ./pi_agent.fish"
