# Template Context - BillPay Complete Stack

## 📋 TEMPLATE REQUIREMENTS

### **Input Parameters Needed:**
```yaml
# Project Configuration
project_name: string (pattern: ^[a-z0-9-]+$)
environment: enum [dev, staging, prod]
deployment_type: enum [simulation, real-aws-oidc, real-aws-legacy]
cloud_provider: enum [aws, gcp, azure, oci]
region: string (cloud-specific)

# BillPay Applications
deploy_backend_api: boolean (default: true)
deploy_payment_service: boolean (default: true)
deploy_user_service: boolean (default: true)
deploy_admin_service: boolean (default: false)
deploy_frontend_payment: boolean (default: true)
deploy_frontend_admin: boolean (default: true)
deploy_feature_flags: boolean (default: true)

# Infrastructure Components
deploy_vpc: boolean (default: true)
deploy_kubernetes: enum [eks, gke, aks, oke]
deploy_container_registry: boolean (default: true)
deploy_object_storage: boolean (default: true)
deploy_load_balancer: boolean (default: true)
deploy_secrets_manager: boolean (default: true)
deploy_monitoring: boolean (default: false)
```

### **Skeleton Files Structure:**
```
skeleton/
├── catalog-info.yaml.j2           # Backstage catalog registration
├── README.md.j2                   # Project documentation
├── .github/
│   └── workflows/
│       ├── deploy.yml.j2          # Main deployment workflow
│       ├── destroy.yml.j2         # Cleanup workflow
│       └── manage.yml.j2          # Management actions
├── terraform/
│   ├── terragrunt.hcl.j2         # Terragrunt configuration
│   ├── variables.tf.j2           # Terraform variables
│   └── outputs.tf.j2             # Terraform outputs
├── docs/
│   ├── architecture.md.j2        # Architecture documentation
│   └── deployment.md.j2          # Deployment guide
└── scripts/
    ├── setup.sh.j2              # Setup script
    └── validate.sh.j2           # Validation script
```

## 🔧 TEMPLATE GENERATION LOGIC

### **Conditional File Generation:**
```jinja2
{% if deploy_backend_api %}
# Include backend-specific files
├── src/main/java/
├── build.gradle
├── Dockerfile
└── k8s/backend-deployment.yaml
{% endif %}

{% if deploy_frontend_payment %}
# Include frontend-specific files
├── angular.json
├── package.json
├── src/app/
└── s3-deployment.yaml
{% endif %}

{% if cloud_provider == "aws" %}
# AWS-specific configurations
├── terraform/aws/
├── .github/workflows/aws-deploy.yml
{% elif cloud_provider == "gcp" %}
# GCP-specific configurations
├── terraform/gcp/
├── .github/workflows/gcp-deploy.yml
{% endif %}
```
