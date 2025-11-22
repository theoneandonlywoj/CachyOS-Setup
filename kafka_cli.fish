#!/usr/bin/env fish
# === kafka_cli.fish ===
# Purpose: Install Kafka CLI tools via Mise or Apache Kafka releases on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set KAFKA_VERSION "latest"  # Use "latest" or specific version like "3.7.0"

echo "🚀 Starting Kafka CLI setup..."
echo "📌 Target version: $KAFKA_VERSION"
echo
echo "💡 Kafka CLI tools provide command-line interface for Apache Kafka:"
echo "   - Manage topics (create, list, describe, delete)"
echo "   - Produce and consume messages"
echo "   - Manage consumer groups"
echo "   - Configure brokers and topics"
echo "   - Monitor and debug Kafka clusters"
echo

# === 1. Check Mise installation ===
set use_mise false
if command -v mise > /dev/null
    echo "✅ Mise found. Attempting installation via Mise first..."
    set use_mise true
    
    # Load Mise environment in current shell
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
    
    # Try to install Kafka via Mise
    echo "🔍 Checking if Kafka is available via Mise..."
    if test "$KAFKA_VERSION" = "latest"
        mise install kafka@latest
        if test $status -eq 0
            mise use -g kafka@latest
        end
    else
        mise install kafka@$KAFKA_VERSION
        if test $status -eq 0
            mise use -g kafka@$KAFKA_VERSION
        end
    end
    
    if test $status -eq 0
        echo "✅ Kafka CLI installed via Mise."
        set kafka_installed_via_mise true
        # Re-activate mise and ensure shims are in PATH
        set -x PATH ~/.local/share/mise/shims $PATH
        mise activate fish | source
        mise reshim
    else
        echo "⚠ Kafka installation via Mise failed. Falling back to Apache releases..."
        set use_mise false
    end
else
    echo "ℹ Mise not found. Will install from Apache Kafka releases."
    echo "💡 Tip: Install mise first (./mise.fish) for better version management."
end

