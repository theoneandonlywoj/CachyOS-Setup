#!/usr/bin/env fish
# === vault.fish ===
# Purpose: Install Vault (HashiCorp secrets management) on CachyOS
# Installs Vault via mise (preferred) or falls back to pacman/AUR
# Author: theoneandonlywoj

echo "🚀 Starting Vault installation..."

# === 1. Check if Vault is already installed ===
command -q vault; and set -l vault_installed "installed"
if test -n "$vault_installed"
    echo "✅ Vault is already installed."
    vault version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Vault installation."
        exit 0
    end
    echo "📦 Removing existing Vault installation..."
    # Try to remove via mise first
    if command -v mise > /dev/null
        mise uninstall vault 2>/dev/null
    end
    # Try to remove via pacman
    if pacman -Qq vault > /dev/null 2>&1
        sudo pacman -R --noconfirm vault
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/vault
        sudo rm -f /usr/local/bin/vault
    end
    if test -f ~/.local/bin/vault
        rm -f ~/.local/bin/vault
    end
    echo "✅ Vault removed."
end

# === 2. Check for Mise and prefer mise installation ===
set use_mise false
if command -v mise > /dev/null
    echo "✅ Mise found. Preferring mise installation method."
    set use_mise true
    
    # Load Mise environment in current shell
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
    
    # Check if Vault is available via mise
    echo "🔍 Checking if Vault is available via mise..."
    mise install vault@latest
    if test $status -eq 0
        mise use -g vault@latest
        if test $status -eq 0
            echo "✅ Vault installed successfully via mise"
            set vault_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        else
            echo "⚠ Failed to set Vault as global via mise, but installation succeeded."
            set vault_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        end
    else
        echo "⚠ Vault installation via mise failed. Falling back to pacman/AUR..."
        set use_mise false
    end
else
    echo "ℹ Mise not found. Will install via pacman/AUR."
    echo "💡 Tip: Install mise first (./mise.fish) for better version management."
end

# === 3. Fallback: Install via pacman/AUR if mise failed or not available ===
if not set -q vault_installed_via_mise
    echo "📦 Installing Vault via package manager..."
    
    # Check if available in official repos
    if pacman -Si vault > /dev/null 2>&1
        echo "📦 Installing Vault from official Arch repository..."
        sudo pacman -S --needed --noconfirm vault
        if test $status -ne 0
            echo "❌ Failed to install Vault from official repository."
            exit 1
        end
        echo "✅ Vault installed from official repository."
    else
        # Try AUR helper
        set AUR_HELPER ""
        for helper in yay paru trizen pikaur
            if command -v $helper > /dev/null
                set AUR_HELPER $helper
                break
            end
        end
        
        if test -n "$AUR_HELPER"
            echo "📦 Installing Vault from AUR using $AUR_HELPER..."
            $AUR_HELPER -S --needed --noconfirm vault
            if test $status -ne 0
                echo "❌ Failed to install Vault from AUR."
                exit 1
            end
            echo "✅ Vault installed from AUR."
        else
            echo "❌ No AUR helper found and Vault not in official repos."
            echo "💡 Install an AUR helper (yay, paru, etc.) or install mise first."
            exit 1
        end
    end
end

# === 4. Ensure mise environment is active for verification ===
if set -q vault_installed_via_mise
    # Ensure mise shims are in PATH
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
end

# === 5. Setup Vault autocomplete ===
echo "📦 Setting up Vault shell completion..."
# Check for vault via mise first, then regular PATH
if set -q vault_installed_via_mise
    if mise exec -- vault version > /dev/null 2>&1
        # Use mise exec to install autocomplete
        mise exec -- vault -autocomplete-install 2>/dev/null
        if test $status -eq 0
            echo "✅ Vault autocomplete configured for Fish."
        else
            echo "⚠ Failed to configure autocomplete automatically."
            echo "💡 You can run manually: mise exec -- vault -autocomplete-install"
        end
    end
