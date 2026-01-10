#!/usr/bin/env fish
# === copyq.fish ===
# Purpose: Install CopyQ (clipboard manager with history) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting CopyQ installation..."
echo
echo "💡 CopyQ is a powerful clipboard manager:"
echo "   - Clipboard history with search"
echo "   - Graphical user interface"
echo "   - Customizable actions and commands"
echo "   - Image and text support"
echo "   - Works on X11 and Wayland"
echo "   - Auto-start option"
echo

# === 1. Check if CopyQ is already installed ===
command -q copyq; and set -l copyq_installed "installed"
if test -n "$copyq_installed"
    echo "✅ CopyQ is already installed."
    copyq --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping CopyQ installation."
        exit 0
    end
    echo "📦 Removing existing CopyQ installation..."
    sudo pacman -R --noconfirm copyq
    if test $status -ne 0
        echo "❌ Failed to remove CopyQ."
        exit 1
    end
    echo "✅ CopyQ removed."
end

# === 2. Install CopyQ ===
echo "📦 Installing CopyQ from official repository..."
sudo pacman -S --needed --noconfirm copyq
if test $status -ne 0
    echo "❌ Failed to install CopyQ."
    exit 1
end
echo "✅ CopyQ installed."

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q copyq
    echo "✅ CopyQ installed successfully"
    copyq --version 2>&1 | head -n 1
else
    echo "❌ CopyQ installation verification failed."
    exit 1
end

# === 4. Start CopyQ server ===
echo
echo "🚀 Starting CopyQ server..."
# Check if CopyQ server is already running
copyq eval "true" 2>/dev/null
if test $status -eq 0
    echo "✅ CopyQ server is already running."
else
    # Start CopyQ server in background
    copyq &; disown
    sleep 1
    # Verify server started
    copyq eval "true" 2>/dev/null
    if test $status -eq 0
        echo "✅ CopyQ server started successfully."
    else
        echo "⚠️  CopyQ server may not have started. Try running 'copyq' manually."
    end
end

# === 5. Enable auto-start (optional) ===
echo
read -P "Do you want to enable CopyQ auto-start on login? [Y/n] " autostart
if test -z "$autostart" -o "$autostart" = "y" -o "$autostart" = "Y"
    echo "📝 Setting up auto-start..."
    # Create autostart directory if it doesn't exist
    mkdir -p ~/.config/autostart
    
    # Create desktop entry for autostart
    printf '%s\n' \
        '[Desktop Entry]' \
        'Type=Application' \
        'Name=CopyQ' \
        'Comment=Clipboard manager with history' \
        'Exec=copyq' \
        'Icon=copyq' \
        'Terminal=false' \
        'Categories=Utility;' \
        'X-GNOME-Autostart-enabled=true' > ~/.config/autostart/copyq.desktop
    
    echo "✅ Auto-start enabled. CopyQ will start automatically on login."
    echo "   To disable, remove ~/.config/autostart/copyq.desktop"
else
    echo "⚠️  Auto-start not enabled. You'll need to start CopyQ manually."
    echo "   To enable later, run: copyq"
    echo "   Then: Right-click tray icon → Preferences → General → Start with system"
end

echo
echo "🎉 CopyQ installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Start CopyQ server (if not already running)"
echo "   copyq &"
echo ""
echo "   # Or launch CopyQ GUI (starts server if needed)"
echo "   copyq"
echo ""
echo "   # Or launch from applications menu"
echo "   # Look for 'CopyQ' in your applications"
echo ""
echo "   # Check if server is running"
echo "   copyq eval 'true'"
echo ""
echo "   # Note: CopyQ server must be running for CLI commands to work"
echo ""
echo "💡 Accessing clipboard history:"
echo "   # Click the CopyQ tray icon to view history"
echo "   # Or press the default hotkey (usually Ctrl+Shift+V)"
echo "   # Search through history by typing"
echo "   # Click any item to copy it to clipboard"
echo ""
echo "💡 Supported content types:"
echo "   - Plain text"
echo "   - Rich text (HTML)"
echo "   - Images"
echo "   - URLs"
echo "   - File paths"
echo ""
echo "💡 Key features:"
echo "   # Clipboard history"
echo "   - Automatically saves everything you copy"
echo "   - Searchable history"
echo "   - Configurable history size"
echo "   - Persistent storage across reboots"
echo ""
echo "   # Actions and commands"
echo "   - Custom actions for clipboard items"
echo "   - Scriptable with JavaScript"
echo "   - Command-line interface"
echo "   - Automation support"
echo ""
echo "   # Organization"
echo "   - Tabs for organizing clipboard items"
echo "   - Tags and notes"
echo "   - Filtering and sorting"
echo "   - Export/import clipboard data"
echo ""
echo "💡 Command-line usage:"
echo "   # IMPORTANT: CopyQ server must be running first!"
echo "   # Start server: copyq &"
echo ""
echo "   # Show clipboard history"
echo "   copyq show"
echo ""
echo "   # Show specific item (0 = most recent)"
echo "   copyq show 0"
echo ""
echo "   # Copy text to clipboard"
echo "   copyq add 'text to copy'"
echo ""
echo "   # Get clipboard content"
echo "   copyq clipboard"
echo ""
echo "   # Clear history"
echo "   copyq clear"
echo ""
echo "   # List all items"
echo "   copyq read 0 1 2"
echo ""
echo "💡 Fish shell integration:"
echo "   # Add to your config.fish for quick access:"
echo "   function clip --description 'Show clipboard history'"
echo "       # Ensure CopyQ server is running"
echo "       copyq eval 'true' 2>/dev/null; or copyq &; disown"
echo "       copyq show"
echo "   end"
echo ""
echo "   # Or create an alias (server must be running):"
echo "   alias clip='copyq show'"
echo ""
echo "💡 Tips:"
echo "   - Enable auto-start so CopyQ runs on login"
echo "   - Configure hotkeys in Preferences → Shortcuts"
echo "   - Use tabs to organize different types of content"
echo "   - Set maximum history size to manage memory"
echo "   - Use search to quickly find old clipboard items"
echo "   - Create custom actions for frequently used operations"
echo "   - Export important clipboard items for backup"
echo ""
echo "💡 Configuration:"
echo "   # Config file location:"
echo "   ~/.config/copyq/"
echo ""
echo "   # Edit settings:"
echo "   # Right-click tray icon → Preferences"
echo "   # Or edit: ~/.config/copyq/copyq.conf"
echo ""
echo "💡 Alternative clipboard tools:"
echo "   # For Wayland users:"
echo "   - cliphist (simple clipboard history for Wayland)"
echo "   - wl-clipboard (Wayland clipboard utilities)"
echo ""
echo "   # For X11 users:"
echo "   - clipmenu (clipboard manager with dmenu/rofi)"
echo "   - parcellite (lightweight clipboard manager)"
echo "   - gpaste (GNOME clipboard manager)"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://hluk.github.io/CopyQ/"
echo "   - GitHub: https://github.com/hluk/CopyQ"
echo "   - Documentation: https://github.com/hluk/CopyQ/wiki"
echo "   - Arch Wiki: https://wiki.archlinux.org/title/CopyQ"

