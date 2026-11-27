#!/usr/bin/env fish
# === step_cli.fish ===
# Purpose: Install step-cli (certificate and PKI toolkit) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting step-cli installation..."

# === 1. Install step-cli ===
sudo pacman -S --needed --noconfirm step-cli
if test $status -ne 0
    echo "❌ Failed to install step-cli. Rerun: ./step_cli.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
if not command -q step-cli
    echo "❌ step-cli installation verification failed: step-cli is not on PATH."
    exit 1
end
step-cli version

echo
echo "✅ step-cli setup complete!"
echo "💡 Arch names the binary step-cli (upstream docs call it step)."
echo "💡 Inspect a certificate: step-cli certificate inspect node1.crt"
echo "💡 New CA: step-cli ca init; existing CA: step-cli ca bootstrap"
