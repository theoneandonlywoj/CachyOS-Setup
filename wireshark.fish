#!/usr/bin/env fish
# === wireshark.fish ===
# Purpose: Install Wireshark network protocol analyzer on CachyOS
# Installs Wireshark from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Wireshark installation..."

# === 1. Check if Wireshark is already installed ===
command -q wireshark; and set -l wireshark_installed "installed"
command -q tshark; and set -l tshark_installed "installed"

if test -n "$wireshark_installed" -o -n "$tshark_installed"
    echo "✅ Wireshark is already installed."
    if test -n "$wireshark_installed"
        wireshark --version 2>&1 | head -n 1
    end
    if test -n "$tshark_installed"
        tshark --version 2>&1 | head -n 1
    end
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Wireshark installation."
        exit 0
    end
    echo "📦 Removing existing Wireshark installation..."
    sudo pacman -R --noconfirm wireshark-qt wireshark-cli 2>/dev/null
    if test $status -ne 0
        echo "⚠ Some packages may not have been removed, continuing..."
    end
    echo "✅ Wireshark removed."
end

# === 2. Choose installation type ===
echo "📌 Choose Wireshark installation:"
echo "   1) Wireshark CLI only (tshark, command-line tools)"
echo "   2) Wireshark with GUI (Full version with Qt interface)"
read -P "Select [1/2]: " install_choice

if test "$install_choice" = "1"
    set PACKAGES "wireshark-cli"
    set INSTALL_TYPE "CLI only"
else if test "$install_choice" = "2"
    set PACKAGES "wireshark-qt wireshark-cli"
    set INSTALL_TYPE "Full version with GUI"
else
    echo "❌ Invalid choice. Defaulting to full installation."
    set PACKAGES "wireshark-qt wireshark-cli"
    set INSTALL_TYPE "Full version with GUI"
end

echo "📌 Selected: Wireshark $INSTALL_TYPE"

# === 3. Install Wireshark ===
echo "📦 Installing Wireshark ($INSTALL_TYPE)..."
if test "$install_choice" = "1"
    sudo pacman -S --needed --noconfirm wireshark-cli
else
    sudo pacman -S --needed --noconfirm wireshark-qt wireshark-cli
end

if test $status -ne 0
    echo "❌ Failed to install Wireshark."
    exit 1
end
echo "✅ Wireshark installed."

# === 4. Setup Wireshark for non-root usage ===
echo "⚙️ Configuring Wireshark for non-root usage..."
echo "💡 Wireshark typically requires root privileges to capture packets."
echo "💡 To run Wireshark without root, you can:"
echo "   - Add your user to the wireshark group: sudo usermod -aG wireshark $USER"
echo "   - Or run with sudo when needed"
read -P "Do you want to add your user to the wireshark group? [y/N] " add_group

if test "$add_group" = "y" -o "$add_group" = "Y"
    echo "📦 Adding $USER to wireshark group..."
    sudo usermod -aG wireshark $USER
    if test $status -eq 0
        echo "✅ User added to wireshark group."
        echo "⚠️ You need to log out and log back in (or run 'newgrp wireshark') for the changes to take effect."
    else
        echo "⚠ Failed to add user to wireshark group."
    end
end

# === 5. Check and fix snapper Boost library issue (if present) ===
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
                echo "⚠ Failed to fix snapper, but Wireshark is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
set verification_passed true

if command -q tshark
    echo "✅ tshark CLI installed successfully"
    tshark --version 2>&1 | head -n 1
else
    echo "❌ tshark installation verification failed."
    set verification_passed false
end

if test -n "$wireshark_installed" -o "$install_choice" = "2"
    if command -q wireshark
        echo "✅ Wireshark GUI installed successfully"
        wireshark --version 2>&1 | head -n 1
    else
        echo "❌ Wireshark GUI installation verification failed."
        set verification_passed false
    end
end

if test "$verification_passed" = "false"
    echo "⚠️ Some components failed verification."
end

echo
echo "✅ Wireshark installation complete!"
echo "💡 Wireshark is a network protocol analyzer for:"
echo "   - Capturing and analyzing network traffic"
echo "   - Troubleshooting network problems"
echo "   - Network security analysis"
echo "   - Protocol development and learning"
echo ""
echo "💡 Basic Wireshark commands:"
echo "   - tshark -i interface: Capture packets from interface"
echo "   - tshark -r file: Read and analyze saved capture file"
echo "   - tshark -i any: Capture from all interfaces"
echo "   - wireshark: Launch GUI (if installed)"
echo ""
echo "💡 Common tshark usage:"
echo "   - Capture packets: tshark -i wlan0"
echo "   - Save to file: tshark -i wlan0 -w capture.pcap"
echo "   - Filter packets: tshark -i wlan0 -f 'port 80'"
echo "   - Display packets: tshark -i wlan0 -x"
echo "   - Count packets: tshark -i wlan0 -c 100"
echo ""
echo "💡 Useful tshark filters:"
echo "   - http: HTTP traffic only"
echo "   - tcp port 80: TCP traffic on port 80"
echo "   - host 192.168.1.1: Traffic to/from specific host"
echo "   - icmp: ICMP traffic only"
echo "   - tcp and port 443: HTTPS traffic"
echo ""
echo "💡 Security and permissions:"
echo "   - Normal packet capture requires elevated privileges"
echo "   - Or add user to wireshark group (done above if you chose yes)"
echo "   - For basic pcap reading: tshark -r file.pcap"
echo ""
echo "💡 GUI usage (if installed):"
echo "   - wireshark: Launch GUI interface"
echo "   - wireshark file.pcap: Open saved capture"
echo "   - Use filter bar for live filtering"
echo "   - Right-click packets for detailed analysis"
echo ""
echo "💡 Tips:"
echo "   - Use color rules to highlight interesting packets"
echo "   - Export specific packets or conversations"
echo "   - Use statistics for protocol distribution"
echo "   - Follow TCP streams for HTTP analysis"
echo ""
echo "💡 Example workflows:"
echo "   1. Capture HTTP traffic: tshark -i any -f 'port 80' -w http_capture.pcap"
echo "   2. Analyze saved file: tshark -r http_capture.pcap"
echo "   3. Get packet count: tshark -r http_capture.pcap | wc -l"
echo "   4. Extract DNS queries: tshark -r http_capture.pcap 'dns'"
echo ""

