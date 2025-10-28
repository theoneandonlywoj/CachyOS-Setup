#!/usr/bin/env fish
# === just.fish ===
# Purpose: Install Just (command runner) on CachyOS (Arch Linux)
# Author: theoneandonlywoj
# Description:
#   Just is a modern command runner inspired by 'make' but simpler
#   and more focused. It's great for running repetitive tasks.

echo "🚀 Starting Just installation..."

# === 1. Check if Just is already installed ===
command -q just; and set -l just_installed "installed"
if test -n "$just_installed"
    echo "✅ Just is already installed."
    just --version
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Just installation."
        exit 0
    end
    echo "📦 Removing existing Just installation..."
    sudo pacman -R --noconfirm just
    if test $status -ne 0
        echo "❌ Failed to remove Just."
        exit 1
    end
    echo "✅ Just removed."
end

# === 2. Determine installation method ===
echo "🔍 Checking for Just in repositories..."

# Check if AUR helper is available
set AUR_HELPER ""
for helper in yay paru trizen pikaur
    if command -v $helper > /dev/null
        set AUR_HELPER $helper
        break
    end
end

# === 3. Install Just ===
if pacman -Si just > /dev/null 2>&1
    echo "📦 Installing Just from official Arch repository..."
    sudo pacman -S --needed --noconfirm just
else if test -n "$AUR_HELPER"
    echo "📦 Installing Just from AUR using $AUR_HELPER..."
    $AUR_HELPER -S --needed --noconfirm just-bin
else
    echo "📥 Installing Just using cargo (Rust package manager)..."
    
    # Check if cargo is installed
    if not command -v cargo > /dev/null
        echo "📦 Installing Rust and cargo first..."
        read -P "Install Rust? [Y/n] " install_rust
        if test -z "$install_rust" -o "$install_rust" = "y" -o "$install_rust" = "Y"
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
            source ~/.cargo/env
        else
            echo "❌ Cargo is required to install Just. Please install Rust first."
            exit 1
        end
    end
    
    cargo install just
    if test $status -ne 0
        echo "❌ Failed to install Just via cargo."
        exit 1
    end
end

if test $status -ne 0
    echo "❌ Failed to install Just."
    exit 1
end

echo "✅ Just installed."

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q just
if test $status -eq 0
    echo "✅ Just installed successfully"
    just --version
else
    echo "❌ Just installation verification failed."
    exit 1
end

# === 5. Set up completion ===
echo
echo "📦 Setting up Just shell completion..."

# Fish shell autocompletion
mkdir -p ~/.config/fish/completions
just --completions fish > ~/.config/fish/completions/just.fish

if test $status -eq 0
    echo "✅ Just autocomplete configured for Fish."
else
    echo "⚠ Failed to configure autocomplete."
end

# === 6. Create sample justfile ===
echo
read -P "Do you want to create a sample justfile in ~/justfile? [y/N] " create_sample
if test "$create_sample" = "y" -o "$create_sample" = "Y"
    if test -f ~/justfile
        echo "⚠ ~/justfile already exists. Skipping sample creation."
    else
        echo "📝 Creating sample justfile..."
        set -l justfile_content '# `justfile` - Sample justfile
# Default recipe (run with `just`)
default:
    @echo "Hello from Just! Run `just --list` to see all available recipes."

# Recipe with help text
build:
    @echo "Building..."
    # Add your build commands here

# Recipe with dependencies
test: build
    @echo "Running tests..."
    # Add your test commands here

# Recipe with parameters
serve host=''"'"'localhost'"'"' port=''"'"'8080'"'"':
    @echo "Starting server on {{host}}:{{port}}..."
    # python -m http.server --bind {{host}} {{port}}

# Recipe with private recipe (use lowercase)
_setup:
    @echo "Setting up..."

# Public recipe that uses private recipe
setup: _setup
    @echo "Setup complete!"
'
        echo $justfile_content > ~/justfile
        echo "✅ Sample justfile created at ~/justfile"
    end
end

# === 7. Show useful commands ===
echo
echo "✅ Just installation complete!"
echo "💡 Just is a modern command runner:"
echo "   - Simple task runner inspired by 'make'"
echo "   - No configuration needed, just a justfile"
echo "   - Cross-platform (works everywhere)"
echo "   - Built-in variable support"
echo "   - Recipe dependencies"
echo "   - Shell escaping and execution"
echo "💡 Basic commands:"
echo "   - just: Run the default recipe"
echo "   - just <recipe>: Run a specific recipe"
echo "   - just --list: List all available recipes"
echo "   - just --show <recipe>: Show a recipe's contents"
echo "   - just --dry-run: Show what would run"
echo "   - just -u: Update the justfile"
echo "💡 Example usage:"
echo "   # In a project directory with a justfile:"
echo "   just              # Run default recipe"
echo "   just build        # Run 'build' recipe"
echo "   just test         # Run 'test' recipe"
echo "   just --list       # List all recipes"
echo "💡 Sample justfile recipes:"
echo "   default:"
echo "       @echo 'Hello from Just!'"
echo "   "
echo "   build:"
echo "       cargo build --release"
echo "   "
echo "   test: build"
echo "       cargo test"
echo "   "
echo "   clean:"
echo "       rm -rf target/"
echo "💡 Tips:"
echo "   - Create a justfile in your project root"
echo "   - Use '#' for comments"
echo "   - Use '@' prefix to prevent echoing commands"
echo "   - Use '{{variable}}' for variable substitution"
echo "   - Prefix recipe names with _ to make them private"
echo "   - Run 'just --help' for more options"
echo "💡 Additional resources:"
echo "   - Official site: https://github.com/casey/just"
echo "   - Documentation: https://github.com/casey/just/tree/master/man"
echo "   - Examples: https://github.com/casey/just/tree/master/examples"

