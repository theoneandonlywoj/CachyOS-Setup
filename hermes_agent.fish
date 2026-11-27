#!/usr/bin/env fish
# === hermes_agent.fish ===
# Purpose: Install Hermes Agent via official install script
# Author: theoneandonlywoj

echo "🚀 Starting Hermes Agent installation..."
echo

# === 1. Install ffmpeg (voice/TTS conversion) ===
sudo pacman -S --needed --noconfirm ffmpeg
if test $status -ne 0
    echo "❌ Failed to install ffmpeg. Rerun: ./hermes_agent.fish"
    exit 1
end

# === 2. Ensure ~/.local/bin is in PATH ===
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

# === 3. Install or update Hermes Agent ===
# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

if command -q hermes
    echo "🔄 Updating Hermes Agent in place..."
    hermes update
else
    echo "📦 Installing Hermes Agent..."
    run_installer https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh
end
if test $status -ne 0
    echo "❌ Hermes Agent install/update failed. Rerun: ./hermes_agent.fish"
    exit 1
end

# === 4. Verify installation ===
echo "🧪 Verifying installation..."
if command -v hermes > /dev/null
    echo "✅ Hermes Agent installed successfully!"
    echo "📌 Version info:"
    hermes -h 2>/dev/null | head -10
else
    echo "❌ Hermes verification failed. It may require a shell restart."
    echo "💡 Try restarting your terminal or running:"
    echo "   source ~/.config/fish/config.fish"
    exit 1
end

# === 5. Optional setup and diagnostics ===
if test -t 0
    read -l -P "Run 'hermes setup' now? [y/N] " run_setup
    if test "$run_setup" = "y" -o "$run_setup" = "Y"
        hermes setup; or echo "⚠️  hermes setup did not finish; rerun it later."
    end
end
timeout 60 hermes doctor </dev/null; or echo "⚠️  hermes doctor reported problems (expected before provider setup)."

echo
echo "🎉 Hermes Agent installation complete!"
echo
echo "💡 To use Hermes in this terminal, you may need to restart or run:"
echo "   source ~/.config/fish/config.fish"
echo
echo "📚 Next steps:"
echo "   hermes doctor    - Verify setup"
echo "   hermes --help    - View available commands"