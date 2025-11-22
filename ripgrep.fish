#!/usr/bin/env fish
# === ripgrep.fish ===
# Purpose: Install ripgrep (fast text search tool) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting ripgrep installation..."
echo
echo "💡 ripgrep (rg) is a fast text search tool:"
echo "   - Extremely fast grep alternative"
echo "   - Respects .gitignore by default"
echo "   - Recursive directory search"
echo "   - Supports regex patterns"
echo "   - Great for code searching"
echo

# === 1. Check if ripgrep is already installed ===
command -q rg; and set -l ripgrep_installed "installed"
if test -n "$ripgrep_installed"
    echo "✅ ripgrep is already installed."
    rg --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping ripgrep installation."
        exit 0
    end
    echo "📦 Removing existing ripgrep installation..."
    sudo pacman -R --noconfirm ripgrep
    if test $status -ne 0
        echo "❌ Failed to remove ripgrep."
        exit 1
    end
    echo "✅ ripgrep removed."
end

# === 2. Install ripgrep ===
echo "📦 Installing ripgrep from official repository..."
sudo pacman -S --needed --noconfirm ripgrep
if test $status -ne 0
    echo "❌ Failed to install ripgrep."
    exit 1
end
echo "✅ ripgrep installed."

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q rg
    echo "✅ ripgrep installed successfully"
    rg --version 2>&1 | head -n 1
else
    echo "❌ ripgrep installation verification failed."
    exit 1
end

echo
echo "🎉 ripgrep installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Search for text in current directory"
echo "   rg 'search term'"
echo ""
echo "   # Search in specific directory"
echo "   rg 'search term' /path/to/directory"
echo ""
echo "   # Search with case-insensitive match"
echo "   rg -i 'search term'"
echo ""
echo "   # Search for whole words only"
echo "   rg -w 'search term'"
echo ""
echo "   # Search in specific file types"
echo "   rg 'search term' -t py"
echo "   rg 'search term' -t js"
echo ""
echo "💡 Common options:"
echo "   # Show context lines"
echo "   rg 'search term' -C 3"
echo "   rg 'search term' -A 5    # After context"
echo "   rg 'search term' -B 5    # Before context"
echo ""
echo "   # Show only filenames"
echo "   rg 'search term' -l"
echo ""
echo "   # Show line numbers"
echo "   rg 'search term' -n"
echo ""
echo "   # Count matches"
echo "   rg 'search term' -c"
echo ""
echo "   # Search with regex"
echo "   rg 'pattern.*regex'"
echo ""
echo "💡 File type filtering:"
echo "   # Search only in Python files"
echo "   rg 'search term' -t py"
echo ""
echo "   # Search only in JavaScript files"
echo "   rg 'search term' -t js"
echo ""
echo "   # Search in multiple file types"
echo "   rg 'search term' -t py -t js"
echo ""
echo "   # Exclude file types"
echo "   rg 'search term' -T md"
echo ""
echo "   # List supported file types"
echo "   rg --type-list"
echo ""
echo "💡 Advanced options:"
echo "   # Search in hidden files"
echo "   rg 'search term' --hidden"
echo ""
echo "   # Don't respect .gitignore"
echo "   rg 'search term' --no-ignore"
echo ""
echo "   # Search in binary files"
echo "   rg 'search term' --text"
echo ""
echo "   # Follow symlinks"
echo "   rg 'search term' --follow"
echo ""
echo "   # Maximum depth"
echo "   rg 'search term' --max-depth 3"
echo ""
echo "💡 Output formatting:"
echo "   # JSON output"
echo "   rg 'search term' --json"
echo ""
echo "   # Show only matching text"
echo "   rg 'search term' -o"
echo ""
echo "   # Show file and line"
echo "   rg 'search term' --with-filename --line-number"
echo ""
echo "💡 Comparison with grep:"
echo "   # grep example:"
echo "   grep -r 'pattern' ."
echo ""
echo "   # ripgrep example (faster, respects .gitignore):"
echo "   rg 'pattern'"
echo ""
echo "💡 Use cases:"
echo "   # Find all function definitions"
echo "   rg '^def ' -t py"
echo ""
echo "   # Find TODO comments"
echo "   rg 'TODO|FIXME'"
echo ""
echo "   # Find imports"
echo "   rg '^import |^from ' -t py"
echo ""
echo "   # Search in codebase (respects .gitignore)"
echo "   rg 'function_name'"
echo ""
echo "💡 Tips:"
echo "   - ripgrep is much faster than grep for large codebases"
echo "   - Automatically respects .gitignore files"
echo "   - Great for searching code repositories"
echo "   - Use -i for case-insensitive search"
echo "   - Use -w for whole word matching"
echo "   - Combine with fzf for interactive search"
echo ""
echo "💡 Resources:"
echo "   - GitHub: https://github.com/BurntSushi/ripgrep"
echo "   - Documentation: https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md"
echo "   - Man page: man rg"

