#!/usr/bin/env fish
# === rclone.fish ===
# Purpose: Install rclone (cloud storage sync tool) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting rclone installation..."
echo
echo "💡 rclone is a command-line program to sync files and directories:"
echo "   - Support for 70+ cloud storage providers"
echo "   - Sync, copy, move, and manage files"
echo "   - Mount cloud storage as local filesystem"
echo "   - Encrypted backups and transfers"
echo "   - Bandwidth limiting and scheduling"
echo

# === 1. Check if rclone is already installed ===
command -q rclone; and set -l rclone_installed "installed"
if test -n "$rclone_installed"
    echo "✅ rclone is already installed."
    rclone version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping rclone installation."
        exit 0
    end
    echo "📦 Removing existing rclone installation..."
    # Try to remove via pacman
    if pacman -Qq rclone > /dev/null 2>&1
        sudo pacman -R --noconfirm rclone
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/rclone
        sudo rm -f /usr/local/bin/rclone
    end
    if test -f ~/.local/bin/rclone
        rm -f ~/.local/bin/rclone
    end
    echo "✅ rclone removed."
end

# === 2. Install rclone ===
echo "📦 Installing rclone from official repository..."
sudo pacman -S --needed --noconfirm rclone
if test $status -ne 0
    echo "❌ Failed to install rclone."
    exit 1
end
echo "✅ rclone installed."

# === 3. Install Fish shell completions ===
echo "📦 Installing Fish shell completions..."
if command -q rclone
    sudo rclone completion fish > /etc/fish/completions/rclone.fish 2>/dev/null
    if test $status -eq 0
        echo "✅ Fish completions installed."
    else
        echo "⚠ Warning: Failed to install Fish completions."
        echo "   rclone is still fully functional."
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q rclone
    echo "✅ rclone installed successfully"
    rclone version 2>&1 | head -n 1
else
    echo "❌ rclone installation verification failed."
    exit 1
end

echo
echo "🎉 rclone installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Configure a remote (interactive)"
echo "   rclone config"
echo ""
echo "   # List remotes"
echo "   rclone listremotes"
echo ""
echo "   # List files in remote"
echo "   rclone ls remote:path"
echo ""
echo "   # Copy files"
echo "   rclone copy source/ remote:destination/"
echo ""
echo "   # Sync directories"
echo "   rclone sync source/ remote:destination/"
echo ""
echo "   # Move files"
echo "   rclone move source/ remote:destination/"
echo ""
echo "💡 Supported providers:"
echo "   - Google Drive, Dropbox, OneDrive"
echo "   - Amazon S3, Backblaze B2"
echo "   - Azure Blob Storage, DigitalOcean Spaces"
echo "   - FTP, SFTP, WebDAV"
echo "   - And 60+ more providers"
echo ""
echo "💡 Common commands:"
echo "   # Copy file"
echo "   rclone copy file.txt remote:path/"
echo ""
echo "   # Sync directories (one-way)"
echo "   rclone sync local/ remote:path/"
echo ""
echo "   # Copy with progress"
echo "   rclone copy -P source/ remote:dest/"
echo ""
echo "   # List files"
echo "   rclone ls remote:path"
echo "   rclone lsd remote:path          # List directories"
echo "   rclone lsf remote:path          # List files and dirs"
echo ""
echo "   # Delete files"
echo "   rclone delete remote:path/file"
echo "   rclone purge remote:path/       # Delete directory"
echo ""
echo "   # Check files"
echo "   rclone check source/ remote:path/"
echo ""
echo "   # Show disk usage"
echo "   rclone size remote:path/"
echo ""
echo "💡 Mounting (FUSE):"
echo "   # Mount remote as local directory"
echo "   rclone mount remote:path/ /mnt/rclone/"
echo ""
echo "   # Mount with cache"
echo "   rclone mount remote:path/ /mnt/rclone/ --vfs-cache-mode writes"
echo ""
echo "   # Unmount"
echo "   fusermount -u /mnt/rclone/"
echo ""
echo "💡 Advanced options:"
echo "   # Dry run (test without making changes)"
echo "   rclone copy --dry-run source/ remote:dest/"
echo ""
echo "   # Bandwidth limiting"
echo "   rclone copy --bwlimit 1M source/ remote:dest/"
echo ""
echo "   # Exclude files"
echo "   rclone copy --exclude '*.tmp' source/ remote:dest/"
echo ""
echo "   # Include only specific files"
echo "   rclone copy --include '*.jpg' source/ remote:dest/"
echo ""
echo "   # Verbose output"
echo "   rclone copy -v source/ remote:dest/"
echo ""
echo "   # Progress and stats"
echo "   rclone copy -P --stats 5s source/ remote:dest/"
echo ""
echo "💡 Configuration:"
echo "   # Config file location: ~/.config/rclone/rclone.conf"
echo "   # Edit config manually"
echo "   rclone config edit"
echo ""
echo "   # Show config"
echo "   rclone config show"
echo ""
echo "   # Delete remote"
echo "   rclone config delete remote_name"
echo ""
echo "💡 Encryption:"
echo "   # Create encrypted remote"
echo "   rclone config"
echo "   # Select 'crypt' as remote type"
echo "   # Point to another remote for storage"
echo ""
echo "💡 Useful flags:"
echo "   -P, --progress              Show progress"
echo "   -v, --verbose               Verbose output"
echo "   --dry-run                   Test run without changes"
echo "   --bwlimit RATE              Limit bandwidth"
echo "   --exclude PATTERN           Exclude files"
echo "   --include PATTERN           Include only files"
echo "   --stats DURATION            Show stats every DURATION"
echo "   --transfers N               Number of parallel transfers"
echo "   --checkers N                Number of parallel checkers"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://rclone.org/"
echo "   - Documentation: https://rclone.org/docs/"
echo "   - Configuration: https://rclone.org/docs/#configuration"
echo "   - Providers: https://rclone.org/overview/"
echo "   - Forum: https://forum.rclone.org/"

