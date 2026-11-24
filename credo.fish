#!/usr/bin/env fish
# === credo.fish ===
# Purpose: Print Credo (Elixir static-analysis linter) project setup/update instructions
# Author: theoneandonlywoj

echo "🔍 Credo project guidance (installs nothing)..."

# === 1. Instructions ===
echo "💡 Prerequisites: Mise-managed Elixir (./elixir_and_erlang.fish) and a Mix project."
echo "💡 Setup: add this to the deps in mix.exs, then run: mix deps.get"
echo '   {:credo, "~> 1.7", only: [:dev, :test], runtime: false}'
echo "💡 Update: mix deps.update credo"
echo "💡 Verify: mix credo; mix credo --strict"
echo "💡 Use: mix credo; mix credo --suggest; mix credo --format json"
echo "💡 Recovery: inspect mix.exs/mix.lock; no global archive is installed."
