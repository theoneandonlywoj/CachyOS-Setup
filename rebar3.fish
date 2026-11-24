#!/usr/bin/env fish
# === rebar3.fish ===
# Purpose: Install rebar3 (Erlang build tool) via Mise on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting rebar3 setup via Mise..."

# === 1. Check prerequisites ===
# The repository's .tool-versions must not decide which tools mise activates.
cd "$HOME"; or exit 1

if not command -q mise
    echo "❌ Mise is not installed. Run ./mise.fish first, then rerun ./rebar3.fish."
    exit 1
end

if not mise which erl >/dev/null 2>&1; and not command -q erl
    echo "❌ Erlang is not installed. Run ./elixir_and_erlang.fish first, then rerun ./rebar3.fish."
    exit 1
end

# === 2. Install or update rebar3 ===
# mise, never pacman: the pacman package would bring in a second Erlang.
mise use -g rebar@latest; and mise upgrade rebar
if test $status -ne 0
    echo "❌ rebar3 install/update failed; an existing install is untouched. Rerun: ./rebar3.fish"
    exit 1
end

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
mise exec -- rebar3 --version
if test $status -ne 0
    echo "❌ rebar3 installation verification failed."
    exit 1
end

echo
echo "✅ rebar3 setup complete!"
echo "💡 First use: rebar3 new app my_app; rebar3 compile; rebar3 ct"
