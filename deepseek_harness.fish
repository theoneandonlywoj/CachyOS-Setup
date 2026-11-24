#!/usr/bin/env fish
# === deepseek_harness.fish ===
# Purpose: Install DeepSeek Harness (dsh) from source on CachyOS
# Source: https://github.com/deepseek-ai/deepseek-harness
# Author: theoneandonlywoj

set -l DSH_REPO_URL "https://github.com/deepseek-ai/deepseek-harness.git"
set -l DSH_BRANCH "master"
set -l DSH_SOURCE_DIR "$HOME/.local/share/deepseek-harness"
set -l DSH_BIN_DIR "$HOME/.local/bin"
set -l DSH_LAUNCHER "$DSH_BIN_DIR/dsh"

echo "🚀 Starting DeepSeek Harness installation from source..."
echo "💡 DeepSeek Harness (dsh) is an open-source agent harness where everything is a plugin."
echo "   - Developer preview with compatibility-breaking changes"
echo "   - Web UI served at http://127.0.0.1:3080 by default"
echo "   - Source checkout: $DSH_SOURCE_DIR"
echo "   - Launcher: $DSH_LAUNCHER"
echo

# === 1. Check Node.js, npm and Git ===
# The repository's .tool-versions must not pick the Node: use the global one.
cd "$HOME"; or exit 1

# mise first on PATH, so a leftover pacman /usr/bin/node cannot shadow it.
set -x PATH ~/.local/share/mise/shims $PATH
if not command -q mise; or not mise which node >/dev/null 2>&1
    echo "❌ Node.js via Mise not found. Run ./nodejs.fish first."
    exit 1
end
mise activate fish | source

set -l node_version (mise exec -- node --version 2>/dev/null | string trim)
set -l node_version_parts (string replace -r '^v' '' -- $node_version | string split '.')
set -l node_major $node_version_parts[1]
set -l node_minor $node_version_parts[2]

if test -z "$node_major"; or not string match -qr '^[0-9]+$' -- $node_major
    echo "❌ Could not determine the Node.js version: $node_version"
    exit 1
end

if test "$node_major" -lt 24; or test "$node_major" -eq 24 -a "$node_minor" -lt 9
    echo "❌ Node.js 24.9+ required (mise use -g node@24). Found: $node_version"
    exit 1
end
echo "✅ Node.js version: $node_version"

if not command -q git
    echo "📦 Installing git..."
    sudo pacman -S --needed --noconfirm git
    if test $status -ne 0
        echo "❌ Failed to install git. Rerun: ./deepseek_harness.fish"
        exit 1
    end
end
set -l git_version (git --version | string match -r '[0-9]+\.[0-9]+' | string split '.')
if test (count $git_version) -ne 2; or test "$git_version[1]" -lt 2; or test "$git_version[1]" -eq 2 -a "$git_version[2]" -lt 26
    echo "❌ Git 2.26+ is required. Found: "(git --version)
    exit 1
end
echo "✅ "(git --version)
echo

# Reads package.json on stdin; fails when this Node does not satisfy engines.node.
function check_engines
    mise exec -- node -e '
        const path = require("node:path")
        let range, ok
        try {
            const semver = require(path.join(path.dirname(process.execPath), "../lib/node_modules/npm/node_modules/semver"))
            const pkg = JSON.parse(require("node:fs").readFileSync(0, "utf8"))
            if (!pkg || typeof pkg !== "object" || Array.isArray(pkg)) throw new Error("not a JSON object")
            range = pkg.engines?.node
            ok = !range || semver.satisfies(process.version, range)
        } catch (e) {
            console.error("❌ Could not read the upstream engines.node (network or parse failure): " + e.message)
            process.exit(2)
        }
        if (!ok) {
            console.error("❌ DeepSeek Harness needs Node.js " + range + ". Found: " + process.version + ". Run ./nodejs.fish")
            process.exit(1)
        }
    '
end

