#!/usr/bin/env fish
# === lynx.fish ===
# Purpose: Set up Lynx (Lean proofs for Erlang/Elixir): elan, the pinned Lean toolchain and an optional Mix dependency
# Author: theoneandonlywoj
# Docs: https://github.com/josevalim/lynx
# Run it inside a Mix project to be offered the Lynx dependency.

echo "🚀 Starting Lynx setup..."

# === 1. Require Erlang and Elixir 1.18+ via Mise ===
# The check must not install what the current directory pins: auto-install stays off.
if not command -q mise
    or not mise which erl >/dev/null 2>&1
    or not mise which elixir >/dev/null 2>&1
    or not MISE_EXEC_AUTO_INSTALL=false mise exec -- elixir -e 'System.halt(if Version.match?(System.version(), ">= 1.18.0"), do: 0, else: 1)' >/dev/null 2>&1
    echo "❌ Erlang and Elixir 1.18+ via Mise are not active here. Run ./elixir_and_erlang.fish first, then rerun ./lynx.fish."
    exit 1
end
echo "✅ Erlang and Elixir 1.18+ found."

# === 2. Install or update elan (Lean toolchain manager) ===
# Never look for the name of this script on PATH: /usr/bin has a text browser called that.
# Download first, then run: piping curl into bash reports bash's exit status, which is 0 on an empty download.
# Extra arguments go to the installer: run_installer <url> -y
function run_installer --argument-names url
    set -l f (mktemp); or return 1
    curl -fsSL -o $f $url; and bash $f $argv[2..-1]
    set -l st $status
    rm -f $f
    return $st
end

set -l elan "$HOME/.elan/bin/elan"
command -q elan; and set elan (command -s elan)

if not test -x "$elan"
    echo "📦 Installing elan..."
    run_installer https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -y --no-modify-path
else if pacman -Qo "$elan" >/dev/null 2>&1
    echo "✅ elan is owned by pacman; upgrades come from 'paru -Syu'."
else
    echo "🔄 Updating elan in place..."
    "$elan" self update
end
if test $status -ne 0
    echo "❌ elan install/update failed; an existing install is untouched. Rerun: ./lynx.fish"
    exit 1
end

if test -d "$HOME/.elan/bin"; and not contains -- "$HOME/.elan/bin" $PATH
    # fish_add_path returns 1 when the directory is already present; it is not, so 1 is a failure.
    fish_add_path -U "$HOME/.elan/bin"
    if test $status -ne 0
        echo "❌ Failed to add ~/.elan/bin to the Fish PATH."
        exit 1
    end
end

"$elan" --version
if test $status -ne 0
    echo "❌ elan verification failed."
    exit 1
end

# === 3. Install the Lean toolchain Lynx pins ===
set -l toolchain (curl -fsSL --max-time 15 https://raw.githubusercontent.com/josevalim/lynx/main/lean-toolchain 2>/dev/null | string trim)[1]
if not string match -qr '^leanprover/lean4:\S+$' -- "$toolchain"
    set toolchain leanprover/lean4:v4.33.1
    echo "⚠ Could not read the Lynx pin; using the fallback $toolchain."
end

# elan refuses to install a toolchain that is already there.
set -l installed ("$elan" toolchain list 2>/dev/null | string replace -r '\s.*$' '')
if contains -- "$toolchain" $installed
    echo "✅ $toolchain is already installed."
else
    echo "📦 Installing $toolchain (several hundred MB)..."
    "$elan" toolchain install $toolchain
    if test $status -ne 0
        echo "❌ Failed to install $toolchain. Rerun: ./lynx.fish"
        exit 1
    end
end

# === 4. Offer the Lynx dependency to the Mix project in this directory ===
set -l dep '{:lynx, git: "https://github.com/josevalim/lynx.git", only: :test}'

if test -f mix.exs; and test -t 0
    set -l has_dep no
    if grep -q ':lynx' mix.exs
        echo "✅ mix.exs already lists Lynx."
        set has_dep yes
    else if grep -q apps_path mix.exs
        echo "⚠ This is an umbrella root; mix.exs is unchanged. Add this line in the app that needs it:"
        echo "   $dep"
    else
        read -P "Add Lynx as a test-only dependency to $PWD/mix.exs? [y/N] " add_dep
        if test "$add_dep" = y -o "$add_dep" = Y
            # Build the new file beside mix.exs and swap it in, so an interrupted run leaves the old file.
            # cp -p first: the new file keeps the permissions of the old one.
            set -l new mix.exs.lynx_tmp
            cp -p mix.exs $new; or exit 1
            awk -v dep="$dep" '
                /^[[:space:]]*defp?[[:space:]]+deps[[:space:]]+do[[:space:]]*$/ { in_deps = 1; print; next }
                in_deps && /^[[:space:]]*\[[[:space:]]*$/ {
                    print
                    match($0, /^[[:space:]]*/)
                    printf "%s  %s,\n", substr($0, 1, RLENGTH), dep
                    in_deps = 0; inserted = 1; next
                }
                in_deps && !/^[[:space:]]*(#.*)?$/ { in_deps = 0 }
                { print }
                END { exit inserted ? 0 : 1 }
            ' mix.exs >$new
            if test $status -ne 0
                rm -f $new
                echo "⚠ No multi-line 'defp deps do [' block found; mix.exs is unchanged. Add this line yourself:"
                echo "   $dep"
            else
                set -l backup mix.exs.backup_(date +%Y%m%d_%H%M%S)
                cp -p mix.exs $backup; and mv $new mix.exs
                if test $status -ne 0
                    rm -f $new
                    echo "❌ Failed to update mix.exs; it is unchanged."
                    exit 1
                end
                echo "✅ Added Lynx to mix.exs (backup: $backup)."
                set has_dep yes
            end
        end
    end

    if test $has_dep = yes
        mise exec -- mix local.hex --force --if-missing; and mise exec -- mix deps.get
        if test $status -ne 0
            echo "❌ Fetching dependencies failed. Rerun ./lynx.fish in this directory."
            exit 1
        end
    end
end

echo
echo "✅ Lynx setup complete!"
echo "💡 Lake uses the toolchain elan selects in a directory. To pin it for a project:"
echo "   echo '$toolchain' > lean-toolchain"
echo "💡 Verify laws: mix test --only laws"
echo "💡 Guide:       MIX_ENV=test mix help Lynx"
