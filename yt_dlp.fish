#!/usr/bin/env fish
# === yt_dlp.fish ===
# Purpose: Install yt-dlp (YouTube downloader) on CachyOS
# Installs yt-dlp via mise (preferred), pip, pacman/AUR, or GitHub releases
# Author: theoneandonlywoj

echo "🚀 Starting yt-dlp installation..."

# === 1. Check if yt-dlp is already installed ===
command -q yt-dlp; and set -l ytdlp_installed "installed"
if test -n "$ytdlp_installed"
    echo "✅ yt-dlp is already installed."
    yt-dlp --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping yt-dlp installation."
        exit 0
    end
    echo "📦 Removing existing yt-dlp installation..."
    # Try to remove via mise first
    if command -v mise > /dev/null
        mise uninstall yt-dlp 2>/dev/null
    end
    # Try to remove via pip
    if command -v pip > /dev/null
        pip uninstall -y yt-dlp 2>/dev/null
        pip3 uninstall -y yt-dlp 2>/dev/null
    end
    # Try to remove via pacman
    if pacman -Qq yt-dlp > /dev/null 2>&1
        sudo pacman -R --noconfirm yt-dlp
    end
    # Remove manually installed binary
    if test -f /usr/local/bin/yt-dlp
        sudo rm -f /usr/local/bin/yt-dlp
    end
    if test -f ~/.local/bin/yt-dlp
        rm -f ~/.local/bin/yt-dlp
    end
    echo "✅ yt-dlp removed."
end

# === 2. Check for Mise and prefer mise installation ===
set use_mise false
if command -v mise > /dev/null
    echo "✅ Mise found. Preferring mise installation method."
    set use_mise true
    
    # Load Mise environment in current shell
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
    
    # Check if yt-dlp is available via mise
    echo "🔍 Checking if yt-dlp is available via mise..."
    mise install yt-dlp@latest
    if test $status -eq 0
        mise use -g yt-dlp@latest
        if test $status -eq 0
            echo "✅ yt-dlp installed successfully via mise"
            set ytdlp_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        else
            echo "⚠ Failed to set yt-dlp as global via mise, but installation succeeded."
            set ytdlp_installed_via_mise true
            # Re-activate mise and ensure shims are in PATH
            set -x PATH ~/.local/share/mise/shims $PATH
            mise activate fish | source
            mise reshim
        end
    else
        echo "⚠ yt-dlp installation via mise failed. Falling back to other methods..."
        set use_mise false
    end
else
    echo "ℹ Mise not found. Will install via pip, pacman/AUR, or GitHub releases."
    echo "💡 Tip: Install mise first (./mise.fish) for better version management."
end

# === 3. Fallback: Install via pip (preferred if mise not available) ===
if not set -q ytdlp_installed_via_mise
    # Check for Python and pip
    set python_cmd ""
    set pip_cmd ""
    
    # Try python3 first, then python
    if command -v python3 > /dev/null
        set python_cmd python3
        if command -v pip3 > /dev/null
            set pip_cmd pip3
        end
    else if command -v python > /dev/null
        set python_cmd python
        if command -v pip > /dev/null
            set pip_cmd pip
        end
    end
    
    # Install pip if Python is available but pip is not
    if test -n "$python_cmd" -a -z "$pip_cmd"
        echo "📦 Python found but pip is missing. Installing pip..."
        sudo pacman -S --needed --noconfirm python-pip
        if test $status -eq 0
            if command -v pip3 > /dev/null
                set pip_cmd pip3
            else if command -v pip > /dev/null
                set pip_cmd pip
            end
        end
    end
    
    # Try pip installation
    if test -n "$pip_cmd"
        echo "📦 Installing yt-dlp via pip..."
        $pip_cmd install --upgrade --user yt-dlp
        if test $status -eq 0
            echo "✅ yt-dlp installed successfully via pip"
            set ytdlp_installed_via_pip true
            # Ensure ~/.local/bin is in PATH
            if not contains "$HOME/.local/bin" $fish_user_paths
                set -U fish_user_paths $HOME/.local/bin $fish_user_paths
            end
        else
            echo "⚠ Failed to install yt-dlp via pip. Trying other methods..."
        end
    end
end

