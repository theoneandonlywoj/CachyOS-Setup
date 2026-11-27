#!/usr/bin/env fish
# === kubectl.fish ===
# Purpose: Install kubectl (Kubernetes CLI) on CachyOS
# Installs kubectl and related tools from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting kubectl installation..."

# === 1. Install kubectl ===
echo "📦 Installing kubectl..."
sudo pacman -S --needed --noconfirm kubectl
if test $status -ne 0
    echo "❌ Failed to install kubectl."
    exit 1
end
echo "✅ kubectl installed."

# === 2. Install optional kubectl tools ===
echo "📦 Installing optional kubectl tools..."
echo "💡 The following tools enhance kubectl capabilities:"
echo "   - krew: Kubectl plugin manager"
echo "   - kubectx: Switch between Kubernetes contexts and namespaces"
echo "   - kubectl-cert-manager: Certificate management plugin"
set -l install_tools
if test -t 0
    read -P "Do you want to install optional kubectl tools? [y/N] " install_tools
end

if test "$install_tools" = "y" -o "$install_tools" = "Y"
    echo "📦 Installing kubectl tools..."
    sudo pacman -S --needed --noconfirm krew kubectx kubectl-cert-manager
    if test $status -ne 0
        echo "⚠ Failed to install some tools, but kubectl is still installed."
    else
        echo "✅ kubectl tools installed."
    end
end

# === 3. Setup kubectl autocomplete ===
echo "📦 Setting up kubectl shell completion..."
if command -q kubectl
    # Fish shell autocompletion
    kubectl completion fish > ~/.config/fish/completions/kubectl.fish
    if test $status -eq 0
        echo "✅ kubectl autocomplete configured for Fish."
    else
        echo "⚠ Failed to configure autocomplete."
    end
end

# === 4. Check and fix snapper Boost library issue (if present) ===
if test -f /usr/bin/snapper
    echo
    echo "🔧 Checking for snapper Boost library issue..."
    snapper --version > /dev/null 2>&1
    if test $status -ne 0
        echo "⚠ Detected snapper Boost library version mismatch."
        echo "💡 This can happen after Boost updates."
        set -l fix_snapper
        if test -t 0
            read -P "Do you want to fix snapper? [y/N] " fix_snapper
        end
        
        if test "$fix_snapper" = "y" -o "$fix_snapper" = "Y"
            echo "📦 Updating snapper to fix Boost library version mismatch..."
            sudo pacman -S --needed --noconfirm snapper
            if test $status -eq 0
                echo "✅ Snapper fixed successfully."
            else
                echo "⚠ Failed to fix snapper, but kubectl is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q kubectl
if test $status -eq 0
    echo "✅ kubectl installed successfully"
    kubectl version --client --short 2>&1
else
    echo "❌ kubectl installation verification failed."
end

echo
echo "✅ kubectl installation complete!"
echo "💡 kubectl is the Kubernetes command-line tool:"
echo "   - Manage Kubernetes clusters"
echo "   - Deploy and manage applications"
echo "   - Debug and inspect resources"
echo "   - Scale and update deployments"
echo "💡 Basic commands:"
echo "   - kubectl get nodes: List cluster nodes"
echo "   - kubectl get pods: List pods"
echo "   - kubectl get services: List services"
echo "   - kubectl apply -f file.yaml: Apply manifest"
echo "   - kubectl logs pod-name: View logs"
echo "   - kubectl exec -it pod-name -- /bin/sh: Execute in pod"
echo "💡 Setup cluster access:"
echo "   1. Configure kubeconfig: ~/.kube/config"
echo "   2. Add cluster credentials"
echo "   3. Set context: kubectl config use-context my-cluster"
echo "💡 Using kubectx (if installed):"
echo "   - kubectx: Switch context"
echo "   - kubens: Switch namespace"
echo "   - kubectx -: Return to previous context"
echo "💡 Using krew plugin manager (if installed):"
echo "   - krew search: Search for plugins"
echo "   - krew install: Install a plugin"
echo "   - krew list: List installed plugins"
echo "💡 Troubleshooting:"
echo "   - kubectl config view: View configuration"
echo "   - kubectl cluster-info: Cluster information"
echo "   - kubectl get events: Recent events"
echo "💡 Resources:"
echo "   - Kubernetes docs: https://kubernetes.io/docs/"
echo "   - kubectl cheat sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/"

