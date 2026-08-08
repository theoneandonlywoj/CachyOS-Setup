#!/usr/bin/env fish
# === playwright_cli.fish ===
# Purpose: Install the Playwright CLI for coding agents via npm and Mise on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set NODEJS_VERSION lts
set PLAYWRIGHT_CLI_PACKAGE @playwright/cli
set PLAYWRIGHT_CLI_VERSION latest

echo "🚀 Starting Playwright CLI setup via Mise..."
echo "📌 Target versions:"
echo "   Node.js        → $NODEJS_VERSION"
echo "   Playwright CLI → $PLAYWRIGHT_CLI_PACKAGE@$PLAYWRIGHT_CLI_VERSION"
echo

# === 1. Check Mise installation ===
if not command -v mise > /dev/null
    echo "❌ Mise is not installed. Please install it first using:"
    echo "   ./mise.fish"
    echo "Then re-run this script."
    exit 1
end

# === 2. Load Mise environment in current shell for script execution ===
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source

# === 3. Install Node.js via Mise if needed ===
echo "📦 Checking for Node.js and npm..."
if not mise exec -- node --version > /dev/null 2>&1
    echo "🔧 Installing Node.js $NODEJS_VERSION via Mise..."
    mise install node@$NODEJS_VERSION
    if test $status -ne 0
        echo "❌ Node.js installation failed. Aborting."
        exit 1
    end

    mise use -g node@$NODEJS_VERSION
    if test $status -ne 0
        echo "❌ Failed to set Node.js as the global Mise version. Aborting."
        exit 1
    end
end

set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source
mise reshim

if not mise exec -- npm --version > /dev/null 2>&1
    echo "❌ npm is not available through Node.js. Aborting."
    exit 1
end

echo "✅ Node.js: "(mise exec -- node --version)
echo "✅ npm: "(mise exec -- npm --version)

# === 4. Install Playwright CLI globally ===
echo "🔧 Installing Playwright CLI via npm..."
mise exec -- npm install -g "$PLAYWRIGHT_CLI_PACKAGE@$PLAYWRIGHT_CLI_VERSION"
if test $status -ne 0
    echo "❌ Playwright CLI installation failed. Aborting."
    exit 1
end

# Refresh Mise shims so the globally installed executable is available immediately.
mise reshim

# === 5. Add automatic Mise activation to Fish config if not already present ===
set fish_config_file ~/.config/fish/config.fish
set activation_line "mise activate fish | source"

mkdir -p (dirname $fish_config_file)
if not grep -Fxq "$activation_line" $fish_config_file 2>/dev/null
    echo "$activation_line" >> $fish_config_file
    echo "🔧 Added automatic Mise activation to $fish_config_file"
end

# === 6. Verify installation ===
echo "🧪 Verifying Playwright CLI installation..."
if mise exec -- playwright-cli --help > /dev/null 2>&1
    set playwright_cli_path (command -v playwright-cli)
    if test -z "$playwright_cli_path"
        set playwright_cli_path "available through Mise"
    end
    echo "✅ Playwright CLI installed successfully: $playwright_cli_path"
else
    echo "❌ Playwright CLI verification failed."
    exit 1
end

echo
echo "🎉 Playwright CLI setup complete via Mise!"
echo
echo "💡 Important:"
echo "   To use 'playwright-cli' in this terminal immediately,"
echo "   run the following command in your current shell:"
echo "       mise activate fish | source"
echo "   In future terminals, this will happen automatically thanks to the config file update."
echo
echo "💡 Quick start:"
echo "   playwright-cli open https://example.com"
echo "   playwright-cli snapshot"
echo "   playwright-cli screenshot"
echo
echo "💡 Optional agent skills:"
echo "   playwright-cli install --skills"
