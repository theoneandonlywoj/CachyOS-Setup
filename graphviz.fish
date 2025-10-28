#!/usr/bin/env fish
# === graphviz.fish ===
# Purpose: Install Graphviz graph visualization tool on CachyOS
# Installs Graphviz from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Graphviz installation..."

# === 1. Check if Graphviz is already installed ===
command -q dot; and set -l graphviz_installed "installed"
if test -n "$graphviz_installed"
    echo "✅ Graphviz is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Graphviz installation."
        exit 0
    end
    echo "📦 Removing existing Graphviz installation..."
    sudo pacman -R --noconfirm graphviz
    if test $status -ne 0
        echo "❌ Failed to remove Graphviz."
        exit 1
    end
    echo "✅ Graphviz removed."
end

# === 2. Install Graphviz ===
echo "📦 Installing Graphviz..."
sudo pacman -S --needed --noconfirm graphviz
if test $status -ne 0
    echo "❌ Failed to install Graphviz."
    exit 1
end
echo "✅ Graphviz installed."

# === 3. Install optional Graphviz tools ===
echo "📦 Installing optional Graphviz tools..."
echo "💡 The following tools enhance Graphviz capabilities:"
echo "   - xdot: Interactive viewer for Graphviz files"
echo "   - dot2tex: Convert Graphviz to LaTeX"
echo "   - python-graphviz: Python bindings for Graphviz"
read -P "Do you want to install additional tools? [y/N] " install_tools

if test "$install_tools" = "y" -o "$install_tools" = "Y"
    echo "📦 Installing Graphviz tools..."
    sudo pacman -S --needed --noconfirm xdot dot2tex python-graphviz python-pygraphviz
    if test $status -ne 0
        echo "⚠ Failed to install some tools, but Graphviz is still installed."
    else
        echo "✅ Graphviz tools installed."
    end
end

# === 4. Check and fix snapper Boost library issue (if present) ===
if test -f /usr/bin/snapper
    echo
    echo "🔧 Checking for snapper Boost library issue..."
    snapper --version > /dev/null 2>&1
    if test $status -ne 0
        echo "⚠ Detected snapper Boost library version mismatch."
        echo "💡 This can happen after Boost updates."
        read -P "Do you want to fix snapper? [y/N] " fix_snapper
        
        if test "$fix_snapper" = "y" -o "$fix_snapper" = "Y"
            echo "📦 Reinstalling snapper to fix Boost library version mismatch..."
            sudo pacman -S --noconfirm snapper
            if test $status -eq 0
                echo "✅ Snapper fixed successfully."
            else
                echo "⚠ Failed to fix snapper, but Graphviz is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q dot
if test $status -eq 0
    echo "✅ Graphviz installed successfully"
    dot -V 2>&1 | head -n 1
    echo "✅ Available commands:"
    echo "   - dot: Main Graphviz layout engine"
    echo "   - neato: Undirected graph layout"
    echo "   - fdp: Force-directed graph layout"
    echo "   - sfdp: Scalable force-directed layout"
    echo "   - twopi: Radial graph layout"
    echo "   - circo: Circular graph layout"
else
    echo "❌ Graphviz installation verification failed."
end

echo
echo "✅ Graphviz installation complete!"
echo "💡 Graphviz is a graph visualization tool:"
echo "   - Create diagrams from text descriptions"
echo "   - Support for multiple layout engines"
echo "   - Export to PNG, SVG, PDF, PostScript"
echo "   - Used by documentation tools and code analyzers"
echo "💡 Basic usage:"
echo "   - Create file: graph.dot"
echo "   - Generate: dot -Tpng graph.dot -o graph.png"
echo "   - Or: dot -Tsvg graph.dot -o graph.svg"
echo "   - Or: dot -Tpdf graph.dot -o graph.pdf"
echo "💡 Example DOT file syntax:"
echo "   digraph G {"
echo "     A -> B"
echo "     B -> C"
echo "     C -> A"
echo "   }"
echo "💡 Layout engines:"
echo "   - dot: Hierarchical layouts"
echo "   - neato: Spring-model layouts"
echo "   - fdp: Force-directed layouts"
echo "   - sfdp: Scalable force-directed layouts"
echo "   - circo: Circular layouts"
echo "💡 Integration:"
echo "   - Works with PlantUML for enhanced diagrams"
echo "   - Python: import graphviz"
echo "   - Often used by Doxygen, Sphinx, etc."
echo "💡 Tips:"
echo "   - Use xdot for interactive viewing"
echo "   - Use different engines for different graph types"
echo "   - Customize with attributes (color, shape, size)"
echo "   - See: http://graphviz.org/docs/ for full documentation"

