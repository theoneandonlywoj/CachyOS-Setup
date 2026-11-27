#!/usr/bin/env fish
# === executor.fish ===
# Purpose: Install or update Executor (MCP gateway) via npm and Mise on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Executor setup via Mise..."

# === 1. Require Node.js 20+ via Mise ===
# The repository's .tool-versions must not pick the Node: use the global one.
cd "$HOME"; or exit 1

if not command -q mise
    echo "❌ Mise is not installed. Run ./mise.fish first, then rerun ./executor.fish."
    exit 1
end

# mise first on PATH, so a leftover pacman /usr/bin/node cannot shadow it.
set -x PATH ~/.local/share/mise/shims $PATH
mise activate fish | source
if not mise which node >/dev/null 2>&1
    echo "❌ Node.js via Mise not found. Run ./nodejs.fish first, then rerun ./executor.fish."
    exit 1
end

set -l node_version (mise exec -- node --version 2>/dev/null | string trim)
if not string match -qr '^v\d+\.\d+\.\d+' -- "$node_version"
    echo "❌ Could not determine the Node.js version: $node_version"
    exit 1
end
set -l node_parts (string replace -r '^v' '' -- $node_version | string split '.')
if test $node_parts[1] -lt 20
    echo "❌ Node.js 20+ required (mise use -g node@24). Found: $node_version"
    exit 1
end
echo "✅ Node.js: $node_version"

# === 2. Install or update Executor ===
mise exec -- npm install -g executor@latest
if test $status -ne 0
    echo "❌ Executor install/update failed. Rerun: ./executor.fish"
    exit 1
end
mise reshim

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
mise exec -- executor --version
if test $status -ne 0
    echo "❌ Executor installation verification failed."
    exit 1
end

# === 4. Optional agent wiring (terminal only, default N) ===
set -l executor_port 4788
if set -q EXECUTOR_PORT; and test -n "$EXECUTOR_PORT"
    set executor_port $EXECUTOR_PORT
end
set -l mcp_url "http://127.0.0.1:$executor_port/mcp"
set -l configured_agents
set -l warned_agents
set -l declined_agents
set -l skipped_agents

if test -t 0
    echo
    echo "Detecting installed coding-agent CLIs..."
    # Format: method|binary candidates|display name
    set -l agent_integrations \
        "claude|claude|Claude Code" \
        "codex|codex|OpenAI Codex CLI" \
        "gemini|gemini|Gemini CLI" \
        "add-mcp|cursor-agent cursor|Cursor" \
        "add-mcp|opencode|OpenCode"
    set -l add_mcp_pending

    for entry in $agent_integrations
        set -l fields (string split '|' "$entry")
        set -l method $fields[1]
        set -l agent_label $fields[3]
        set -l found_bin
        for bin in (string split ' ' -- "$fields[2]")
            if command -q "$bin"
                set found_bin "$bin"
                break
            end
        end

        if test -z "$found_bin"
            echo "  Skipped $agent_label (CLI not found)"
            set -a skipped_agents "$agent_label"
            continue
        end

        if test "$method" != add-mcp; and $found_bin mcp list 2>/dev/null | grep -qw executor
            echo "  $agent_label already has the Executor MCP server. Skipping."
            set -a configured_agents "$agent_label"
            continue
        end

        read -l -P "  $agent_label detected ($found_bin). Connect it to Executor? [y/N] " reply
        if test "$reply" != "y" -a "$reply" != "Y"
            set -a declined_agents "$agent_label"
            continue
        end

        switch $method
            case claude
                claude mcp add --transport http --scope user executor $mcp_url
            case codex
                codex mcp add executor -- executor mcp
            case gemini
                gemini mcp add --transport http executor $mcp_url
            case add-mcp
                set -a add_mcp_pending "$agent_label"
                continue
        end
        if test $status -eq 0
            set -a configured_agents "$agent_label"
        else
            set -a warned_agents "$agent_label"
        end
    end

    if test (count $add_mcp_pending) -gt 0
        # add-mcp detects the clients itself and writes the entry into each config.
        mise exec -- npx -y add-mcp $mcp_url --transport http --name executor
        if test $status -eq 0
            set -a configured_agents $add_mcp_pending
        else
            set -a warned_agents $add_mcp_pending
        end
    end

    echo
    echo "Agents connected:  "(string join ', ' -- $configured_agents)
    echo "Needs attention:   "(string join ', ' -- $warned_agents)
    echo "Declined by user:  "(string join ', ' -- $declined_agents)
    echo "Not installed:     "(string join ', ' -- $skipped_agents)
else
    echo "💡 No terminal: agent wiring skipped."
end

echo
echo "✅ Executor setup complete!"
echo "💡 Agents connected over HTTP need the local service. This script does not start it:"
echo "   executor install          # systemd user service, port 4788 by default"
echo "   executor daemon run       # or a background daemon without a service"
echo "   executor daemon status"
echo "💡 Web UI: executor web"
exit 0
