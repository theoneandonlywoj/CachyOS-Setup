#!/usr/bin/env fish
# =====================================================================
# 🖊️  Xournal++ Installation Script (with PDF Support)
# For: CachyOS / Arch Linux
# =====================================================================
# This script installs Xournal++ and all dependencies needed
# for full PDF annotation support (via Poppler).
# =====================================================================

echo "🚀 Starting Xournal++ installation (with PDF support)..."

# --- Ensure running on Arch/CachyOS ---
if not test -f /etc/arch-release
    echo "❌ This script is designed for Arch-based systems like CachyOS."
    exit 1
end

# --- Update package database ---
echo "📦 Updating package database..."
sudo pacman -Sy --noconfirm

# --- Install dependencies and Xournal++ ---
echo "📥 Installing Xournal++ and PDF libraries..."
sudo pacman -S --noconfirm --needed \
    xournalpp \
    poppler-glib \
    poppler-data \
    gtk3 \
    libsndfile \
    hicolor-icon-theme

# --- Verify installation ---
echo "🧪 Verifying installation..."
if command -v xournalpp >/dev/null
    echo "✅ Xournal++ installed successfully!"
else
    echo "❌ Installation failed. Please check for errors."
    exit 1
end

# --- Check PDF support via Poppler ---
echo "🔍 Checking Poppler library for PDF support..."
if pacman -Q poppler-glib >/dev/null
    echo "✅ Poppler (PDF rendering) is installed and ready!"
else
    echo "❌ Poppler missing — PDF annotation may not work properly."
    echo "   Try manually installing it: sudo pacman -S poppler-glib"
end

# --- Done ---
echo "🎉 Installation complete!"
echo "You can now run Xournal++ with:"
echo "    xournalpp"
