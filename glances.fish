#!/usr/bin/env fish
# === glances.fish ===
# Purpose: Install glances system monitoring tool on CachyOS
# Installs glances from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting glances installation..."

# === 1. Check if glances is already installed ===
command -q glances; and set -l glances_installed "installed"
if test -n "$glances_installed"
    echo "✅ glances is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping glances installation."
        exit 0
    end
    echo "📦 Removing existing glances installation..."
    sudo pacman -R --noconfirm glances
    if test $status -ne 0
        echo "❌ Failed to remove glances."
        exit 1
    end
    echo "✅ glances removed."
end

# === 2. Install glances ===
echo "📦 Installing glances..."
sudo pacman -S --needed --noconfirm glances
if test $status -ne 0
    echo "❌ Failed to install glances."
    exit 1
end
echo "✅ glances installed."

# === 3. Install optional glances plugins ===
echo "📦 Installing optional glances plugins..."
echo "💡 The following packages enhance glances capabilities:"
echo "   - python-pip: Python package manager for additional plugins"
read -P "Do you want to install Python packages for additional plugins? [y/N] " install_python

if test "$install_python" = "y" -o "$install_python" = "Y"
    echo "📦 Installing python-pip..."
    sudo pacman -S --needed --noconfirm python-pip
    if test $status -ne 0
        echo "⚠ Failed to install python-pip, but glances is still installed."
    else
        echo "✅ python-pip installed."
        echo "💡 You can now install glances plugins with: pip install glances[ACTION]"
        echo "   Example: pip install glances[bam,cloud,cpuinfo,docker,export,folders,gpu,ip,raid,snmp,web,wifi]"
    end
end

# === 4. Check and fix snapper Boost library issue (if present) ===
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
                echo "⚠ Failed to fix snapper, but glances is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q glances
if test $status -eq 0
    echo "✅ glances installed successfully"
    glances --version 2>&1 | head -n 1
else
    echo "❌ glances installation verification failed."
end

echo
echo "✅ glances installation complete!"
echo "💡 You can now launch glances from:"
echo "   - Command line: glances"
echo "💡 glances is a cross-platform system monitoring tool with:"
echo "   - Real-time monitoring of CPU, memory, disk, and network"
echo "   - Process list with resource usage"
echo "   - System uptime and load average"
echo "   - Network interface statistics"
echo "   - File system usage"
echo "💡 Basic glances keyboard shortcuts:"
echo "   - q or ESC: Quit"
echo "   - c: CPU info"
echo "   - m: Memory info"
echo "   - i: I/O info"
echo "   - n: Network info"
echo "   - f: File system info"
echo "   - p: Process list"
echo "   - s: Sensors"
echo "   - h: Help"
echo "💡 Usage examples:"
echo "   - Basic monitoring: glances"
echo "   - Web interface: glances -w (access at http://localhost:61208)"
echo "   - Share monitoring: glances --enable-plugin-influxdb"
echo "   - Watch specific processes: glances --processes"
echo "💡 Advanced features:"
echo "   - Web server mode: glances -w"
echo "   - Export to CSV/JSON: glances --export csv"
echo "   - Add color thresholds for alerts"
echo "   - Docker container monitoring"

