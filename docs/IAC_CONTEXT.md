# IAC Repository Context - ia-ops-iac

## 🏗️ WORKFLOW: deploy-billpay-complete.yml

### **Workflow Inputs:**
```yaml
inputs:
  project_name:
    description: 'Target project name'
    required: true
    type: string
  environment:
    description: 'Environment (dev/staging/prod)'
    required: true
    type: choice
    options: [dev, staging, prod]
  deployment_type:
    description: 'Deployment type'
    required: true
    type: choice
    options: [simulation, real-aws-oidc, real-aws-legacy]
  cloud_provider:
    description: 'Cloud provider'
    required: true
    type: choice
    options: [aws, gcp, azure, oci]
  region:
    description: 'Cloud region'
    required: true
    type: string
  billpay_applications:
    description: 'BillPay apps to deploy (comma-separated booleans)'
    required: true
    type: string
    # Example: "true,true,true,false,true,true,true"
    # Order: backend_api,payment_service,user_service,admin_service,frontend_payment,frontend_admin,feature_flags
  infrastructure_components:
    description: 'Infrastructure components (comma-separated booleans)'
    required: true
    type: string
    # Example: "true,eks,true,true,true,true,false"
    # Order: vpc,kubernetes,container_registry,object_storage,load_balancer,secrets_manager,monitoring
  target_repository:
    description: 'Target repository name'
    required: true
    type: string
```

## 🔧 TERRAGRUNT STRUCTURE

### **Environment-Specific Configs:**
```
terragrunt/
├── environments/
│   ├── dev/
│   │   ├── aws/
│   │   │   ├── terragrunt.hcl     # Dev AWS config
│   │   │   ├── vpc/
│   │   │   ├── eks/
│   │   │   ├── ecr/
│   │   │   └── s3-cloudfront/
│   │   ├── gcp/
│   │   └── azure/
│   ├── staging/
│   └── prod/
├── modules/                        # Reusable Terragrunt modules
└── terragrunt.hcl                 # Global config
```

### **Dynamic Configuration Generation:**
```python
# scripts/generate_terragrunt_config.py
def generate_config(project_name, environment, cloud_provider, components):
    config = {
        "terraform": {
            "source": f"../../../modules/{cloud_provider}//"
        },
        "inputs": {
            "project_name": project_name,
            "environment": environment,
            "deploy_vpc": components["vpc"],
            "deploy_eks": components["kubernetes"] == "eks",
            "deploy_ecr": components["container_registry"],
            # ... all other components
        }
    }
    return config
```

## 🐍 PYTHON SCRIPTS CONTEXT

### **Dynamic Logic Scripts:**
```python
# scripts/billpay_deployment_orchestrator.py
class BillPayDeploymentOrchestrator:
    def __init__(self, project_name, environment, cloud_provider):
        self.project_name = project_name
        self.environment = environment
        self.cloud_provider = cloud_provider
    
    def parse_applications(self, apps_string):
        """Parse comma-separated boolean string for BillPay apps"""
        apps = apps_string.split(',')
        return {
            'backend_api': apps[0] == 'true',
            'payment_service': apps[1] == 'true',
            'user_service': apps[2] == 'true',
            'admin_service': apps[3] == 'true',
            'frontend_payment': apps[4] == 'true',
            'frontend_admin': apps[5] == 'true',
            'feature_flags': apps[6] == 'true'
        }
    
    def parse_infrastructure(self, infra_string):
        """Parse comma-separated infrastructure components"""
        infra = infra_string.split(',')
        return {
            'vpc': infra[0] == 'true',
            'kubernetes': infra[1],  # eks/gke/aks/oke
            'container_registry': infra[2] == 'true',
            'object_storage': infra[3] == 'true',
            'load_balancer': infra[4] == 'true',
            'secrets_manager': infra[5] == 'true',
            'monitoring': infra[6] == 'true'
        }
    
    def generate_deployment_plan(self, apps, infra):
        """Generate deployment plan based on selected components"""
        plan = {
            'phases': [],
            'dependencies': {},
            'estimated_time': 0
        }
        
        # Phase 1: Infrastructure
        if infra['vpc']:
            plan['phases'].append('vpc')
            plan['estimated_time'] += 5
        
        if infra['kubernetes']:
            plan['phases'].append('kubernetes')
            plan['estimated_time'] += 10
            plan['dependencies']['kubernetes'] = ['vpc']
        
        # Phase 2: Applications
        if apps['backend_api']:
            plan['phases'].append('backend_api')
            plan['estimated_time'] += 8
            plan['dependencies']['backend_api'] = ['kubernetes', 'container_registry']
        
        return plan
```
