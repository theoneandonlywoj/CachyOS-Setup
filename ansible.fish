#!/usr/bin/env fish
# === ansible.fish ===
# Purpose: Install Ansible (automation platform) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting Ansible installation..."
echo
echo "💡 Ansible is an automation platform:"
echo "   - Configuration management"
echo "   - Application deployment"
echo "   - Infrastructure provisioning"
echo "   - Orchestration and automation"
echo "   - Agentless architecture (SSH-based)"
echo

# === 1. Check if Ansible is already installed ===
command -q ansible; and set -l ansible_installed "installed"
if test -n "$ansible_installed"
    echo "✅ Ansible is already installed."
    ansible --version 2>&1 | head -n 1
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Ansible installation."
        exit 0
    end
    echo "📦 Removing existing Ansible installation..."
    # Try to remove via pacman
    if pacman -Qq ansible > /dev/null 2>&1
        sudo pacman -R --noconfirm ansible
    end
    # Try to remove via pip
    if command -v pip > /dev/null
        pip uninstall -y ansible 2>/dev/null
    end
    echo "✅ Ansible removed."
end

# === 2. Install Ansible ===
echo "📦 Installing Ansible from official repository..."
sudo pacman -S --needed --noconfirm ansible
if test $status -ne 0
    echo "❌ Failed to install Ansible."
    exit 1
end
echo "✅ Ansible installed."

# === 3. Install recommended dependencies ===
echo "📦 Installing recommended dependencies..."
sudo pacman -S --needed --noconfirm openssh python-paramiko python-jinja python-yaml python-markupsafe
if test $status -ne 0
    echo "⚠ Warning: Failed to install some dependencies."
    echo "   Ansible may have limited functionality."
else
    echo "✅ Dependencies installed."
end

# === 4. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -q ansible
    echo "✅ Ansible installed successfully"
    ansible --version 2>&1 | head -n 1
else
    echo "❌ Ansible installation verification failed."
    exit 1
end

echo
echo "🎉 Ansible installation complete!"
echo
echo "💡 Basic usage:"
echo "   # Test connectivity to hosts"
echo "   ansible all -i inventory.ini -m ping"
echo ""
echo "   # Run a command on remote hosts"
echo "   ansible all -i inventory.ini -a 'uptime'"
echo ""
echo "   # Run a playbook"
echo "   ansible-playbook playbook.yml"
echo ""
echo "   # Check playbook syntax"
echo "   ansible-playbook --syntax-check playbook.yml"
echo ""
echo "   # Run playbook in dry-run mode"
echo "   ansible-playbook --check playbook.yml"
echo ""
echo "💡 Inventory files:"
echo "   # Simple inventory (inventory.ini)"
echo "   [webservers]"
echo "   web1.example.com"
echo "   web2.example.com"
echo ""
echo "   [dbservers]"
echo "   db1.example.com"
echo ""
echo "   # With variables"
echo "   [webservers]"
echo "   web1.example.com ansible_user=admin ansible_port=2222"
echo ""
echo "💡 Playbook example (playbook.yml):"
echo "   ---"
echo "   - name: Install and start nginx"
echo "     hosts: webservers"
echo "     become: yes"
echo "     tasks:"
echo "       - name: Install nginx"
echo "         package:"
echo "           name: nginx"
echo "           state: present"
echo ""
echo "       - name: Start nginx"
echo "         service:"
echo "           name: nginx"
echo "           state: started"
echo "           enabled: yes"
echo ""
echo "💡 Common modules:"
echo "   # Package management"
echo "   ansible all -i inventory.ini -m package -a 'name=nginx state=present'"
echo ""
echo "   # Service management"
echo "   ansible all -i inventory.ini -m service -a 'name=nginx state=started'"
echo ""
echo "   # File operations"
echo "   ansible all -i inventory.ini -m copy -a 'src=file.txt dest=/tmp/file.txt'"
echo ""
echo "   # Command execution"
echo "   ansible all -i inventory.ini -m command -a 'uptime'"
echo ""
echo "   # Shell commands"
echo "   ansible all -i inventory.ini -m shell -a 'ls -la /tmp'"
echo ""
echo "💡 Configuration:"
echo "   # Ansible config file: /etc/ansible/ansible.cfg or ~/.ansible.cfg"
echo "   [defaults]"
echo "   inventory = ./inventory.ini"
echo "   remote_user = admin"
echo "   host_key_checking = False"
echo ""
echo "💡 SSH setup:"
echo "   # Generate SSH key if needed"
echo "   ssh-keygen -t ed25519 -C \"ansible@example.com\""
echo ""
echo "   # Copy SSH key to remote hosts"
echo "   ssh-copy-id user@hostname"
echo ""
echo "   # Or use ansible to copy keys"
echo "   ansible all -i inventory.ini -m authorized_key ..."
echo ""
echo "💡 Collections and roles:"
echo "   # Install a collection"
echo "   ansible-galaxy collection install community.general"
echo ""
echo "   # Install a role"
echo "   ansible-galaxy install geerlingguy.docker"
echo ""
echo "   # Initialize a new role"
echo "   ansible-galaxy init my_role"
echo ""
echo "💡 Vault (encrypted variables):"
echo "   # Create encrypted file"
echo "   ansible-vault create secrets.yml"
echo ""
echo "   # Edit encrypted file"
echo "   ansible-vault edit secrets.yml"
echo ""
echo "   # Encrypt existing file"
echo "   ansible-vault encrypt secrets.yml"
echo ""
echo "   # Use in playbook"
echo "   ansible-playbook playbook.yml --ask-vault-pass"
echo ""
echo "💡 Resources:"
echo "   - Official site: https://www.ansible.com/"
echo "   - Documentation: https://docs.ansible.com/"
echo "   - User Guide: https://docs.ansible.com/ansible/latest/user_guide/"
echo "   - Module Index: https://docs.ansible.com/ansible/latest/collections/index.html"
echo "   - Galaxy: https://galaxy.ansible.com/"

