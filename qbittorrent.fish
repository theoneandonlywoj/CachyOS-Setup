#!/usr/bin/env fish
# === qbittorrent.fish ===
# Purpose: Install qBittorrent torrent client on CachyOS
# Installs qBittorrent from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting qBittorrent installation..."

# === 1. Check if qBittorrent is already installed ===
command -q qbittorrent; and set -l qbittorrent_installed "installed"
if test -n "$qbittorrent_installed"
    echo "✅ qBittorrent is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping qBittorrent installation."
        exit 0
    end
    echo "📦 Removing existing qBittorrent installation..."
    sudo pacman -R --noconfirm qbittorrent
    if test $status -ne 0
        echo "❌ Failed to remove qBittorrent."
        exit 1
    end
    echo "✅ qBittorrent removed."
end

# === 2. Install qBittorrent ===
echo "📦 Installing qBittorrent..."
sudo pacman -S --needed --noconfirm qbittorrent
if test $status -ne 0
    echo "❌ Failed to install qBittorrent."
    exit 1
end
echo "✅ qBittorrent installed."

# === 3. Install optional qBittorrent components ===
echo "📦 Installing optional qBittorrent components..."
echo "💡 Additional components available:"
echo "   - qbittorrent-nox: Web-based interface (headless server)"
read -P "Do you want to install qbittorrent-nox (web UI)? [y/N] " install_nox

if test "$install_nox" = "y" -o "$install_nox" = "Y"
    echo "📦 Installing qbittorrent-nox..."
    sudo pacman -S --needed --noconfirm qbittorrent-nox
    if test $status -eq 0
        echo "✅ qbittorrent-nox installed."
        echo "💡 To run qbittorrent-nox:"
        echo "   - Start service: systemctl --user start qbittorrent-nox"
        echo "   - Enable on boot: systemctl --user enable qbittorrent-nox"
        echo "   - Access web UI: http://localhost:8080 (default credentials: admin/adminadmin)"
    else
        echo "⚠ Failed to install qbittorrent-nox."
    end
end

# === 4. Check and fix snapper Boost library issue (if present) ===
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
                echo "⚠ Failed to fix snapper, but qBittorrent is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q qbittorrent
if test $status -eq 0
    echo "✅ qBittorrent installed successfully"
    qbittorrent --version 2>&1 | head -n 1
else
    echo "❌ qBittorrent installation verification failed."
end

echo
echo "✅ qBittorrent installation complete!"
echo "💡 qBittorrent is a free and open-source torrent client:"
echo "   - No ads or bundled software"
echo "   - Feature-rich GUI"
echo "   - Built-in search engine"
echo "   - RSS feed support"
echo "   - Sequential downloading"
echo "   - IP filtering support"
echo "   - Bandwidth scheduling"
echo "💡 Launch qBittorrent:"
echo "   - Command line: qbittorrent"
echo "   - Applications menu (Network category)"
echo "💡 Tips:"
echo "   - Configure download/upload limits in Options → Speed"
echo "   - Set default download location in Options → Downloads"
echo "   - Enable encryption in Options → BitTorrent"
echo "   - Use built-in search (View → Search Engine)"
echo "   - Set up RSS feeds for automatic downloads"
echo "   - Configure port forwarding for better connectivity"
echo "💡 Keyboard shortcuts:"
echo "   - Ctrl+N: New torrent"
echo "   - Ctrl+O: Open torrent file"
echo "   - Delete: Remove torrent"
echo "   - Space: Pause/Resume selected torrents"
echo "   - Ctrl+P: Preferences"
echo "💡 Security:"
echo "   - Consider using a VPN for privacy"
echo "   - Enable IP filtering (Options → Connection → IP Filtering)"
echo "   - Use encrypted connections (Options → BitTorrent → Encryption mode)"