# === 2. Check an existing source installation ===
set -l existing_checkout false
if test -d "$DSH_SOURCE_DIR/.git"
    set existing_checkout true
    echo "✅ Existing DeepSeek Harness source checkout detected."

    set -l origin_url (git -C "$DSH_SOURCE_DIR" remote get-url origin 2>/dev/null)
    set -l normalized_origin (string replace -r '\.git$' '' -- "$origin_url")
    if test $status -ne 0; or test "$normalized_origin" != "https://github.com/deepseek-ai/deepseek-harness" -a "$normalized_origin" != "git@github.com:deepseek-ai/deepseek-harness" -a "$normalized_origin" != "ssh://git@github.com/deepseek-ai/deepseek-harness"
        echo "❌ The checkout at $DSH_SOURCE_DIR does not point to DeepSeek Harness."
        echo "   Origin: $origin_url"
        echo "💡 Move it aside or choose another installation location before re-running."
        exit 1
    end

    set -l checkout_changes (git -C "$DSH_SOURCE_DIR" status --short 2>&1)
    if test $status -ne 0; or test (count $checkout_changes) -gt 0
        echo "❌ The source checkout has local changes; it was not touched:"
        echo "   git -C $DSH_SOURCE_DIR status --short"
        printf '   %s\n' $checkout_changes
        echo "💡 Commit or discard them, then rerun: ./deepseek_harness.fish"
        exit 1
    end

    echo "🔍 Fetching the latest upstream version information..."
    git -C "$DSH_SOURCE_DIR" fetch --tags origin $DSH_BRANCH
    if test $status -ne 0
        echo "❌ Failed to fetch upstream changes. The checkout is unchanged. Rerun: ./deepseek_harness.fish"
        exit 1
    end

    set -l fetched (git -C "$DSH_SOURCE_DIR" rev-parse FETCH_HEAD)
    or begin; echo "❌ Could not resolve the fetched commit. The checkout is unchanged. Rerun: ./deepseek_harness.fish"; exit 1; end
    git -C "$DSH_SOURCE_DIR" show "$fetched:package.json" | check_engines
    if test $status -ne 0
        echo "💡 The checkout is unchanged. Rerun: ./deepseek_harness.fish"
        exit 1
    end

    set -l local_version (git -C "$DSH_SOURCE_DIR" show HEAD:package.json 2>/dev/null | node -e 'let data = ""; process.stdin.on("data", chunk => data += chunk).on("end", () => { try { console.log(JSON.parse(data).version ?? "unknown") } catch { console.log("unknown") } })')
    set -l upstream_version (git -C "$DSH_SOURCE_DIR" show "origin/$DSH_BRANCH:package.json" 2>/dev/null | node -e 'let data = ""; process.stdin.on("data", chunk => data += chunk).on("end", () => { try { console.log(JSON.parse(data).version ?? "unknown") } catch { console.log("unknown") } })')
    set -l local_commit (git -C "$DSH_SOURCE_DIR" rev-parse --short HEAD 2>/dev/null)
    set -l upstream_commit (git -C "$DSH_SOURCE_DIR" rev-parse --short "origin/$DSH_BRANCH" 2>/dev/null)

    echo "📊 Version comparison:"
    echo "   Installed source: $local_version"
    echo "   Upstream source:  $upstream_version"
    if test "$local_version" = "$upstream_version"
        echo "   Result: package versions match"
    else
        echo "   Result: package versions differ"
    end
    echo "📊 Commit comparison:"
    echo "   Installed commit: $local_commit"
    echo "   Upstream commit:  $upstream_commit"
    if test "$local_commit" = "$upstream_commit"
        echo "   Result: checkout is up to date"
    else
        echo "   Result: upstream changes are available"
    end

    echo "🔄 Updating the source checkout..."
    git -C "$DSH_SOURCE_DIR" merge --ff-only $fetched
    if test $status -ne 0
        echo "❌ Could not fast-forward the checkout."
        echo "💡 Resolve the repository state manually, then rerun: ./deepseek_harness.fish"
        exit 1
    end
else if test -e "$DSH_SOURCE_DIR"
    echo "❌ The install path exists but is not a Git checkout: $DSH_SOURCE_DIR"
    echo "💡 Move it aside and re-run this script. It will not remove existing files."
    exit 1
end

# === 3. Clone the source repository when needed ===
if not $existing_checkout
    curl -fsSL https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/$DSH_BRANCH/package.json | check_engines
    if test $status -ne 0
        echo "💡 Nothing was cloned. Rerun: ./deepseek_harness.fish"
        exit 1
    end
    echo "📥 Cloning DeepSeek Harness from source..."
    mkdir -p (path dirname "$DSH_SOURCE_DIR")
    git clone --branch $DSH_BRANCH --single-branch "$DSH_REPO_URL" "$DSH_SOURCE_DIR"
    if test $status -ne 0
        echo "❌ Failed to clone DeepSeek Harness. Rerun: ./deepseek_harness.fish"
        exit 1
    end
end

# === 4. Install dependencies and build ===
echo "📦 Installing DeepSeek Harness dependencies..."
cd "$DSH_SOURCE_DIR"
if test $status -ne 0
    echo "❌ Failed to enter the DeepSeek Harness source checkout."
    exit 1
end

