#!/usr/bin/env fish
# === herdr.fish ===
# Purpose: Install Herdr and configure it for Fish on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "Starting Herdr installation..."
echo

# Resolve the repository directory so the tracked configuration can be installed
# even when this script is launched from another working directory.
set -l script_path (status filename)
set -l repo_root (dirname (realpath "$script_path"))
set -l repo_config "$repo_root/.config/herdr/config.toml"
set -l repo_scripts "$repo_root/.config/herdr/scripts"
set -l config_dir "$HOME/.config/herdr"
set -l config_file "$config_dir/config.toml"

# === 1. Install dependencies ===
echo "Installing required dependencies (curl, git, python)..."
sudo pacman -S --needed --noconfirm curl git python
if test $status -ne 0
    echo "Failed to install dependencies. Aborting."
    exit 1
end

# === 2. Ensure the direct-install directory is available in Fish ===
mkdir -p "$HOME/.local/bin"
if test $status -ne 0
    echo "Failed to create ~/.local/bin."
    exit 1
end

# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if not contains -- "$HOME/.local/bin" $PATH
    fish_add_path -U "$HOME/.local/bin"
    if test $status -ne 0
        echo "Failed to add ~/.local/bin to the Fish PATH."
        exit 1
    end
end

# === 3. Install Herdr using the official Linux installer ===
if command -q herdr
    echo "Herdr is already installed: "(herdr --version 2>/dev/null | head -n 1)
    read -P "Run the official installer again? [y/N] " reinstall
    if test "$reinstall" = "y" -o "$reinstall" = "Y"
        echo "Updating Herdr..."
        curl -fsSL https://herdr.dev/install.sh | sh
        if test $status -ne 0
            echo "Herdr update failed. Aborting."
            exit 1
        end
    else
        echo "Skipping Herdr binary installation."
    end
else
    echo "Downloading and installing Herdr..."
    curl -fsSL https://herdr.dev/install.sh | sh
    if test $status -ne 0
        echo "Herdr installation failed. Aborting."
        exit 1
    end
end

# Refresh the command lookup after the installer changes ~/.local/bin.
if not contains -- "$HOME/.local/bin" $PATH
    fish_add_path "$HOME/.local/bin" >/dev/null 2>&1
end

# === 4. Install the custom configuration and Fish helper scripts ===
echo
echo "Installing Herdr configuration..."
mkdir -p "$config_dir/scripts"
if test $status -ne 0
    echo "Failed to create $config_dir/scripts. Aborting."
    exit 1
end

if test -f "$config_file"
    echo "Existing Herdr config found at $config_file. Preserving it."

    # Migrate the command path from the macOS configuration when this script is
    # run on a machine that already has the shared Herdr config installed.
    if grep -q "new-workspace-3-tabs.zsh" "$config_file"
        set -l backup_file "$config_file.backup_"(date +%Y%m%d%H%M%S)
        cp "$config_file" "$backup_file"
        sed -i 's#new-workspace-3-tabs.zsh#new-workspace-3-tabs.fish#g' "$config_file"
        echo "Migrated the workspace binding; backup saved to $backup_file"
    end
else if test -f "$repo_config"
    cp "$repo_config" "$config_file"
    if test $status -ne 0
        echo "Failed to install the custom Herdr config. Aborting."
        exit 1
    end
    echo "Custom Herdr config installed at $config_file"
else
    echo "Tracked Herdr config not found; generating the default config."
    herdr --default-config > "$config_file"
    if test $status -ne 0
        rm -f "$config_file"
        echo "Could not generate the Herdr config. Aborting."
        exit 1
    end
end

for helper in new-workspace-3-tabs.fish workspace-status.fish start-agent-hidden.fish
    set -l source_helper "$repo_scripts/$helper"
    set -l target_helper "$config_dir/scripts/$helper"
    if test -f "$target_helper"
        echo "Preserving existing helper: $target_helper"
    else if test -f "$source_helper"
        cp "$source_helper" "$target_helper"
        chmod +x "$target_helper"
        echo "Installed helper: $target_helper"
    else
        echo "Warning: tracked helper not found: $source_helper"
    end
end

# === 5. Verify the binary ===
echo
echo "Verifying Herdr installation..."
if not command -q herdr
    echo "Herdr was not found in PATH. Restart Fish and try again."
    exit 1
