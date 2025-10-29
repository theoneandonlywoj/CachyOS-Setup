#!/usr/bin/env fish

echo "🧰 Installing Hex and Rebar via Mix..."

# 1) Validate prerequisites
if not type -q elixir
  echo "❌ Elixir not found. Install via mise or pacman."
  exit 1
end
if not type -q mix
  echo "❌ mix not found on PATH. Ensure Elixir is correctly installed."
  exit 1
end

# 2) Ensure mix home exists
set -l MIX_HOME "$HOME/.mix"
mkdir -p $MIX_HOME

# 3) Install Hex
echo "📦 Installing Hex..."
mix local.hex --force
if test $status -ne 0
  echo "❌ Failed to install Hex"
  exit 1
end
echo "✅ Hex installed"

# 4) Install Rebar
echo "📦 Installing Rebar..."
mix local.rebar --force
if test $status -ne 0
  echo "❌ Failed to install Rebar"
  exit 1
end
echo "✅ Rebar installed"

echo "🚀 Hex and Rebar setup complete"


