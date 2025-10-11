#!/usr/bin/env fish
# === vivaldi_install.fish ===
# Purpose: Install Vivaldi browser on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🌐 Starting Vivaldi installation..."

# === 1. Install prerequisite packages ===
echo "📦 Installing prerequisites (base-devel, wget, gnupg)..."
sudo pacman -S --needed --noconfirm base-devel wget gnupg
if test $status -ne 0
    echo "❌ Failed to install prerequisites. Aborting."
    exit 1
end
echo "✅ Prerequisites installed."

# === 2. Import Vivaldi's GPG key ===
echo "🔑 Importing Vivaldi repository key..."
wget -qO- https://repo.vivaldi.com/stable/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/pacman/keyrings/vivaldi.gpg
if test $status -ne 0
    echo "❌ Failed to import Vivaldi GPG key."
    exit 1
end
echo "✅ Vivaldi GPG key imported."

# === 3. Add Vivaldi repository ===
echo "📜 Adding Vivaldi repository..."
set repo_file /etc/pacman.d/vivaldi-mirrorlist
echo "[vivaldi]" | sudo tee /etc/pacman.d/vivaldi-mirrorlist > /dev/null
echo "SigLevel = Optional TrustedOnly" | sudo tee -a /etc/pacman.d/vivaldi-mirrorlist > /dev/null
echo "Server = https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee -a /etc/pacman.d/vivaldi-mirrorlist > /dev/null
echo "✅ Vivaldi repository added."

# === 4. Update package database ===
echo "🔄 Updating package database..."
sudo pacman -Sy
if test $status -ne 0
    echo "❌ Failed to update package database."
    exit 1
end

# === 5. Install Vivaldi ===
echo "📦 Installing Vivaldi..."
sudo pacman -S --needed --noconfirm vivaldi
if test $status -ne 0
    echo "❌ Failed to install Vivaldi."
    exit 1
end
echo "✅ Vivaldi installed successfully."

# === 6. Verify installation ===
echo
echo "🧪 Verifying Vivaldi installation..."
vivaldi --version
if test $status -eq 0
    echo "✅ Vivaldi is ready to use!"
else
    echo "❌ Verification failed."
end

echo
echo "💡 You can launch Vivaldi from your application menu or by typing 'vivaldi' in the terminal."

