#!/usr/bin/env fish
# === omniroute.fish ===
# Purpose: Install or update OmniRoute (self-hosted AI gateway) via npm and Mise on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting OmniRoute setup via Mise..."

# npm 11+ may block lifecycle scripts; OmniRoute's postinstall prepares its native runtime.
# Package list from the OmniRoute README; if npm warns about others, add them here.
set -l npm_allow_scripts "omniroute,keytar,onnxruntime-node,@parcel/watcher,@swc/core,protobufjs,esbuild"

# === 1. Require a supported Node.js via Mise ===
# The repository's .tool-versions must not pick the Node: use the global one.
cd "$HOME"; or exit 1

if not command -q mise
    echo "❌ Mise is not installed. Run ./mise.fish first, then rerun ./omniroute.fish."
    exit 1
end

# mise first on PATH, so a leftover pacman /usr/bin/node cannot shadow it.
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source
if not mise which node >/dev/null 2>&1
    echo "❌ Node.js via Mise not found. Run ./nodejs.fish first, then rerun ./omniroute.fish."
    exit 1
end

set -l node_version (mise exec -- node --version 2>/dev/null | string trim)
if not string match -qr '^v\d+\.\d+\.\d+' -- "$node_version"
    echo "❌ Could not determine the Node.js version: $node_version"
    exit 1
end
set -l node_parts (string replace -r '^v' '' -- $node_version | string split '.')
set -l patch (string match -r '^\d+' -- $node_parts[3])
set -l node_ok
if test $node_parts[1] -ge 24 -a $node_parts[1] -le 26
    set node_ok yes
else if test $node_parts[1] -eq 22
    if test $node_parts[2] -gt 22; or test $node_parts[2] -eq 22 -a $patch -ge 2
        set node_ok yes
    end
end
if test -z "$node_ok"
    echo "❌ OmniRoute needs Node.js 22.22.2+ (22.x) or 24-26 (mise use -g node@24). Found: $node_version"
    exit 1
end
echo "✅ Node.js: $node_version"

# === 2. Install or update OmniRoute ===
set -l npm_args install -g --no-fund --no-audit
set -l npm_major (mise exec -- npm --version 2>/dev/null | string match -r '^\d+')
if test -z "$npm_major"
    echo "❌ npm is not available through Node.js. Run ./nodejs.fish first, then rerun ./omniroute.fish."
    exit 1
end
if test $npm_major -ge 11
    echo "💡 npm $npm_major detected: allowing OmniRoute's install scripts: $npm_allow_scripts"
    set -a npm_args --allow-scripts=$npm_allow_scripts
end

set -l npm_log (mktemp -t omniroute-npm-install.XXXXXX)
if test $status -ne 0
    echo "❌ Failed to create the npm log file. Rerun: ./omniroute.fish"
    exit 1
end
echo "⏳ Downloading and building OmniRoute; this can take several minutes."
echo "   Full npm log: $npm_log"
mise exec -- npm $npm_args omniroute@latest >$npm_log 2>&1
if test $status -ne 0
    echo "❌ OmniRoute install/update failed. Last lines of the log:"
    tail -n 30 $npm_log
    echo "💡 Rerun: ./omniroute.fish"
    exit 1
end
grep -E '^(added|changed|removed|up to date)' $npm_log | tail -n 1

# Peer-dependency and deprecation warnings stay in the log; blocked install scripts are shown.
# fsevents is macOS-only.
set -l blocked (string match -r '^npm warn install-scripts +[^ ]+@.*' <$npm_log | string match -v '*fsevents@*')
if test (count $blocked) -gt 0
    echo "⚠️  npm skipped install scripts for packages not in npm_allow_scripts:"
    printf '   %s\n' $blocked
    echo "   If OmniRoute misbehaves, add them to npm_allow_scripts in omniroute.fish and rerun."
end
mise reshim

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
mise exec -- omniroute --version
if test $status -ne 0
    echo "❌ OmniRoute installation verification failed."
    exit 1
end

echo
echo "✅ OmniRoute setup complete!"
echo "💡 First run:  omniroute setup            (admin password and first provider)"
echo "💡 Start:      omniroute                  (dashboard: http://localhost:20128)"
echo "💡 Background: omniroute serve --daemon --no-open   (status, stop, restart, logs --follow)"
echo "💡 After an update, restart a running server: omniroute restart"
echo "💡 API: http://localhost:20128/v1, model auto; check with: omniroute doctor"
echo "💡 Keep API keys out of the shell history: use the dashboard or the wizard."
echo "🔐 Data: ~/.omniroute/ (back up its .env together with storage.sqlite)."
