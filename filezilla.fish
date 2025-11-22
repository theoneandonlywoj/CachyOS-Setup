#!/usr/bin/env fish
# === filezilla.fish ===
# Purpose: Install FileZilla (FTP client) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting FileZilla installation..."
echo
echo "💡 FileZilla is a powerful FTP client:"
echo "   - FTP, FTPS, and SFTP support"
echo "   - Graphical user interface"
echo "   - Site manager for saved connections"
echo "   - Drag and drop file transfers"
echo "   - Queue management"
echo "   - Cross-platform support"
echo

# === 1. Check if FileZilla is already installed ===
command -q filezilla; and set -l filezilla_installed "installed"
if test -n "$filezilla_installed"
    echo "✅ FileZilla is already installed."
    filezilla --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping FileZilla installation."
        exit 0
    end
    echo "📦 Removing existing FileZilla installation..."
    sudo pacman -R --noconfirm filezilla
    if test $status -ne 0
        echo "❌ Failed to remove FileZilla."
        exit 1
    end
    echo "✅ FileZilla removed."
end

# === 2. Install FileZilla ===
echo "📦 Installing FileZilla from official repository..."
sudo pacman -S --needed --noconfirm filezilla
if test $status -ne 0
    echo "❌ Failed to install FileZilla."
    exit 1
end
echo "✅ FileZilla installed."

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q filezilla
    echo "✅ FileZilla installed successfully"
    filezilla --version 2>&1 | head -n 1
else
    echo "❌ FileZilla installation verification failed."
    exit 1
end

echo
echo "🎉 FileZilla installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Launch FileZilla"
echo "   filezilla"
echo ""
echo "   # Or launch from applications menu"
echo "   # Look for 'FileZilla' in your applications"
echo ""
echo "💡 Connecting to FTP servers:"
echo "   # Quick Connect (File → Site Manager → New Site)"
echo "   Host: ftp.example.com"
echo "   Port: 21 (FTP) or 22 (SFTP)"
echo "   Protocol: FTP, SFTP, or FTPS"
echo "   Logon Type: Normal, Anonymous, or Ask for password"
echo "   User: your_username"
echo "   Password: your_password"
echo ""
echo "💡 Supported protocols:"
echo "   - FTP (File Transfer Protocol)"
echo "   - FTPS (FTP over SSL/TLS)"
echo "   - SFTP (SSH File Transfer Protocol)"
echo ""
echo "💡 Key features:"
echo "   # Site Manager"
echo "   - Save multiple server connections"
echo "   - Organize sites in folders"
echo "   - Import/export site configurations"
echo ""
echo "   # File transfer"
echo "   - Drag and drop files between local and remote"
echo "   - Queue multiple transfers"
echo "   - Resume interrupted transfers"
echo "   - Synchronized browsing"
echo ""
echo "   # File management"
echo "   - Create directories"
echo "   - Delete files and folders"
echo "   - Rename files"
echo "   - Set file permissions (chmod)"
echo ""
echo "💡 Command-line usage:"
echo "   # Launch FileZilla"
echo "   filezilla"
echo ""
echo "   # Open with specific site"
echo "   filezilla --site-manager"
echo ""
echo "💡 Tips:"
echo "   - Use Site Manager to save frequently used connections"
echo "   - Enable 'Synchronized browsing' for easier navigation"
echo "   - Use queue for multiple file transfers"
echo "   - Set transfer speed limits if needed"
echo "   - Use SFTP for secure file transfers"
echo "   - Configure firewall rules if connections fail"
echo ""
echo "💡 Security:"
echo "   - Prefer SFTP over FTP (more secure)"
echo "   - Use FTPS if SFTP is not available"
echo "   - Avoid plain FTP for sensitive data"
echo "   - Keep FileZilla updated for security patches"
echo ""
echo "💡 Alternative CLI tools:"
echo "   # For command-line FTP operations, consider:"
echo "   - lftp (powerful FTP client)"
echo "   - sftp (SSH file transfer)"
echo "   - rsync (efficient file synchronization)"
echo "   - rclone (cloud storage sync)"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://filezilla-project.org/"
echo "   - Documentation: https://wiki.filezilla-project.org/"
echo "   - Download: https://filezilla-project.org/download.php?type=client"

