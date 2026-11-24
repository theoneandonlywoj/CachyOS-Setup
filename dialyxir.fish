#!/usr/bin/env fish
# === dialyxir.fish ===
# Purpose: Print Dialyxir (Dialyzer wrapper) project setup/update instructions
# Author: theoneandonlywoj

echo "🔍 Dialyxir project guidance (installs nothing)..."

# === 1. Instructions ===
echo "💡 Prerequisites: Mise-managed Elixir (./elixir_and_erlang.fish) and a Mix project."
echo "💡 Setup: add this to the deps in mix.exs, then run: mix deps.get"
echo '   {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}'
echo "💡 Update: mix deps.update dialyxir"
echo "💡 Verify: mix dialyzer; mix dialyzer --format dialyxir"
echo "💡 Use: mix dialyzer"
echo "💡 Recovery: inspect mix.exs/mix.lock; no global archive is installed."
