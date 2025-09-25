#!/bin/bash

# 🔑 Setup AWS Secrets for GitHub Repository

echo "🔑 AWS Secrets Setup for BillPay Demo"
echo "====================================="
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "📦 Install it with: sudo apt install gh"
    echo "🔗 Or visit: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "🔐 Please authenticate with GitHub first:"
    echo "gh auth login"
    exit 1
fi

echo "📋 This script will help you add AWS credentials to the ia-ops-iac repository"
echo ""

# Get AWS credentials
read -p "🔑 Enter your AWS Access Key ID: " AWS_ACCESS_KEY_ID
echo ""
read -s -p "🔐 Enter your AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo ""
echo ""

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "❌ AWS credentials cannot be empty"
    exit 1
fi

echo "📤 Adding secrets to giovanemere/ia-ops-iac repository..."

# Add secrets to repository
if gh secret set AWS_ACCESS_KEY_ID --body "$AWS_ACCESS_KEY_ID" --repo giovanemere/ia-ops-iac; then
    echo "✅ AWS_ACCESS_KEY_ID added successfully"
else
    echo "❌ Failed to add AWS_ACCESS_KEY_ID"
    exit 1
fi

if gh secret set AWS_SECRET_ACCESS_KEY --body "$AWS_SECRET_ACCESS_KEY" --repo giovanemere/ia-ops-iac; then
    echo "✅ AWS_SECRET_ACCESS_KEY added successfully"
else
    echo "❌ Failed to add AWS_SECRET_ACCESS_KEY"
    exit 1
fi

echo ""
echo "🎉 AWS secrets configured successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Go to Backstage: http://localhost:3000"
echo "2. Create a new demo using the BillPay template"
echo "3. The workflow should now work with AWS credentials"
echo ""
echo "🔗 Verify secrets at:"
echo "https://github.com/giovanemere/ia-ops-iac/settings/secrets/actions"
echo ""
echo "✅ Setup complete!"
