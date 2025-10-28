#!/usr/bin/env fish
# === terraform.fish ===
# Purpose: Install Terraform (IaC) tool on CachyOS
# Installs Terraform and related tools from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting Terraform installation..."

# === 1. Check if Terraform is already installed ===
command -q terraform; and set -l terraform_installed "installed"
if test -n "$terraform_installed"
    echo "✅ Terraform is already installed."
    terraform version
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping Terraform installation."
        exit 0
    end
    echo "📦 Removing existing Terraform installation..."
    sudo pacman -R --noconfirm terraform
    if test $status -ne 0
        echo "❌ Failed to remove Terraform."
        exit 1
    end
    echo "✅ Terraform removed."
end

# === 2. Install Terraform ===
echo "📦 Installing Terraform..."
sudo pacman -S --needed --noconfirm terraform
if test $status -ne 0
    echo "❌ Failed to install Terraform."
    exit 1
end
echo "✅ Terraform installed."

# === 3. Install optional Terraform tools ===
echo "📦 Installing optional Terraform tools..."
echo "💡 The following tools enhance Terraform workflows:"
echo "   - terragrunt: Wrapper for managing Terraform modules"
echo "   - tflint: Linter for Terraform code"
read -P "Do you want to install additional Terraform tools? [y/N] " install_tools

if test "$install_tools" = "y" -o "$install_tools" = "Y"
    echo "📦 Installing Terragrunt and TFLint..."
    sudo pacman -S --needed --noconfirm terragrunt tflint
    if test $status -ne 0
        echo "⚠ Failed to install some tools, but Terraform is still installed."
    else
        echo "✅ Terraform tools installed."
        echo "   - Terragrunt: $(command -v terragrunt)"
        echo "   - TFLint: $(command -v tflint)"
    end
end

# === 4. Setup Terraform autocomplete ===
echo "📦 Setting up Terraform shell completion..."
if command -q terraform
    # Fish shell autocompletion
    mkdir -p ~/.config/fish/completions
    terraform -install-autocomplete fish 2>/dev/null
    if test $status -eq 0
        echo "✅ Terraform autocomplete configured for Fish."
    else
        echo "⚠ Failed to configure autocomplete."
    end
end

# === 5. Check and fix snapper Boost library issue (if present) ===
if test -f /usr/bin/snapper
    echo
    echo "🔧 Checking for snapper Boost library issue..."
    snapper --version > /dev/null 2>&1
    if test $status -ne 0
        echo "⚠ Detected snapper Boost library version mismatch."
        echo "💡 This can happen after Boost updates."
        read -P "Do you want to fix snapper? [y/N] " fix_snapper
        
        if test "$fix_snapper" = "y" -o "$fix_snapper" = "Y"
            echo "📦 Reinstalling snapper to fix Boost library version mismatch..."
            sudo pacman -S --noconfirm snapper
            if test $status -eq 0
                echo "✅ Snapper fixed successfully."
            else
                echo "⚠ Failed to fix snapper, but Terraform is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q terraform
if test $status -eq 0
    echo "✅ Terraform installed successfully"
    terraform version 2>&1 | head -n 3
else
    echo "❌ Terraform installation verification failed."
end

echo
echo "✅ Terraform installation complete!"
echo "💡 Terraform is HashiCorp's Infrastructure as Code tool:"
echo "   - Define infrastructure as code"
echo "   - Manage cloud resources (AWS, Azure, GCP)"
echo "   - Version control infrastructure"
echo "   - Idempotent and reproducible deployments"
echo "💡 Terraform workflow:"
echo "   1. Initialize: terraform init"
echo "   2. Plan changes: terraform plan"
echo "   3. Apply: terraform apply"
echo "   4. Destroy: terraform destroy"
echo "💡 Basic commands:"
echo "   - terraform init: Initialize a working directory"
echo "   - terraform plan: Preview changes"
echo "   - terraform apply: Apply changes"
echo "   - terraform destroy: Destroy infrastructure"
echo "   - terraform validate: Check configuration"
echo "   - terraform fmt: Format configuration files"
echo "💡 Tips for getting started:"
echo "   1. Create a main.tf file with provider and resources"
echo "   2. Run: terraform init"
echo "   3. Run: terraform plan to preview"
echo "   4. Run: terraform apply to create resources"
echo "💡 Example main.tf:"
echo "   provider \"aws\" {"
echo "     region = \"us-west-2\""
echo "   }"
echo "   "
echo "   resource \"aws_instance\" \"web\" {"
echo "     ami           = \"ami-12345678\""
echo "     instance_type = \"t2.micro\""
echo "   }"
echo "💡 State management:"
echo "   - Terraform stores state in terraform.tfstate"
echo "   - Use remote state (S3, etc.) for teams"
echo "   - Never commit .tfstate files to version control"
echo "💡 Additional resources:"
echo "   - Terraform Registry: https://registry.terraform.io"
echo "   - Documentation: https://www.terraform.io/docs"

