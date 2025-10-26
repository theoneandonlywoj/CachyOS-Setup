#!/usr/bin/env fish
# === aws_cli.fish ===
# Purpose: Install AWS CLI on CachyOS
# Installs AWS CLI from official repositories
# Author: theoneandonlywoj

echo "🚀 Starting AWS CLI installation..."

# === 1. Ask user which version to install ===
echo "📌 Choose AWS CLI version:"
echo "   1) AWS CLI v1 (Classic, more stable)"
echo "   2) AWS CLI v2 (Latest, recommended)"
read -P "Select [1/2]: " version_choice

if test "$version_choice" = "1"
    set PACKAGE_NAME "aws-cli"
    set VERSION_NAME "v1"
else if test "$version_choice" = "2"
    set PACKAGE_NAME "aws-cli-v2"
    set VERSION_NAME "v2"
else
    echo "❌ Invalid choice."
    exit 1
end

echo "📌 Selected: AWS CLI $VERSION_NAME"

# === 2. Check if AWS CLI is already installed ===
command -q aws; and set -l aws_installed "installed"
if test -n "$aws_installed"
    echo "✅ AWS CLI is already installed."
    aws --version
    read -P "Do you want to reinstall? [y/N] " reinstall
    if test "$reinstall" != "y" -a "$reinstall" != "Y"
        echo "⚠ Skipping AWS CLI installation."
        exit 0
    end
end

# === 3. Install AWS CLI ===
echo "📦 Installing $PACKAGE_NAME..."
sudo pacman -S --needed --noconfirm $PACKAGE_NAME
if test $status -ne 0
    echo "❌ Failed to install AWS CLI."
    exit 1
end
echo "✅ AWS CLI installed."

# === 4. Setup AWS CLI completion ===
echo "📦 Setting up AWS CLI shell completion..."
if command -q aws
    # Fish shell autocompletion
    mkdir -p ~/.config/fish/completions
    set aws_completer (which aws_completer 2>/dev/null)
    if test -n "$aws_completer"
        ln -sf $aws_completer ~/.config/fish/completions/aws.fish 2>/dev/null
        if test $status -eq 0
            echo "✅ AWS CLI autocomplete configured for Fish."
        else
            echo "⚠ Failed to configure autocomplete."
        end
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
                echo "⚠ Failed to fix snapper, but AWS CLI is still fully functional."
            end
        end
    else
        echo "✅ Snapper is working correctly."
    end
end

# === 6. Verify installation ===
echo
echo "🧪 Verifying installation..."
command -q aws
if test $status -eq 0
    echo "✅ AWS CLI installed successfully"
    aws --version
else
    echo "❌ AWS CLI installation verification failed."
end

echo
echo "✅ AWS CLI installation complete!"
echo "💡 AWS CLI is the command-line interface for Amazon Web Services:"
echo "   - Manage AWS services from command line"
echo "   - Automate infrastructure tasks"
echo "   - Interact with S3, EC2, Lambda, and more"
echo "   - CI/CD integration"
echo "💡 Setup (required before use):"
echo "   1. Create AWS account at aws.amazon.com"
echo "   2. Create IAM user with programmatic access"
echo "   3. Configure credentials: aws configure"
echo "   Or set credentials:"
echo "   export AWS_ACCESS_KEY_ID='your-key'"
echo "   export AWS_SECRET_ACCESS_KEY='your-secret'"
echo "💡 Basic commands:"
echo "   - aws configure: Set up credentials"
echo "   - aws s3 ls: List S3 buckets"
echo "   - aws ec2 describe-instances: List EC2 instances"
echo "   - aws lambda list-functions: List Lambda functions"
echo "   - aws sts get-caller-identity: Verify credentials"
echo "💡 Common use cases:"
echo "   - S3: aws s3 cp, aws s3 sync"
echo "   - EC2: aws ec2 start-instances, stop-instances"
echo "   - Lambda: aws lambda invoke, update-function-code"
echo "   - IAM: aws iam list-users, create-role"
echo "💡 Tips:"
echo "   - Use --profile to switch between profiles"
echo "   - Use --region to specify AWS region"
echo "   - Use --output json/yaml/table for different output formats"
echo "   - Enable MFA with aws sts get-session-token"
echo "💡 Configuration:"
echo "   - Config: ~/.aws/config"
echo "   - Credentials: ~/.aws/credentials"
echo "   - Multiple profiles supported"
echo "💡 Example workflow:"
echo "   1. aws configure"
echo "   2. aws s3 ls"
echo "   3. aws ec2 describe-instances"
echo "   4. aws s3 cp file s3://bucket/"

