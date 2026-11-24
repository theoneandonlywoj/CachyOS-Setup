#!/usr/bin/env fish
# === elixir_and_erlang.fish ===
# Purpose: Install specific versions of Erlang & Elixir via Mise on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Version configuration ===
set ERLANG_VERSION 27.1
set ELIXIR_VERSION 1.18.0

echo "🚀 Starting Erlang & Elixir setup via Mise..."
echo "📌 Target versions:"
echo "   Erlang  → $ERLANG_VERSION"
echo "   Elixir  → $ELIXIR_VERSION"
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

# === 3. Install required build dependencies ===
echo "📦 Installing required build dependencies (without system update)..."
sudo pacman -S --needed --noconfirm base-devel openssl libxslt fop wxwidgets libpng glu mesa git curl
if test $status -ne 0
    echo "❌ Failed to install required dependencies. Aborting."
    exit 1
end

# === 4. Install Erlang via Mise ===
echo "🔧 Installing Erlang $ERLANG_VERSION via Mise..."
mise install erlang@$ERLANG_VERSION
mise use -g erlang@$ERLANG_VERSION 
if test $status -ne 0
    echo "❌ Erlang installation failed. Rerun: ./elixir_and_erlang.fish"
    exit 1
end

# === 5. Install Elixir via Mise ===
echo "🔧 Installing Elixir $ELIXIR_VERSION via Mise..."
mise install elixir@$ELIXIR_VERSION
mise use -g elixir@$ELIXIR_VERSION
if test $status -ne 0
    echo "❌ Elixir installation failed. Rerun: ./elixir_and_erlang.fish"
    exit 1
end

# Reload PATH again to be safe
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source

# === 6. Add automatic activation to Fish config if not already present ===
set fish_config_file ~/.config/fish/config.fish
set activation_line "mise activate fish | source"

if not grep -Fxq "$activation_line" $fish_config_file
    echo "$activation_line" >> $fish_config_file
    echo "🔧 Added automatic Mise activation to $fish_config_file"
end

# === 7. Verify installations ===
echo "🧪 Verifying installations..."
set erlang_version (command erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell 2>/dev/null)
set elixir_version (command elixir -v 2>/dev/null | grep "Elixir" | awk '{print $2}')

if test -n "$erlang_version"
    echo "✅ Erlang installed successfully: OTP $erlang_version"
else
    echo "❌ Erlang verification failed."
end

if test -n "$elixir_version"
    echo "✅ Elixir installed successfully: v$elixir_version"
else
    echo "❌ Elixir verification failed."
end

echo
echo "🎉 Erlang & Elixir setup complete via Mise!"
echo
echo "💡 Important:"
echo "   To use 'iex', 'erl', 'mix', and 'elixir' in this terminal immediately,"
echo "   run the following command in your current shell:"
echo "       mise activate fish | source"
echo "   In future terminals, this will happen automatically thanks to the config file update."
echo
echo "📚 Installed versions:"
echo "   Erlang  → $ERLANG_VERSION"
echo "   Elixir  → $ELIXIR_VERSION"
echo
echo "💡 To start a new Elixir project:"
echo "   mix new my_app"

