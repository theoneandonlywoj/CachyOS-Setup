#!/usr/bin/env fish
# === container_tui.fish ===
# Purpose: Install container TUIs (lazydocker and ctop) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting container TUI installation..."

# === 1. Install lazydocker and ctop ===
for pkg in lazydocker ctop
    sudo pacman -S --needed --noconfirm $pkg
    if test $status -ne 0
        echo "❌ Failed to install $pkg. Rerun: ./container_tui.fish"
        exit 1
    end
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."
for bin in lazydocker ctop
    if not command -q $bin
        echo "❌ Installation verification failed: $bin is not on PATH."
        exit 1
    end
end
lazydocker --version
ctop -v

echo
echo "✅ Container TUI setup complete!"
echo "💡 To use them with Podman (./podman.fish), point DOCKER_HOST at its socket:"
echo "   set -Ux DOCKER_HOST unix://\$XDG_RUNTIME_DIR/podman/podman.sock"
echo "💡 Run: lazydocker, or ctop"
