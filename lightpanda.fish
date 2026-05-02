#!/usr/bin/env fish
# === lightpanda.fish ===
# Purpose: Full LightPanda headless browser setup on CachyOS (Arch Linux)
# Includes: install, checksum verification, optional systemd service
# Author: theoneandonlywoj

echo "🌐 Starting LightPanda headless browser setup..."

# === 1. Install required dependencies ===
echo "📦 Installing required dependencies (curl, jq)..."
sudo pacman -S --noconfirm curl jq
if test $status -ne 0
    echo "❌ Failed to install curl and jq. Aborting."
    exit 1
end

# === 2. Detect architecture ===
set arch (uname -m)
switch $arch
    case x86_64
        set download_url "https://github.com/lightpanda-io/browser/releases/download/nightly/lightpanda-x86_64-linux"
    case aarch64 arm64
        set download_url "https://github.com/lightpanda-io/browser/releases/download/nightly/lightpanda-aarch64-linux"
    case '*'
        echo "❌ Unsupported architecture: $arch. Aborting."
        exit 1
end
echo "🖥 Detected architecture: $arch"

# === 3. Backup existing binary if present ===
set install_dir "$HOME/.local/bin"
set binary_path "$install_dir/lightpanda"

if test -f $binary_path
    set timestamp (date "+%Y_%m_%d_%H_%M_%S")
    set backup_path "$install_dir/lightpanda.backup_$timestamp"
    echo "⚠ Existing lightpanda binary found. Backing up to $backup_path..."
    mv $binary_path $backup_path
    if test $status -ne 0
        echo "❌ Failed to backup existing binary. Aborting."
        exit 1
    end
end

# === 4. Create install directory ===
mkdir -p $install_dir

# === 5. Fetch expected SHA256 digest ===
echo "🔐 Fetching expected checksum from GitHub API..."
set expected_digest (curl --fail -sL "https://api.github.com/repos/lightpanda-io/browser/releases/tags/nightly" \
    | jq -r '.assets[] | select(.name == "'(basename $download_url)'") | .digest')

if test -z "$expected_digest" -o "$expected_digest" = "null"
    echo "❌ Could not retrieve checksum from GitHub API. Aborting."
    exit 1
end

set expected_sha256 (string replace "sha256:" "" $expected_digest)
echo "✅ Expected SHA256: $expected_sha256"

# === 6. Download LightPanda binary ===
echo "📥 Downloading LightPanda nightly build..."
curl --fail -L -o $binary_path $download_url
if test $status -ne 0
    echo "❌ Failed to download LightPanda. Aborting."
    exit 1
end

# === 7. Verify checksum ===
echo "🔍 Verifying checksum..."
set actual_sha256 (sha256sum $binary_path | awk '{print $1}')

if test "$actual_sha256" != "$expected_sha256"
    echo "❌ Checksum verification FAILED!"
    echo "   Expected: $expected_sha256"
    echo "   Actual:   $actual_sha256"
    rm -f $binary_path
    exit 1
end
echo "✅ Checksum verified OK."

# === 8. Make executable ===
chmod +x $binary_path
if test $status -ne 0
    echo "❌ Failed to make binary executable. Aborting."
    exit 1
end

# === 9. Add to fish PATH ===
set -U fish_user_paths $install_dir $fish_user_paths
echo "✅ lightpanda installed to $binary_path and added to PATH."

# === 10. Verify installation ===
echo "🧪 Testing LightPanda..."
if command -v lightpanda &>/dev/null
    lightpanda version
    if test $status -ne 0
        # fallback — try running directly
        $binary_path version
    end
else
    $binary_path version
end

if test $status -eq 0
    echo "✅ LightPanda installed and working!"
else
    echo "⚠ LightPanda binary installed but version check failed."
    echo "   You can run it with: $binary_path"
end

# === 11. Optional: systemd user service ===
echo
echo "🛠 Would you like to set up a systemd user service to run LightPanda's CDP server?"
echo "   This will start a LightPanda CDP server on ws://127.0.0.1:9222 automatically."
echo
read -P "Set up systemd user service? [y/N] " confirm

if test "$confirm" = "y" -o "$confirm" = "Y"
    set service_dir "$HOME/.config/systemd/user"
    mkdir -p $service_dir

    echo "[Unit]
Description=LightPanda Headless Browser CDP Server
After=network.target

[Service]
Type=simple
ExecStart=$binary_path serve --host 127.0.0.1 --port 9222
Restart=on-failure
RestartSec=5
Environment=LIGHTPANDA_DISABLE_TELEMETRY=true

[Install]
WantedBy=default.target" > "$service_dir/lightpanda.service"

    systemctl --user daemon-reload
    systemctl --user enable lightpanda.service
    systemctl --user start lightpanda.service

    if test $status -eq 0
        echo "✅ LightPanda systemd user service set up and started."
        echo "   Control it with:"
        echo "     systemctl --user status lightpanda"
        echo "     systemctl --user stop lightpanda"
        echo "     systemctl --user restart lightpanda"
    else
        echo "❌ Failed to start the service. Check with:"
        echo "     systemctl --user status lightpanda"
    end
else
    echo "⏭ Skipping systemd service setup."
end

# === 12. Reminders ===
echo
echo "💡 Reminders:"
echo "   • Start CDP server:  lightpanda serve --host 127.0.0.1 --port 9222"
echo "   • Fetch a URL:        lightpanda fetch --dump html https://example.com"
echo "   • MCP mode:           lightpanda mcp"
echo "   • Disable telemetry:  export LIGHTPANDA_DISABLE_TELEMETRY=true"
echo
echo "🌐 LightPanda setup complete!"
