#!/usr/bin/env fish
# === syncthing.fish ===
# Purpose: Install Syncthing continuous file synchronization on CachyOS
# Installs Syncthing from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Syncthing installation..."

# === 1. Check if Syncthing is already installed ===
command -q syncthing; and set -l syncthing_installed "installed"
if test -n "$syncthing_installed"
    echo "✅ Syncthing is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Syncthing installation."
        exit 0
    end
    echo "📦 Removing existing Syncthing installation..."
    sudo pacman -R --noconfirm syncthing
    if test $status -ne 0
        echo "❌ Failed to remove Syncthing."
        exit 1
    end
    echo "✅ Syncthing removed."
end

# === 2. Install Syncthing ===
echo "📦 Installing Syncthing..."
sudo pacman -S --needed --noconfirm syncthing
if test $status -ne 0
    echo "❌ Failed to install Syncthing."
    exit 1
end
echo "✅ Syncthing installed."

# === 3. Install optional server components ===
echo "📦 Checking for optional Syncthing server components..."
echo "💡 The following optional packages provide additional Syncthing functionality:"
echo "   - syncthing-discosrv: Discovery server for improved peer discovery"
echo "   - syncthing-relaysrv: Relay server for NAT traversal"
read -P "Do you want to install server components? [y/N] " install_servers

if test "$install_servers" = "y" -o "$install_servers" = "Y"
    echo "📦 Installing Syncthing server components..."
    sudo pacman -S --needed --noconfirm syncthing-discosrv syncthing-relaysrv
    if test $status -ne 0
        echo "⚠ Failed to install some server components, but Syncthing is still installed."
    else
        echo "✅ Server components installed."
    end
end

# === 4. Setup Syncthing service (optional) ===
echo "📦 Setting up Syncthing service..."
read -P "Do you want to enable and start Syncthing service? [y/N] " enable_service

if test "$enable_service" = "y" -o "$enable_service" = "Y"
    echo "📦 Enabling Syncthing service..."
    sudo systemctl enable syncthing@$USER.service
    if test $status -eq 0
        echo "📦 Starting Syncthing service..."
        sudo systemctl start syncthing@$USER.service
        if test $status -eq 0
            echo "✅ Syncthing service started successfully."
            echo "💡 Syncthing is now running and will start automatically on boot."
        else
            echo "⚠ Failed to start Syncthing service."
        end
    else
        echo "⚠ Failed to enable Syncthing service."
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
                echo "⚠ Failed to fix snapper, but Syncthing is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q syncthing
if test $status -eq 0
    echo "✅ Syncthing installed successfully"
    syncthing --version 2>&1 | head -n 1
else
    echo "❌ Syncthing installation verification failed."
end

echo
echo "✅ Syncthing installation complete!"
echo "💡 Syncthing is a continuous file synchronization tool:"
echo "   - Real-time file synchronization"
echo "   - Works across multiple devices"
echo "   - End-to-end encryption"
echo "   - No central server required"
echo "💡 Access the web interface:"
echo "   - Open browser: http://localhost:8384"
echo "   - Default admin interface is available at port 8384"
echo "💡 Service management:"
echo "   - Start: systemctl --user start syncthing"
echo "   - Stop: systemctl --user stop syncthing"
echo "   - Status: systemctl --user status syncthing"
echo "   - Enable: systemctl --user enable syncthing"
echo "💡 Getting started:"
echo "   1. Access web interface at http://localhost:8384"
echo "   2. Set up admin password and accept terms"
echo "   3. Add a new folder or connect to an existing device"
echo "   4. Share your device ID with other devices you want to sync"
echo "💡 Configuration location:"
echo "   - Config: ~/.config/syncthing/"
echo "   - Default sync folder: ~/Sync/"

