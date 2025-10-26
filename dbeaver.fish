#!/usr/bin/env fish
# === dbeaver.fish ===
# Purpose: Install DBeaver database tool on CachyOS
# Installs DBeaver from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting DBeaver installation..."

# === 1. Check if DBeaver is already installed ===
command -q dbeaver; and set -l dbeaver_installed "installed"
if test -n "$dbeaver_installed"
    echo "✅ DBeaver is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping DBeaver installation."
        exit 0
    end
    echo "📦 Removing existing DBeaver installation..."
    sudo pacman -R --noconfirm dbeaver
    if test $status -ne 0
        echo "❌ Failed to remove DBeaver."
        exit 1
    end
    echo "✅ DBeaver removed."
end

# === 2. Install DBeaver ===
echo "📦 Installing DBeaver..."
sudo pacman -S --needed --noconfirm dbeaver
if test $status -ne 0
    echo "❌ Failed to install DBeaver."
    exit 1
end
echo "✅ DBeaver installed."

# === 3. Check and fix snapper Boost library issue (if present) ===
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
                echo "⚠ Failed to fix snapper, but DBeaver is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q dbeaver
if test $status -eq 0
    echo "✅ DBeaver installed successfully"
    dbeaver --version 2>&1 | head -n 1
else
    echo "❌ DBeaver installation verification failed."
end

echo
echo "✅ DBeaver installation complete!"
echo "💡 DBeaver is a universal SQL client for:"
echo "   - MySQL, PostgreSQL, Oracle, SQL Server"
echo "   - MongoDB, Redis, Cassandra"
echo "   - SQLite, H2, Derby"
echo "   - And many more database systems"
echo "💡 You can now launch DBeaver from:"
echo "   - Applications menu (Development category)"
echo "   - Command line: dbeaver"
echo "💡 DBeaver features:"
echo "   - Database administration and development"
echo "   - SQL query editor with syntax highlighting"
echo "   - ER diagrams and data export/import"
echo "   - Query results visualization"
echo "   - SSH tunneling for remote databases"
echo "💡 Getting started:"
echo "   - Create a new database connection"
echo "   - Choose your database type"
echo "   - Enter connection details"
echo "   - Test and save the connection"
echo "💡 Tips:"
echo "   - Connect to remote databases using SSH tunnel for security"
echo "   - Export query results to CSV, Excel, or SQL"
echo "   - Use ER diagrams to visualize database structure"
echo "   - Schedule SQL scripts to run automatically"

