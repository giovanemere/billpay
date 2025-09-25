# GitHub Repository Context - BillPay

## 📦 REPOSITORY STRUCTURE GENERATED

### **Repository Name Pattern:**
```
giovanemere/{project_name}
Example: giovanemere/billpay-demo-prod
```

### **Generated Files:**
```
{project_name}/
├── .github/
│   ├── workflows/
│   │   ├── deploy.yml              # Main deployment (triggers ia-ops-iac)
│   │   ├── destroy.yml             # Infrastructure cleanup
│   │   ├── manage.yml              # Post-deployment management
│   │   └── validate.yml            # Pre-deployment validation
│   └── ISSUE_TEMPLATE/
│       └── deployment-issue.md     # Issue template for deployments
├── catalog-info.yaml               # Backstage catalog registration
├── README.md                       # Project documentation with architecture
├── docs/
│   ├── architecture.md             # BillPay architecture specific to this deployment
│   ├── deployment.md               # Deployment instructions
│   └── management.md               # Post-deployment management guide
├── terraform/                      # Terraform configurations (if needed)
│   ├── terragrunt.hcl             # Environment-specific Terragrunt config
│   ├── variables.tf               # Project-specific variables
│   └── outputs.tf                 # Project outputs
└── scripts/
    ├── setup.sh                   # Local setup script
    ├── validate.sh                # Pre-deployment validation
    └── cleanup.sh                 # Local cleanup
```

## 🔐 REPOSITORY SECRETS REQUIRED

### **OIDC Configuration (Recommended):**
```bash
# Set in repository secrets
AWS_ROLE_ARN=arn:aws:iam::ACCOUNT:role/BillPayGitHubActionsRole
GITHUB_TOKEN=ghp_... (for cross-repo workflow triggers)
```

### **Legacy Configuration (Fallback):**
```bash
# Only if OIDC not available
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
```

## 🔄 WORKFLOW TRIGGERS

### **Main Deployment Workflow (deploy.yml):**
```yaml
name: Deploy BillPay Complete Stack
on:
  workflow_dispatch:
    inputs:
      deployment_type:
        type: choice
        options: [simulation, real-aws-oidc, real-aws-legacy]
      force_deploy:
        type: boolean
        default: false

jobs:
  trigger-iac-deployment:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger IAC Deployment
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            await github.rest.actions.createWorkflowDispatch({
              owner: 'giovanemere',
              repo: 'ia-ops-iac',
              workflow_id: 'deploy-billpay-complete.yml',
              ref: 'trunk',
              inputs: {
                project_name: '${{ github.event.repository.name }}',
                deployment_type: '${{ inputs.deployment_type }}',
                // ... all other parameters from template
              }
            });
```