else if command -q vault
    # Fish shell autocompletion
    vault -autocomplete-install 2>/dev/null
    if test $status -eq 0
        echo "✅ Vault autocomplete configured for Fish."
    else
        echo "⚠ Failed to configure autocomplete (may need manual setup)."
        echo "💡 You can run manually: vault -autocomplete-install"
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
set vault_verified false
if set -q vault_installed_via_mise
    # Verify via mise
    if mise exec -- vault version > /dev/null 2>&1
        set vault_verified true
        echo "✅ Vault installed successfully via mise"
        mise exec -- vault version 2>&1
    end
else if command -q vault
    set vault_verified true
    echo "✅ Vault installed successfully"
    vault version 2>&1
end

if not $vault_verified
    echo "❌ Vault installation verification failed."
    if set -q vault_installed_via_mise
        echo "💡 Vault was installed via mise. Try running: mise reshim"
        echo "💡 Or restart your terminal to ensure mise shims are in PATH."
    end
    exit 1
end

echo
echo "✅ Vault installation complete!"
echo "💡 Vault is HashiCorp's secrets management tool:"
echo "   - Securely store and access secrets"
echo "   - Dynamic secrets generation"
echo "   - Encryption as a service"
echo "   - Access control and audit logging"
echo "   - Multiple authentication methods"
echo "💡 Basic commands:"
echo "   - vault version: Show Vault version"
echo "   - vault status: Check Vault server status"
echo "   - vault auth: Authenticate to Vault"
echo "   - vault kv get <path>: Read a secret"
echo "   - vault kv put <path> key=value: Write a secret"
echo "   - vault kv list <path>: List secrets"
echo "   - vault kv delete <path>: Delete a secret"
echo "💡 Server management:"
echo "   - vault server -dev: Start development server"
echo "   - vault operator init: Initialize a new Vault cluster"
echo "   - vault operator unseal: Unseal a Vault server"
echo "   - vault operator seal: Seal a Vault server"
echo "💡 Authentication:"
echo "   - vault auth -method=userpass username=user: Userpass auth"
echo "   - vault auth -method=ldap username=user: LDAP auth"
echo "   - vault auth -method=aws: AWS auth"
echo "   - vault token create: Create a new token"
echo "💡 KV secrets engine (v2):"
echo "   - vault kv get secret/myapp/config: Read secret"
echo "   - vault kv put secret/myapp/config username=admin password=secret: Write secret"
echo "   - vault kv list secret/: List secrets"
echo "   - vault kv delete secret/myapp/config: Delete secret"
echo "   - vault kv destroy -versions=1 secret/myapp/config: Destroy version"
echo "💡 Development server:"
echo "   # Start dev server (for testing only)"
echo "   vault server -dev"
echo "   # Set VAULT_ADDR environment variable"
echo "   export VAULT_ADDR='http://127.0.0.1:8200'"
echo "   # Use root token from dev server output"
echo "💡 Production setup:"
echo "   1. Initialize: vault operator init"
echo "   2. Unseal: vault operator unseal <key>"
echo "   3. Authenticate: vault auth <token>"
echo "   4. Configure: vault write, vault read, etc."
echo "💡 Environment variables:"
echo "   - VAULT_ADDR: Vault server address"
echo "   - VAULT_TOKEN: Authentication token"
echo "   - VAULT_NAMESPACE: Vault namespace"
echo "💡 Configuration:"
echo "   - Config file: /etc/vault.d/vault.hcl (server)"
echo "   - Client config: ~/.vault (client)"
echo "💡 Security best practices:"
echo "   - Never store root tokens in plain text"
echo "   - Use policies for access control"
echo "   - Enable audit logging"
echo "   - Use TLS in production"
echo "   - Rotate encryption keys regularly"
echo "💡 Resources:"
echo "   - Vault docs: https://www.vaultproject.io/docs"
echo "   - Learn Vault: https://learn.hashicorp.com/vault"
echo "   - Vault API: https://www.vaultproject.io/api"

