#!/usr/bin/env fish
# === postman.fish ===
# Purpose: Install Postman API client on CachyOS
# Downloads and installs Postman from official source
# Author: theoneandonlywoj

echo "🚀 Starting Postman installation..."

# === 1. Install dependencies ===
echo "📦 Installing dependencies..."
sudo pacman -S --needed --noconfirm curl wget
if test $status -ne 0
    echo "❌ Failed to install dependencies."
    exit 1
end
echo "✅ Dependencies installed."

# === 2. Download Postman ===
set -l POSTMAN_URL "https://dl.pstmn.io/download/latest/linux64"
set -l POSTMAN_DIR "/opt/postman"
set -l POSTMAN_DESKTOP "/usr/share/applications/postman.desktop"

# Recover from an interrupted swap: restore the old install, drop stale staging.
if not test -e $POSTMAN_DIR; and test -e $POSTMAN_DIR.old
    sudo mv $POSTMAN_DIR.old $POSTMAN_DIR
    or exit 1
end
sudo rm -rf $POSTMAN_DIR.new $POSTMAN_DIR.old

set -l tmp (mktemp -d)
or exit 1
echo "📥 Downloading the latest Postman..."
mkdir $tmp/app
and curl -fL $POSTMAN_URL -o $tmp/postman.tar.gz
if test $status -ne 0
    rm -rf $tmp
    echo "❌ Failed to download Postman; the existing install is untouched. Rerun: ./postman.fish"
    exit 1
end
echo "✅ Postman downloaded."

# === 3. Extract Postman, then swap it in ===
echo "📦 Extracting Postman..."
tar -xzf $tmp/postman.tar.gz -C $tmp/app --strip-components=1
and test -f $tmp/app/Postman
and sudo mv $tmp/app $POSTMAN_DIR.new
if test $status -ne 0
    rm -rf $tmp
    echo "❌ Failed to extract Postman; the existing install is untouched. Rerun: ./postman.fish"
    exit 1
end
rm -rf $tmp

if test -e $POSTMAN_DIR
    sudo mv $POSTMAN_DIR $POSTMAN_DIR.old
    or exit 1
end
sudo mv $POSTMAN_DIR.new $POSTMAN_DIR
if test $status -ne 0
    test -e $POSTMAN_DIR.old; and sudo mv $POSTMAN_DIR.old $POSTMAN_DIR
    echo "❌ Failed to install Postman. Rerun: ./postman.fish"
    exit 1
end
sudo rm -rf $POSTMAN_DIR.old
echo "✅ Postman installed."

# === 4. Create desktop entry ===
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

# === 5. Create symlink for command line access ===
echo "🔗 Creating command line symlink..."
sudo ln -sf $POSTMAN_DIR/Postman /usr/local/bin/postman
if test $status -ne 0
    echo "⚠ Failed to create symlink."
else
    echo "✅ Command line access created."
end

# === 6. Set proper permissions ===
echo "⚙ Setting permissions..."
sudo chown -R root:root $POSTMAN_DIR
sudo chmod +x $POSTMAN_DIR/Postman
sudo chmod +x /usr/local/bin/postman
echo "✅ Permissions set."

# === 7. Verify installation ===
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
