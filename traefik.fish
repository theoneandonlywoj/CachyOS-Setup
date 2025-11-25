#!/usr/bin/env fish
# === traefik.fish ===
# Purpose: Install Traefik (modern reverse proxy) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Traefik installation..."
echo
echo "💡 Traefik is a modern reverse proxy and load balancer:"
echo "   - Automatic HTTPS with Let's Encrypt"
echo "   - Native Docker, Kubernetes, and more integrations"
echo "   - Dynamic configuration"
echo "   - Web dashboard"
echo "   - Middleware support"
echo "   - Metrics and tracing"
echo

# === 1. Check if Traefik is already installed ===
command -q traefik; and set -l traefik_installed "installed"
if test -n "$traefik_installed"
    echo "✅ Traefik is already installed."
    traefik version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Traefik installation."
        exit 0
    end
    echo "📦 Removing existing Traefik installation..."
    sudo pacman -R --noconfirm traefik
    if test $status -ne 0
        echo "❌ Failed to remove Traefik."
        exit 1
    end
    echo "✅ Traefik removed."
end

# === 2. Install Traefik ===
echo "📦 Installing Traefik from official repository..."
sudo pacman -S --needed --noconfirm traefik
if test $status -ne 0
    echo "❌ Failed to install Traefik."
    exit 1
end
echo "✅ Traefik installed."

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q traefik
    echo "✅ Traefik installed successfully"
    traefik version 2>&1 | head -n 1
else
    echo "❌ Traefik installation verification failed."
    exit 1
end

echo
echo "🎉 Traefik installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Check version"
echo "   traefik version"
echo ""
echo "   # Run with config file"
echo "   traefik --configFile=/etc/traefik/traefik.yml"
echo ""
echo "💡 Configuration locations:"
echo "   - /etc/traefik/traefik.yml (static config)"
echo "   - /etc/traefik/dynamic/ (dynamic config directory)"
echo ""
echo "💡 Example static configuration (traefik.yml):"
echo "   api:"
echo "     dashboard: true"
echo "     insecure: true  # For local dev only"
echo "   entryPoints:"
echo "     web:"
echo "       address: ':80'"
echo "     websecure:"
echo "       address: ':443'"
echo "   providers:"
echo "     file:"
echo "       directory: /etc/traefik/dynamic"
echo "       watch: true"
echo ""
echo "💡 Systemd service:"
echo "   # Enable and start Traefik service"
echo "   sudo systemctl enable traefik"
echo "   sudo systemctl start traefik"
echo ""
echo "   # Check status"
echo "   sudo systemctl status traefik"
echo ""
echo "💡 Dashboard:"
echo "   - Access at http://localhost:8080/dashboard/"
echo "   - Enable in config with api.dashboard: true"
echo ""
echo "💡 Docker integration:"
echo "   providers:"
echo "     docker:"
echo "       endpoint: 'unix:///var/run/docker.sock'"
echo "       exposedByDefault: false"
echo ""
echo "💡 Let's Encrypt (automatic HTTPS):"
echo "   certificatesResolvers:"
echo "     letsencrypt:"
echo "       acme:"
echo "         email: your@email.com"
echo "         storage: /etc/traefik/acme.json"
echo "         httpChallenge:"
echo "           entryPoint: web"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://traefik.io/"
echo "   - Documentation: https://doc.traefik.io/traefik/"
echo "   - GitHub: https://github.com/traefik/traefik"