# === 2. Fallback: Install from Apache Kafka releases ===
if not set -q kafka_installed_via_mise
    echo "📥 Installing Kafka CLI from Apache Kafka releases..."
    
    # Detect architecture and Scala version
    set arch (uname -m)
    set scala_version "2.13"  # Default Scala version for Kafka
    
    # Get latest version from Apache Kafka if needed
    if test "$KAFKA_VERSION" = "latest"
        echo "🔍 Fetching latest Kafka version..."
        # Try to get latest version from Apache Kafka downloads page
        set KAFKA_VERSION (curl -s https://kafka.apache.org/downloads | grep -oP 'kafka_\d+\.\d+-\K[\d.]+' | head -n1)
        
        if test -z "$KAFKA_VERSION"
            echo "⚠ Failed to fetch latest version. Using fallback..."
            set KAFKA_VERSION "3.7.0"
        end
    end
    
    echo "📦 Downloading Kafka v$KAFKA_VERSION..."
    set KAFKA_FILENAME "kafka_$scala_version-$KAFKA_VERSION.tgz"
    set KAFKA_URL "https://archive.apache.org/dist/kafka/$KAFKA_VERSION/$KAFKA_FILENAME"
    set KAFKA_TMP_DIR (mktemp -d)
    set KAFKA_TAR "$KAFKA_TMP_DIR/kafka.tgz"
    set KAFKA_INSTALL_DIR "$HOME/.local/kafka"
    
    # Download Kafka
    curl -L -o $KAFKA_TAR $KAFKA_URL
    if test $status -ne 0
        echo "❌ Failed to download Kafka from Apache."
        rm -rf $KAFKA_TMP_DIR
        exit 1
    end
    
    # Extract Kafka
    echo "📦 Extracting Kafka..."
    mkdir -p $KAFKA_INSTALL_DIR
    cd $KAFKA_TMP_DIR
    tar -xzf $KAFKA_TAR
    if test $status -ne 0
        echo "❌ Failed to extract Kafka archive."
        rm -rf $KAFKA_TMP_DIR
        exit 1
    end
    
    # Find the extracted directory
    set kafka_dir (find . -maxdepth 1 -type d -name "kafka_*" | head -n1)
    
    if test -n "$kafka_dir" -a -d "$kafka_dir"
        # Move to installation directory
        rm -rf $KAFKA_INSTALL_DIR
        mv $kafka_dir $KAFKA_INSTALL_DIR
        
        # Create symlinks for common CLI tools in a bin directory
        mkdir -p $HOME/.local/bin
        for script in kafka-topics kafka-console-producer kafka-console-consumer kafka-configs kafka-consumer-groups kafka-broker-api-versions kafka-log-dirs kafka-metadata-shell kafka-reassign-partitions kafka-replica-verification kafka-run-class kafka-server-start kafka-server-stop kafka-streams-application-reset kafka-verifiable-consumer kafka-verifiable-producer
            if test -f "$KAFKA_INSTALL_DIR/bin/$script.sh"
                ln -sf "$KAFKA_INSTALL_DIR/bin/$script.sh" "$HOME/.local/bin/$script"
            end
        end
        
        # Set KAFKA_HOME in fish config
        set fish_config_file ~/.config/fish/config.fish
        set kafka_home_line "set -gx KAFKA_HOME $KAFKA_INSTALL_DIR"
        set kafka_path_line "set -gx PATH \$KAFKA_HOME/bin \$PATH"
        
        if not grep -Fxq "$kafka_home_line" $fish_config_file
            echo "$kafka_home_line" >> $fish_config_file
            echo "🔧 Added KAFKA_HOME to $fish_config_file"
        end
        
        if not grep -Fxq "$kafka_path_line" $fish_config_file
            echo "$kafka_path_line" >> $fish_config_file
            echo "🔧 Added Kafka bin directory to PATH in $fish_config_file"
        end
        
        # Cleanup
        cd -
        rm -rf $KAFKA_TMP_DIR
        
        echo "✅ Kafka CLI installed from Apache releases."
        set kafka_installed_via_apache true
        
        # Set environment variables for current session
        set -gx KAFKA_HOME $KAFKA_INSTALL_DIR
        set -gx PATH $KAFKA_HOME/bin $PATH
    else
        echo "❌ Could not find extracted Kafka directory."
        cd -
        rm -rf $KAFKA_TMP_DIR
        exit 1
    end
end

# === 3. Add automatic activation to Fish config if using Mise ===
if set -q kafka_installed_via_mise
    set fish_config_file ~/.config/fish/config.fish
    set activation_line "mise activate fish | source"
    
    if not grep -Fxq "$activation_line" $fish_config_file
        echo "$activation_line" >> $fish_config_file
        echo "🔧 Added automatic Mise activation to $fish_config_file"
    end
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."

# Ensure mise shims are in PATH for verification if using mise
if set -q kafka_installed_via_mise
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
end

# Check for kafka-topics command (most common CLI tool)
set kafka_verified false
if command -q kafka-topics
    set kafka_verified true
    echo "✅ Kafka CLI tools installed successfully"
    kafka-topics --version 2>&1 | head -n 1
else if test -f "$HOME/.local/bin/kafka-topics"
    set kafka_verified true
    echo "✅ Kafka CLI tools installed successfully"
    $HOME/.local/bin/kafka-topics --version 2>&1 | head -n 1
else
    echo "❌ Kafka CLI verification failed."
    echo "💡 If installed via Mise, try running: mise activate fish | source"
    echo "💡 If installed from Apache, ensure ~/.local/bin is in your PATH"
    exit 1
end

echo
echo "🎉 Kafka CLI setup complete!"
echo
if set -q kafka_installed_via_mise
    echo "💡 Important:"
    echo "   To use Kafka CLI tools in this terminal immediately,"
    echo "   run the following command in your current shell:"
    echo "       mise activate fish | source"
    echo "   In future terminals, this will happen automatically thanks to the config file update."
    echo
    echo "📚 Installed version: $KAFKA_VERSION (via Mise)"
else
    echo "💡 Important:"
    echo "   Kafka CLI tools are installed at: $KAFKA_INSTALL_DIR"
    echo "   Symlinks are available in: ~/.local/bin"
    echo "   KAFKA_HOME and PATH have been configured in your Fish config."
    echo "   You may need to restart your terminal or run:"
    echo "       source ~/.config/fish/config.fish"
    echo
    echo "📚 Installed version: $KAFKA_VERSION (from Apache releases)"
end
echo
echo "💡 Basic usage:"
echo "   # List topics"
echo "   kafka-topics --bootstrap-server localhost:9092 --list"
echo ""
echo "   # Create a topic"
echo "   kafka-topics --bootstrap-server localhost:9092 --create --topic my-topic --partitions 3 --replication-factor 1"
echo ""
echo "   # Describe a topic"
echo "   kafka-topics --bootstrap-server localhost:9092 --describe --topic my-topic"
echo ""
echo "   # Delete a topic"
echo "   kafka-topics --bootstrap-server localhost:9092 --delete --topic my-topic"
echo ""
echo "💡 Producer and Consumer:"
echo "   # Start a console producer"
echo "   kafka-console-producer --bootstrap-server localhost:9092 --topic my-topic"
echo ""
echo "   # Start a console consumer"
echo "   kafka-console-consumer --bootstrap-server localhost:9092 --topic my-topic --from-beginning"
echo ""
echo "   # Consumer with group"
echo "   kafka-console-consumer --bootstrap-server localhost:9092 --topic my-topic --group my-group"
echo ""
echo "💡 Consumer Groups:"
echo "   # List consumer groups"
echo "   kafka-consumer-groups --bootstrap-server localhost:9092 --list"
echo ""
echo "   # Describe a consumer group"
echo "   kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group my-group"
echo ""
echo "💡 Configuration:"
echo "   # List broker configurations"
echo "   kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 0 --describe"
echo ""
echo "   # Alter topic configuration"
echo "   kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name my-topic --alter --add-config retention.ms=86400000"
echo ""
echo "💡 Common options:"
echo "   --bootstrap-server HOST:PORT    # Kafka broker address"
echo "   --topic TOPIC                    # Topic name"
echo "   --partitions N                   # Number of partitions"
echo "   --replication-factor N           # Replication factor"
echo "   --from-beginning                 # Read from beginning (consumer)"
echo "   --group GROUP                    # Consumer group name"
echo ""
echo "💡 Note:"
echo "   Kafka requires a running Kafka broker to use CLI tools."
echo "   You can start a local Kafka server using:"
echo "       $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties"
echo "   (Requires ZooKeeper or KRaft mode)"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://kafka.apache.org/"
echo "   - Documentation: https://kafka.apache.org/documentation/"
echo "   - Quick Start: https://kafka.apache.org/quickstart"
echo "   - CLI Tools: https://kafka.apache.org/documentation/#tools"

