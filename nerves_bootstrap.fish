#!/usr/bin/env fish
# === nerves_bootstrap.fish ===
# Purpose: Install Nerves Bootstrap for embedded Elixir development on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Nerves Bootstrap setup..."
echo

# === 1. Check for Elixir installation ===
if not command -v mix > /dev/null
    echo "❌ Elixir/Mix is not installed. Please install Elixir first using:"
    echo "   ./elixir_and_erlang.fish"
    echo "Then re-run this script."
    exit 1
end

# === 2. Load Mise environment if available ===
if command -v mise > /dev/null
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
    echo "🔧 Loaded Mise environment"
end

# === 3. Check and install yay if needed ===
if not command -v yay > /dev/null
    echo "📦 yay is not installed. Installing yay from AUR..."
    
    # Install base-devel and git if not already installed (required to build yay)
    sudo pacman -S --needed --noconfirm base-devel git
    if test $status -ne 0
        echo "❌ Failed to install base-devel and git. Aborting."
        exit 1
    end
    
    # Clone and build yay
    cd /tmp
    if test -d yay
        rm -rf yay
    end
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    if test $status -ne 0
        echo "❌ Failed to install yay. Aborting."
        exit 1
    end
    cd -
    echo "✅ yay installed successfully"
else
    echo "✅ yay is already installed"
end

# === 4. Install required dependencies ===
echo "📦 Installing required dependencies via yay..."
set required_packages base-devel ncurses5-compat-libs git squashfs-tools curl
yay -S --needed --noconfirm $required_packages

# Verify packages are installed (yay may crash after successful installation)
set missing_packages
for pkg in $required_packages
    # Extract package name (handle package names with slashes like cachyos/ncurses5-compat-libs)
    set pkg_name (string split '/' $pkg)[-1]
    if not pacman -Q $pkg_name > /dev/null 2>&1
        set -a missing_packages $pkg_name
    end
end

if test -n "$missing_packages"
    echo "❌ Failed to install required dependencies: $missing_packages"
    echo "   Aborting."
    exit 1
end

echo "✅ All required dependencies are installed"

# === 5. Install Hex package manager ===
echo "🔧 Installing Hex package manager..."
mix local.hex --force
if test $status -ne 0
    echo "❌ Failed to install Hex. Aborting."
    exit 1
end

# === 6. Install Rebar ===
echo "🔧 Installing Rebar..."
mix local.rebar --force
if test $status -ne 0
    echo "❌ Failed to install Rebar. Aborting."
    exit 1
end

# === 7. Install Nerves Bootstrap archive ===
echo "🔧 Installing Nerves Bootstrap archive..."
mix archive.install hex nerves_bootstrap --force
if test $status -ne 0
    echo "❌ Failed to install Nerves Bootstrap. Aborting."
    exit 1
end

# === 8. Verify installation ===
echo "🧪 Verifying installation..."
if command -v mix > /dev/null
    # Check if nerves.new command is available (this confirms nerves_bootstrap is installed)
    if mix help nerves.new > /dev/null 2>&1
        echo "✅ Nerves Bootstrap installed successfully"
        echo "   The 'mix nerves.new' command is available"
    else
        echo "⚠️  Nerves Bootstrap installation may have failed."
        echo "   The 'mix nerves.new' command is not available."
    end
else
    echo "❌ Mix command not found. Verification failed."
end

echo
echo "🎉 Nerves Bootstrap setup complete!"
echo
echo "💡 To create a new Nerves project:"
echo "   mix nerves.new my_nerves_app"

