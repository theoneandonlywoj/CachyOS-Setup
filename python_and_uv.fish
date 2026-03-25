#!/usr/bin/env fish
# === python_and_uv.fish ===
# Purpose: Install uv and Python 3.11+ on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set PYTHON_VERSION 3.11

echo "🚀 Starting Python & uv setup..."
echo "📌 Target versions:"
echo "   Python → $PYTHON_VERSION+"
echo "   uv     → latest"
echo

# === 1. Install uv via standalone installer ===
if command -v uv > /dev/null
    echo "✅ uv is already installed: "(uv --version)
else
    echo "🔧 Installing uv via standalone installer..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    if test $status -ne 0
        echo "❌ Failed to install uv. Aborting."
        exit 1
    end
end

# === 2. Ensure ~/.local/bin is in PATH ===
if not contains "$HOME/.local/bin" $fish_user_paths
    set -U fish_user_paths $HOME/.local/bin $fish_user_paths
    echo "🔧 Added ~/.local/bin to Fish PATH."
end

# === 3. Install Python via uv ===
echo "🔧 Installing Python $PYTHON_VERSION via uv..."
uv python install $PYTHON_VERSION --default
if test $status -ne 0
    echo "❌ Python installation failed. Aborting."
    exit 1
end

# === 4. Set up Fish shell autocompletion for uv ===
set completions_file ~/.config/fish/completions/uv.fish
set completions_line "uv generate-shell-completion fish | source"

if not test -f $completions_file; or not grep -Fxq "$completions_line" $completions_file
    mkdir -p ~/.config/fish/completions
    echo "$completions_line" > $completions_file
    echo "🔧 Added uv shell completions for Fish."
end

# === 5. Verify installations ===
echo "🧪 Verifying installations..."
set uv_ver (command uv --version 2>/dev/null)
set python_ver (command python3 --version 2>/dev/null)

if test -n "$uv_ver"
    echo "✅ uv installed successfully: $uv_ver"
else
    echo "❌ uv verification failed."
end

if test -n "$python_ver"
    echo "✅ Python installed successfully: $python_ver"
else
    echo "❌ Python verification failed."
end

echo
echo "🎉 Python & uv setup complete!"
echo
echo "💡 Quick start:"
echo "   uv init my_project    → Create a new Python project"
echo "   uv add requests       → Add a dependency"
echo "   uv run python main.py → Run a script with managed dependencies"
echo "   uv tool install ruff  → Install a CLI tool globally"
echo
echo "📚 Installed versions:"
echo "   Python → $python_ver"
echo "   uv     → $uv_ver"
