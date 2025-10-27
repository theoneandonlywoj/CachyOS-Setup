#!/usr/bin/env fish
# === mcp_servers.fish ===
# Purpose: Install and configure MCP servers for Cursor AI
# Author: theoneandonlywoj

echo "🚀 Starting MCP servers installation/configuration..."

# === 1. Check/Install and activate mise ===
echo "🔧 Checking for mise..."
if not command -v mise > /dev/null
    echo "⚠️ Mise not found. Please install it first by running: ./mise.fish"
    echo "   Or visit: https://mise.run"
    exit 1
else
    echo "✅ Mise found: $(mise --version)"
end

# Activate mise in current shell
echo "⚙ Activating mise in current shell..."
mise activate fish | source

# === 2. Check/Install Node.js and npm with mise ===
echo "📦 Checking for Node.js and npm..."
if not mise exec -- node --version > /dev/null 2>&1
    echo "⚠️ Node.js not found. Installing Node.js (LTS) with mise..."
    mise install node@lts
    mise use -g node@lts
    if test $status -ne 0
        echo "❌ Failed to install Node.js. Aborting."
        exit 1
    end
    echo "✅ Node.js installed: $(mise exec -- node --version)"
else
    echo "✅ Node.js already installed: $(mise exec -- node --version)"
end

# Verify npm is available through mise
echo "🔍 Verifying npm..."
if not mise exec -- npm --version > /dev/null 2>&1
    echo "❌ npm not found. This shouldn't happen with Node.js installed via mise."
    echo "   Trying to install again..."
    mise reshim
    if not mise exec -- npm --version > /dev/null 2>&1
        echo "❌ npm still not found. Aborting."
        exit 1
    end
end
echo "✅ npm available: $(mise exec -- npm --version)"

# === 3. Test package availability in npm registry ===
# Function to check if a package exists in npm registry
function test_package_exists
    set package_name $argv[1]
    mise exec -- npm view $package_name version > /dev/null 2>&1
    return $status
end

# Define packages to test
set all_packages @modelcontextprotocol/server-filesystem \
                 @modelcontextprotocol/server-github \
                 @modelcontextprotocol/server-postgres \
                 @modelcontextprotocol/server-memory \
                 @modelcontextprotocol/server-sequential-thinking \
                 @sentry/mcp-server \
                 chrome-devtools-mcp

echo "🧪 Testing package availability..."
set available_packages

for pkg in $all_packages
    if test_package_exists $pkg
        echo "✅ $pkg - available"
        set -a available_packages $pkg
    else
        echo "⚠️  $pkg - not found, skipping"
    end
end

if test (count $available_packages) -eq 0
    echo "❌ No MCP server packages available. Aborting."
    exit 1
end

echo "✅ Found "(count $available_packages)" available package(s)"

# === 4. Create Cursor MCP directory ===
echo "📁 Creating Cursor MCP configuration directory..."
set cursor_mcp_dir $HOME/.cursor
mkdir -p $cursor_mcp_dir

set mcp_json_path $cursor_mcp_dir/mcp.json

# Backup existing mcp.json if it exists
if test -f $mcp_json_path
    set timestamp (date "+%Y_%m_%d_%H_%M_%S")
    set backup_file $cursor_mcp_dir/mcp.json.backup_$timestamp
    echo "⚠️ Existing mcp.json found. Backing up to $backup_file..."
    cp $mcp_json_path $backup_file
end

# === 5. Create mcp.json configuration dynamically ===
echo "📄 Creating mcp.json configuration..."
echo '{' > $mcp_json_path
echo '  "mcpServers": {' >> $mcp_json_path

set first_server 1
for pkg in $available_packages
    # Extract server name from package name
    set server_name $pkg
    # Handle @modelcontextprotocol/server-* packages
    if string match -q '@modelcontextprotocol/server-*' $pkg
        set server_name (string replace '@modelcontextprotocol/server-' '' $pkg)
    # Handle @sentry/mcp-server
    else if string match -q '@sentry/mcp-server' $pkg
        set server_name "sentry"
    # Handle chrome-devtools-mcp
    else if string match -q 'chrome-devtools-mcp' $pkg
        set server_name "chrome-devtools"
    # For other @scope/package-name patterns, use the last part after /
    else if string match -q '@*/*' $pkg
        set server_name (string split '/' $pkg | tail -1)
        if string match -q '*mcp-server*' $server_name
            set server_name (string replace 'mcp-server' '' $server_name | string trim --chars='-')
        end
    end
    
    if test $first_server -ne 1
        echo ',' >> $mcp_json_path
    end
    
    echo "    \"$server_name\": {" >> $mcp_json_path
    echo '      "command": "npx",' >> $mcp_json_path
    echo '      "args": [' >> $mcp_json_path
    echo '        "-y",' >> $mcp_json_path
    echo "        \"$pkg\"" >> $mcp_json_path
    
    # Add specific configuration based on server type
    switch $server_name
        case filesystem
            echo ',' >> $mcp_json_path
            echo "        \"$HOME\"" >> $mcp_json_path
        case github
            echo '      ],' >> $mcp_json_path
            echo '      "env": {' >> $mcp_json_path
            echo '        "GITHUB_PERSONAL_ACCESS_TOKEN": ""' >> $mcp_json_path
            echo '      }' >> $mcp_json_path
        case postgres
            echo '      ],' >> $mcp_json_path
            echo '      "env": {' >> $mcp_json_path
            echo '        "POSTGRES_CONNECTION_STRING": "postgresql://localhost:5432/my_db"' >> $mcp_json_path
            echo '      }' >> $mcp_json_path
        case '*'
            # No additional config needed for memory and sequential-thinking
    end
    
    if not contains $server_name github postgres
        echo '      ]' >> $mcp_json_path
    end
    
    echo '    }' >> $mcp_json_path
    
    set first_server 0
end

echo '  }' >> $mcp_json_path
echo '}' >> $mcp_json_path

if test $status -ne 0
    echo "❌ Failed to create mcp.json. Aborting."
    exit 1
end

# === 6. Install MCP servers globally (optional) ===
echo "📦 Installing MCP server packages globally..."
mise exec -- npm install -g $available_packages

if test $status -ne 0
    echo "⚠️ Global installation failed, but you can still use npx (which is already configured in mcp.json)"
else
    echo "✅ MCP servers installed globally"
end

# === 7. Display configuration and instructions ===
echo ""
echo "✅ MCP servers installation/configuration complete!"
echo ""
echo "📄 Configuration location: $mcp_json_path"
echo ""
echo "⚠️ IMPORTANT: You need to configure the following environment variables in $mcp_json_path:"
echo ""
echo "1. GitHub: GITHUB_PERSONAL_ACCESS_TOKEN"
echo "   Get one at: https://github.com/settings/tokens"
echo ""
echo "2. PostgreSQL: Update POSTGRES_CONNECTION_STRING with your database details"
echo ""
echo "3. Sentry: Add SENTRY_DSN or SENTRY_API_KEY in the sentry server config"
echo "   Get one at: https://sentry.io/settings/{org}/auth-tokens/"
echo ""
echo "🔄 After configuring, restart Cursor for changes to take effect."
echo ""
echo "📖 To test MCP servers, open Cursor and check Settings > Features > MCP Servers"
echo ""
echo "ℹ️  Note: For Phoenix-specific MCP servers (Vancouver, MCPhoenix, Anubis MCP)"
echo "   built in Elixir, check Hex.pm packages for deeper Phoenix integration."

