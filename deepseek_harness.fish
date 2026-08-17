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

# === 1. Check and install build dependencies ===
echo "🔍 Checking build dependencies..."
set -l missing_dependencies
for dependency in git node npm
    if not command -q $dependency
        set missing_dependencies $missing_dependencies $dependency
    end
end
if not command -q corepack; and not command -q pnpm
    set missing_dependencies $missing_dependencies pnpm
end

if test (count $missing_dependencies) -gt 0
    echo "📦 Installing missing dependencies: $missing_dependencies"
    if not command -q sudo
        echo "❌ sudo is required to install: $missing_dependencies"
        exit 1
    end
    sudo pacman -S --needed --noconfirm git nodejs npm pnpm
    if test $status -ne 0
        echo "❌ Failed to install build dependencies. Aborting."
        exit 1
    end
end

if not command -q git; or not command -q node
    echo "❌ Git and Node.js are required. Aborting."
    exit 1
end

set -l node_version (node --version 2>/dev/null | string trim)
set -l node_version_parts (string replace -r '^v' '' -- $node_version | string split '.')
set -l node_major $node_version_parts[1]
set -l node_minor $node_version_parts[2]

if test -z "$node_major"; or not string match -qr '^[0-9]+$' -- $node_major
    echo "❌ Could not determine the Node.js version: $node_version"
    exit 1
end

if test "$node_major" -lt 22; or test "$node_major" -eq 22 -a "$node_minor" -lt 19; or test "$node_major" -eq 23
    echo "❌ DeepSeek Harness requires Node.js 22.19+ or 24+. Found: $node_version"
    echo "💡 Update Node.js or select a compatible version with Mise before re-running."
    exit 1
end

echo "✅ Node.js version: $node_version"

# Prefer Corepack so pnpm follows the version pinned by DeepSeek Harness.
set -l pnpm_command
if command -q corepack
    corepack enable >/dev/null 2>&1
    set pnpm_command corepack pnpm
else if command -q pnpm
    set pnpm_command pnpm
else
    echo "❌ Corepack or pnpm is required to install DeepSeek Harness."
    echo "💡 Install Corepack with Node.js or install pnpm, then re-run this script."
    exit 1
end

set -l pnpm_version ($pnpm_command --version 2>/dev/null)
if test $status -ne 0 -o -z "$pnpm_version"
    echo "❌ Could not run pnpm through the selected package manager."
    exit 1
end
echo "✅ pnpm version: $pnpm_version"
echo

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

    echo "🔍 Fetching the latest upstream version information..."
    git -C "$DSH_SOURCE_DIR" fetch --tags origin $DSH_BRANCH
    if test $status -ne 0
        echo "❌ Failed to fetch upstream changes. Aborting without modifying the checkout."
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

    set -l checkout_changes (git -C "$DSH_SOURCE_DIR" status --porcelain 2>/dev/null | string collect)
    if test -n "$checkout_changes"
        echo "⚠ Local changes were found in the source checkout."
        echo "💡 The script will not overwrite them or reset the repository."
    end

    read -l -P "Do you want to update/reinstall DeepSeek Harness and rebuild it? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping DeepSeek Harness installation."
        exit 0
    end

    if test -z "$checkout_changes"
        echo "🔄 Updating the source checkout..."
        git -C "$DSH_SOURCE_DIR" merge --ff-only "origin/$DSH_BRANCH"
        if test $status -ne 0
            echo "❌ Could not update the checkout with a fast-forward merge."
            echo "💡 Resolve the repository state manually, then re-run this script."
            exit 1
        end
    else
        echo "ℹ Keeping the checkout at its current commit because it has local changes."
    end
else if test -e "$DSH_SOURCE_DIR"
    echo "❌ The install path exists but is not a Git checkout: $DSH_SOURCE_DIR"
    echo "💡 Move it aside and re-run this script. It will not remove existing files."
    exit 1
end

# === 3. Clone the source repository when needed ===
if not $existing_checkout
    echo "📥 Cloning DeepSeek Harness from source..."
    mkdir -p (path dirname "$DSH_SOURCE_DIR")
    git clone --branch $DSH_BRANCH --single-branch "$DSH_REPO_URL" "$DSH_SOURCE_DIR"
    if test $status -ne 0
        echo "❌ Failed to clone DeepSeek Harness. Aborting."
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
$pnpm_command install
if test $status -ne 0
    echo "❌ Dependency installation failed."
    exit 1
end

echo "🔨 Building DeepSeek Harness..."
$pnpm_command run build
if test $status -ne 0
    echo "❌ DeepSeek Harness build failed."
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
    if test (count $pnpm_command) -eq 2
        printf '%s\n' 'exec corepack pnpm dsh "$@"'
    else
        printf '%s\n' 'exec pnpm dsh "$@"'
    end
end > "$DSH_LAUNCHER"
chmod +x "$DSH_LAUNCHER"
if test $status -ne 0
    echo "❌ Failed to create the dsh launcher."
    exit 1
end

# === 6. Add the launcher directory to Fish PATH ===
if not contains "$DSH_BIN_DIR" $fish_user_paths
    set -U fish_user_paths "$DSH_BIN_DIR" $fish_user_paths
    echo "➕ Added $DSH_BIN_DIR to the Fish PATH."
end
set -gx PATH "$DSH_BIN_DIR" $PATH

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
