#!/bin/bash

echo "🔍 Starting BillPay Project Analysis..."
echo "=================================="

# Step 1: Clone all repositories
echo "📥 Step 1: Cloning repositories..."
cd /home/giovanemere/periferia/billpay

# Clone repositories manually first to ensure we have access
repos=(
    "git@github.com:giovanemere/poc-billpay-back.git"
    "git@github.com:giovanemere/poc-billpay-front-a.git"
    "git@github.com:giovanemere/poc-billpay-front-b.git"
    "git@github.com:giovanemere/poc-billpay-front-feature-flags.git"
    "git@github.com:giovanemere/templates_backstage.git"
    "git@github.com:giovanemere/ia-ops-iac.git"
)

for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    if [ -d "$repo_name" ]; then
        echo "✓ $repo_name already exists, pulling latest..."
        cd "$repo_name" && git pull && cd ..
    else
        echo "📥 Cloning $repo_name..."
        git clone "$repo" || echo "⚠️  Failed to clone $repo_name"
    fi
done

echo ""
echo "📊 Step 2: Analyzing project structure..."

# Create analysis directory
mkdir -p analysis

# Analyze each repository
for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    if [ -d "$repo_name" ]; then
        echo "🔍 Analyzing $repo_name..."
        
        # Check for key files and create summary
        {
            echo "# Analysis for $repo_name"
            echo "Generated: $(date)"
            echo ""
            
            # Check technology stack
            echo "## Technology Stack"
            [ -f "$repo_name/package.json" ] && echo "- Node.js (package.json found)"
            [ -f "$repo_name/Dockerfile" ] && echo "- Docker (Dockerfile found)"
            [ -f "$repo_name/docker-compose.yml" ] && echo "- Docker Compose"
            [ -d "$repo_name/kubernetes" ] && echo "- Kubernetes manifests"
            [ -d "$repo_name/.github/workflows" ] && echo "- GitHub Actions CI/CD"
            [ -f "$repo_name/terraform" ] && echo "- Terraform IaC"
            
            echo ""
            echo "## File Structure"
            find "$repo_name" -maxdepth 2 -type f -name "*.json" -o -name "Dockerfile*" -o -name "*.yml" -o -name "*.yaml" | head -20
            
            echo ""
            echo "## Dependencies (if Node.js)"
            if [ -f "$repo_name/package.json" ]; then
                cat "$repo_name/package.json" | grep -A 20 '"dependencies"' | head -15
            fi
            
            echo ""
            echo "---"
            
        } > "analysis/${repo_name}-analysis.md"
    fi
done

echo ""
echo "🎯 Step 3: Identifying AWS Requirements..."

# Create comprehensive AWS requirements analysis
{
    echo "# AWS Infrastructure Requirements for BillPay"
    echo "Generated: $(date)"
    echo ""
    
    echo "## Required AWS Services"
    echo ""
    
    # Analyze each repo for AWS needs
    frontend_count=0
    backend_count=0
    has_docker=false
    
    for repo in "${repos[@]}"; do
        repo_name=$(basename "$repo" .git)
        if [ -d "$repo_name" ]; then
            if [[ "$repo_name" == *"front"* ]]; then
                ((frontend_count++))
                echo "### Frontend Application: $repo_name"
                echo "- **S3 Bucket**: Static website hosting"
                echo "- **CloudFront**: CDN distribution"
                echo "- **Route 53**: Custom domain (optional)"
                echo ""
            elif [[ "$repo_name" == *"back"* ]]; then
                ((backend_count++))
                echo "### Backend Application: $repo_name"
                echo "- **ECR Repository**: Container registry"
                echo "- **EKS**: Kubernetes cluster"
                echo "- **Application Load Balancer**: Traffic distribution"
                echo "- **RDS**: Database (if needed)"
                echo ""
            elif [[ "$repo_name" == *"iac"* ]]; then
                echo "### Infrastructure as Code: $repo_name"
                echo "- **IAM Roles**: Terraform execution"
                echo "- **S3 Backend**: Terraform state"
                echo "- **DynamoDB**: State locking"
                echo ""
            fi
            
            [ -f "$repo_name/Dockerfile" ] && has_docker=true
        fi
    done
    
    echo "## Core Infrastructure Requirements"
    echo ""
    echo "### Networking"
    echo "- **VPC**: Isolated network environment"
    echo "- **Public Subnets**: Load balancers and NAT gateways"
    echo "- **Private Subnets**: EKS worker nodes"
    echo "- **Internet Gateway**: Public internet access"
    echo "- **NAT Gateway**: Outbound internet for private subnets"
    echo ""
    
    echo "### Security"
    echo "- **Security Groups**: Network-level security"
    echo "- **IAM Roles**: Service permissions"
    echo "- **AWS Secrets Manager**: Sensitive data storage"
    echo "- **Certificate Manager**: SSL/TLS certificates"
    echo ""
    
    if [ "$has_docker" = true ]; then
        echo "### Container Infrastructure"
        echo "- **EKS Cluster**: Kubernetes orchestration"
        echo "- **EKS Node Groups**: Worker nodes"
        echo "- **ECR Repositories**: Container images ($backend_count repositories needed)"
        echo "- **AWS Load Balancer Controller**: Ingress management"
        echo ""
    fi
    
    echo "### Monitoring & Logging"
    echo "- **CloudWatch**: Logs and metrics"
    echo "- **CloudWatch Container Insights**: EKS monitoring"
    echo "- **AWS X-Ray**: Distributed tracing (optional)"
    echo ""
    
    echo "## Estimated Costs (Monthly)"
    echo "- **EKS Cluster**: ~$73 (cluster) + ~$30-100 (nodes)"
    echo "- **ALB**: ~$20-30"
    echo "- **NAT Gateway**: ~$45"
    echo "- **ECR**: ~$1-5 (depending on image size)"
    echo "- **CloudFront**: ~$1-10 (depending on traffic)"
    echo "- **Route 53**: ~$0.50 per hosted zone"
    echo ""
    echo "**Total Estimated**: $170-265/month"
    
} > "analysis/aws-requirements.md"

echo ""
echo "✅ Analysis Complete!"
echo "📁 Results saved in: /home/giovanemere/periferia/billpay/analysis/"
echo ""
echo "📋 Summary:"
echo "- Repositories analyzed: $(ls -1d */ 2>/dev/null | wc -l)"
echo "- Frontend apps: $(ls -1d *front* 2>/dev/null | wc -l)"
echo "- Backend apps: $(ls -1d *back* 2>/dev/null | wc -l)"
echo "- Infrastructure repos: $(ls -1d *iac* *template* 2>/dev/null | wc -l)"
echo ""
echo "🚀 Next steps:"
echo "1. Review analysis files in ./analysis/"
echo "2. Verify AWS requirements"
echo "3. Create deployment MCP based on findings"
echo "4. Execute infrastructure provisioning"