# === 4. Fallback: Install via pacman/AUR if pip failed or not available ===
if not set -q ytdlp_installed_via_mise -a not set -q ytdlp_installed_via_pip
    echo "📦 Installing yt-dlp via package manager..."
    
    # Check if available in official repos
    if pacman -Si yt-dlp > /dev/null 2>&1
        echo "📦 Installing yt-dlp from official Arch repository..."
        sudo pacman -S --needed --noconfirm yt-dlp
        if test $status -eq 0
            echo "✅ yt-dlp installed from official repository."
            set ytdlp_installed_via_pacman true
        else
            echo "❌ Failed to install yt-dlp from official repository."
        end
    else
        # Try AUR helper
        set AUR_HELPER ""
        for helper in yay paru trizen pikaur
            if command -v $helper > /dev/null
                set AUR_HELPER $helper
                break
            end
        end
        
        if test -n "$AUR_HELPER"
            echo "📦 Installing yt-dlp from AUR using $AUR_HELPER..."
            $AUR_HELPER -S --needed --noconfirm yt-dlp
            if test $status -eq 0
                echo "✅ yt-dlp installed from AUR."
                set ytdlp_installed_via_pacman true
            else
                echo "⚠ Failed to install yt-dlp from AUR."
            end
        end
    end
end

