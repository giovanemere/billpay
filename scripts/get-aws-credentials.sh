#!/bin/bash

echo "🔑 AWS Credentials Helper for GitHub Secrets"
echo "==========================================="
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS CLI not configured or credentials invalid"
    echo ""
    echo "🔧 Configure AWS CLI first:"
    echo "aws configure"
    exit 1
fi

# Get current identity
echo "✅ Current AWS Identity:"
aws sts get-caller-identity --output table

echo ""
echo "🔍 Current AWS Configuration:"
echo "Access Key ID: $(aws configure get aws_access_key_id | head -c 10)..."
echo "Region: $(aws configure get region)"
echo ""

echo "📋 GitHub Secrets to Configure:"
echo "==============================="
echo ""
echo "Secret Name: AWS_ACCESS_KEY_ID"
echo "Secret Value: $(aws configure get aws_access_key_id)"
echo ""
echo "Secret Name: AWS_SECRET_ACCESS_KEY"
echo "Secret Value: [HIDDEN - Get from ~/.aws/credentials]"
echo ""

echo "🔗 Configure at:"
echo "https://github.com/giovanemere/ia-ops-iac/settings/secrets/actions"
echo ""

echo "💡 Alternative - Create new access key:"
echo "1. Go to: https://console.aws.amazon.com/iam/home#/users"
echo "2. Select user: $(aws sts get-caller-identity --query 'Arn' --output text | cut -d'/' -f2)"
echo "3. Security credentials → Create access key"
echo "4. Use new keys in GitHub secrets"
