#!/usr/bin/env fish
# Start an agent in a new Herdr workspace without focusing that workspace.
# Usage: start-agent-hidden.fish [kind] [name] [cwd] [agent arguments...]

set -l kind
if test (count $argv) -gt 0
    set kind (string lower -- "$argv[1]")
else if command -q opencode
    set kind opencode
else if command -q claude
    set kind claude
else if command -q codex
    set kind codex
else
    echo "No supported agent CLI found. Pass an agent kind explicitly."
    exit 1
end

set -l name "$kind"
if test (count $argv) -gt 1
    set name (string lower -- "$argv[2]")
end
set name (string replace -ar '[^a-z0-9_-]' '-' -- "$name")
if test -z "$name"
    echo "Agent name cannot be empty."
    exit 1
end

set -l cwd "$PWD"
if test (count $argv) -gt 2
    set cwd "$argv[3]"
end
if not test -d "$cwd"
    echo "Working directory does not exist: $cwd"
    exit 1
end

set -l workspace_json (herdr workspace create --cwd "$cwd" --label "$name" --no-focus 2>&1)
if test $status -ne 0
    echo "$workspace_json"
    exit 1
end

set -l pane_id (printf '%s\n' "$workspace_json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
print(data["result"]["root_pane"]["pane_id"])
')
if test $status -ne 0 -o -z "$pane_id"
    echo "Could not determine the new Herdr pane."
    exit 1
end

set -l agent_args
if test (count $argv) -gt 3
    set agent_args $argv[4..-1]
end

set -l start_output
set -l start_status
if test (count $agent_args) -gt 0
    set start_output (herdr agent start "$name" --kind "$kind" --pane "$pane_id" --timeout 30000 -- $agent_args 2>&1)
    set start_status $status
else
    set start_output (herdr agent start "$name" --kind "$kind" --pane "$pane_id" --timeout 30000 2>&1)
    set start_status $status
end
if test $start_status -ne 0
    echo "$start_output"
    exit 1
end

echo "Started $kind agent '$name' in background workspace $pane_id."
