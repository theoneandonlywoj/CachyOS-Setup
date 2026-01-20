#!/usr/bin/env fish
# === setup_litellm.fish ===
# Purpose: Setup LiteLLM proxy for Google Gemini in Cursor on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting LiteLLM + Gemini installation..."
echo
echo "💡 LiteLLM is a local proxy server that:"
echo "   - Translates OpenAI API calls to Google Gemini format"
echo "   - Allows using Gemini Flash/Pro models inside Cursor"
echo "   - Runs quietly in the background via Systemd"
echo "   - Saves you money (Gemini API is free/cheaper than GPT-4)"
echo

# === 1. Check/Install Dependencies (pipx) ===
echo "📦 Checking dependencies..."
set -l pipx_cmd ""

# Function to test if pipx actually works
function test_pipx_works
    set test_cmd $argv[1]
    $test_cmd --version > /dev/null 2>&1
    return $status
end

# Check if pipx exists and actually works
set pipx_works false
if command -q pipx
    if test_pipx_works pipx
        set pipx_cmd "pipx"
        set pipx_works true
        echo "✅ pipx is already installed and working."
    else
        echo "⚠️  pipx command found but not working. Will reinstall..."
    end
end

# If pipx doesn't work, try to install via mise first
if not $pipx_works
    if command -q mise
        echo "✅ Mise found. Installing pipx via mise..."
        
        # Load Mise environment in current shell
        set -x PATH ~/.local/share/mise/shims $PATH
        mise activate fish | source
        
        # Install pipx via mise
        mise install pipx@latest
        if test $status -eq 0
            mise use -g pipx@latest
            if test $status -eq 0
                # Re-activate mise and ensure shims are in PATH
                set -x PATH ~/.local/share/mise/shims $PATH
                mise activate fish | source
                mise reshim
                
                # Check if pipx is now available and working
                if command -q pipx
                    if test_pipx_works pipx
                        set pipx_cmd "pipx"
                        set pipx_works true
                        echo "✅ pipx installed successfully via mise"
                    else
                        echo "⚠️  pipx installed but not working. Trying mise exec..."
                        if test_pipx_works "mise exec -- pipx"
                            set pipx_cmd "mise exec -- pipx"
                            set pipx_works true
                            echo "✅ pipx works via mise exec"
                        end
                    end
                else
                    if test_pipx_works "mise exec -- pipx"
                        set pipx_cmd "mise exec -- pipx"
                        set pipx_works true
                        echo "✅ pipx works via mise exec"
                    end
                end
            else
                echo "⚠️  Failed to set pipx as global via mise, but installation succeeded."
                set -x PATH ~/.local/share/mise/shims $PATH
                mise activate fish | source
                mise reshim
                if command -q pipx
                    if test_pipx_works pipx
                        set pipx_cmd "pipx"
                        set pipx_works true
                    else if test_pipx_works "mise exec -- pipx"
                        set pipx_cmd "mise exec -- pipx"
                        set pipx_works true
                    end
                else if test_pipx_works "mise exec -- pipx"
                    set pipx_cmd "mise exec -- pipx"
                    set pipx_works true
                end
            end
        else
            echo "⚠️  pipx installation via mise failed. Falling back to pacman..."
        end
    end
    
    # Fallback to pacman if mise not available or installation failed
    if not $pipx_works
        echo "⚠️  pipx not working. Installing python-pipx via pacman..."
        sudo pacman -S --needed --noconfirm python-pipx
        if test $status -ne 0
            echo "❌ Failed to install pipx."
            exit 1
        end
        echo "✅ pipx installed."
        
        # Try to use pipx command, fallback to python3 -m pipx if needed
        if command -q pipx
            if test_pipx_works pipx
                set pipx_cmd "pipx"
                set pipx_works true
            end
        end
        
        if not $pipx_works
            # Refresh PATH and try again
            set -gx PATH $PATH /usr/bin
            if command -q pipx
                if test_pipx_works pipx
                    set pipx_cmd "pipx"
                    set pipx_works true
                end
            end
        end
        
        if not $pipx_works
            # Use python3 -m pipx as fallback
            if test_pipx_works "python3 -m pipx"
                set pipx_cmd "python3 -m pipx"
                set pipx_works true
                echo "⚠️  Using python3 -m pipx (pipx command not working)"
            end
        end
        
        # Ensure pipx path is recognized for future sessions
        if $pipx_works
            $pipx_cmd ensurepath 2>/dev/null || python3 -m pipx ensurepath 2>/dev/null || true
        end
    end
