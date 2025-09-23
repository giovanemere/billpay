# AWS Infrastructure Requirements for BillPay
Generated: Tue Sep 23 09:38:05 -05 2025

## Required AWS Services

### Backend Application: poc-billpay-back
- **ECR Repository**: Container registry
- **EKS**: Kubernetes cluster
- **Application Load Balancer**: Traffic distribution
- **RDS**: Database (if needed)

### Frontend Application: poc-billpay-front-a
- **S3 Bucket**: Static website hosting
- **CloudFront**: CDN distribution
- **Route 53**: Custom domain (optional)

### Frontend Application: poc-billpay-front-b
- **S3 Bucket**: Static website hosting
- **CloudFront**: CDN distribution
- **Route 53**: Custom domain (optional)

### Frontend Application: poc-billpay-front-feature-flags
- **S3 Bucket**: Static website hosting
- **CloudFront**: CDN distribution
- **Route 53**: Custom domain (optional)

### Backend Application: templates_backstage
- **ECR Repository**: Container registry
- **EKS**: Kubernetes cluster
- **Application Load Balancer**: Traffic distribution
- **RDS**: Database (if needed)

### Infrastructure as Code: ia-ops-iac
- **IAM Roles**: Terraform execution
- **S3 Backend**: Terraform state
- **DynamoDB**: State locking

## Core Infrastructure Requirements

### Networking
- **VPC**: Isolated network environment
- **Public Subnets**: Load balancers and NAT gateways
- **Private Subnets**: EKS worker nodes
- **Internet Gateway**: Public internet access
- **NAT Gateway**: Outbound internet for private subnets

### Security
- **Security Groups**: Network-level security
- **IAM Roles**: Service permissions
- **AWS Secrets Manager**: Sensitive data storage
- **Certificate Manager**: SSL/TLS certificates

### Container Infrastructure
- **EKS Cluster**: Kubernetes orchestration
- **EKS Node Groups**: Worker nodes
- **ECR Repositories**: Container images (2 repositories needed)
- **AWS Load Balancer Controller**: Ingress management

### Monitoring & Logging
- **CloudWatch**: Logs and metrics
- **CloudWatch Container Insights**: EKS monitoring
- **AWS X-Ray**: Distributed tracing (optional)

## Estimated Costs (Monthly)
- **EKS Cluster**: ~3 (cluster) + ~0-100 (nodes)
- **ALB**: ~0-30
- **NAT Gateway**: ~5
- **ECR**: ~-5 (depending on image size)
- **CloudFront**: ~-10 (depending on traffic)
- **Route 53**: ~./analyze-project.sh.50 per hosted zone

**Total Estimated**: 70-265/month
