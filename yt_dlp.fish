#!/usr/bin/env fish
# === yt_dlp.fish ===
# Purpose: Install yt-dlp (YouTube downloader) on CachyOS
# Updates yt-dlp through its existing owner (mise, pacman, pipx, standalone binary), or installs it via mise
# Author: theoneandonlywoj

echo "🚀 Starting yt-dlp installation..."

# === 1. Install or update yt-dlp with its existing owner ===
set -l ytdlp yt-dlp
if command -q mise
    set -x PATH ~/.local/share/mise/shims $PATH
    mise activate fish | source
end

if command -q mise; and test -n "$(mise ls --installed yt-dlp 2>/dev/null)"
    echo "🔄 Updating yt-dlp via mise..."
    set ytdlp mise exec -- yt-dlp
    mise upgrade yt-dlp
else if pacman -Qq yt-dlp >/dev/null 2>&1
    echo "✅ yt-dlp is owned by pacman; upgrades come from 'paru -Syu'."
else if command -q pipx; and pipx list --short 2>/dev/null | string match -qr '^yt-dlp '
    echo "🔄 Updating yt-dlp via pipx..."
    pipx upgrade yt-dlp
else if test -x ~/.local/bin/yt-dlp
    echo "🔄 Updating ~/.local/bin/yt-dlp..."
    set ytdlp ~/.local/bin/yt-dlp
    ~/.local/bin/yt-dlp -U
else if test -x /usr/local/bin/yt-dlp
    # Installed by earlier versions of this script.
    echo "🔄 Updating /usr/local/bin/yt-dlp..."
    set ytdlp /usr/local/bin/yt-dlp
    sudo /usr/local/bin/yt-dlp -U
else if command -q mise
    echo "📦 Installing yt-dlp via mise..."
    set ytdlp mise exec -- yt-dlp
    mise use -g yt-dlp@latest
else
    echo "❌ Mise is not installed. Run ./mise.fish first."
    exit 1
end
if test $status -ne 0
    echo "❌ yt-dlp install/update failed; an existing install is untouched. Rerun: ./yt_dlp.fish"
    exit 1
end
if command -q mise
    mise reshim
end

# === 2. Verify installation ===
echo
echo "🧪 Verifying installation..."
$ytdlp --version
if test $status -ne 0
    echo "❌ yt-dlp installation verification failed."
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
echo "   - Rerun ./yt_dlp.fish"
echo "💡 Supported sites:"
echo "   - YouTube, Vimeo, Dailymotion, Twitch, and 1000+ more"
echo "   - Run 'yt-dlp --list-extractors' to see all supported sites"
echo "💡 Resources:"
echo "   - GitHub: https://github.com/yt-dlp/yt-dlp"
echo "   - Documentation: https://github.com/yt-dlp/yt-dlp#usage"
echo "   - Options: https://github.com/yt-dlp/yt-dlp#options"

