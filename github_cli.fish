#!/usr/bin/env fish
# === github_cli.fish ===
# Purpose: Install GitHub CLI (gh) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set GH_VERSION "latest"  # Use "latest" or specific version like "2.47.0"

echo "🚀 Starting GitHub CLI (gh) installation..."
echo "📌 Target version: $GH_VERSION"
echo

# === 1. Check if already installed ===
if command -v gh > /dev/null
    set current_version (gh --version | head -n1 | awk '{print $3}')
    echo "✅ GitHub CLI is already installed: v$current_version"
    echo "🔍 Checking if update is needed..."
end

# === 2. Determine installation method ===
echo "🔍 Determining best installation method..."

# Check if AUR helper is available
set AUR_HELPER ""
for helper in yay paru trizen pikaur
    if command -v $helper > /dev/null
        set AUR_HELPER $helper
        break
    end
end

# === 3. Installation methods ===
if test -n "$AUR_HELPER"
    echo "📦 Installing via AUR helper: $AUR_HELPER"

    # Install using AUR helper
    $AUR_HELPER -S --needed --noconfirm github-cli

    if test $status -ne 0
        echo "❌ Failed to install via $AUR_HELPER. Trying official repository..."
        sudo pacman -S --needed --noconfirm github-cli
    end

else if pacman -Si github-cli > /dev/null 2>&1
    echo "📦 Installing from official Arch repository..."
    sudo pacman -S --needed --noconfirm github-cli

else
    echo "📥 Installing via official script..."

    # Install dependencies for script method
    echo "📦 Installing required dependencies..."
    sudo pacman -S --needed --noconfirm curl tar

    # Download and run official install script
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
        sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

    echo "deb [arch=(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
        sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    # For Arch, we need to use the binary directly
    echo "🔧 Downloading binary release..."
    set temp_dir (mktemp -d)
    cd $temp_dir

    if test "$GH_VERSION" = "latest"
        set download_url (curl -s https://api.github.com/repos/cli/cli/releases/latest | grep "browser_download_url.*linux_amd64.tar.gz" | cut -d '"' -f 4)
    else
        set download_url "https://github.com/cli/cli/releases/download/v$GH_VERSION/gh_{$GH_VERSION}_linux_amd64.tar.gz"
    end

    echo "📥 Downloading from: $download_url"
    curl -L -o gh.tar.gz "$download_url"

    if test $status -ne 0
        echo "❌ Failed to download GitHub CLI. Aborting."
        exit 1
    end

    # Extract and install
    echo "📦 Extracting archive..."
    tar -xzf gh.tar.gz
    set gh_dir (find . -name "gh_*_linux_amd64" -type d | head -n1)

    if test -n "$gh_dir" -a -d "$gh_dir"
        echo "🔧 Installing binary..."
        sudo cp -r $gh_dir/bin/gh /usr/local/bin/
        sudo cp -r $gh_dir/share/* /usr/local/share/

        # Install man pages
        if test -d "$gh_dir/share/man"
            sudo cp -r $gh_dir/share/man/* /usr/local/share/man/
        end
    else
        echo "❌ Could not find extracted gh directory. Aborting."
        exit 1
    end

    # Cleanup
    rm -rf $temp_dir
end

# === 4. Verify installation ===
echo "🧪 Verifying installation..."

if command -v gh > /dev/null
    set installed_version (gh --version | head -n1 | awk '{print $3}')
    echo "✅ GitHub CLI installed successfully: v$installed_version"
else
    echo "❌ GitHub CLI installation failed. Please check the installation method."
    exit 1
end

# === 5. Set up completion ===
echo "🔧 Setting up shell completion..."

# Fish completion
if test -d /usr/share/fish/vendor_completions.d/
    sudo mkdir -p /usr/share/fish/vendor_completions.d/
    gh completion -s fish | sudo tee /usr/share/fish/vendor_completions.d/gh.fish > /dev/null
end

# Also set up for current user
mkdir -p ~/.config/fish/completions
gh completion -s fish > ~/.config/fish/completions/gh.fish

if test $status -eq 0
    echo "✅ Fish completion installed"
else
    echo "⚠️  Could not install Fish completion"
end

# === 6. Authenticate (optional) ===
echo "🔐 Authentication setup (optional)..."
echo
echo "💡 To authenticate with GitHub, run:"
echo "   gh auth login"
echo
echo "   This will allow you to:"
echo "   - Create and clone repositories"
echo "   - Create issues and pull requests"
echo "   - View and manage notifications"
echo "   - And much more!"

# === 7. Show useful commands ===
echo
echo "📚 Useful GitHub CLI commands:"
echo "   gh auth login          - Authenticate with GitHub"
echo "   gh repo create         - Create a new repository"
echo "   gh repo clone owner/repo - Clone a repository"
echo "   gh issue create        - Create a new issue"
echo "   gh pr create           - Create a pull request"
echo "   gh gist create         - Create a gist"
echo "   gh help                - Show all available commands"

# === 8. Test basic functionality ===
echo
echo "🧪 Testing basic functionality..."
if gh --version > /dev/null 2>&1
    echo "✅ Basic functionality test passed"

    # Test if authenticated
    if gh auth status > /dev/null 2>&1
        set github_user (gh api user --jq .login 2>/dev/null)
        if test -n "$github_user"
            echo "✅ Already authenticated as: $github_user"
        else
            echo "🔓 Not authenticated. Run 'gh auth login' to get started."
        end
    else
        echo "🔓 Not authenticated. Run 'gh auth login' to get started."
    end
else
    echo "⚠️  Basic functionality test failed"
end

echo
echo "🎉 GitHub CLI installation complete!"
echo
echo "💡 Next steps:"
echo "   1. Run 'gh auth login' to authenticate with GitHub"
echo "   2. Run 'gh help' to explore all available commands"
echo "   3. Check out https://cli.github.com/manual/ for detailed documentation"
