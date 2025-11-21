#!/usr/bin/env fish
# === helm.fish ===
# Purpose: Install Helm (Kubernetes package manager) on CachyOS
# Installs Helm via mise (preferred) or falls back to pacman/AUR
# Author: theoneandonlywoj

echo "🚀 Starting Helm installation..."

# === 1. Check if Helm is already installed ===
command -q helm; and set -l helm_installed "installed"
if test -n "$helm_installed"
    echo "✅ Helm is already installed."
    helm version --short 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Helm installation."
        exit 0
    end
    echo "📦 Removing existing Helm installation..."
    # Try to remove via mise first
    if command -v mise > /dev/null
        mise uninstall helm 2>/dev/null
    end
    # Try to remove via pacman
    if pacman -Qq helm > /dev/null 2>&1
        sudo pacman -R --noconfirm helm
    end
    echo "✅ Helm removed."
end

# === 2. Check for Mise and prefer mise installation ===
set use_mise false
if command -v mise > /dev/null
    echo "✅ Mise found. Preferring mise installation method."
    set use_mise true
    
    # Load Mise environment in current shell
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
    
    # Check if Helm is available via mise
    echo "🔍 Checking if Helm is available via mise..."
    mise install helm@latest
    if test $status -eq 0
        mise use -g helm@latest
        if test $status -eq 0
            echo "✅ Helm installed successfully via mise"
            set helm_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        else
            echo "⚠ Failed to set Helm as global via mise, but installation succeeded."
            set helm_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        end
    else
        echo "⚠ Helm installation via mise failed. Falling back to pacman/AUR..."
        set use_mise false
    end
else
    echo "ℹ Mise not found. Will install via pacman/AUR."
    echo "💡 Tip: Install mise first (./mise.fish) for better version management."
end

# === 3. Fallback: Install via pacman/AUR if mise failed or not available ===
if not set -q helm_installed_via_mise
    echo "📦 Installing Helm via package manager..."
    
    # Check if available in official repos
    if pacman -Si helm > /dev/null 2>&1
        echo "📦 Installing Helm from official Arch repository..."
        sudo pacman -S --needed --noconfirm helm
        if test $status -ne 0
            echo "❌ Failed to install Helm from official repository."
            exit 1
        end
        echo "✅ Helm installed from official repository."
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
            echo "📦 Installing Helm from AUR using $AUR_HELPER..."
            $AUR_HELPER -S --needed --noconfirm helm
            if test $status -ne 0
                echo "❌ Failed to install Helm from AUR."
                exit 1
            end
            echo "✅ Helm installed from AUR."
        else
            echo "❌ No AUR helper found and Helm not in official repos."
            echo "💡 Install an AUR helper (yay, paru, etc.) or install mise first."
            exit 1
        end
    end
end

# === 4. Ensure mise environment is active for verification ===
if set -q helm_installed_via_mise
    # Ensure mise shims are in PATH
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
end

# === 5. Setup Helm autocomplete ===
echo "📦 Setting up Helm shell completion..."
# Check for helm via mise first, then regular PATH
set helm_found false
if set -q helm_installed_via_mise
    if mise exec -- helm --version > /dev/null 2>&1
        set helm_found true
        # Use mise exec to get helm completion
        mkdir -p ~/.config/fish/completions
        mise exec -- helm completion fish > ~/.config/fish/completions/helm.fish
        if test $status -eq 0
            echo "✅ Helm autocomplete configured for Fish."
        else
            echo "⚠ Failed to configure autocomplete."
        end
    end
else if command -q helm
    # Fish shell autocompletion
    mkdir -p ~/.config/fish/completions
    helm completion fish > ~/.config/fish/completions/helm.fish
    if test $status -eq 0
        echo "✅ Helm autocomplete configured for Fish."
        set helm_found true
    else
        echo "⚠ Failed to configure autocomplete."
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
set helm_verified false
if set -q helm_installed_via_mise
    # Verify via mise
    if mise exec -- helm --version > /dev/null 2>&1
        set helm_verified true
        echo "✅ Helm installed successfully via mise"
        mise exec -- helm version --short 2>&1
    end
