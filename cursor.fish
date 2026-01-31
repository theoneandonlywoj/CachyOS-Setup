#!/usr/bin/env fish
# === cursor.fish ===
# Purpose: Install or update Cursor AI on CachyOS / Arch Linux
# Author: theoneandonlywoj

echo "🚀 Starting Cursor AI installation/update..."

# === 1. Install dependencies ===
echo "📦 Installing required dependencies..."
sudo pacman -S --noconfirm fuse2 wget
if test $status -ne 0
    echo "❌ Failed to install dependencies. Aborting."
    exit 1
end

# === 2. Prepare installation directory ===
set cursor_dir $HOME/opt
mkdir -p $cursor_dir
set cursor_appimage $cursor_dir/cursor.appimage

# === 3. Backup old Cursor AppImage if exists ===
if test -f $cursor_appimage
    set timestamp (date "+%Y_%m_%d_%H_%M_%S")
    set backup_file $cursor_dir/cursor.appimage.backup_$timestamp
    echo "⚠ Existing Cursor AppImage found. Backing up to $backup_file..."
    mv $cursor_appimage $backup_file
    if test $status -ne 0
        echo "❌ Failed to backup existing AppImage. Aborting."
        exit 1
    end
end

# === 4. Download latest Cursor AppImage ===
echo "🔽 Downloading latest Cursor AppImage..."
wget -O $cursor_appimage "https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/2.4"
if test $status -ne 0
    echo "❌ Failed to download Cursor AppImage. Aborting."
    exit 1
end

# === 5. Make AppImage executable ===
chmod +x $cursor_appimage
if test $status -ne 0
    echo "❌ Failed to make AppImage executable. Aborting."
    exit 1
end

# === 6. Download Cursor icon ===
set icon_file $cursor_dir/cursor.png
echo "🖼 Downloading Cursor icon..."
curl -fsSL https://www.cursor.com/favicon.ico -o $icon_file
if test $status -ne 0
    echo "❌ Failed to download Cursor icon. Aborting."
    exit 1
end

# === 7. Remove old desktop entries matching Cursor ===
echo "🗑 Cleaning up old Cursor desktop entries..."
for f in /usr/share/applications/cursor*.desktop
    if test -f $f
        sudo rm $f
    end
end

# === 8. Create or update desktop entry ===
set desktop_entry /usr/share/applications/cursor.desktop
echo "📄 Creating/updating desktop entry at $desktop_entry..."
sudo sh -c "echo '[Desktop Entry]
Name=Cursor
Exec=$cursor_appimage
Icon=$icon_file
Type=Application
Categories=Development;' > $desktop_entry"
if test $status -ne 0
    echo "❌ Failed to create/update desktop entry. Aborting."
    exit 1
end

# === 9. Refresh desktop database ===
update-desktop-database /usr/share/applications
echo "✅ Desktop entry created/updated successfully!"

# === 10. Create or update symlink for terminal access ===
if test -L /usr/local/bin/cursor
    sudo rm /usr/local/bin/cursor
end
sudo ln -s $cursor_appimage /usr/local/bin/cursor
echo "🔗 Symlink updated: /usr/local/bin/cursor → $cursor_appimage"

echo "🎉 Cursor installation/update complete!"
echo "📦 Backup of old AppImage (if any) is located in $cursor_dir"
echo "🖱 You can now launch Cursor from the application menu or by running 'cursor' in the terminal."
echo ""
echo "📋 Installed Cursor version:"
cursor --version
echo ""
echo "💡 Tip: To move the Chat panel to the right, go to View → Appearance → Move Secondary Side Bar Right"
echo ""
echo "⌨️  Useful shortcuts:"
echo "   Ctrl+Alt+E    → Editors (e.g. turn off Editor to full screen the Agent)"
echo "   Ctrl+J        → Pane / Terminal (toggle terminal panel)"
echo "   Ctrl+Shift+J  → Cursor Settings"
echo "   Ctrl+B        → Sidebar (toggle file explorer)"
echo "   Ctrl+Shift+B  → Browser (open browser inside Cursor)"
echo "   Ctrl+L        → Chat / Sidepanel (toggle Chat panel)"
echo "   Ctrl+1        → Focus Editor (switch from Chat to code)"
echo '   Ctrl+`        → Focus Terminal (from editor; backtick key)'
echo "   Esc           → Unfocus (e.g. leave Chat or Terminal, accept terminal command)"
echo ""
echo "   General navigation & workflow:"
echo "   Ctrl+Shift+P  → Command palette (run any command)"
echo "   Ctrl+Shift+P  → type 'New Cursor Rule' → Enter (add a new Cursor rule)"
echo "   Ctrl+P        → Quick Open (go to file)"
echo "   Ctrl+Shift+E  → Focus file explorer"
echo "   Ctrl+Shift+G  → Source control (Git)"
echo "   Ctrl+\\       → Split editor right"
echo ""
echo "   When in Browser:"
echo "   Find the icon in the top-right corner of the browser → enable Select Element, then hold left mouse button to add the element to the chat"
echo ""
echo "   When focused in Chat:"
echo "   @             → Add a file to context"
echo "   Shift+Tab     → Change modes (Agent, Plan, Debug, Ask)"
echo "   Ctrl+/        → Change the Model"
echo "   Ctrl+Shift+/  → Change the Agent Cycle Count"

