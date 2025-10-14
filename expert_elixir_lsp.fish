#!/usr/bin/env fish
# === install_expert_lsp.fish ===
# Purpose: Install Elixir's Expert LSP server from GitHub releases
# Author: theoneandonlywoj

# === Configuration ===
set INSTALL_DIR "$HOME/.local/share/elixir-expert-lsp"
set REPO "elixir-lang/expert"
set RELEASE "nightly"  # Can be "nightly" or specific version like "v0.1.0"
set PATTERN "expert_linux_amd64"

echo "🚀 Starting Expert LSP installation..."
echo "📌 Repository: $REPO"
echo "📌 Release: $RELEASE"
echo "📌 Install directory: $INSTALL_DIR"
echo "📌 Pattern: $PATTERN"
echo

# === 1. Check prerequisites ===
echo "🔍 Checking prerequisites..."

if not command -v gh > /dev/null
    echo "❌ GitHub CLI (gh) is not installed. Please install it first."
    echo "💡 You can use the github_cli.fish script or run:"
    echo "   sudo pacman -S github-cli"
    exit 1
end

if not gh auth status > /dev/null 2>&1
    echo "⚠️  GitHub CLI is not authenticated. Some features may be limited."
    echo "💡 You can authenticate with: gh auth login"
end

# === 2. Create installation directory ===
echo "📁 Setting up installation directory..."
mkdir -p "$INSTALL_DIR"

if test $status -ne 0
    echo "❌ Failed to create installation directory: $INSTALL_DIR"
    exit 1
end

echo "✅ Installation directory ready: $INSTALL_DIR"

# === 3. Download Expert LSP ===
echo "📥 Downloading Expert LSP..."

# Save current directory
set current_dir (pwd)

# Change to installation directory
cd "$INSTALL_DIR"

if test $status -ne 0
    echo "❌ Failed to change to installation directory"
    exit 1
end

echo "🔧 Downloading release '$RELEASE' from $REPO..."
gh release download "$RELEASE" --pattern "$PATTERN" --repo "$REPO"

if test $status -ne 0
    echo "❌ Failed to download Expert LSP. Possible reasons:"
    echo "   - Network connectivity issues"
    echo "   - Repository or release not found"
    echo "   - Authentication required for private repository"
    echo "   - Pattern '$PATTERN' not found in release '$RELEASE'"

    # Try to list available releases for debugging
    echo "🔍 Available releases in $REPO:"
    gh release list --repo "$REPO" --limit 5

    # Try to list assets in the specific release
    if test "$RELEASE" != "nightly"
        echo "🔍 Assets in release $RELEASE:"
        gh release view "$RELEASE" --repo "$REPO" --json assets --jq '.assets[].name'
    end

    cd "$current_dir"
    exit 1
end

# === 4. Make executable ===
echo "🔧 Setting executable permissions..."
if test -f "$PATTERN"
    chmod +x "$PATTERN"
    echo "✅ Made $PATTERN executable"
else
    echo "❌ Downloaded file '$PATTERN' not found in $INSTALL_DIR"
    echo "📁 Current directory contents:"
    ls -la
    cd "$current_dir"
    exit 1
end

# Return to original directory
cd "$current_dir"

# === 5. Add to PATH in Fish config ===
echo "🛠️ Updating Fish configuration..."
set fish_config_file ~/.config/fish/config.fish
set path_line "set -gx PATH \$HOME/.local/share/elixir-expert-lsp \$PATH"

if not grep -q "set -gx PATH.*\.local/share/elixir-expert-lsp" $fish_config_file
    echo "# Expert LSP installation" >> $fish_config_file
    echo "$path_line" >> $fish_config_file
    echo "🔧 Added Expert LSP to PATH in $fish_config_file"
else
    echo "✅ Expert LSP PATH already configured in $fish_config_file"
end

# Reload PATH for current session
set -gx PATH $HOME/.local/share/elixir-expert-lsp $PATH

# === 6. Show installation details ===
echo
echo "📚 Installation details:"
echo "   Binary:      $INSTALL_DIR/$PATTERN"
echo "   Repository:  $REPO"
echo "   Release:     $RELEASE"
echo "   Permissions: "(ls -l "$INSTALL_DIR/$PATTERN" | awk '{print $1}')

# === 7. Doom Emacs configuration ===
echo
echo "💡 Doom Emacs configuration:"
echo "   Add this to your ~/.doom.d/config.el:"
echo
echo "   ;; Expert LSP configuration"
echo "   (after! lsp-mode"
echo "     (setq lsp-elixir-language-server-path \\\"$INSTALL_DIR/$PATTERN\\\"))"
echo
echo "   Or if you want to use both ElixirLS and Expert:"
echo "   (after! lsp-mode"
echo "     (setq lsp-elixir-language-server-path \\\"$INSTALL_DIR/$PATTERN\\\""
echo "           lsp-elixir-alternative-server-path \\\"$INSTALL_DIR/$PATTERN\\\"))"
