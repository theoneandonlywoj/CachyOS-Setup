#!/usr/bin/env fish
# === bend.fish ===
# Purpose: Install Bend via the official installer on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Bend installation..."

# === 1. Install or update Bend ===
# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

run_installer https://bend-lang.com/install.sh
if test $status -ne 0
    echo "❌ Bend install/update failed. Rerun: ./bend.fish"
    exit 1
end

# === 2. Ensure the installer's target is in PATH ===
set -l bend_home "$HOME/.bend"
test -n "$BEND_HOME"; and set bend_home "$BEND_HOME"

# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if not contains -- "$bend_home/bin" $PATH
    fish_add_path -U "$bend_home/bin"
    if test $status -ne 0
        echo "❌ Failed to add $bend_home/bin to the Fish PATH."
        exit 1
    end
end

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
"$bend_home/bin/bend" version
if test $status -ne 0
    echo "❌ Bend installation verification failed."
    exit 1
end

echo
echo "✅ Bend setup complete!"
echo "💡 Built-in guide:   bend guide"
echo "💡 Run a program:    bend hello.bend"
echo "💡 Check only:       bend hello.bend --check-only"
echo "💡 Building binaries needs clang 19+."
echo "💡 Guide: docs/guide_bend.md"
