#!/usr/bin/env fish
# === postman.fish ===
# Purpose: Install Postman API client on CachyOS
# Downloads and installs Postman from official source
# Author: theoneandonlywoj

echo "🚀 Starting Postman installation..."

# === 1. Check if Postman is already installed ===
set -l postman_installed (test -f /opt/postman/Postman; and echo "installed")
if test -n "$postman_installed"
    echo "ℹ Postman is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "ℹ Skipping Postman installation."
        exit 0
    end
    echo "📦 Removing existing Postman installation..."
    sudo rm -rf /opt/postman
    sudo rm -f /usr/share/applications/postman.desktop
    sudo rm -f /usr/local/bin/postman
end

# === 2. Install dependencies ===
echo "📦 Installing dependencies..."
sudo pacman -S --needed --noconfirm curl wget
if test $status -ne 0
    echo "❌ Failed to install dependencies."
    exit 1
end
echo "✅ Dependencies installed."

# === 3. Download Postman ===
set -l POSTMAN_VERSION "10.25.0"
set -l POSTMAN_URL "https://dl.pstmn.io/download/latest/linux64"
set -l POSTMAN_TAR "postman-linux-x64.tar.gz"
set -l POSTMAN_DIR "/opt/postman"
set -l POSTMAN_DESKTOP "/usr/share/applications/postman.desktop"

echo "📥 Downloading Postman $POSTMAN_VERSION..."
cd /tmp
if test -f $POSTMAN_TAR
    rm $POSTMAN_TAR
end

curl -L $POSTMAN_URL -o $POSTMAN_TAR
if test $status -ne 0
    echo "❌ Failed to download Postman."
    exit 1
end
echo "✅ Postman downloaded."

# === 4. Extract and install Postman ===
echo "📦 Extracting Postman..."
if test -d $POSTMAN_DIR
    sudo rm -rf $POSTMAN_DIR
end

sudo mkdir -p $POSTMAN_DIR
sudo tar -xzf $POSTMAN_TAR -C $POSTMAN_DIR --strip-components=1
if test $status -ne 0
    echo "❌ Failed to extract Postman."
    exit 1
end
echo "✅ Postman extracted."

# === 5. Create desktop entry ===
echo "🔗 Creating desktop entry..."
echo "[Desktop Entry]
Name=Postman
Comment=API Development Environment
Exec=/opt/postman/Postman
Icon=/opt/postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;Network;
StartupWMClass=Postman" | sudo tee $POSTMAN_DESKTOP > /dev/null

if test $status -ne 0
    echo "⚠ Failed to create desktop entry."
else
    echo "✅ Desktop entry created."
end

# === 6. Create symlink for command line access ===
echo "🔗 Creating command line symlink..."
sudo ln -sf $POSTMAN_DIR/Postman /usr/local/bin/postman
if test $status -ne 0
    echo "⚠ Failed to create symlink."
else
    echo "✅ Command line access created."
end

# === 7. Set proper permissions ===
echo "⚙ Setting permissions..."
sudo chown -R root:root $POSTMAN_DIR
sudo chmod +x $POSTMAN_DIR/Postman
sudo chmod +x /usr/local/bin/postman
echo "✅ Permissions set."

# === 8. Clean up ===
echo "🧹 Cleaning up..."
rm -f $POSTMAN_TAR
echo "✅ Cleanup complete."

# === 9. Verify installation ===
echo
echo "🧪 Verifying installation..."
if test -f $POSTMAN_DIR/Postman
    echo "✅ Postman binary found at $POSTMAN_DIR/Postman"
else
    echo "❌ Postman binary not found."
end

if test -f $POSTMAN_DESKTOP
    echo "✅ Desktop entry created at $POSTMAN_DESKTOP"
else
    echo "❌ Desktop entry not found."
end

if test -L /usr/local/bin/postman
    echo "✅ Command line symlink created"
else
    echo "❌ Command line symlink not found."
end

echo
echo "✅ Postman installation complete!"
echo "💡 You can now launch Postman from:"
echo "   - Applications menu (Development category)"
echo "   - Command line: postman"
echo "   - Direct execution: /opt/postman/Postman"
echo "💡 Postman will be available system-wide for all users."
