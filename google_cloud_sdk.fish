#!/usr/bin/env fish
# === google_cloud_sdk.fish ===
# Purpose: Install or update Google Cloud SDK on CachyOS / Arch Linux
# Author: theoneandonlywoj

echo "🚀 Starting Google Cloud SDK installation/update..."

# === 1. Install dependencies ===
echo "📦 Installing required dependencies..."
sudo pacman -S --noconfirm curl python unzip
if test $status -ne 0
    echo "❌ Failed to install dependencies. Aborting."
    exit 1
end

# === 2. Prepare installation directory ===
set gcloud_dir $HOME/opt
mkdir -p $gcloud_dir
set gcloud_sdk_dir $gcloud_dir/google-cloud-sdk

# === 3. Backup old installation if exists ===
if test -d $gcloud_sdk_dir
    set timestamp (date "+%Y_%m_%d_%H_%M_%S")
    set backup_dir $gcloud_dir/google-cloud-sdk.backup_$timestamp
    echo "⚠ Existing Google Cloud SDK found. Backing up to $backup_dir..."
    mv $gcloud_sdk_dir $backup_dir
    if test $status -ne 0
        echo "❌ Failed to backup existing SDK. Aborting."
        exit 1
    end
end

# === 4. Download latest Google Cloud SDK ===
echo "🔽 Downloading latest Google Cloud SDK..."
set gcloud_archive $HOME/gcloud-sdk.tar.gz
curl -fSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz -o $gcloud_archive
if test $status -ne 0
    echo "❌ Failed to download Google Cloud SDK. Aborting."
    exit 1
end

# === 5. Extract the SDK ===
echo "📦 Extracting Google Cloud SDK..."
cd $HOME
tar -xzf $gcloud_archive
if test $status -ne 0
    echo "❌ Failed to extract SDK archive. Aborting."
    rm $gcloud_archive
    exit 1
end

# === 6. Move SDK to opt directory ===
mv google-cloud-sdk $gcloud_dir
if test $status -ne 0
    echo "❌ Failed to move SDK to opt directory. Aborting."
    exit 1
end

# === 7. Clean up archive ===
rm $gcloud_archive
echo "🧹 Removed temporary archive."

# === 8. Run installation script ===
echo "⚙️ Running Google Cloud SDK installation..."
$gcloud_sdk_dir/install.sh --quiet
if test $status -ne 0
    echo "❌ Failed to run installation script. Aborting."
    exit 1
end

# === 9. Create or update symlink for gcloud command ===
echo "🔗 Creating symlinks for terminal access..."
if test -L /usr/local/bin/gcloud
    sudo rm /usr/local/bin/gcloud
end
sudo ln -s $gcloud_sdk_dir/bin/gcloud /usr/local/bin/gcloud

if test -L /usr/local/bin/gsutil
    sudo rm /usr/local/bin/gsutil
end
sudo ln -s $gcloud_sdk_dir/bin/gsutil /usr/local/bin/gsutil

if test -L /usr/local/bin/bq
    sudo rm /usr/local/bin/bq
end
sudo ln -s $gcloud_sdk_dir/bin/bq /usr/local/bin/bq

echo "✅ Symlinks created successfully!"

# === 10. Initialize gcloud (user will need to authenticate) ===
echo "🔐 Initializing Google Cloud SDK..."
echo "⚠️  You will need to authenticate with your Google account."
echo "⚠️  Run 'gcloud init' to configure your default project and credentials."
echo "⚠️  Or run 'gcloud auth login' to authenticate."
echo ""

# === 11. Add to PATH in fish config ===
set fish_config $HOME/.config/fish/config.fish
if not grep -q "google-cloud-sdk" $fish_config
    echo "📝 Adding Google Cloud SDK to PATH in fish config..."
    echo "" >> $fish_config
    echo "# Google Cloud SDK" >> $fish_config
    echo "set -gx PATH \$HOME/opt/google-cloud-sdk/bin \$PATH" >> $fish_config
    echo "✅ Added to PATH in fish config."
else
    echo "ℹ️  Google Cloud SDK already in PATH."
end

# === 12. Source the path for current session ===
set -gx PATH $HOME/opt/google-cloud-sdk/bin $PATH

echo "🎉 Google Cloud SDK installation/update complete!"
echo "📦 Backup of old SDK (if any) is located in $gcloud_dir"
echo "🖱 You can now use 'gcloud' command in the terminal."
echo "🔧 Next steps:"
echo "   1. Run 'gcloud init' to configure your default project"
echo "   2. Or run 'gcloud auth login' to authenticate"
echo "   3. Run 'gcloud version' to verify installation"

