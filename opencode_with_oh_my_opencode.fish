#!/usr/bin/env fish
# === opencode_with_oh_my_opencode.fish ===
# Purpose: Install OpenCode and oh-my-opencode on CachyOS (Arch Linux)
# Author: theoneandonlywoj

# === Provider configuration ===
# Set your provider subscriptions below.
# Options for CLAUDE_SUBSCRIPTION: "no", "yes", "max20"
# Options for all others: "yes", "no"
set CLAUDE_SUBSCRIPTION "yes"
set OPENAI_SUBSCRIPTION "no"
set GEMINI_SUBSCRIPTION "no"
set COPILOT_SUBSCRIPTION "no"
set OPENCODE_ZEN_SUBSCRIPTION "no"
set ZAI_CODING_PLAN "no"
set KIMI_FOR_CODING "no"

echo "Starting OpenCode & oh-my-opencode setup..."
echo "Provider configuration:"
echo "   Claude       -> $CLAUDE_SUBSCRIPTION"
echo "   OpenAI       -> $OPENAI_SUBSCRIPTION"
echo "   Gemini       -> $GEMINI_SUBSCRIPTION"
echo "   Copilot      -> $COPILOT_SUBSCRIPTION"
echo "   OpenCode Zen -> $OPENCODE_ZEN_SUBSCRIPTION"
echo "   Z.ai Coding  -> $ZAI_CODING_PLAN"
echo "   Kimi         -> $KIMI_FOR_CODING"
echo

# === 1. Install Bun if not present (required for oh-my-opencode) ===
if not command -v bun > /dev/null
    echo "Bun is not installed. Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    if test $status -ne 0
        echo "Bun installation failed. Aborting."
        exit 1
    end
    # Load Bun into current shell
    set -x PATH ~/.bun/bin $PATH
    echo "Bun installed successfully."
else
    echo "Bun is already installed."
end

# === 2. Install OpenCode ===
# Check if OpenCode is already installed
if command -v opencode > /dev/null
    echo "OpenCode is already installed."
else
    # Try pacman first (Arch Linux)
    if command -v pacman > /dev/null
        echo "Installing OpenCode via pacman..."
        sudo pacman -S opencode
        if test $status -ne 0
            # Fallback to official installer
            echo "Pacman install failed, trying official installer..."
            curl -fsSL https://opencode.ai/install | bash
            if test $status -ne 0
                echo "OpenCode installation failed. Aborting."
                exit 1
            end
        end
    else
        # Use official installer for other distros
        echo "Installing OpenCode via official installer..."
        curl -fsSL https://opencode.ai/install | bash
        if test $status -ne 0
            echo "OpenCode installation failed. Aborting."
            exit 1
        end
    end
end

# Reload PATH to pick up OpenCode binary
set -x PATH ~/.local/bin $PATH

# === 3. Verify OpenCode installation ===
if not command -v opencode > /dev/null
    echo "OpenCode binary not found in PATH after installation. Aborting."
    exit 1
end

set opencode_version (opencode --version 2>/dev/null)
echo "OpenCode installed successfully: $opencode_version"

# === 4. Install oh-my-opencode via Bun ===
echo "Installing oh-my-opencode..."
bunx oh-my-opencode install --no-tui \
    --claude=$CLAUDE_SUBSCRIPTION \
    --openai=$OPENAI_SUBSCRIPTION \
    --gemini=$GEMINI_SUBSCRIPTION \
    --copilot=$COPILOT_SUBSCRIPTION \
    --opencode-zen=$OPENCODE_ZEN_SUBSCRIPTION \
    --zai-coding-plan=$ZAI_CODING_PLAN \
    --kimi-for-coding=$KIMI_FOR_CODING
if test $status -ne 0
    echo "oh-my-opencode installation failed. Aborting."
    exit 1
end

# === 5. Verify oh-my-opencode installation ===
echo "Verifying oh-my-opencode installation..."

set omo_config ~/.config/opencode/oh-my-opencode.json
set oc_config ~/.config/opencode/opencode.json

if test -f $omo_config
    echo "oh-my-opencode config found: $omo_config"
else
    # Check for JSONC variant
    if test -f ~/.config/opencode/oh-my-opencode.jsonc
        echo "oh-my-opencode config found: ~/.config/opencode/oh-my-opencode.jsonc"
    else
        echo "oh-my-opencode config not found. Installation may have failed."
    end
end

if test -f $oc_config
    if grep -q "oh-my-opencode" $oc_config
        echo "oh-my-opencode plugin registered in OpenCode config."
    else
        echo "oh-my-opencode plugin not found in OpenCode config."
    end
end

# Run oh-my-opencode doctor for detailed verification
echo
echo "Running oh-my-opencode doctor..."
if command -v oh-my-opencode > /dev/null
    oh-my-opencode doctor --verbose
else
    bunx oh-my-opencode doctor --verbose
end

echo
echo "OpenCode & oh-my-opencode setup complete!"
echo
echo "Important:"
echo "   You must authenticate with your providers using:"
echo "   opencode auth login"
echo
echo "   Then select your provider(s) and complete OAuth authentication."
echo "   Supported providers: Anthropic (Claude), Google (Gemini), GitHub (Copilot)"
echo
echo "Quick start:"
echo "   cd /path/to/your/project"
echo "   opencode"
echo
echo "Useful commands inside OpenCode:"
echo "   /init           -> Generate AGENTS.md for your project"
echo "   /init-deep      -> Generate hierarchical AGENTS.md files"
echo "   /start-work     -> Strategic planning mode (Prometheus)"
echo "   ultrawork (ulw) -> Activate all agents in parallel"
