#!/usr/bin/env fish
# === GitHub SSH + Git Config Setup for CachyOS (KDE Plasma, Fish shell) ===
# Author: theoneandonlywoj
# Description:
#   Generates an SSH key, starts ssh-agent, copies it to clipboard,
#   configures global Git user info, and optionally tests GitHub connection.

set key_path ~/.ssh/id_ed25519
set pub_key ~/.ssh/id_ed25519.pub

# === 1. Check if key already exists ===
if test -f $key_path
    echo "🔑 SSH key already exists at $key_path"
    read -l -P "Do you want to overwrite it? (y/N) " overwrite
    if test (string lower $overwrite) != "y"
        echo "➡️  Keeping existing key. Skipping key generation."
        set skip_gen 1
    else
        echo "🧹 Removing old key..."
        rm -f $key_path $pub_key
    end
end

# === 2. Generate a new SSH key ===
if not set -q skip_gen
    echo "🔧 Generating new SSH key..."
    ssh-keygen -t ed25519 -C "theoneandonlywoj@gmail.com" -f $key_path -N "" -q
    if test $status -ne 0
        echo "❌ SSH key generation failed."
        exit 1
    end
end

# === 3. Start ssh-agent ===
eval (ssh-agent -c)
if test $status -ne 0
    echo "❌ Failed to start ssh-agent."
    exit 1
end

# === 4. Add the SSH key to the agent ===
ssh-add $key_path
if test $status -ne 0
    echo "❌ Failed to add SSH key to agent."
    exit 1
end

# === 5. Copy the public key to clipboard ===
echo "📋 Copying SSH public key to clipboard..."

if type -q wl-copy
    cat $pub_key | wl-copy
    echo "✅ Key copied using wl-copy (Wayland)."
else if type -q xclip
    cat $pub_key | xclip -selection clipboard
    echo "✅ Key copied using xclip (X11)."
else
    echo "⚠️  No clipboard utility found."
    echo "   Install one with:"
    echo "     sudo pacman -S wl-clipboard    # for Wayland"  # rerun-gate: allow hint text
    echo "     sudo pacman -S xclip           # for X11"  # rerun-gate: allow hint text
end

# === 6. Display the key as backup ===
echo
echo "Here’s your public key:"
cat $pub_key
echo
echo "➡️  Add this key to GitHub:"
echo "   https://github.com/settings/ssh/new"

# === 7. Configure Git user information ===
echo
echo "🧭 Let's configure your Git identity."
read -l -P "Enter your Git user name: " git_name
read -l -P "Enter your Git email: " git_email

if test -n "$git_name"
    git config --global user.name "$git_name"
end

if test -n "$git_email"
    git config --global user.email "$git_email"
end

echo
# Setting automatically to auto setup a new branch
git config --global push.autoSetupRemote true
echo "✅ Git user configuration updated:"
git config --global --list | grep 'user\.'

# === 8. Ask if user wants to test connection ===
echo
read -l -P "Do you want to test your GitHub SSH connection now? (Y/n) " test_choice
if test -z "$test_choice" -o (string lower $test_choice) = "y"
    echo
    echo "🔍 Testing connection to GitHub..."
    ssh -T git@github.com
else
    echo "🕒 Skipping connection test. You can run manually later with:"
    echo "    ssh -T git@github.com"
end