else if command -q helm
    set helm_verified true
    echo "✅ Helm installed successfully"
    helm version --short 2>&1
end

if not $helm_verified
    echo "❌ Helm installation verification failed."
    if set -q helm_installed_via_mise
        echo "💡 Helm was installed via mise. Try running: mise reshim"
        echo "💡 Or restart your terminal to ensure mise shims are in PATH."
    end
    exit 1
end

# === 7. Initialize Helm (if not already initialized) ===
echo
read -P "Do you want to initialize Helm? (creates ~/.config/helm) [Y/n] " init_helm
if test -z "$init_helm" -o "$init_helm" = "y" -o "$init_helm" = "Y"
    if not test -d ~/.config/helm
        echo "🔧 Initializing Helm..."
        if set -q helm_installed_via_mise
            mise exec -- helm repo add stable https://charts.helm.sh/stable 2>/dev/null
            mise exec -- helm repo update 2>/dev/null
        else
            helm repo add stable https://charts.helm.sh/stable 2>/dev/null
            helm repo update 2>/dev/null
        end
        echo "✅ Helm initialized."
    else
        echo "ℹ Helm already initialized."
    end
end

echo
echo "✅ Helm installation complete!"
echo "💡 Helm is the Kubernetes package manager:"
echo "   - Package and deploy Kubernetes applications"
echo "   - Manage application releases"
echo "   - Share and reuse application configurations"
echo "   - Version control for Kubernetes deployments"
echo "💡 Basic commands:"
echo "   - helm search repo: Search for charts"
echo "   - helm install <name> <chart>: Install a chart"
echo "   - helm list: List installed releases"
echo "   - helm upgrade <name> <chart>: Upgrade a release"
echo "   - helm uninstall <name>: Uninstall a release"
echo "   - helm status <name>: Show release status"
echo "💡 Common workflows:"
echo "   1. Search for charts: helm search repo nginx"
echo "   2. Install: helm install my-nginx bitnami/nginx"
echo "   3. List releases: helm list"
echo "   4. Upgrade: helm upgrade my-nginx bitnami/nginx"
echo "   5. Uninstall: helm uninstall my-nginx"
echo "💡 Repository management:"
echo "   - helm repo add <name> <url>: Add a repository"
echo "   - helm repo list: List repositories"
echo "   - helm repo update: Update repository index"
echo "   - helm repo remove <name>: Remove a repository"
echo "💡 Chart development:"
echo "   - helm create <name>: Create a new chart"
echo "   - helm lint <chart>: Lint a chart"
echo "   - helm package <chart>: Package a chart"
echo "   - helm template <chart>: Render chart templates"
echo "💡 Popular repositories:"
echo "   - Bitnami: helm repo add bitnami https://charts.bitnami.com/bitnami"
echo "   - Prometheus: helm repo add prometheus-community https://prometheus-community.github.io/helm-charts"
echo "   - Grafana: helm repo add grafana https://grafana.github.io/helm-charts"
echo "💡 Tips:"
echo "   - Use --dry-run to preview changes: helm install --dry-run"
echo "   - Use --debug for verbose output"
echo "   - Use --namespace to specify namespace"
echo "   - Use --set to override values: helm install --set key=value"
echo "   - Use --values to pass values file: helm install -f values.yaml"
echo "💡 Configuration:"
echo "   - Helm config: ~/.config/helm"
echo "   - Chart repositories: ~/.config/helm/repositories.yaml"
echo "   - Cache: ~/.cache/helm"
echo "💡 Resources:"
echo "   - Helm docs: https://helm.sh/docs/"
echo "   - Chart Hub: https://artifacthub.io/"
echo "   - Helm Hub: https://hub.helm.sh/"

