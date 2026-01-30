#!/usr/bin/env fish

set SCRIPT_DIR (dirname (realpath (status filename)))
set PARENT_DIR (dirname $SCRIPT_DIR)

echo "Making all fish scripts in $PARENT_DIR executable..."
chmod +x $PARENT_DIR/*.fish

echo "Running setup scripts..."

$PARENT_DIR/caddy.fish
$PARENT_DIR/copyq.fish
$PARENT_DIR/vivaldi.fish
$PARENT_DIR/keymapp.fish
$PARENT_DIR/mise.fish
$PARENT_DIR/pdf_support.fish
$PARENT_DIR/dbeaver.fish
$PARENT_DIR/dust.fish
$PARENT_DIR/exiftool.fish
$PARENT_DIR/gping.fish
$PARENT_DIR/graphviz.fish
$PARENT_DIR/htop.fish
$PARENT_DIR/inotify-tools.fish
$PARENT_DIR/krita.fish
$PARENT_DIR/kubectl.fish
$PARENT_DIR/mkcert.fish
$PARENT_DIR/mtr.fish
$PARENT_DIR/netcat.fish
$PARENT_DIR/ngrok.fish
$PARENT_DIR/podman.fish
$PARENT_DIR/podman_compose.fish
$PARENT_DIR/postman.fish
$PARENT_DIR/rclone.fish
$PARENT_DIR/ripgrep.fish
$PARENT_DIR/vault.fish
$PARENT_DIR/vivaldi.fish
$PARENT_DIR/vlc.fish
$PARENT_DIR/webcord.fish
$PARENT_DIR/wireshark.fish
$PARENT_DIR/wrk.fish
$PARENT_DIR/yt_dlp.fish
$PARENT_DIR/gitleaks.fish
$PARENT_DIR/github_cli.fish
$PARENT_DIR/git_setup.fish
$PARENT_DIR/emacs.fish
$PARENT_DIR/doom_emacs.fish
$PARENT_DIR/elixir_and_erlang.fish
$PARENT_DIR/elixirls.fish

echo "Setup complete!"
