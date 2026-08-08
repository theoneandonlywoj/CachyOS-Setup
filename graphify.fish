#!/usr/bin/env fish
# === graphify.fish ===
# Purpose: Install Graphify (codebase → queryable knowledge graph) on CachyOS (Arch Linux)
# Includes: uv check, graphifyy[pdf,video,mcp] CLI, OpenCode skill registration
# Author: theoneandonlywoj

echo "🕸  Starting Graphify setup..."

# === 1. Check uv prerequisite ===
if not command -v uv > /dev/null
    echo "❌ uv not found. Graphify is installed via 'uv tool install'."
    echo "💡 Run ./python_and_uv.fish first, then re-run this script."
    exit 1
end
echo "✅ uv found: "(uv --version)

# === 2. Ensure ~/.local/bin is in PATH (uv tool bin dir) ===
if not contains "$HOME/.local/bin" $fish_user_paths
    set -U fish_user_paths $HOME/.local/bin $fish_user_paths
    echo "🔧 Added ~/.local/bin to Fish PATH."
end

# === 3. Install Graphify CLI (package: graphifyy, with extras) ===
if command -v graphify > /dev/null
    echo "✅ Graphify CLI is already installed: "(graphify --version 2>/dev/null)
else
    echo "📦 Installing Graphify CLI (graphifyy[pdf,video,mcp]) via uv..."
    uv tool install "graphifyy[pdf,video,mcp]"
    if test $status -ne 0
        echo "❌ Failed to install graphifyy. Aborting."
        exit 1
    end
end

# === 4. Verify installation ===
echo "🧪 Verifying installation..."
if command -v graphify > /dev/null
    echo "✅ graphify available: "(graphify --version 2>/dev/null)
else
    echo "❌ graphify not found in PATH."
    echo "💡 Run 'uv tool update-shell' and open a new terminal, then re-run this script."
    exit 1
end

# === 5. Register the /graphify skill with OpenCode ===
echo "⚙  Registering /graphify skill with OpenCode..."
graphify install --platform opencode
if test $status -ne 0
    echo "⚠  Skill registration failed. Retry manually: graphify install --platform opencode"
else
    echo "✅ /graphify skill registered with OpenCode."
end

# === 6. Usage guide ===
echo
echo "🚀 Graphify setup complete!"
echo
echo "💡 Usage inside OpenCode:"
echo "   /graphify .                  → Map current project into a knowledge graph"
echo "   /graphify . --update         → Re-extract only changed files"
echo "   /graphify query \"...\"        → Ask a question against the graph"
echo
echo "📂 Output (graphify-out/):"
echo "   graph.html                   → Interactive graph (open in any browser)"
echo "   GRAPH_REPORT.md              → Highlights: god nodes, communities, questions"
echo "   graph.json                   → Full graph data (query without re-reading files)"
echo
echo "🖥  CLI usage (any terminal):"
echo "   graphify query \"what connects auth to the database?\""
echo "   graphify path \"UserService\" \"DatabasePool\""
echo "   graphify explain \"RateLimiter\""
echo
echo "🔌 MCP server (mcp extra installed):"
echo "   python -m graphify.serve graphify-out/graph.json"
echo
echo "🧹 Uninstall:"
echo "   graphify uninstall           → Remove skill from AI assistants"
echo "   uv tool uninstall graphifyy  → Remove the CLI"
