#!/usr/bin/env fish
# === ardour.fish ===
# Purpose: Install Ardour DAW on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Ardour installation..."

# === 1. Check for existing Ardour installation ===
if command -v ardour9 > /dev/null
    echo "⚠ Existing Ardour installation detected."
    read -l -P "Do you want to remove it and reinstall? (y/N): " confirm
    switch $confirm
        case y Y
            echo "🧹 Removing existing Ardour installation..."
            sudo pacman -R --noconfirm ardour
            if test $status -ne 0
                echo "❌ Failed to remove Ardour. Aborting."
                exit 1
            end
        case '*'
            echo "ℹ Skipping removal."
    end
end

# === 2. Install dependencies ===
echo "📦 Installing required dependencies..."
if pacman -Qi jack > /dev/null 2>&1
    echo "ℹ JACK (jack) is already installed — skipping jack2 (they conflict)."
    sudo pacman -S --noconfirm --needed ardour pipewire alsa-plugins lib32-alsa-plugins lib32-libpulse
else
    sudo pacman -S --noconfirm --needed ardour pipewire jack2 alsa-plugins lib32-alsa-plugins lib32-libpulse
end
if test $status -ne 0
    echo "❌ Failed to install dependencies. Aborting."
    exit 1
end

# === 3. Verify installation ===
echo
echo "🧪 Verifying Ardour installation..."
if command -v ardour9 > /dev/null
    echo "✅ Ardour installed successfully: $(ardour9 --version 2>&1 | head -n 1)"
else
    echo "❌ Ardour not found in PATH. You may need to restart your terminal."
end

echo
echo "🎉 Ardour installation complete!"
echo "💡 You can now launch Ardour from:"
echo "   - Application menu (Sound & Video category)"
echo "   - Terminal: ardour9"
echo
echo "💡 Tips for using Ardour on Linux:"
echo "   - Audio: Use PipeWire or JACK for low-latency audio"
echo "   - MIDI: Ardour supports MIDI via ALSA and JACK"
echo "   - Plugins: Ardour supports LV2, VST2, and VST3 formats"
echo "   - Ardour is free/libre software — no trial limitations"
echo "   - Console: ardour9 --help for command-line options"