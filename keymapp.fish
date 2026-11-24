#!/usr/bin/env fish
# === keymapp.fish ===
# Purpose: Install or update Keymapp for ZSA keyboards on CachyOS / Arch Linux
# Author: theoneandonlywoj

echo "🚀 Starting Keymapp installation/update..."

# === 1. Install dependencies ===
echo "📦 Installing required dependencies..."
sudo pacman -S --needed --noconfirm libusb webkit2gtk-4.1 gtk3
if test $status -ne 0
    echo "❌ Failed to install dependencies. Aborting."
    exit 1
end

# === 2. Create plugdev group if it doesn't exist ===
echo "👥 Creating plugdev group..."
sudo groupadd -f plugdev
if test $status -ne 0
    echo "❌ Failed to create plugdev group. Aborting."
    exit 1
end

# === 3. Add current user to plugdev group ===
echo "👤 Adding $USER to plugdev group..."
sudo usermod -aG plugdev $USER
if test $status -ne 0
    echo "❌ Failed to add user to plugdev group. Aborting."
    exit 1
end
echo "✅ User $USER added to plugdev group"

# === 4. Create or backup udev rules file ===
set udev_rules_file /etc/udev/rules.d/50-zsa.rules
echo "📄 Creating/updating udev rules at $udev_rules_file..."

# Create the udev rules file with content
set udev_content "# Rules for Oryx web flashing and live training
KERNEL==\"hidraw*\", ATTRS{idVendor}==\"16c0\", MODE=\"0664\", GROUP=\"plugdev\"
KERNEL==\"hidraw*\", ATTRS{idVendor}==\"3297\", MODE=\"0664\", GROUP=\"plugdev\"

# Legacy rules for live training over webusb (Not needed for firmware v21+)
  # Rule for all ZSA keyboards
  SUBSYSTEM==\"usb\", ATTR{idVendor}==\"3297\", GROUP=\"plugdev\"
  # Rule for the Moonlander
  SUBSYSTEM==\"usb\", ATTR{idVendor}==\"3297\", ATTR{idProduct}==\"1969\", GROUP=\"plugdev\"
  # Rule for the Ergodox EZ
  SUBSYSTEM==\"usb\", ATTR{idVendor}==\"feed\", ATTR{idProduct}==\"1307\", GROUP=\"plugdev\"
  # Rule for the Planck EZ
  SUBSYSTEM==\"usb\", ATTR{idVendor}==\"feed\", ATTR{idProduct}==\"6060\", GROUP=\"plugdev\"

# Wally Flashing rules for the Ergodox EZ
ATTRS{idVendor}==\"16c0\", ATTRS{idProduct}==\"04[789B]?\", ENV{ID_MM_DEVICE_IGNORE}=\"1\"
ATTRS{idVendor}==\"16c0\", ATTRS{idProduct}==\"04[789A]?\", ENV{MTP_NO_PROBE}=\"1\"
SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"16c0\", ATTRS{idProduct}==\"04[789ABCD]?\", MODE:=\"0666\"
KERNEL==\"ttyACM*\", ATTRS{idVendor}==\"16c0\", ATTRS{idProduct}==\"04[789B]?\", MODE:=\"0666\"

# Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0483\", ATTRS{idProduct}==\"df11\", MODE:=\"0666\", SYMLINK+=\"stm32_dfu\"
# Keymapp Flashing rules for the Voyager
SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"3297\", MODE:=\"0666\", SYMLINK+=\"ignition_dfu\""

if test -f $udev_rules_file; and echo $udev_content | cmp -s - $udev_rules_file
    echo "✅ udev rules are already current."
else
    if test -f $udev_rules_file
        set backup_file $udev_rules_file.backup_(date "+%Y_%m_%d_%H_%M_%S")
        echo "⚠ Existing udev rules differ. Backing up to $backup_file..."
        sudo cp $udev_rules_file $backup_file
        or exit 1
    end
    echo $udev_content | sudo tee $udev_rules_file > /dev/null
    if test $status -ne 0
        echo "❌ Failed to create udev rules. Aborting."
        exit 1
    end
end

# === 5. Apply udev rules ===
echo "⚙️ Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

# === 6. Prepare installation directory ===
set keymapp_dir $HOME/opt
mkdir -p $keymapp_dir

# === 7. Download Keymapp ===
echo "🔽 Downloading latest Keymapp..."
# Stage next to the install, so each replacement below is a rename.
set staging (mktemp -d $keymapp_dir/.keymapp.XXXXXX)
or exit 1
set keymapp_tar $staging/keymapp-latest.tar.gz
wget -O $keymapp_tar "https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz"
if test $status -ne 0
    rm -rf $staging
    echo "❌ Failed to download Keymapp; the existing install is untouched. Rerun: ./keymapp.fish"
    exit 1
end

# === 8. Extract Keymapp, then replace the installed files ===
echo "📦 Extracting Keymapp..."
mkdir $staging/new
and tar -xzf $keymapp_tar -C $staging/new
and chmod +x $staging/new/keymapp
if test $status -ne 0
    rm -rf $staging
    echo "❌ Failed to extract Keymapp; the existing install is untouched. Rerun: ./keymapp.fish"
    exit 1
end

set keymapp_binary $keymapp_dir/keymapp
for f in $staging/new/*
    mv -fT $f $keymapp_dir/(basename $f)
    if test $status -ne 0
        rm -rf $staging
        echo "❌ Failed to install Keymapp. Rerun: ./keymapp.fish"
        exit 1
    end
end
rm -rf $staging

# === 9. Create symlink for direct access ===
echo "🔗 Creating symlink for direct access..."
set local_bin_dir $HOME/.local/bin
mkdir -p $local_bin_dir

ln -sfn $keymapp_binary $local_bin_dir/keymapp
if test $status -ne 0
    echo "⚠️ Failed to create symlink. You can still run Keymapp using: $keymapp_binary"
else
    echo "✅ Symlink created at $local_bin_dir/keymapp"
end

echo "✅ Keymapp installation/update complete!"
echo ""
echo "⚠️  IMPORTANT: You need to REBOOT your system for the udev rules to take effect."
echo "   Without rebooting, Keymapp may not be able to access your ZSA keyboard."
echo ""
echo "🖱 After rebooting, you can launch Keymapp by running: keymapp"

