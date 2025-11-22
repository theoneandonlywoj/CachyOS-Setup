#!/usr/bin/env fish
# === redis_cli.fish ===
# Purpose: Install Redis CLI via Mise on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set REDIS_VERSION "latest"  # Use "latest" or specific version like "7.2.0"

echo "🚀 Starting Redis CLI setup via Mise..."
echo "📌 Target version: $REDIS_VERSION"
echo
echo "💡 Redis CLI is a command-line interface for Redis:"
echo "   - Connect to Redis servers"
echo "   - Execute Redis commands"
echo "   - Monitor Redis operations"
echo "   - Test and debug Redis applications"
echo

# === 1. Check Mise installation ===
if not command -v mise > /dev/null
    echo "❌ Mise is not installed. Please install it first using:"
    echo "   curl https://mise.run | sh"
    echo "   Or run: ./mise.fish"
    echo "Then re-run this script."
    exit 1
end

# === 2. Load Mise environment in current shell for script execution ===
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source

# === 3. Install Redis CLI via Mise ===
echo "🔧 Installing Redis CLI $REDIS_VERSION via Mise..."
if test "$REDIS_VERSION" = "latest"
    mise install redis@latest
    if test $status -eq 0
        mise use -g redis@latest
    end
else
    mise install redis@$REDIS_VERSION
    if test $status -eq 0
        mise use -g redis@$REDIS_VERSION
    end
end

if test $status -ne 0
    echo "❌ Redis CLI installation via Mise failed. Aborting."
    exit 1
end

echo "✅ Redis CLI installed via Mise."

# Reload PATH again to be safe
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source
mise reshim

# === 4. Add automatic activation to Fish config if not already present ===
set fish_config_file ~/.config/fish/config.fish
set activation_line "mise activate fish | source"

if not grep -Fxq "$activation_line" $fish_config_file
    echo "$activation_line" >> $fish_config_file
    echo "🔧 Added automatic Mise activation to $fish_config_file"
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
set redis_cli_verified false

# Ensure mise shims are in PATH for verification
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source

if command -q redis-cli
    set redis_cli_verified true
    echo "✅ Redis CLI installed successfully"
    redis-cli --version 2>&1 | head -n 1
else
    echo "❌ Redis CLI verification failed."
    echo "💡 If installed via Mise, try running: mise activate fish | source"
    exit 1
end

echo
echo "🎉 Redis CLI setup complete!"
echo
echo "💡 Important:"
echo "   To use 'redis-cli' in this terminal immediately,"
echo "   run the following command in your current shell:"
echo "       mise activate fish | source"
echo "   In future terminals, this will happen automatically thanks to the config file update."
echo
echo "📚 Installed version: $REDIS_VERSION (via Mise)"
echo
echo "💡 Basic usage:"
echo "   # Connect to local Redis server (default: localhost:6379)"
echo "   redis-cli"
echo ""
echo "   # Connect to remote Redis server"
echo "   redis-cli -h hostname -p port"
echo ""
echo "   # Connect with authentication"
echo "   redis-cli -a password"
echo ""
echo "   # Execute a single command"
echo "   redis-cli PING"
echo "   redis-cli GET key"
echo "   redis-cli SET key value"
echo ""
echo "   # Execute multiple commands"
echo "   redis-cli PING GET key SET key value"
echo ""
echo "💡 Common commands:"
echo "   # Server info"
echo "   redis-cli INFO"
echo "   redis-cli INFO server"
echo "   redis-cli INFO memory"
echo ""
echo "   # Key operations"
echo "   redis-cli KEYS '*'              # List all keys"
echo "   redis-cli GET key                # Get value"
echo "   redis-cli SET key value          # Set value"
echo "   redis-cli DEL key                # Delete key"
echo "   redis-cli EXISTS key             # Check if key exists"
echo "   redis-cli TTL key                # Get time to live"
echo ""
echo "   # Database operations"
echo "   redis-cli DBSIZE                 # Get number of keys"
echo "   redis-cli FLUSHDB                # Clear current database"
echo "   redis-cli FLUSHALL               # Clear all databases"
echo ""
echo "   # Monitoring"
echo "   redis-cli MONITOR                # Monitor commands in real-time"
echo "   redis-cli --latency              # Check latency"
echo "   redis-cli --latency-history      # Latency over time"
echo ""
echo "💡 Interactive mode:"
echo "   # Start interactive session"
echo "   redis-cli"
echo "   # Then type commands:"
echo "   127.0.0.1:6379> PING"
echo "   127.0.0.1:6379> SET mykey \"Hello\""
echo "   127.0.0.1:6379> GET mykey"
echo "   127.0.0.1:6379> EXIT"
echo ""
echo "💡 Advanced usage:"
echo "   # Pipe commands"
echo "   echo 'PING' | redis-cli"
echo "   cat commands.txt | redis-cli"
echo ""
echo "   # Execute Lua script"
echo "   redis-cli EVAL \"return redis.call('get', KEYS[1])\" 1 mykey"
echo ""
echo "   # Monitor mode"
echo "   redis-cli --monitor"
echo ""
echo "   # Scan keys (safer than KEYS)"
echo "   redis-cli --scan"
echo "   redis-cli --scan --pattern 'user:*'"
echo ""
echo "💡 Configuration:"
echo "   # Use different database (0-15)"
echo "   redis-cli -n 1"
echo ""
echo "   # Use raw protocol"
echo "   redis-cli --raw"
echo ""
echo "   # Use CSV output"
echo "   redis-cli --csv"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://redis.io/"
echo "   - Documentation: https://redis.io/docs/"
echo "   - Command reference: https://redis.io/commands/"
echo "   - Redis CLI guide: https://redis.io/docs/manual/cli/"

