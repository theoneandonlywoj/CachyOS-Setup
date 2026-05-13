#!/usr/bin/env fish
# === nmap.fish ===
# Purpose: Install nmap on CachyOS (Arch Linux)
# Author: theoneandonlywoj

function print_usage
    echo "📚 Nmap CLI usage:"
    echo
    echo "   ── Target Specification ──"
    echo "   nmap 192.168.1.1                  # Scan a single host"
    echo "   nmap 192.168.1.0/24               # Scan a subnet (CIDR)"
    echo "   nmap 192.168.1.1-254              # Scan an IP range"
    echo "   nmap 192.168.1,3,5.100-200        # Scan comma-separated range"
    echo "   nmap -iL targets.txt              # Scan hosts from a file"
    echo
    echo "   ── Scan Techniques ──"
    echo "   nmap -sS <target>                 # TCP SYN scan (default, stealthy)"
    echo "   nmap -sT <target>                 # TCP connect scan (no raw socket needed)"
    echo "   nmap -sU <target>                 # UDP scan"
    echo "   nmap -sP <target>                 # Ping scan (discover live hosts only)"
    echo "   nmap -sV <target>                 # Service/version detection"
    echo "   nmap -O <target>                  # OS detection"
    echo "   nmap -A <target>                  # Aggressive: OS, services, scripts, traceroute"
    echo
    echo "   ── Port Specification ──"
    echo "   nmap -p 80 <target>               # Scan a single port"
    echo "   nmap -p 22,80,443 <target>        # Scan specific ports"
    echo "   nmap -p 1-1000 <target>           # Scan a port range"
    echo "   nmap -p- <target>                 # Scan all 65535 ports"
    echo "   nmap --top-ports 100 <target>     # Scan top 100 most common ports"
    echo
    echo "   ── Output & Performance ──"
    echo "   nmap -v <target>                  # Verbose output (use -vv for more)"
    echo "   nmap -oN scan.txt <target>        # Normal output to file"
    echo "   nmap -oX scan.xml <target>        # XML output to file"
    echo "   nmap -T4 <target>                 # Aggressive timing (T0–T5, default T3)"
    echo
    echo "   ── NSE Scripts ──"
    echo "   nmap --script=vuln <target>       # Run vulnerability detection scripts"
    echo "   nmap --script=http-headers <target> # Run HTTP header script"
    echo "   nmap --script=http-enum <target>  # Enumerate HTTP directories"
    echo "   nmap --script=default <target>    # Run default safe scripts"
    echo
end

echo "🚀 Starting Nmap setup..."
echo

# === 1. Check if already installed ===
if command -v nmap > /dev/null
    set installed_version (nmap --version 2>/dev/null | head -1)
    echo "ℹ️  Nmap is already installed:"
    echo "   $installed_version"
    echo
    echo "💡 To upgrade to the latest version, run:"
    echo "   sudo pacman -S nmap"
    echo
    print_usage
    exit 0
end

# === 2. Install nmap ===
echo "📦 Installing nmap..."
sudo pacman -S --needed --noconfirm nmap
if test $status -ne 0
    echo "❌ Failed to install nmap. Aborting."
    exit 1
end

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
set nmap_version (command nmap --version 2>/dev/null | head -1)

if test -n "$nmap_version"
    echo "✅ Nmap installed successfully:"
    echo "   $nmap_version"
else
    echo "❌ Nmap verification failed."
    exit 1
end

echo
echo "🎉 Nmap setup complete!"
echo
print_usage