# === 5. Final fallback: Install from GitHub releases ===
if not set -q ytdlp_installed_via_mise -a not set -q ytdlp_installed_via_pip -a not set -q ytdlp_installed_via_pacman
    echo "📥 Installing yt-dlp from GitHub releases..."
    
    # Detect architecture
    set arch (uname -m)
    switch $arch
        case x86_64
            set YTDLP_ARCH "x86_64"
        case aarch64 arm64
            set YTDLP_ARCH "arm64"
        case '*'
            echo "❌ Unsupported architecture: $arch"
            exit 1
    end
    
    # Get latest version from GitHub API
    echo "🔍 Fetching latest yt-dlp version..."
    set YTDLP_VERSION (curl -s https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    
    if test -z "$YTDLP_VERSION"
        echo "⚠ Failed to fetch latest version. Using fallback method..."
        set YTDLP_VERSION "2024.01.07"
    end
    
    echo "📦 Downloading yt-dlp v$YTDLP_VERSION..."
    set YTDLP_FILENAME "yt-dlp_$YTDLP_VERSION"_linux_"$YTDLP_ARCH"
    set YTDLP_URL "https://github.com/yt-dlp/yt-dlp/releases/download/$YTDLP_VERSION/$YTDLP_FILENAME"
    set YTDLP_TMP_DIR (mktemp -d)
    set YTDLP_BIN "$YTDLP_TMP_DIR/yt-dlp"
    
    curl -L -o $YTDLP_BIN $YTDLP_URL
    if test $status -ne 0
        echo "❌ Failed to download yt-dlp from GitHub."
        rm -rf $YTDLP_TMP_DIR
        exit 1
    end
    
    # Make executable and install
    chmod +x $YTDLP_BIN
    sudo mkdir -p /usr/local/bin
    sudo cp $YTDLP_BIN /usr/local/bin/yt-dlp
    
    # Cleanup
    rm -rf $YTDLP_TMP_DIR
    
    if test $status -eq 0
        echo "✅ yt-dlp installed from GitHub releases."
    else
        echo "❌ Failed to install yt-dlp binary."
        exit 1
    end
end

# === 6. Ensure mise environment is active for verification ===
if set -q ytdlp_installed_via_mise
    # Ensure mise shims are in PATH
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
end

# === 7. Verify installation ===
echo
echo "🧪 Verifying installation..."
set ytdlp_verified false
if set -q ytdlp_installed_via_mise
    # Verify via mise
    if mise exec -- yt-dlp --version > /dev/null 2>&1
        set ytdlp_verified true
        echo "✅ yt-dlp installed successfully via mise"
        mise exec -- yt-dlp --version 2>&1
    end
else if command -q yt-dlp
    set ytdlp_verified true
    echo "✅ yt-dlp installed successfully"
    yt-dlp --version 2>&1
end

if not $ytdlp_verified
    echo "❌ yt-dlp installation verification failed."
    if set -q ytdlp_installed_via_mise
        echo "💡 yt-dlp was installed via mise. Try running: mise reshim"
        echo "💡 Or restart your terminal to ensure mise shims are in PATH."
    else if set -q ytdlp_installed_via_pip
        echo "💡 yt-dlp was installed via pip. Ensure ~/.local/bin is in your PATH."
        echo "💡 Or restart your terminal to apply PATH changes."
    end
    exit 1
end

echo
echo "✅ yt-dlp installation complete!"
echo "💡 yt-dlp is a YouTube downloader (fork of youtube-dl):"
echo "   - Download videos and audio from YouTube and many other sites"
echo "   - Extract audio, download playlists, choose quality"
echo "   - Support for 1000+ sites"
echo "   - Regular updates and active development"
echo "💡 Basic usage:"
echo "   - yt-dlp <url>: Download video"
echo "   - yt-dlp -f 'best[height<=720]' <url>: Download best quality up to 720p"
echo "   - yt-dlp -x --audio-format mp3 <url>: Extract audio as MP3"
echo "   - yt-dlp -f 'bestvideo+bestaudio' <url>: Download best video and audio separately"
echo "💡 Common commands:"
echo "   # Download video (best quality)"
echo "   yt-dlp https://www.youtube.com/watch?v=VIDEO_ID"
echo ""
echo "   # Download audio only (MP3)"
echo "   yt-dlp -x --audio-format mp3 https://www.youtube.com/watch?v=VIDEO_ID"
echo ""
echo "   # Download playlist"
echo "   yt-dlp https://www.youtube.com/playlist?list=PLAYLIST_ID"
echo ""
echo "   # Download with specific quality"
echo "   yt-dlp -f 'best[height<=480]' <url>"
echo ""
echo "   # Download subtitles"
echo "   yt-dlp --write-subs --sub-lang en <url>"
echo ""
echo "   # List available formats"
echo "   yt-dlp -F <url>"
echo "💡 Format selection:"
echo "   - -f 'best': Best quality (default)"
echo "   - -f 'worst': Worst quality"
echo "   - -f 'bestvideo+bestaudio': Best video and audio separately"
echo "   - -f 'best[height<=720]': Best quality up to 720p"
echo "   - -f 'mp4/best': Prefer MP4 format"
echo "💡 Audio extraction:"
echo "   - -x, --extract-audio: Extract audio"
echo "   - --audio-format mp3: Convert to MP3"
echo "   - --audio-format opus: Convert to Opus"
echo "   - --audio-quality 0: Best audio quality (0-9, 0=best)"
echo "💡 Playlist options:"
echo "   - --playlist-start N: Start from item N"
echo "   - --playlist-end N: End at item N"
echo "   - --playlist-items 1,3,5: Download specific items"
echo "💡 Output options:"
echo "   - -o '%(title)s.%(ext)s': Custom output filename"
echo "   - -o '~/Downloads/%(uploader)s/%(title)s.%(ext)s': Organized output"
echo "   - --output '%(title)s - %(uploader)s.%(ext)s': Include uploader"
echo "💡 Advanced options:"
echo "   - --write-subs: Download subtitles"
echo "   - --write-auto-subs: Download auto-generated subtitles"
echo "   - --sub-lang en: Specify subtitle language"
echo "   - --embed-subs: Embed subtitles in video"
echo "   - --write-thumbnail: Download thumbnail"
echo "   - --embed-thumbnail: Embed thumbnail in audio file"
echo "💡 Configuration:"
echo "   - Config file: ~/.config/yt-dlp/config"
echo "   - Example config:"
echo "     -o '~/Downloads/%(uploader)s/%(title)s.%(ext)s'"
echo "     --write-thumbnail"
echo "     --embed-thumbnail"
echo "💡 Update:"
echo "   - yt-dlp -U: Update to latest version"
echo "   - pip install --upgrade yt-dlp: Update if installed via pip"
echo "💡 Supported sites:"
echo "   - YouTube, Vimeo, Dailymotion, Twitch, and 1000+ more"
echo "   - Run 'yt-dlp --list-extractors' to see all supported sites"
echo "💡 Resources:"
echo "   - GitHub: https://github.com/yt-dlp/yt-dlp"
echo "   - Documentation: https://github.com/yt-dlp/yt-dlp#usage"
echo "   - Options: https://github.com/yt-dlp/yt-dlp#options"

