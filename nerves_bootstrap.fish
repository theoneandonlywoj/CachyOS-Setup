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

# === 3. Install missing dependencies (never upgrade installed AUR packages) ===
set required_packages base-devel ncurses5-compat-libs git squashfs-tools curl
set to_install
for pkg in $required_packages
    pacman -Qq $pkg >/dev/null 2>&1; or set -a to_install $pkg
end

if test (count $to_install) -gt 0
    if not command -q yay
        if not test -t 0
            echo "❌ yay is not installed: install yay first"
            exit 1
        end
        echo "📦 yay is not installed. Installing yay from AUR..."
        sudo pacman -S --needed --noconfirm base-devel git
        if test $status -ne 0
            echo "❌ Failed to install base-devel and git. Rerun: ./nerves_bootstrap.fish"
            exit 1
        end
        set build_dir (mktemp -d)
        git clone https://aur.archlinux.org/yay.git $build_dir/yay
        and cd $build_dir/yay
        and makepkg -si --noconfirm
        if test $status -ne 0
            echo "❌ Failed to install yay. Rerun: ./nerves_bootstrap.fish"
            exit 1
        end
        cd -
        rm -rf $build_dir
    end
    echo "📦 Installing required dependencies via yay: $to_install"
    yay -S --needed --noconfirm $to_install
end

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

# === 4. Install Hex package manager ===
echo "🔧 Installing Hex package manager..."
mix local.hex --force
if test $status -ne 0
    echo "❌ Failed to install Hex. Rerun: ./nerves_bootstrap.fish"
    exit 1
end

# === 5. Install Rebar ===
echo "🔧 Installing Rebar..."
mix local.rebar --force
if test $status -ne 0
    echo "❌ Failed to install Rebar. Rerun: ./nerves_bootstrap.fish"
    exit 1
end

# === 6. Install Nerves Bootstrap archive ===
echo "🔧 Installing Nerves Bootstrap archive..."
mix archive.install hex nerves_bootstrap --force
if test $status -ne 0
    echo "❌ Failed to install Nerves Bootstrap. Rerun: ./nerves_bootstrap.fish"
    exit 1
end

# === 7. Verify installation ===
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

