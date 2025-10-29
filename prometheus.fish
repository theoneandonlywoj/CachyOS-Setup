#!/usr/bin/env fish
# === prometheus.fish ===
# Purpose: Install and run Prometheus on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Prometheus setup..."
echo

# === 1. Install Prometheus ===
echo "📦 Installing prometheus via pacman..."
sudo pacman -S --needed --noconfirm prometheus
if test $status -ne 0
    echo "❌ Failed to install prometheus. Aborting."
    exit 1
end

# === 2. Basic paths and info ===
set PROM_CONFIG /etc/prometheus/prometheus.yml
set PROM_DATA /var/lib/prometheus
set PROM_USER prometheus
echo "📁 Config: $PROM_CONFIG"
echo "💾 Data dir: $PROM_DATA"
echo "👤 Service user: $PROM_USER"
echo

# === 3. Enable and start service ===
echo "⚙ Enabling and starting prometheus.service..."
sudo systemctl enable --now prometheus.service
if test $status -ne 0
    echo "❌ Failed to enable/start prometheus.service. Aborting."
    exit 1
end

# === 4. Verify service status ===
echo "🔎 Checking prometheus.service status..."
systemctl --no-pager --full status prometheus.service | sed -n '1,12p'

# === 5. Verify listening port (optional) ===
if command -q ss
    echo "🔌 Verifying Prometheus is listening on TCP/9090..."
    ss -tulpen | grep -E ":9090\\s" | head -n 3
end

# === 6. Tips & next steps ===
echo
echo "🎉 Prometheus is installed and running!"
echo "   UI: http://localhost:9090"
echo "   Config file: $PROM_CONFIG"
echo "   Data directory: $PROM_DATA"
echo
echo "🧭 Useful commands:"
echo "   sudo systemctl status prometheus.service"
echo "   sudo systemctl restart prometheus.service"
echo "   sudo journalctl -u prometheus.service -f"
echo
echo "💡 To edit scrape targets, modify: $PROM_CONFIG and then restart the service."
echo
echo "✅ Done."


