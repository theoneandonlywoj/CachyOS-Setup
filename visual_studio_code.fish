#!/usr/bin/env fish
# === visual_studio_code.fish ===
# Purpose: Install Visual Studio Code on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Visual Studio Code setup..."
echo
echo "📌 Available editions:"
echo "   code (Code - OSS)          → Open-source build from Arch community repo"
echo "   visual-studio-code-bin     → Official Microsoft build (AUR)"
echo

set selected_edition "code"

# === 1. Choose edition ===
set -l edition_choice
if test -t 0
    echo "Select VS Code edition to install:"
    echo "   1) code (Code - OSS) — open-source, from Arch community repo"
    echo "   2) visual-studio-code-bin (Official) — Microsoft build, proprietary features, from AUR"
    read -P "Enter choice [1] or 2: " edition_choice
else if pacman -Qq visual-studio-code-bin >/dev/null 2>&1
    # Keep the installed edition. Checked first: this package also provides "code".
    set edition_choice 2
end

switch "$edition_choice"
    case 2
        set selected_edition "visual-studio-code-bin"
        echo "🔧 Selected: Official Microsoft build (visual-studio-code-bin)"
    case '*'
        echo "🔧 Selected: Code - OSS (open-source build)"
end

# === 2. Install VS Code ===
switch $selected_edition
    case code
        echo "📦 Installing Code - OSS from Arch community repository..."
        sudo pacman -S --needed --noconfirm code
        if test $status -ne 0
            echo "❌ Failed to install Code - OSS. Aborting."
            exit 1
        end

        # Install code-features for marketplace/repo access on OSS build
        echo "📦 Installing code-features for extension marketplace support..."
        sudo pacman -S --needed --noconfirm code-features 2>/dev/null
        if test $status -ne 0
            echo "⚠ code-features not available. Attempting AUR install..."
            set aur_helper ""
            for helper in yay paru trizen pikaur
                if command -v $helper > /dev/null
                    set aur_helper $helper
                    break
                end
            end
            if test -n "$aur_helper"; and not pacman -Qq code-features >/dev/null 2>&1
                $aur_helper -S --needed --noconfirm code-features
            end
        end

    case visual-studio-code-bin
        # Check for AUR helper
        set aur_helper ""
        for helper in yay paru trizen pikaur
            if command -v $helper > /dev/null
                set aur_helper $helper
                break
            end
        end

        if pacman -Qq visual-studio-code-bin >/dev/null 2>&1
            echo "✅ visual-studio-code-bin is already installed; upgrades come from 'paru -Syu'."
        else if test -z "$aur_helper"
            echo "❌ No AUR helper found. Please install yay, paru, trizen, or pikaur first."
            echo "   Falling back to Code - OSS from official repos..."
            set selected_edition "code"
            sudo pacman -S --needed --noconfirm code
            if test $status -ne 0
                echo "❌ Failed to install Code - OSS. Aborting."
                exit 1
            end
        else
            echo "📦 Installing visual-studio-code-bin from AUR using $aur_helper..."
            $aur_helper -S --needed --noconfirm visual-studio-code-bin
            if test $status -ne 0
                echo "❌ Failed to install visual-studio-code-bin. Rerun: ./visual_studio_code.fish"
                exit 1
            end
        end
end

# === 3. Verify installation ===
echo "🧪 Verifying installation..."
set code_version (command code --version 2>/dev/null | head -n 1)

if test -n "$code_version"
    echo "✅ VS Code installed successfully: $code_version"
else
    echo "❌ VS Code verification failed."
    exit 1
end

echo
echo "🎉 Visual Studio Code setup complete!"
echo
echo "📚 Installed edition: $selected_edition"
echo "   Version: $code_version"
echo
echo "💡 Usage:"
echo "   code                    → Open VS Code"
echo "   code .                  → Open current directory"
echo "   code /path/to/file      → Open a specific file"
echo "   code /path/to/folder    → Open a folder as workspace"
echo "   code --diff file1 file2 → Compare two files"
echo
echo "💡 Tip:"
echo "   Launch VS Code, then press Ctrl+Shift+X to browse extensions."
echo "   For Code - OSS, use the Open VSX Registry (open-vsx.org)"
echo "   or the Microsoft marketplace via code-features."
