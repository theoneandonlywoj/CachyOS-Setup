#!/usr/bin/env fish
# === elixirls.fish ===
# Purpose: Install ElixirLS LSP server for Elixir from GitHub releases
# Author: theoneandonlywoj

# === Configuration ===
set INSTALL_DIR "$HOME/.local/share/elixir-ls"
set REPO "elixir-lsp/elixir-ls"
set RELEASE "v0.29.3"  # Can be "latest" or specific version like "v0.15.0"
set PATTERN "elixir-ls-*.zip"

echo "🚀 Starting ElixirLS LSP installation..."
echo "📌 Repository: $REPO"
echo "📌 Release: $RELEASE"
echo "📌 Install directory: $INSTALL_DIR"
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

if not command -v unzip > /dev/null
    echo "📦 Installing unzip..."
    sudo pacman -S --needed --noconfirm unzip
    if test $status -ne 0
        echo "❌ Failed to install unzip. Aborting."
        exit 1
    end
end

echo "✅ Prerequisites check passed"

# === 2. Remove existing installation if it exists ===
if test -d "$INSTALL_DIR"
    echo "🗑️  Removing existing ElixirLS installation..."
    rm -rf "$INSTALL_DIR"
    if test $status -ne 0
        echo "❌ Failed to remove existing installation. Aborting."
        exit 1
    end
    echo "✅ Existing installation removed"
end

# === 3. Create installation directory ===
echo "📁 Setting up installation directory..."
mkdir -p "$INSTALL_DIR"

if test $status -ne 0
    echo "❌ Failed to create installation directory: $INSTALL_DIR"
    exit 1
end

echo "✅ Installation directory ready: $INSTALL_DIR"

# === 4. Download ElixirLS ===
echo "📥 Downloading ElixirLS LSP server..."

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
    echo "❌ Failed to download ElixirLS. Possible reasons:"
    echo "   - Network connectivity issues"
    echo "   - Repository or release not found"
    echo "   - Authentication required for private repository"
    echo "   - Pattern '$PATTERN' not found in release '$RELEASE'"

    # Try to list available releases for debugging
    echo "🔍 Available releases in $REPO:"
    gh release list --repo "$REPO" --limit 5

    # Try to list assets in the specific release
    if test "$RELEASE" != "latest"
        echo "🔍 Assets in release $RELEASE:"
        gh release view "$RELEASE" --repo "$REPO" --json assets --jq '.assets[].name'
    end

    cd "$current_dir"
    exit 1
end

# === 5. Extract and setup ===
echo "📦 Extracting ElixirLS archive..."

# Find the downloaded zip file
set zip_file (find . -name "elixir-ls-*.zip" | head -n1)

if test -z "$zip_file"
    echo "❌ Downloaded zip file not found in $INSTALL_DIR"
    echo "📁 Current directory contents:"
    ls -la
    cd "$current_dir"
    exit 1
end

echo "📦 Extracting $zip_file..."
unzip -q "$zip_file"

if test $status -ne 0
    echo "❌ Failed to extract ElixirLS archive. Aborting."
    cd "$current_dir"
    exit 1
end

# Remove the zip file after extraction
rm "$zip_file"

# Check if files were extracted directly (no subdirectory)
if test -f "language_server.sh"
    echo "✅ ElixirLS files extracted directly to installation directory"
else
    # Find the extracted directory if files were in a subdirectory
    set extracted_dir (find . -name "elixir-ls-*" -type d | head -n1)
    
    if test -z "$extracted_dir"
        echo "❌ language_server.sh not found and no extracted directory found"
        echo "📁 Current directory contents:"
        ls -la
        cd "$current_dir"
        exit 1
    end
    
    # Move contents from extracted directory to install directory
    echo "🔧 Setting up ElixirLS files from subdirectory..."
    mv "$extracted_dir"/* .
    rmdir "$extracted_dir"
end

# === 6. Make executable ===
echo "🔧 Setting executable permissions..."
if test -f "language_server.sh"
    chmod +x "language_server.sh"
    echo "✅ Made language_server.sh executable"
else
    echo "❌ language_server.sh not found in $INSTALL_DIR"
    echo "📁 Current directory contents:"
    ls -la
    cd "$current_dir"
    exit 1
end

# Return to original directory
cd "$current_dir"

# === 7. Add to PATH in Fish config ===
echo "🛠️ Updating Fish configuration..."
set fish_config_file ~/.config/fish/config.fish
set path_line "set -gx PATH \$HOME/.local/share/elixir-ls \$PATH"

if not grep -q "set -gx PATH.*\.local/share/elixir-ls" $fish_config_file
    echo "# ElixirLS LSP installation" >> $fish_config_file
    echo "$path_line" >> $fish_config_file
    echo "🔧 Added ElixirLS LSP to PATH in $fish_config_file"
else
    echo "✅ ElixirLS LSP PATH already configured in $fish_config_file"
end

# Reload PATH for current session
set -gx PATH $HOME/.local/share/elixir-ls $PATH

# === 8. Test ElixirLS installation ===
echo "🧪 Testing ElixirLS installation..."
if test -f "$INSTALL_DIR/language_server.sh"
    echo "✅ ElixirLS binary found: $INSTALL_DIR/language_server.sh"
    echo "✅ ElixirLS LSP server is ready"
else
    echo "❌ ElixirLS binary not found at expected location: $INSTALL_DIR/language_server.sh"
    echo "📁 Contents of $INSTALL_DIR:"
    ls -la "$INSTALL_DIR" 2>/dev/null || echo "Directory not found"
    exit 1
end

# === 9. Show installation details ===
echo
echo "📚 Installation details:"
echo "   Binary:      $INSTALL_DIR/language_server.sh"
echo "   Repository:  $REPO"
echo "   Release:     $RELEASE"
echo "   Permissions: "(ls -l "$INSTALL_DIR/language_server.sh" | awk '{print $1}')

# === 10. Doom Emacs configuration ===
echo
echo "💡 Doom Emacs configuration:"
echo "   Update your ~/.doom.d/config.el with:"
echo
echo "   ;; Eglot Configuration for ElixirLS"
echo "   (after! eglot"
echo "     ;; Configure Elixir LSP to use ElixirLS server"
echo "     (setq eglot-server-programs"
echo "           '((elixir-mode . (\"~/.local/share/elixir-ls/language_server.sh\"))))"
echo "     ;; Eglot UI configuration"
echo "     (setq eglot-autoshutdown t"
echo "           eglot-confirm-server-initiated-edits nil"
echo "           eglot-connect-timeout 60"
echo "           eglot-ignored-server-capabilities '(:documentHighlightProvider)))"
echo
echo "   Then run: doom sync"

echo
echo "🎉 ElixirLS LSP installation complete!"
echo
echo "💡 Important:"
echo "   To use 'language_server.sh' in this terminal immediately,"
echo "   run the following command in your current shell:"
echo "       set -gx PATH \$HOME/.local/share/elixir-ls \$PATH"
echo "   In future terminals, this will happen automatically thanks to the config file update."
echo
echo "📚 Next steps:"
echo "   1. Update your Doom Emacs configuration as shown above"
echo "   2. Run 'doom sync' to apply changes"
echo "   3. Restart Emacs to load the new configuration"
echo "   4. Open an Elixir file to test the LSP server"
