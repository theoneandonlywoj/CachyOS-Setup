#!/usr/bin/env fish
# === zigbee2mqtt.fish ===
# Purpose: Install Zigbee2MQTT on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Configuration ===
set Z2M_VERSION 1.42.0
set Z2M_DIR /opt/zigbee2mqtt
set GATEWAY_IP 192.168.1.105
set GATEWAY_PORT 6638
set COORDINATOR_PORT /dev/ttyUSB0
set MQTT_HOST localhost
set MQTT_PORT 1883

echo "🚀 Starting Zigbee2MQTT setup..."
echo "📌 Target version: v$Z2M_VERSION"
echo "📌 Install directory: $Z2M_DIR"
echo "📌 Gateway: tcp://$GATEWAY_IP:$GATEWAY_PORT"
echo "📌 Coordinator port: $COORDINATOR_PORT"
echo

# === 1. Check Node.js & npm ===
if not command -v node > /dev/null
    echo "❌ Node.js is not installed. Please install it first."
    exit 1
end
echo "✅ Node.js: "(node --version)
echo "✅ npm: "(npm --version)
set NODE_PATH (command -v node)
set NPM_PATH (command -v npm)
echo

# === 2. Install system dependencies ===
echo "📦 Installing system dependencies (Mosquitto MQTT broker, git, make, gcc, netcat)..."
sudo pacman -S --needed --noconfirm mosquitto git make gcc openbsd-netcat
if test $status -ne 0
    echo "❌ Failed to install system dependencies. Aborting."
    exit 1
end
echo

# === 3. Check Zigbee gateway connectivity ===
echo "🌐 Checking Zigbee gateway connectivity..."
nc -zv $GATEWAY_IP $GATEWAY_PORT > /dev/null 2>&1
if test $status -eq 0
    echo "✅ Gateway is reachable at tcp://$GATEWAY_IP:$GATEWAY_PORT"
else
    echo "⚠️  Could not reach gateway at tcp://$GATEWAY_IP:$GATEWAY_PORT"
    echo "   Make sure the device is online and reachable, then re-run this script."
    exit 1
end
echo

# === 4. Create zigbee2mqtt user ===
echo "👤 Creating zigbee2mqtt system user..."
if not id zigbee2mqtt &> /dev/null
    sudo useradd -r -s /sbin/nologin -d $Z2M_DIR zigbee2mqtt
    echo "✅ User 'zigbee2mqtt' created."
else
    echo "ℹ️  User 'zigbee2mqtt' already exists."
end
echo

# === 5. Clone / update Zigbee2MQTT ===
if test -d "$Z2M_DIR"
    echo "ℹ️  Zigbee2MQTT directory already exists at $Z2M_DIR."
    echo "💡 To reinstall, delete the directory and re-run this script."
    echo
else
    echo "🔧 Cloning Zigbee2MQTT v$Z2M_VERSION..."
    sudo git clone --branch $Z2M_VERSION --depth 1 https://github.com/Koenkk/zigbee2mqtt.git $Z2M_DIR
    if test $status -ne 0
        echo "❌ Failed to clone Zigbee2MQTT. Aborting."
        exit 1
    end
    echo "✅ Cloned successfully."
    echo

    echo "📦 Installing npm dependencies..."
    sudo bash -c "cd $Z2M_DIR && $NPM_PATH ci"
    if test $status -ne 0
        echo "❌ npm install failed. Aborting."
        exit 1
    end
    echo "✅ npm dependencies installed."
    echo

    echo "🔒 Setting ownership..."
    sudo chown -R zigbee2mqtt:zigbee2mqtt $Z2M_DIR
    echo
end

# === 6. Configure Zigbee2MQTT ===
set config_file "$Z2M_DIR/data/configuration.yaml"
if not test -f "$config_file"
    echo "⚙️  Creating default configuration..."
    sudo mkdir -p "$Z2M_DIR/data"
    echo "homeassistant: false" | sudo tee "$config_file" > /dev/null
    echo "permit_join: false" | sudo tee -a "$config_file" > /dev/null
    echo "mqtt:" | sudo tee -a "$config_file" > /dev/null
    echo "  base_topic: zigbee2mqtt" | sudo tee -a "$config_file" > /dev/null
    echo "  server: mqtt://$MQTT_HOST:$MQTT_PORT" | sudo tee -a "$config_file" > /dev/null
    echo "serial:" | sudo tee -a "$config_file" > /dev/null
    echo "  port: $COORDINATOR_PORT" | sudo tee -a "$config_file" > /dev/null
    sudo chown -R zigbee2mqtt:zigbee2mqtt "$Z2M_DIR/data"
    echo "✅ Configuration created at $config_file"