end
echo "Herdr: "(command -v herdr)
echo "Version: "(herdr --version 2>/dev/null | head -n 1)

# === 6. Set up integrations for installed coding agents ===
echo
echo "Detecting installed coding-agent CLIs..."

# Format: integration name|binary candidates|display name
set -l agent_integrations \
    "claude|claude|Claude Code" \
    "codex|codex|OpenAI Codex CLI" \
    "cursor|cursor-agent|Cursor CLI" \
    "opencode|opencode|OpenCode" \
    "grok|grok|Grok CLI" \
    "pi|pi|Pi" \
    "kimi|kimi kimi-cli|Kimi CLI" \
    "kilo|kilo kilocode|Kilo Code" \
    "hermes|hermes|Hermes" \
    "antigravity-cli|antigravity|Antigravity CLI"

set -l configured_agents
set -l warned_agents
set -l declined_agents
set -l skipped_agents
set -l integration_status (herdr integration status 2>/dev/null)

for entry in $agent_integrations
    set -l fields (string split '|' "$entry")
    set -l agent_name $fields[1]
    set -l agent_bins $fields[2]
    set -l agent_label $fields[3]
    set -l found_bin

    for bin in (string split ' ' -- "$agent_bins")
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

    if string match -q -- "$agent_name: current*" $integration_status
        echo "  $agent_label integration already installed. Skipping."
        set -a configured_agents "$agent_label"
        continue
    end

    read -P "  $agent_label detected ($found_bin). Install Herdr integration? [Y/n] " install_reply
    if test "$install_reply" = "n" -o "$install_reply" = "N"
        echo "  Declined $agent_label integration."
        set -a declined_agents "$agent_label"
        continue
    end

    set -l install_output (herdr integration install "$agent_name" 2>&1)
    set -l install_status $status
    if test $install_status -eq 0
        echo "  $agent_label integration installed."
        set -a configured_agents "$agent_label"
    else
        echo "  Could not install $agent_label integration:"
        for line in $install_output
            echo "    $line"
        end
        echo "    If its config directory is missing, run $found_bin once and rerun this script."
        set -a warned_agents "$agent_label"
    end
end

# === 7. Report agents that Herdr auto-detects without integrations ===
echo
echo "Checking agents Herdr auto-detects with zero setup..."
set -l agent_detect_only \
    "gemini|gemini|Gemini CLI" \
    "amp|amp|Amp" \
    "cline|cline|Cline" \
    "kiro|kiro|Kiro" \
    "agy|agy|Agy" \
    "maki|maki|Maki"
set -l detected_only_agents

for entry in $agent_detect_only
    set -l fields (string split '|' "$entry")
    set -l agent_bins $fields[2]
    set -l agent_label $fields[3]
    for bin in (string split ' ' -- "$agent_bins")
        if command -q "$bin"
            echo "  $agent_label detected; no integration needed."
            set -a detected_only_agents "$agent_label"
            break
        end
    end
end
if test (count $detected_only_agents) -eq 0
    echo "  None found."
end

# === 8. Summary ===
echo
echo "==================================================="
echo "Herdr setup complete!"
echo "==================================================="
echo
echo "Integrations configured:"
if test (count $configured_agents) -gt 0
    for agent in $configured_agents
        echo "  - $agent"
    end
else
    echo "  (none)"
end
echo
echo "Needs attention:"
if test (count $warned_agents) -gt 0
    for agent in $warned_agents
        echo "  - $agent"
    end
else
    echo "  (none)"
end
echo
echo "Declined by user:"
if test (count $declined_agents) -gt 0
    for agent in $declined_agents
        echo "  - $agent"
    end
else
    echo "  (none)"
end
echo
echo "Not installed:"
if test (count $skipped_agents) -gt 0
    for agent in $skipped_agents
        echo "  - $agent"
    end
else
    echo "  (none)"
end

if test (count $warned_agents) -gt 0
    echo
    echo "If integrations failed because the Herdr server was not running, start it with:"
    echo "  herdr server"
    echo "Then rerun this script."
end

echo
echo "Usage:"
echo "  herdr                         Start or attach to Herdr"
echo "  herdr server stop             Stop the background server"
echo "  herdr integration status      Check integration state"
echo "  herdr server reload-config    Reload config after edits"
echo "  ~/.config/herdr/scripts/start-agent-hidden.fish opencode"
echo
echo "Herdr installation finished successfully."
