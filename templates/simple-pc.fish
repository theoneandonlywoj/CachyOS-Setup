#!/usr/bin/env fish

set SCRIPT_DIR (dirname (realpath (status filename)))
set PARENT_DIR (dirname $SCRIPT_DIR)

echo "Making all fish scripts in $PARENT_DIR executable..."
chmod +x $PARENT_DIR/*.fish

echo "Simple PC: Running setup scripts..."

$PARENT_DIR/copyq.fish
$PARENT_DIR/pdf_support.fish
$PARENT_DIR/dust.fish
$PARENT_DIR/exiftool.fish
$PARENT_DIR/gping.fish
$PARENT_DIR/graphviz.fish
$PARENT_DIR/htop.fish
$PARENT_DIR/inotify-tools.fish
$PARENT_DIR/mkcert.fish
$PARENT_DIR/mtr.fish
$PARENT_DIR/netcat.fish
$PARENT_DIR/rclone.fish
$PARENT_DIR/ripgrep.fish
$PARENT_DIR/vault.fish
$PARENT_DIR/vivaldi.fish
$PARENT_DIR/vlc.fish
$PARENT_DIR/wireshark.fish
$PARENT_DIR/yt_dlp.fish
$PARENT_DIR/git_setup.fish

echo "Simple PC: Setup complete! 🎉"