else
    echo "ℹ️  Configuration already exists at $config_file"
end
echo

# === 7. Install systemd service ===
set service_file /etc/systemd/system/zigbee2mqtt.service
if test -f "$service_file"
    echo "ℹ️  systemd service already installed."
else
    echo "🔧 Installing systemd service..."
    echo "[Unit]
Description=Zigbee2MQTT
After=network.target mosquitto.service

[Service]
Type=simple
User=zigbee2mqtt
Group=zigbee2mqtt
WorkingDirectory=$Z2M_DIR
ExecStart=$NODE_PATH $Z2M_DIR/index.js
Restart=on-failure
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target" | sudo tee "$service_file" > /dev/null

    sudo systemctl daemon-reload
    echo "✅ systemd service installed."
end
echo

# === 8. Start & enable Mosquitto ===
echo "🐝 Ensuring Mosquitto MQTT broker is running..."
sudo systemctl enable --now mosquitto > /dev/null 2>&1
if test $status -ne 0
    echo "⚠️  Could not enable Mosquitto. Starting manually..."
    sudo systemctl start mosquitto
end
echo

# === 9. Add user to dialout group for serial access ===
echo "🔌 Adding user '$USER' to dialout group for serial port access..."
sudo usermod -a -G dialout $USER
echo "✅ Added to dialout group (log out & back in for this to take effect)."
echo

# === 10. Verify installation ===
echo "🧪 Verifying installation..."

set expect_files "$Z2M_DIR/index.js" "$Z2M_DIR/package.json" "$Z2M_DIR/data/configuration.yaml"
set all_ok true

for f in $expect_files
    if test -f "$f"
        echo "   ✅ $f"
    else
        echo "   ❌ $f — missing!"
        set all_ok false
    end
end

if $all_ok
    echo "✅ All installation checks passed."
else
    echo "⚠️  Some checks failed. Review the output above."
end

echo
echo "🎉 Zigbee2MQTT setup complete!"
echo
echo "📚 Post-installation steps:"
echo
echo "   💡 Verify connectivity before starting:"
echo "      Gateway →  nc -zv $GATEWAY_IP $GATEWAY_PORT"
echo "      Subscribe →  mosquitto_sub -h $MQTT_HOST -t zigbee2mqtt/# -v"
echo "      Publish →  mosquitto_pub -h $MQTT_HOST -t zigbee2mqtt/test -m 'hello'"
echo
echo "   1. Log out and back in for serial port (dialout) permissions to apply."
echo "   2. Edit your coordinator port if needed:"
echo "      cd $Z2M_DIR/data"
echo "      sudo vim configuration.yaml"
echo
echo "      # Pay attention, if you use the Z2M addon for HA, it is better to edit"
echo "      # Z2M addon yaml configuration file directly"
echo "      # (Select the 3 dot menu in the upper right corner -> \"Edit in YAML\")"
echo "      serial:"
echo "        # Location of SLZB-06U"
echo "        port: tcp://192.168.1.105:6638"
echo "        baudrate: 115200"
echo "        adapter: zstack"
echo "        # Disable green led?"
echo "        disable_led: false"
echo "      # Set output power to max 20"
echo "      advanced:"
echo "        transmit_power: 20"
echo
echo "   3. Verify your coordinator is connected:"
echo "      ls -l $COORDINATOR_PORT"
echo "   4. Start Zigbee2MQTT:"
echo "      sudo systemctl start zigbee2mqtt"
echo "   5. Enable on boot:"
echo "      sudo systemctl enable zigbee2mqtt"
echo "   6. Check logs:"
echo "      sudo journalctl -u zigbee2mqtt -f"
echo "   7. Frontend (if configured):"
echo "      http://localhost:8080"
echo
echo "💡 To pair a new Zigbee device, set permit_join: true in the config,"
echo "   or use the frontend (http://localhost:8080). Remember to disable it after."
echo
