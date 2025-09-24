#!/bin/bash
# Cleanup script for BillPay Demo Simple

echo "🧹 CLEANING UP BILLPAY DEMO"
echo "=========================="

PROJECT_NAME=${1:-billpay-demo}
ENVIRONMENT=${2:-demo}

echo "📦 Cleaning S3 buckets..."
aws s3 rb s3://${PROJECT_NAME}-${ENVIRONMENT}-frontend-a --force 2>/dev/null || echo "Bucket not found"
aws s3 rb s3://${PROJECT_NAME}-${ENVIRONMENT}-frontend-b --force 2>/dev/null || echo "Bucket not found"
aws s3 rb s3://${PROJECT_NAME}-${ENVIRONMENT}-feature-flags --force 2>/dev/null || echo "Bucket not found"

echo "☁️ Listing CloudFront distributions to delete manually..."
aws cloudfront list-distributions --query "DistributionList.Items[?contains(Comment, '${PROJECT_NAME}')].{Id:Id,Comment:Comment}" --output table

echo "✅ Demo cleanup completed!"
echo "⚠️  Remember to delete CloudFront distributions manually from AWS Console"
