#!/usr/bin/env fish
# === gping.fish ===
# Purpose: Install gping (ping with graph visualization) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting gping installation..."
echo
echo "💡 gping is a ping tool with graph visualization:"
echo "   - Real-time graph of ping latency"
echo "   - Visual representation of network latency"
echo "   - Multiple host support"
echo "   - Color-coded latency indicators"
echo "   - Great for monitoring network stability"
echo

# === 1. Check if gping is already installed ===
command -q gping; and set -l gping_installed "installed"
if test -n "$gping_installed"
    echo "✅ gping is already installed."
    gping --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping gping installation."
        exit 0
    end
    echo "📦 Removing existing gping installation..."
    sudo pacman -R --noconfirm gping
    if test $status -ne 0
        echo "❌ Failed to remove gping."
        exit 1
    end
    echo "✅ gping removed."
end

# === 2. Install gping ===
echo "📦 Installing gping from official repository..."
sudo pacman -S --needed --noconfirm gping
if test $status -ne 0
    echo "❌ Failed to install gping."
    exit 1
end
echo "✅ gping installed."

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q gping
    echo "✅ gping installed successfully"
    gping --version 2>&1 | head -n 1
else
    echo "❌ gping installation verification failed."
    exit 1
end

echo
echo "🎉 gping installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Ping a single host with graph"
echo "   gping example.com"
echo ""
echo "   # Ping multiple hosts"
echo "   gping google.com cloudflare.com"
echo ""
echo "   # Ping with IPv4 only"
echo "   gping -4 example.com"
echo ""
echo "   # Ping with IPv6 only"
echo "   gping -6 example.com"
echo ""
echo "💡 Common options:"
echo "   # Set buffer size (number of data points)"
echo "   gping --buffer 100 example.com"
echo ""
echo "   # Set interval between pings (milliseconds)"
echo "   gping --watch-interval 500 example.com"
echo ""
echo "   # Show timestamps"
echo "   gping --timestamp example.com"
echo ""
echo "   # Set graph height"
echo "   gping --height 20 example.com"
echo ""
echo "💡 Display options:"
echo "   # Show help"
echo "   gping --help"
echo ""
echo "   # Show version"
echo "   gping --version"
echo ""
echo "💡 Comparison with ping:"
echo "   # ping shows: text output, statistics"
echo "   gping shows: visual graph, real-time latency"
echo ""
echo "   # ping example:"
echo "   ping -c 10 example.com"
echo ""
echo "   # gping example:"
echo "   gping example.com"
echo ""
echo "💡 Use cases:"
echo "   # Monitor network latency in real-time"
echo "   gping example.com"
echo ""
echo "   # Compare latency to multiple hosts"
echo "   gping google.com cloudflare.com 8.8.8.8"
echo ""
echo "   # Monitor local network device"
echo "   gping 192.168.1.1"
echo ""
echo "   # Check DNS server latency"
echo "   gping 8.8.8.8 1.1.1.1"
echo ""
echo "💡 Tips:"
echo "   - The graph shows latency over time"
echo "   - Green indicates low latency"
echo "   - Yellow/red indicates higher latency"
echo "   - Use Ctrl+C to stop"
echo "   - Multiple hosts show separate graphs"
echo "   - Great for identifying network issues visually"
echo ""
echo "💡 Keyboard shortcuts:"
echo "   Ctrl+C        Stop pinging and exit"
echo ""
echo "💡 Resources:"
echo "   - GitHub: https://github.com/orf/gping"
echo "   - Man page: man gping"

