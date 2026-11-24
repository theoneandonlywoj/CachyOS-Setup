#!/usr/bin/env fish
# === playwright_cli.fish ===
# Purpose: Install the Playwright CLI for coding agents via npm and Mise on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set PLAYWRIGHT_CLI_PACKAGE @playwright/cli
set PLAYWRIGHT_CLI_VERSION latest

echo "🚀 Starting Playwright CLI setup via Mise..."
echo "📌 Target versions:"
echo "   Playwright CLI → $PLAYWRIGHT_CLI_PACKAGE@$PLAYWRIGHT_CLI_VERSION"
echo

# === 1. Check Mise installation ===
# The repository's .tool-versions must not pick the Node: use the global one.
cd "$HOME"; or exit 1

if not command -v mise > /dev/null
    echo "❌ Mise is not installed. Please install it first using:"
    echo "   ./mise.fish"
    echo "Then re-run this script."
    exit 1
end

# === 2. Load Mise environment in current shell for script execution ===
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source

# === 3. Require Node.js via Mise ===
if not mise which node >/dev/null 2>&1
    echo "❌ Node.js via Mise not found. Run ./nodejs.fish first."
    exit 1
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
    echo "❌ Playwright CLI installation failed. Rerun: ./playwright_cli.fish"
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

# === 7. Optional Chromium download ===
if test -t 0
    read -l -P "Download Chromium for Playwright? [y/N] " install_chromium
    if test "$install_chromium" = "y" -o "$install_chromium" = "Y"
        mise exec -- npx playwright install chromium
        if test $status -ne 0
            echo "❌ Chromium download failed. Rerun: ./playwright_cli.fish"
            exit 1
        end
    end
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
echo
echo "📚 Playwright Test guide: docs/guide_playwright_tests.md"
