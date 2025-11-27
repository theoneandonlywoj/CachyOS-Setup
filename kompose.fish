#!/usr/bin/env fish
# === kompose.fish ===
# Purpose: Install Kompose (Docker Compose to Kubernetes converter) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Kompose installation..."
echo
echo "💡 Kompose converts Docker Compose files to Kubernetes resources:"
echo "   - Translate docker-compose.yml to K8s manifests"
echo "   - Support for Deployments, Services, PVCs"
echo "   - Multiple output formats (yaml, json, Helm charts)"
echo "   - Easy migration from Docker Compose to Kubernetes"
echo

# === 1. Check if Kompose is already installed ===
command -q kompose; and set -l kompose_installed "installed"
if test -n "$kompose_installed"
    echo "✅ Kompose is already installed."
    kompose version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Kompose installation."
        exit 0
    end
    echo "📦 Removing existing Kompose installation..."
    sudo pacman -R --noconfirm kompose
    if test $status -ne 0
        echo "❌ Failed to remove Kompose."
        exit 1
    end
    echo "✅ Kompose removed."
end

# === 2. Install Kompose ===
echo "📦 Installing Kompose from official repository..."
sudo pacman -S --needed --noconfirm kompose
if test $status -ne 0
    echo "❌ Failed to install Kompose."
    exit 1
end
echo "✅ Kompose installed."

# === 3. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q kompose
    echo "✅ Kompose installed successfully"
    kompose version 2>&1 | head -n 1
else
    echo "❌ Kompose installation verification failed."
    exit 1
end

echo
echo "🎉 Kompose installation complete!"
echo
echo "═══════════════════════════════════════════════════════════════"
echo "                    KOMPOSE USAGE GUIDE"
echo "═══════════════════════════════════════════════════════════════"
echo
echo "💡 Basic conversion:"
echo "   # Convert docker-compose.yml to Kubernetes YAML files"
echo "   kompose convert"
echo ""
echo "   # Convert a specific file"
echo "   kompose convert -f docker-compose.yml"
echo ""
echo "💡 Output options:"
echo "   # Output to stdout instead of files"
echo "   kompose convert --stdout"
echo ""
echo "   # Output as JSON"
echo "   kompose convert -j"
echo ""
echo "   # Generate Helm chart"
echo "   kompose convert -c"
echo ""
echo "   # Specify output directory"
echo "   kompose convert -o ./k8s-manifests/"
echo ""
echo "💡 Deployment options:"
echo "   # Convert and deploy directly to Kubernetes"
echo "   kompose up"
echo ""
echo "   # Remove deployed resources"
echo "   kompose down"
echo ""
echo "💡 Controller types:"
echo "   # Generate Deployment (default)"
echo "   kompose convert --controller deployment"
echo ""
echo "   # Generate DaemonSet"
echo "   kompose convert --controller daemonset"
echo ""
echo "   # Generate ReplicationController"
echo "   kompose convert --controller replicationcontroller"
echo ""
echo "💡 Example workflow:"
echo "   # 1. Navigate to your docker-compose project"
echo "   cd my-project/"
echo ""
echo "   # 2. Convert docker-compose.yml"
echo "   kompose convert"
echo ""
echo "   # 3. Review generated files"
echo "   ls *.yaml"
echo ""
echo "   # 4. Apply to Kubernetes cluster"
echo "   kubectl apply -f ."
echo ""
echo "💡 Supported docker-compose keys:"
echo "   - image, build, command, entrypoint"
echo "   - ports, expose, environment, env_file"
echo "   - volumes, networks, depends_on"
echo "   - deploy (replicas, resources, restart_policy)"
echo "   - labels (for Kompose-specific options)"
echo ""
echo "💡 Kompose labels (in docker-compose.yml):"
echo "   labels:"
echo "     kompose.service.type: LoadBalancer"
echo "     kompose.service.expose: 'true'"
echo "     kompose.volume.size: 1Gi"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://kompose.io/"
echo "   - Documentation: https://kompose.io/docs/"
echo "   - GitHub: https://github.com/kubernetes/kompose"


