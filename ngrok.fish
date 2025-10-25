#!/usr/bin/env fish
# === ngrok.fish ===
# Purpose: ngrok installation and setup on CachyOS (Arch Linux)
# Includes: ngrok binary, AUR installation, PATH setup
# Author: theoneandonlywoj

echo "🌐 Starting ngrok installation..."

# === 1. Check if running on Arch/CachyOS ===
if not test -f /etc/arch-release
    echo "❌ This script is designed for Arch-based systems like CachyOS."
    exit 1
end

# === 2. Check for AUR helper (yay or paru) ===
set aur_helper ""
if command -v yay >/dev/null
    set aur_helper "yay"
    echo "✅ yay AUR helper found."
else if command -v paru >/dev/null
    set aur_helper "paru"
    echo "✅ paru AUR helper found."
else
    echo "⚠️  No AUR helper found. Installing paru (more reliable than yay)..."
    echo "📦 Installing paru from AUR..."
    
    # Install paru dependencies
    sudo pacman -S --noconfirm --needed base-devel git rust unzip
    
    # Clone and install paru
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
    
    if command -v paru >/dev/null
        set aur_helper "paru"
        echo "✅ paru installed successfully."
    else
        echo "❌ Failed to install paru. Trying alternative method..."
        echo "📦 Installing ngrok directly from official binary..."
        
        # Download ngrok directly from official source
        cd /tmp
        echo "📥 Downloading ngrok from official source..."
        wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip
        if test $status -ne 0
            echo "❌ Failed to download ngrok. Trying alternative URL..."
            wget -O ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
        end
        
        if test -f ngrok.zip
            unzip ngrok.zip
            sudo mv ngrok /usr/local/bin/
            rm ngrok.zip
            echo "✅ ngrok binary installed to /usr/local/bin/"
        else
            echo "❌ Failed to download ngrok binary."
            exit 1
        end
        cd ~
        
        if command -v ngrok >/dev/null
            echo "✅ ngrok installed directly from official binary."
            goto verify_installation
        else
            echo "❌ All installation methods failed. Please install manually."
            exit 1
        end
    end
end

# === 3. Update package database ===
echo "📦 Updating package database..."
sudo pacman -Sy --noconfirm

# === 4. Install ngrok from AUR ===
if test -n "$aur_helper"
    echo "📥 Installing ngrok from AUR using $aur_helper..."
    $aur_helper -S --noconfirm --needed ngrok
    if test $status -ne 0
        echo "❌ Failed to install ngrok from AUR."
        exit 1
    end
end

# === 5. Verify installation ===
verify_installation:
echo "🧪 Verifying ngrok installation..."
if command -v ngrok >/dev/null
    echo "✅ ngrok installed successfully!"
    ngrok version
else
    echo "❌ ngrok installation failed. Please check for errors."
    exit 1
end

# === 6. Create ngrok config directory ===
echo "📁 Setting up ngrok configuration directory..."
mkdir -p ~/.config/ngrok
if test $status -ne 0
    echo "❌ Failed to create ngrok config directory."
    exit 1
end

# === 7. Display usage instructions ===
echo
echo "🎉 ngrok installation complete!"
echo "📝 To get started with ngrok:"
echo "   1. Sign up at https://ngrok.com"
echo "   2. Get your authtoken from the dashboard"
echo "   3. Run: ngrok config add-authtoken YOUR_TOKEN"
echo "   4. Start tunneling: ngrok http 8080"
echo
echo "💡 Configuration files will be stored in ~/.config/ngrok/"
echo "🔗 For more info: https://ngrok.com/docs"
