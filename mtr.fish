#!/usr/bin/env fish
# === mtr.fish ===
# Purpose: Install mtr (My Traceroute - network diagnostic tool) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting mtr installation..."
echo
echo "💡 mtr (My Traceroute) is a network diagnostic tool:"
echo "   - Combines ping and traceroute functionality"
echo "   - Real-time network path analysis"
echo "   - Shows packet loss and latency per hop"
echo "   - Interactive and report modes"
echo "   - Great for troubleshooting network issues"
echo

# === 1. Check if mtr is already installed ===
command -q mtr; and set -l mtr_installed "installed"
if test -n "$mtr_installed"
    echo "✅ mtr is already installed."
    mtr --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping mtr installation."
        exit 0
    end
    echo "📦 Removing existing mtr installation..."
    sudo pacman -R --noconfirm mtr
    if test $status -ne 0
        echo "❌ Failed to remove mtr."
        exit 1
    end
    echo "✅ mtr removed."
end

# === 2. Install mtr ===
echo "📦 Installing mtr from official repository..."
sudo pacman -S --needed --noconfirm mtr
if test $status -ne 0
    echo "❌ Failed to install mtr."
    exit 1
end
echo "✅ mtr installed."

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q mtr
    echo "✅ mtr installed successfully"
    mtr --version 2>&1 | head -n 1
else
    echo "❌ mtr installation verification failed."
    exit 1
end

echo
echo "🎉 mtr installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Interactive mode (default)"
echo "   mtr example.com"
echo ""
echo "   # Report mode (non-interactive)"
echo "   mtr --report --report-cycles 10 example.com"
echo ""
echo "   # IPv4 only"
echo "   mtr -4 example.com"
echo ""
echo "   # IPv6 only"
echo "   mtr -6 example.com"
echo ""
echo "💡 Common options:"
echo "   # Set number of pings"
echo "   mtr --report --report-cycles 5 example.com"
echo ""
echo "   # Set interval between pings (seconds)"
echo "   mtr --interval 2 example.com"
echo ""
echo "   # Set packet size"
echo "   mtr --psize 64 example.com"
echo ""
echo "   # Show AS numbers"
echo "   mtr --aslookup example.com"
echo ""
echo "   # Show IP addresses and hostnames"
echo "   mtr --show-ips example.com"
echo ""
echo "💡 Interactive mode controls:"
echo "   h, ?          Show help"
echo "   d             Toggle DNS resolution"
echo "   n             Toggle DNS resolution (numeric)"
echo "   r             Reset statistics"
echo "   o             Change display options"
echo "   p             Pause/resume"
echo "   q             Quit"
echo ""
echo "💡 Report mode examples:"
echo "   # Basic report"
echo "   mtr --report --report-cycles 10 example.com"
echo ""
echo "   # Report with CSV output"
echo "   mtr --report --report-cycles 10 --csv example.com"
echo ""
echo "   # Report with JSON output"
echo "   mtr --report --report-cycles 10 --json example.com"
echo ""
echo "   # Report with XML output"
echo "   mtr --report --report-cycles 10 --xml example.com"
echo ""
echo "💡 Advanced options:"
echo "   # TCP mode (instead of ICMP)"
echo "   mtr --tcp --port 80 example.com"
echo ""
echo "   # UDP mode"
echo "   mtr --udp --port 53 example.com"
echo ""
echo "   # SCTP mode"
echo "   mtr --sctp example.com"
echo ""
echo "   # Set TTL (time to live)"
echo "   mtr --first-ttl 5 example.com"
echo ""
echo "   # Set maximum TTL"
echo "   mtr --max-ttl 30 example.com"
echo ""
echo "💡 Display options:"
echo "   # Show IP addresses"
echo "   mtr --show-ips example.com"
echo ""
echo "   # Show AS numbers"
echo "   mtr --aslookup example.com"
echo ""
echo "   # No DNS resolution"
echo "   mtr --no-dns example.com"
echo ""
echo "   # Force DNS resolution"
echo "   mtr --dns example.com"
echo ""
echo "💡 Comparison with other tools:"
echo "   # mtr vs ping"
echo "   ping shows: single destination, overall stats"
echo "   mtr shows: each hop, per-hop stats"
echo ""
echo "   # mtr vs traceroute"
echo "   traceroute shows: one packet per hop, static"
echo "   mtr shows: continuous updates, dynamic"
echo ""
echo "💡 Use cases:"
echo "   # Diagnose network latency issues"
echo "   mtr --report --report-cycles 20 example.com"
echo ""
echo "   # Find packet loss location"
echo "   mtr --report --report-cycles 50 example.com"
echo ""
echo "   # Monitor network path over time"
echo "   watch -n 1 'mtr --report --report-cycles 5 example.com'"
echo ""
echo "💡 Tips:"
echo "   - Use report mode for scripts and automation"
echo "   - Interactive mode is great for real-time monitoring"
echo "   - AS lookup helps identify network providers"
echo "   - TCP mode works when ICMP is blocked"
echo "   - Combine with other tools (ping, traceroute) for comprehensive analysis"
echo ""
echo "💡 Resources:"
echo "   - GitHub: https://github.com/traviscross/mtr"
echo "   - Man page: man mtr"
echo "   - Arch Wiki: https://wiki.archlinux.org/title/MTR"

