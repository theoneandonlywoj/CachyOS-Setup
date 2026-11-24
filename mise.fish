#!/usr/bin/env fish
# === mise.fish ===
# Purpose: Install Mise (environment/version manager) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Mise installation..."

# === 1. Install dependencies ===
echo "📦 Installing required dependencies (git, curl)..."
sudo pacman -S --needed --noconfirm git curl
if test $status -ne 0
    echo "❌ Failed to install dependencies. Rerun: ./mise.fish"
    exit 1
end

# === 2. Add ~/.local/bin to PATH for Fish shell ===
mkdir -p "$HOME/.local/bin"
# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if not contains -- "$HOME/.local/bin" $PATH
    fish_add_path -U "$HOME/.local/bin"
    if test $status -ne 0
        echo "❌ Failed to add ~/.local/bin to the Fish PATH."
        exit 1
    end
end

# === 3. Install or update Mise ===
# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

if pacman -Qq mise >/dev/null 2>&1
    echo "✅ Mise is owned by pacman; upgrades come from 'paru -Syu'."
else if command -q mise
    echo "🔄 Updating Mise in place..."
    mise self-update -y
else
    echo "🔽 Downloading and running Mise installer..."
    run_installer https://mise.run
end
if test $status -ne 0
    echo "❌ Mise install/update failed; an existing install is untouched. Rerun: ./mise.fish"
    exit 1
end

# === 4. Initialize Mise in Fish ===
echo "⚙ Initializing Mise in Fish shell..."
if not grep -q "mise activate fish" ~/.config/fish/config.fish 2>/dev/null
    echo -e "\n# Initialize Mise\nmise activate fish | source" >> ~/.config/fish/config.fish
    echo "✅ Added Mise initialization to ~/.config/fish/config.fish"
else
    echo "ℹ Mise initialization already present in Fish config."
end

# === 5. Verify installation ===
echo "🧪 Verifying Mise installation..."
if command -v mise > /dev/null
    echo "✅ Mise installed successfully: $(mise --version)"
else
    echo "❌ Mise not found in PATH. You may need to restart your terminal."
end

echo
echo "🎉 Mise installation complete!"
echo "💡 You can now install runtimes, e.g.:"
echo "   mise use -g node@lts python@3.12"
echo "   mise install"