end

# Final check
if not $pipx_works
    echo "❌ Failed to get a working pipx installation."
    exit 1
end

# === 2. Install LiteLLM ===
echo
echo "📦 Installing LiteLLM via pipx..."
echo "   Installing with [proxy] extras to include all dependencies..."
$pipx_cmd install "litellm[proxy]" --force
if test $status -ne 0
    echo "❌ Failed to install LiteLLM."
    exit 1
end
echo "✅ LiteLLM installed successfully with proxy dependencies."

# === 3. Configure Gemini API Key ===
echo
echo "🔑 Configuration: Google Gemini API Key"
echo "   If you don't have one, get it here: https://aistudio.google.com/app/apikey"
read -P "   Paste your Gemini API Key (starts with AIza...): " -s gemini_key
echo

if test -z "$gemini_key"
    echo "❌ API Key cannot be empty. Aborting."
    exit 1
end

# Store key in a variable for systemd injection later
# We also set it universally for the shell just in case user wants to run CLI manually
set -Ux GEMINI_API_KEY "$gemini_key"
echo "✅ API Key saved to environment."

# === 4. Create LiteLLM Config ===
echo
echo "📝 Creating LiteLLM configuration..."
mkdir -p ~/.config/litellm

# Create config.yaml
echo "model_list:
  - model_name: gemini-2.0-flash
    litellm_params:
      model: gemini/gemini-2.0-flash-exp
      api_key: os.environ/GEMINI_API_KEY

  - model_name: gemini-1.5-pro
    litellm_params:
      model: gemini/gemini-1.5-pro
      api_key: os.environ/GEMINI_API_KEY
" > ~/.config/litellm/config.yaml

if test $status -eq 0
    echo "✅ Config file created at ~/.config/litellm/config.yaml"
else
    echo "❌ Failed to create config file."
    exit 1
end

# === 5. Setup Systemd Service ===
echo
echo "⚙️  Setting up background service..."
mkdir -p ~/.config/systemd/user/

# Get the path to home properly for systemd replacement
set -l user_home $HOME

# Create service file
# We inject the API key directly into the service environment to ensure reliability
printf '[Unit]
Description=LiteLLM Proxy Service
After=network.target

[Service]
ExecStart=%s/.local/bin/litellm --config %s/.config/litellm/config.yaml --port 4000
Restart=always
RestartSec=5
Environment="GEMINI_API_KEY=%s"

[Install]
WantedBy=default.target
' "$user_home" "$user_home" "$gemini_key" > ~/.config/systemd/user/litellm.service

echo "✅ Service file created."

# Reload and Enable
systemctl --user daemon-reload
systemctl --user enable litellm
echo "✅ Service enabled to start on login."

echo "🚀 Starting LiteLLM service..."
systemctl --user restart litellm
sleep 3

# === 6. Verify Installation ===
echo
echo "🧪 Verifying service status..."
if systemctl --user is-active --quiet litellm
    echo "✅ LiteLLM is running (Active)."
else
    echo "❌ LiteLLM failed to start. Check logs with: journalctl --user -u litellm"
    exit 1
end

# === 7. Final Instructions ===
echo
echo "🎉 LiteLLM setup complete!"
echo
echo "💡 Final Step: Configure Cursor"
echo "   1. Open Cursor and go to Settings (Ctrl + Shift + J)"
echo "   2. Navigate to 'Models' (or General > OpenAI API Key)"
echo "   3. Set 'Override OpenAI Base URL' to:"
echo "      http://localhost:4000/v1"
echo "   4. Set 'API Key' to any value (e.g., 'sk-1234')"
echo "   5. Add Model: Click 'Add model' and type exactly:"
echo "      gemini-2.0-flash"
echo ""
echo "💡 Troubleshooting:"
echo "   # Check logs if it stops working"
echo "   journalctl --user -u litellm -f"
echo ""
echo "   # Restart the service"
echo "   systemctl --user restart litellm"
echo ""
echo "   # Edit models config"
echo "   nano ~/.config/litellm/config.yaml"
echo "   (Remember to restart service after editing config)"
echo ""
echo "💡 Usage:"
echo "   Now, in Cursor Chat (Ctrl+L), select 'gemini-2.0-flash'"
echo "   and enjoy free/cheap inference powered by Google!"