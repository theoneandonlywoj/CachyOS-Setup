#!/usr/bin/env fish
# === livebook.fish ===
# Purpose: Install Livebook CLI on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Livebook CLI setup..."
echo
echo "💡 Livebook is an interactive notebook for Elixir:"
echo "   - Create and share live code notebooks"
echo "   - Interactive data exploration"
echo "   - Rich visualizations and markdown support"
echo "   - Collaborative editing"
echo

# === 1. Check for Elixir/Mix installation ===
echo "🔍 Checking for Elixir and Mix..."

# Try to activate Mise if available (since elixir_and_erlang.fish uses Mise)
if command -v mise > /dev/null
    echo "✅ Mise found. Activating environment..."
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
end

# Check if Mix is available
if not command -v mix > /dev/null
    echo "❌ Mix (Elixir build tool) is not installed."
    echo "   Please install Elixir first by running:"
    echo "   ./elixir_and_erlang.fish"
    echo "   Or install Elixir via your package manager:"
    echo "   sudo pacman -S elixir"  # rerun-gate: allow hint text
    exit 1
end

echo "✅ Mix found: $(mix --version | head -n 1)"

# Check Elixir version (Livebook requires Elixir >= 1.18)
echo "🔍 Checking Elixir version compatibility..."
set elixir_version_output (elixir -v 2>/dev/null)
set elixir_version (echo $elixir_version_output | grep "Elixir" | awk '{print $2}')

if test -z "$elixir_version"
    echo "❌ Could not determine Elixir version."
    exit 1
end

echo "   Current Elixir version: $elixir_version"

# Extract major and minor version numbers
set version_parts (string split '.' $elixir_version)
set major_version (echo $version_parts[1] | string trim)
set minor_version (echo $version_parts[2] | string trim)

# Check if version is >= 1.18
set version_ok false
if test "$major_version" -gt 1
    set version_ok true
else if test "$major_version" -eq 1
    if test "$minor_version" -ge 18
        set version_ok true
    end
end

if test "$version_ok" = false
    echo "❌ Livebook requires Elixir >= 1.18, but you have $elixir_version"
    echo
    echo "💡 To fix this:"
    echo "   1. Update elixir_and_erlang.fish to use Elixir 1.18 or later"
    echo "   2. Run: ./elixir_and_erlang.fish"
    echo "   3. Then run this script again: ./livebook.fish"
    echo
    echo "   Or install a newer Elixir version via Mise:"
    echo "   mise install elixir@1.18"
    echo "   mise use -g elixir@1.18"
    exit 1
end

echo "✅ Elixir version is compatible (>= 1.18)"
echo

# === 2. Install Livebook CLI via Mix escript ===
echo "📦 Installing Livebook CLI via Mix escript..."
mix escript.install hex livebook --force
if test $status -ne 0
    echo "❌ Failed to install Livebook CLI. Rerun: ./livebook.fish"
    exit 1
end

echo "✅ Livebook CLI installed via Mix escript."

# === 3. Add Mix escripts directory to Fish PATH ===
set escripts_dir ~/.mix/escripts
if test -d "$escripts_dir"
    echo "🔧 Adding Mix escripts directory to Fish PATH..."
    if not contains "$escripts_dir" $fish_user_paths
        set -U fish_user_paths $fish_user_paths $escripts_dir
        echo "✅ Added $escripts_dir to Fish user PATH."
    else
        echo "ℹ $escripts_dir is already in Fish user PATH."
    end
    
    # Also add to current session PATH
    set -x PATH $escripts_dir $PATH
else
    echo "⚠ Warning: Expected escripts directory not found at $escripts_dir"
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
set -x PATH $escripts_dir $PATH

if command -v livebook > /dev/null
    set livebook_version (livebook --version 2>/dev/null | head -n 1)
    if test -n "$livebook_version"
        echo "✅ Livebook CLI installed successfully: $livebook_version"
    else
        echo "✅ Livebook CLI installed (version check unavailable)"
    end
else
    echo "⚠ Livebook CLI installed but not found in PATH."
    echo "   You may need to restart your terminal or run:"
    echo "   set -x PATH ~/.mix/escripts \$PATH"
end

echo
echo "🎉 Livebook CLI setup complete!"
echo
echo "💡 Usage examples:"
echo "   # Start Livebook server"
echo "   livebook server"
echo
echo "   # Start Livebook server on a specific port"
echo "   livebook server --port 8080"
echo
echo "   # Start Livebook server with password protection"
echo "   livebook server --password your_password"
echo
echo "   # Open Livebook in your browser"
echo "   # Default URL: http://localhost:8080"
echo
echo "📚 For more information, visit:"
echo "   https://livebook.dev"

