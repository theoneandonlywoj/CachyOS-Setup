#!/usr/bin/env fish
#! === grafana.fish ===
# Purpose: Install or update Grafana on CachyOS / Arch Linux
# Author: theoneandonlywoj

echo "📊 Starting Grafana installation/update..."

# === 1. Install Grafana ===
echo "📦 Installing grafana via pacman..."
sudo pacman -S --noconfirm grafana
if test $status -ne 0
    echo "❌ Failed to install grafana. Aborting."
    exit 1
end

# === 2. Enable and start service ===
echo "⚙ Enabling and starting grafana.service..."
sudo systemctl enable --now grafana.service
if test $status -ne 0
    echo "❌ Failed to enable/start grafana.service. Aborting."
    exit 1
end

# === 3. Verify service status ===
echo "🔎 Checking grafana.service status..."
systemctl --no-pager --full status grafana.service | sed -n '1,12p'

# === 4. Verify listening port (optional) ===
if command -q ss
    echo "🔌 Verifying Grafana is listening on TCP/3000..."
    ss -tulpen | grep -E ":3000\s" | head -n 3
end

# === 5. Final info ===
echo
echo "🚀 Grafana is installed and running!"
echo "   URL: http://localhost:3000"
echo "   Default login: admin / admin (you will be prompted to change it)"
echo
echo "🧭 Useful commands:"
echo "   sudo systemctl status grafana.service"
echo "   sudo systemctl restart grafana.service"
echo "   sudo journalctl -u grafana.service -f"
echo
echo "✅ Done."
