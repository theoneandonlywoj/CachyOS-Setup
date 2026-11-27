#!/usr/bin/env fish
# === fwup.fish ===
# Purpose: Install fwup (firmware update tool) from source on CachyOS (Arch Linux)
# Includes: clone, build, verification
# Author: theoneandonlywoj

echo "🔧 Starting fwup installation from source..."

# === 1. Install build dependencies ===
echo "📦 Installing build dependencies..."
sudo pacman -S --needed --noconfirm git rust autoconf automake libtool pkg-config
if test $status -ne 0
    echo "❌ Failed to install build dependencies. Aborting."
    exit 1
end

# === 2. Clone or update the fwup repository ===
if test -e ~/fwup
    set origin_url (git -C ~/fwup remote get-url origin 2>/dev/null | string replace -r '\.git$' '')
    if not test -d ~/fwup/.git; or test "$origin_url" != "https://github.com/fwup-home/fwup"
        echo "❌ ~/fwup is not a checkout of https://github.com/fwup-home/fwup; it was not touched."
        echo "💡 Move it aside, then rerun: ./fwup.fish"
        exit 1
    end
    # Tracked files only: build output must not block a rerun.
    set checkout_changes (git -C ~/fwup status --short --untracked-files=no)
    if test $status -ne 0; or test (count $checkout_changes) -gt 0
        echo "❌ ~/fwup has local changes; it was not touched:"
        printf '   %s\n' $checkout_changes
        exit 1
    end
    echo "🔄 Updating fwup repository..."
    git -C ~/fwup pull --ff-only
else
    echo "📥 Cloning fwup repository..."
    git clone https://github.com/fwup-home/fwup ~/fwup
end
if test $status -ne 0
    echo "❌ Failed to fetch fwup; the installed fwup is untouched. Rerun: ./fwup.fish"
    exit 1
end

# === 3. Build fwup ===
echo "🔨 Building fwup (this may take a few minutes)..."
cd ~/fwup
and ./autogen.sh
and ./configure
and make
if test $status -ne 0
    echo "❌ Build failed; the installed fwup is untouched. Rerun: ./fwup.fish"
    exit 1
end

# === 4. Install fwup ===
echo "📦 Installing fwup..."
sudo make install
if test $status -ne 0
    echo "❌ Installation failed. Aborting."
    exit 1
end

# === 5. Verify installation ===
echo "✅ Verifying fwup installation..."
fwup --version
if test $status -ne 0
    echo "❌ fwup verification failed. Please install manually."
    exit 1
end

echo
echo "🚀 fwup installed successfully!"
echo "📖 Usage: fwup --help"
