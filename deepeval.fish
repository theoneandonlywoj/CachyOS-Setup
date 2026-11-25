#!/usr/bin/env fish
# === deepeval.fish ===
# Purpose: Install or update the DeepEval CLI via uv on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting DeepEval setup via uv..."

# === 1. Check prerequisites ===
if not command -q uv
    echo "❌ uv is not installed. Run ./python_and_uv.fish first, then rerun ./deepeval.fish."
    exit 1
end

set -l uv_tools (uv tool list 2>/dev/null)
if test $status -ne 0
    echo "❌ Could not list the uv tools. Rerun: ./deepeval.fish"
    exit 1
end
set -l uv_owned (string match -r '^deepeval ' -- $uv_tools)
if test -z "$uv_owned"; and command -q deepeval
    echo "❌ DeepEval is already installed by another owner: "(command -s deepeval)
    echo "💡 Update it there, or remove it first, then rerun: ./deepeval.fish"
    exit 1
end

# === 2. Ensure ~/.local/bin exists and is in PATH (uv tool bin dir) ===
mkdir -p "$HOME/.local/bin"
if test $status -ne 0
    echo "❌ Failed to create ~/.local/bin."
    exit 1
end

# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if not contains -- "$HOME/.local/bin" $PATH
    fish_add_path -U "$HOME/.local/bin"
    if test $status -ne 0
        echo "❌ Failed to add ~/.local/bin to the Fish PATH."
        exit 1
    end
end

# === 3. Install or update DeepEval ===
if test -n "$uv_owned"
    uv tool upgrade deepeval
else
    uv tool install deepeval
end
if test $status -ne 0
    echo "❌ DeepEval install/update failed. Rerun: ./deepeval.fish"
    exit 1
end

# === 4. Opt out of telemetry once ===
# Without it, deepeval also creates a .deepeval/ folder in the current directory.
if not set -qU DEEPEVAL_TELEMETRY_OPT_OUT
    set -Ux DEEPEVAL_TELEMETRY_OPT_OUT 1
end

# === 5. Verify installation ===
echo "🧪 Verifying installation..."
command -q deepeval; and deepeval --version
if test $status -ne 0
    echo "❌ DeepEval installation verification failed."
    exit 1
end

echo
echo "✅ DeepEval setup complete!"
echo "💡 In each project: uv add --dev deepeval; then uv run deepeval test run tests/"
echo "📚 Guide: docs/guide_deepeval.md"
