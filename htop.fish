#!/usr/bin/env fish
# === htop.fish ===
# Purpose: Install htop interactive process viewer on CachyOS
# Installs htop from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting htop installation..."

# === 1. Check if htop is already installed ===
command -q htop; and set -l htop_installed "installed"
if test -n "$htop_installed"
    echo "✅ htop is already installed."
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping htop installation."
        exit 0
    end
    echo "📦 Removing existing htop installation..."
    sudo pacman -R --noconfirm htop
    if test $status -ne 0
        echo "❌ Failed to remove htop."
        exit 1
    end
    echo "✅ htop removed."
end

# === 2. Install htop ===
echo "📦 Installing htop..."
sudo pacman -S --needed --noconfirm htop
if test $status -ne 0
    echo "❌ Failed to install htop."
    exit 1
end
echo "✅ htop installed."

# === 3. Install optional system monitoring tools ===
echo "📦 Installing optional system monitoring tools..."
echo "💡 The following tools provide additional system monitoring capabilities:"
echo "   - bashtop: Advanced Bash resource monitor"
echo "   - net-tools: Network utilities (ifconfig, netstat, etc.)"
read -P "Do you want to install additional monitoring tools? [y/N] " install_tools

if test "$install_tools" = "y" -o "$install_tools" = "Y"
    echo "📦 Installing additional monitoring tools..."
    sudo pacman -S --needed --noconfirm bashtop net-tools
    if test $status -ne 0
        echo "⚠ Failed to install some tools, but htop is still installed."
    else
        echo "✅ Additional monitoring tools installed."
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
                echo "⚠ Failed to fix snapper, but htop is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q htop
if test $status -eq 0
    echo "✅ htop installed successfully"
    htop --version 2>&1 | head -n 1
else
    echo "❌ htop installation verification failed."
end

echo
echo "✅ htop installation complete!"
echo "💡 You can now launch htop from:"
echo "   - Command line: htop"
echo "💡 htop is an interactive process viewer with:"
echo "   - Visual representation of CPU and memory usage"
echo "   - Interactive process management"
echo "   - Sort by CPU, memory, or process name"
echo "   - Kill or renice processes"
echo "   - Search and filter processes"
echo "💡 Basic htop keyboard shortcuts:"
echo "   - F1 (h): Help menu"
echo "   - F2 (S): Setup and preferences"
echo "   - F3 (\/): Search processes"
echo "   - F4 (\): Filter processes"
echo "   - F5 (t): Tree view"
echo "   - F6 (<): Sort menu"
echo "   - F7 (-): Decrease priority"
echo "   - F8 (+): Increase priority"
echo "   - F9 (k): Kill process"
echo "   - F10 (q): Quit"
echo "   - Arrow keys: Navigate"
echo "   - Space: Tag/untag process"
echo "   - Tab: Switch between sections"
echo "💡 Usage examples:"
echo "   - Monitor CPU usage: htop"
echo "   - View specific user processes: htop -u username"