# Use the pnpm version pinned by DeepSeek Harness.
set -l pnpm_required (node -e '
    const pm = JSON.parse(require("node:fs").readFileSync("package.json", "utf8")).packageManager
    if (typeof pm !== "string" || !pm.startsWith("pnpm@")) process.exit(1)
    process.stdout.write(pm.slice("pnpm@".length).split("+")[0])
')
if test -z "$pnpm_required"
    echo "❌ Could not determine the required pnpm version from package.json."
    exit 1
end

set -l pnpm_command
if mise exec -- corepack prepare "pnpm@$pnpm_required" --activate
    set pnpm_command mise exec -- corepack pnpm
else
    echo "⚠ Corepack unavailable; installing pnpm@$pnpm_required via npm..."
    mise exec -- npm install -g "pnpm@$pnpm_required"
    if test $status -ne 0
        echo "❌ Failed to install pnpm $pnpm_required. Rerun: ./deepseek_harness.fish. If a corepack pnpm link is in the way, run: mise exec -- corepack disable pnpm"
        exit 1
    end
    set pnpm_command mise exec -- pnpm
end
mise reshim

set -l pnpm_version ($pnpm_command --version 2>/dev/null)
if test "$pnpm_version" != "$pnpm_required"
    echo "❌ pnpm $pnpm_required is required, but found: $pnpm_version"
    exit 1
end
echo "✅ pnpm version: $pnpm_version"

$pnpm_command install
if test $status -ne 0
    echo "❌ Dependency installation failed. Rerun: ./deepseek_harness.fish"
    exit 1
end

echo "🔨 Building DeepSeek Harness..."
$pnpm_command run build
if test $status -ne 0
    echo "❌ DeepSeek Harness build failed. Rerun: ./deepseek_harness.fish"
    exit 1
end

# === 5. Create the dsh launcher ===
echo "🔗 Installing the dsh launcher to $DSH_LAUNCHER..."
mkdir -p "$DSH_BIN_DIR"
if test $status -ne 0
    echo "❌ Failed to create $DSH_BIN_DIR."
    exit 1
end

begin
    printf '%s\n' '#!/usr/bin/env sh' 'DSH_SOURCE_DIR="${DSH_SOURCE_DIR:-$HOME/.local/share/deepseek-harness}"' 'if [ ! -d "$DSH_SOURCE_DIR" ]; then' '    printf "%s\\n" "DeepSeek Harness source checkout not found: $DSH_SOURCE_DIR" >&2' '    exit 1' 'fi' 'cd "$DSH_SOURCE_DIR" || exit 1'
    printf 'exec %s dsh "$@"\n' "$pnpm_command"
end > "$DSH_LAUNCHER"
chmod +x "$DSH_LAUNCHER"
if test $status -ne 0
    echo "❌ Failed to create the dsh launcher."
    exit 1
end

# === 6. Add the launcher directory to Fish PATH ===
# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if not contains -- "$DSH_BIN_DIR" $PATH
    fish_add_path -U "$DSH_BIN_DIR"
    if test $status -ne 0
        echo "❌ Failed to add $DSH_BIN_DIR to the Fish PATH."
        exit 1
    end
end

# === 7. Verify the installation ===
echo
echo "🧪 Verifying DeepSeek Harness installation..."
set -l installed_version ("$DSH_LAUNCHER" --version 2>/dev/null)
if test $status -eq 0
    echo "✅ DeepSeek Harness installed successfully: $installed_version"
    echo "📌 Installation path: $DSH_SOURCE_DIR"
    echo "📌 Launcher path: $DSH_LAUNCHER"
else
    echo "❌ DeepSeek Harness verification failed."
    echo "💡 Try opening a new terminal and running: $DSH_LAUNCHER --version"
    exit 1
end

echo
echo "🎉 DeepSeek Harness installation complete!"
echo
echo "💡 Getting started:"
echo "   dsh web                         # Start the Web UI"
echo "   dsh --help                      # Show launcher help"
echo "   dsh web --help                 # Show Web UI options"
echo "   Web UI: http://127.0.0.1:3080"
echo "   Configure a model in Settings → Models, then choose a workspace."
echo
echo "💡 Add plugins from the command line:"
echo "   dsh plugin --profile web add <package-or-git-spec>"
echo "   dsh plugin --profile web update"
echo "   dsh plugin --profile web remove <package>"
echo "   dsh plugin --profile web why <package>"
echo "   A distributable plugin must declare a dsh.bundle configuration."
echo
echo "💡 Plugins from the Web UI:"
echo "   Settings → Plugins can configure already-loaded plugins and show the plugin inventory."
echo "   The current developer-preview GUI does not install plugins directly."
echo "   For a local development plugin, use:"
echo "   dsh web --patch /absolute/path/to/cordis.yml"
echo "   Documentation: https://github.com/deepseek-ai/deepseek-harness/tree/master/docs/user"
