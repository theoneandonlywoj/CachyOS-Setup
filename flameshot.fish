#!/usr/bin/env fish

echo "📸 Installing Flameshot..."

# 1) Validate pacman
if not type -q pacman
  echo "❌ pacman not found. This script targets CachyOS/Arch."
  exit 1
end

# 2) Install Flameshot
sudo pacman -S --noconfirm --needed flameshot
if test $status -ne 0
  echo "❌ Failed to install Flameshot"
  exit 1
end
echo "✅ Flameshot installed"

# 3) Enable autostart
set -l AUTOSTART_DIR "$HOME/.config/autostart"
set -l DESKTOP_FILE "$AUTOSTART_DIR/flameshot.desktop"
mkdir -p $AUTOSTART_DIR
if not test -f $DESKTOP_FILE
  echo "🔗 Enabling autostart..."
  printf "[Desktop Entry]\nType=Application\nExec=flameshot\nHidden=false\nNoDisplay=false\nX-GNOME-Autostart-enabled=true\nName=Flameshot\n" > $DESKTOP_FILE
  echo "✅ Autostart enabled"
else
  echo "ℹ️  Autostart already configured"
end

echo "🚀 Run 'flameshot gui' to capture screenshots"


