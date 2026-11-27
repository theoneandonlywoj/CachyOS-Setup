#!/usr/bin/env fish
# === observer_cli.fish ===
# Purpose: Print observer_cli (terminal BEAM observer) project setup/update instructions
# Author: theoneandonlywoj

echo "🔍 Observer CLI project guidance (installs nothing)..."

# === 1. Instructions ===
echo "💡 Prerequisites: Mise-managed Elixir (./elixir_and_erlang.fish) and a running BEAM node."
echo "💡 Setup: add this to the deps in mix.exs, then run: mix deps.get"
echo '   {:observer_cli, "~> 1.8", only: [:dev]}'
echo "💡 Update: mix deps.update observer_cli"
echo "💡 Verify: mix run -e ':observer_cli.start()'"
echo "💡 Use: in an IEx/Phoenix/Nerves session, run :observer_cli.start()"
echo "💡 Recovery: inspect mix.exs/mix.lock; no global archive is installed."
