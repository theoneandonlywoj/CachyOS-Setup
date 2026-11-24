#!/usr/bin/env fish
# === graphify.fish ===
# Purpose: Install Graphify (codebase → queryable knowledge graph) on CachyOS (Arch Linux)
# Includes: mise or uv owner check, graphifyy[pdf,video,mcp] CLI, OpenCode skill registration
# Author: theoneandonlywoj

echo "🕸  Starting Graphify setup..."

# === 1. Check mise or uv prerequisite ===
if command -q mise
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
else if not command -q uv
    echo "❌ mise or uv required."
    echo "💡 Run ./mise.fish or ./python_and_uv.fish first, then re-run this script."
    exit 1
end

# === 2. Ensure ~/.local/bin is in PATH (uv tool bin dir) ===
mkdir -p "$HOME/.local/bin"
# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if not contains -- "$HOME/.local/bin" $PATH
    fish_add_path -U "$HOME/.local/bin"
    if test $status -ne 0
        echo "❌ Failed to add ~/.local/bin to the Fish PATH."
        exit 1
    end
end

# === 3. Install or update Graphify CLI with its existing owner ===
set -l mise_tool
set -l uv_owned
if command -q mise
    set mise_tool (mise ls --installed 2>/dev/null | string match -r '^pypi:graphifyy\S*')[1]
end
if command -q uv
    set uv_owned (uv tool list 2>/dev/null | string match -r '^graphifyy ')
end

if test -n "$mise_tool" -a -n "$uv_owned"
    echo "⚠  Graphify is installed by both mise and uv. Keep one and remove the other:"
    echo "   mise unuse -g '$mise_tool'"
    echo "   uv tool uninstall graphifyy"
end

set -l failed
if test -n "$mise_tool"
    echo "🔄 Updating Graphify via mise..."
    mise upgrade $mise_tool; or set failed yes
end
if test -n "$uv_owned"
    echo "🔄 Updating Graphify via uv..."
    uv tool upgrade graphifyy; or set failed yes
end
if test -z "$mise_tool" -a -z "$uv_owned"
    echo "📦 Installing Graphify CLI (graphifyy[pdf,video,mcp])..."
    if command -q mise
        if not command -q uv; and not command -q pipx
            echo "❌ A fresh Graphify install through mise needs uv or pipx. Run ./python_and_uv.fish, then rerun: ./graphify.fish"
            exit 1
        end
        # mise reads [...] as tool options, so Python extras go in extras=
        mise use -g "pypi:graphifyy[extras=pdf,video,mcp]@latest"; or set failed yes
    else
        uv tool install "graphifyy[pdf,video,mcp]"; or set failed yes
    end
end
if test -n "$failed"
    echo "❌ Graphify install/update failed. Rerun: ./graphify.fish"
    exit 1
end
if command -q mise
    mise reshim
end

# === 4. Verify installation ===
echo "🧪 Verifying installation..."
if command -v graphify > /dev/null
    echo "✅ graphify available: "(graphify --version 2>/dev/null)
else
    echo "❌ graphify not found in PATH."
    echo "💡 Open a new terminal, then re-run this script."
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
echo "   mise unuse -g pypi:graphifyy  → Remove the CLI (mise)"
echo "   uv tool uninstall graphifyy  → Remove the CLI (uv)"
