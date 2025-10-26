#!/usr/bin/env fish
# === wrk.fish ===
# Purpose: Install wrk HTTP benchmarking tool on CachyOS
# Installs wrk from AUR or builds from source
# Author: theoneandonlywoj

echo "🚀 Starting wrk installation..."

echo "📌 wrk is an HTTP benchmarking tool for load testing"
echo "💡 Features:"
echo "   - High-performance HTTP benchmarking"
echo "   - Load testing and stress testing"
echo "   - Scriptable with Lua scripting"
echo "   - Multi-threaded for high concurrency"

# === 1. Check if wrk is already installed ===
command -q wrk; and set -l wrk_installed "installed"
if test -n "$wrk_installed"
    echo "✅ wrk is already installed."
    wrk --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping wrk installation."
        exit 0
    end
end

# === 2. Check for build dependencies ===
echo "📦 Checking for build dependencies..."
command -q make; and set -l make_installed "installed"
command -q gcc; and set -l gcc_installed "installed"

if test -z "$make_installed" -o -z "$gcc_installed"
    echo "⚠ Build tools not installed."
    read -P "Do you want to install base-devel? [Y/n] " install_buildtools
    
    if test "$install_buildtools" != "n" -a "$install_buildtools" != "N"
        echo "📦 Installing base-devel..."
        sudo pacman -S --needed --noconfirm base-devel
        if test $status -ne 0
            echo "❌ Failed to install build tools."
            exit 1
        end
        echo "✅ Build tools installed."
    else
        echo "❌ Build tools are required."
        exit 1
    end
else
    echo "✅ Build tools installed."
end

# === 3. Try AUR first, then build from source ===
echo "📦 Attempting to install wrk from AUR..."

# Check for AUR helper
command -q yay; and set -l yay_installed "installed"
command -q paru; and set -l paru_installed "installed"

if test -n "$yay_installed" -o -n "$paru_installed"
    echo "✅ AUR helper found."
    set aur_helper "yay"
    if test -n "$paru_installed"
        set aur_helper "paru"
    end
    
    echo "📦 Installing wrk from AUR using $aur_helper..."
    $aur_helper -S --noconfirm wrk-git
    if test $status -eq 0
        echo "✅ wrk installed from AUR."
    else
        echo "⚠ AUR installation failed, building from source..."
    end
end

# Build from source if not installed via AUR
command -q wrk; and set -l wrk_installed_check "installed"
if test -z "$wrk_installed_check"
    echo "📦 Building wrk from source..."
    cd /tmp
    git clone https://github.com/wg/wrk.git
    if test $status -ne 0
        echo "❌ Failed to clone wrk repository."
        exit 1
    end
    
    cd wrk
    make -j$(nproc)
    if test $status -ne 0
        echo "❌ Failed to build wrk."
        exit 1
    end
    
    echo "📦 Installing wrk..."
    sudo cp wrk /usr/local/bin/
    if test $status -ne 0
        echo "❌ Failed to install wrk."
        exit 1
    end
    echo "✅ wrk installed."
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
                echo "⚠ Failed to fix snapper, but wrk is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q wrk
if test $status -eq 0
    echo "✅ wrk installed successfully"
    wrk --version 2>&1 | head -n 1
else
    echo "❌ wrk installation verification failed."
end

echo
echo "✅ wrk installation complete!"
echo "💡 wrk is a modern HTTP benchmarking tool:"
echo "   - Load testing web servers"
echo "   - Performance benchmarking"
echo "   - Stress testing"
echo "   - Lua scripting support"
echo "💡 Basic usage:"
echo "   - Load test: wrk -t4 -c100 -d30s http://example.com"
echo "   - Custom script: wrk -t2 -c10 -d30s -s script.lua http://example.com"
echo "   - With headers: wrk -H \"User-Agent: MyApp\" http://example.com"
echo "   - File upload: wrk -d30s http://example.com --file data.json"
echo "💡 Parameters:"
echo "   - -t: Number of threads (typically CPU count)"
echo "   - -c: Number of connections"
echo "   - -d: Duration (e.g., 30s, 2m)"
echo "   - -s: Lua script file"
echo "   - --timeout: Request timeout"
echo "💡 Example commands:"
echo "   # Simple load test with 4 threads, 100 connections, 30 seconds"
echo "   wrk -t4 -c100 -d30s http://localhost"
echo ""
echo "   # Test with custom headers"
echo "   wrk -t4 -c50 -d30s http://api.example.com/v1/users \\"
echo "      -H \"Authorization: Bearer token\""
echo ""
echo "   # Test with Lua script"
echo "   wrk -t4 -c100 -d30s http://example.com -s test.lua"
echo "💡 Lua scripting examples:"
echo "   -- Custom request method:"
echo "   wrk.method = \"POST\""
echo "   wrk.body = \"{\\\"key\\\": \\\"value\\\"}\""
echo "   wrk.headers[\"Content-Type\"] = \"application/json\""
echo "💡 Interpreting results:"
echo "   - Requests/sec: Throughput metric"
echo "   - Latency: Response time statistics"
echo "   - Transfer/sec: Network throughput"
echo "💡 Tips:"
echo "   - Start with low concurrency and increase gradually"
echo "   - Monitor server resources during testing"
echo "   - Use appropriate number of threads for your CPU"
echo "   - Test realistic scenarios with Lua scripts"
echo "💡 For more information:"
echo "   - GitHub: https://github.com/wg/wrk"
echo "   - Documentation: https://github.com/wg/wrk/wiki"

