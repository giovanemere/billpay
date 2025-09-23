#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { z } from 'zod';

const server = new Server({
  name: 'billpay-deploy-mcp',
  version: '1.0.0',
});

// Schemas
const SetupInfrastructureSchema = z.object({
  projectName: z.string().default('billpay'),
  region: z.string().default('us-east-1'),
  environment: z.enum(['dev', 'staging', 'prod']).default('dev'),
});

const CreateECRRepositoriesSchema = z.object({
  region: z.string().default('us-east-1'),
});

const DeployEKSClusterSchema = z.object({
  clusterName: z.string().default('billpay-cluster'),
  region: z.string().default('us-east-1'),
  nodeInstanceType: z.string().default('t3.medium'),
  minNodes: z.number().default(1),
  maxNodes: z.number().default(3),
});

const SetupFrontendInfraSchema = z.object({
  region: z.string().default('us-east-1'),
  domains: z.array(z.string()).optional(),
});

const DeployApplicationSchema = z.object({
  appName: z.string(),
  appType: z.enum(['backend', 'frontend']),
  imageUri: z.string().optional(),
  namespace: z.string().default('default'),
});

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'setup_complete_infrastructure',
        description: 'Setup complete AWS infrastructure for BillPay (VPC, IAM, ECR, EKS, S3, CloudFront)',
        inputSchema: SetupInfrastructureSchema,
      },
      {
        name: 'create_ecr_repositories',
        description: 'Create ECR repositories for all BillPay microservices',
        inputSchema: CreateECRRepositoriesSchema,
      },
      {
        name: 'deploy_eks_cluster',
        description: 'Deploy EKS cluster with proper networking and node groups',
        inputSchema: DeployEKSClusterSchema,
      },
      {
        name: 'setup_frontend_infrastructure',
        description: 'Setup S3 buckets and CloudFront distributions for frontend apps',
        inputSchema: SetupFrontendInfraSchema,
      },
      {
        name: 'deploy_application',
        description: 'Deploy specific application (backend to EKS or frontend to S3/CloudFront)',
        inputSchema: DeployApplicationSchema,
      },
      {
        name: 'generate_terraform_modules',
        description: 'Generate Terraform modules based on project analysis',
        inputSchema: z.object({
          outputPath: z.string().default('/home/giovanemere/periferia/billpay/terraform'),
        }),
      },
      {
        name: 'setup_ci_cd_pipelines',
        description: 'Generate GitHub Actions workflows for all repositories',
        inputSchema: z.object({
          projectPath: z.string().default('/home/giovanemere/periferia/billpay'),
        }),
      },
      {
        name: 'setup_backstage_integration',
        description: 'Setup Backstage catalog, templates and TechDocs integration',
        inputSchema: z.object({
          projectPath: z.string().default('/home/giovanemere/periferia/billpay'),
          githubOrg: z.string().default('giovanemere'),
        }),
      },
      {
        name: 'generate_software_templates',
        description: 'Generate Backstage software templates for microservices and frontends',
        inputSchema: z.object({
          templateTypes: z.array(z.enum(['microservice', 'frontend', 'infrastructure'])).default(['microservice', 'frontend']),
        }),
      },
      {
        name: 'configure_techdocs',
        description: 'Configure TechDocs integration with MkDocs and S3 publisher',
        inputSchema: z.object({
          s3Bucket: z.string().optional(),
          region: z.string().default('us-east-1'),
        }),
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'setup_complete_infrastructure':
        return await setupCompleteInfrastructure(args);
      case 'create_ecr_repositories':
        return await createECRRepositories(args);
      case 'deploy_eks_cluster':
        return await deployEKSCluster(args);
      case 'setup_frontend_infrastructure':
        return await setupFrontendInfrastructure(args);
      case 'deploy_application':
        return await deployApplication(args);
      case 'generate_terraform_modules':
        return await generateTerraformModules(args);
      case 'setup_ci_cd_pipelines':
        return await setupCICDPipelines(args);
      case 'setup_backstage_integration':
        return await setupBackstageIntegration(args);
      case 'generate_software_templates':
        return await generateSoftwareTemplates(args);
      case 'configure_techdocs':
        return await configureTechDocs(args);
      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${error instanceof Error ? error.message : String(error)}`,
        },
      ],
    };
  }
});

async function setupCompleteInfrastructure(args: any) {
  const params = SetupInfrastructureSchema.parse(args);
  
  const steps = [
    '🌐 Creating VPC and networking (10.0.0.0/16)',
    '🔐 Setting up IAM roles and policies',
    '📦 Creating ECR repositories (4 repos)',
    '☸️  Deploying EKS cluster',
    '🖥️  Setting up frontend infrastructure (S3 + CloudFront)',
    '📊 Configuring monitoring and logging',
    '🔒 Setting up security groups and secrets',
  ];

  const awsCommands = [
    '# 1. VPC Setup',
    `aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=${params.projectName}-vpc}]'`,
    '',
    '# 2. ECR Repositories',
    'aws ecr create-repository --repository-name billpay-backend',
    'aws ecr create-repository --repository-name billpay-frontend-a',
    'aws ecr create-repository --repository-name billpay-frontend-b',
    'aws ecr create-repository --repository-name billpay-feature-flags',
    '',
    '# 3. EKS Cluster',
    `aws eks create-cluster --name ${params.projectName}-cluster --version 1.28`,
    '',
    '# 4. S3 Buckets for Frontend',
    `aws s3 mb s3://${params.projectName}-frontend-a-${params.environment}`,
    `aws s3 mb s3://${params.projectName}-frontend-b-${params.environment}`,
    `aws s3 mb s3://${params.projectName}-feature-flags-${params.environment}`,
  ];

  return {
    content: [
      {
        type: 'text',
        text: `🚀 Setting up complete infrastructure for ${params.projectName} (${params.environment})\n` +
              `Region: ${params.region}\n\n` +
              `Execution Plan:\n${steps.join('\n')}\n\n` +
              `AWS Commands to Execute:\n${awsCommands.join('\n')}\n\n` +
              `💰 Estimated Monthly Cost: $170-265\n` +
              `⏱️  Estimated Setup Time: 30-45 minutes\n\n` +
              `✅ Infrastructure setup plan generated successfully`,
      },
    ],
  };
}

async function createECRRepositories(args: any) {
  const params = CreateECRRepositoriesSchema.parse(args);
  
  const repositories = [
    'billpay-backend',
    'billpay-frontend-a', 
    'billpay-frontend-b',
    'billpay-feature-flags'
  ];

  const commands = repositories.map(repo => 
    `aws ecr create-repository --repository-name ${repo} --region ${params.region}`
  );

  return {
    content: [
      {
        type: 'text',
        text: `📦 Creating ECR repositories in ${params.region}:\n\n` +
              repositories.map(repo => `- ${repo}`).join('\n') + '\n\n' +
              `Commands to execute:\n${commands.join('\n')}\n\n` +
              `Next: Build and push Docker images to these repositories`,
      },
    ],
  };
}

async function deployEKSCluster(args: any) {
  const params = DeployEKSClusterSchema.parse(args);
  
  const commands = [
    `# Create EKS cluster`,
    `aws eks create-cluster --name ${params.clusterName} \\`,
    `  --version 1.28 \\`,
    `  --role-arn arn:aws:iam::<account>:role/EKSClusterRole \\`,
    `  --resources-vpc-config subnetIds=<subnet-ids>,securityGroupIds=<sg-ids>`,
    '',
    `# Create node group`,
    `aws eks create-nodegroup --cluster-name ${params.clusterName} \\`,
    `  --nodegroup-name ${params.clusterName}-nodes \\`,
    `  --instance-types ${params.nodeInstanceType} \\`,
    `  --capacity-type ON_DEMAND \\`,
    `  --scaling-config minSize=${params.minNodes},maxSize=${params.maxNodes},desiredSize=${params.minNodes}`,
    '',
    `# Update kubeconfig`,
    `aws eks update-kubeconfig --region ${params.region} --name ${params.clusterName}`,
  ];

  return {
    content: [
      {
        type: 'text',
        text: `☸️  Deploying EKS cluster: ${params.clusterName}\n` +
              `Region: ${params.region}\n` +
              `Instance Type: ${params.nodeInstanceType}\n` +
              `Node Range: ${params.minNodes}-${params.maxNodes}\n\n` +
              `Commands:\n${commands.join('\n')}\n\n` +
              `⏱️  Cluster creation takes ~15-20 minutes`,
      },
    ],
  };
}

async function setupFrontendInfrastructure(args: any) {
  const params = SetupFrontendInfraSchema.parse(args);
  
  const frontendApps = [
    'billpay-frontend-a',
    'billpay-frontend-b', 
    'billpay-feature-flags'
  ];

  const s3Commands = frontendApps.map(app => 
    `aws s3 mb s3://${app} --region ${params.region}`
  );

  const cloudfrontCommands = frontendApps.map(app => 
    `aws cloudfront create-distribution --distribution-config file://${app}-config.json`
  );

  return {
    content: [
      {
        type: 'text',
        text: `🖥️  Setting up frontend infrastructure in ${params.region}\n\n` +
              `Applications:\n${frontendApps.map(app => `- ${app}`).join('\n')}\n\n` +
              `S3 Buckets:\n${s3Commands.join('\n')}\n\n` +
              `CloudFront Distributions:\n${cloudfrontCommands.join('\n')}\n\n` +
              `Note: CloudFront distribution configs need to be created first`,
      },
    ],
  };
}

async function deployApplication(args: any) {
  const params = DeployApplicationSchema.parse(args);
  
  if (params.appType === 'backend') {
    return {
      content: [
        {
          type: 'text',
          text: `🚀 Deploying backend application: ${params.appName}\n` +
                `Namespace: ${params.namespace}\n` +
                `Image: ${params.imageUri || 'Not specified'}\n\n` +
                `Steps:\n` +
                `1. Build Docker image\n` +
                `2. Push to ECR\n` +
                `3. Deploy to EKS\n` +
                `4. Configure service and ingress\n\n` +
                `Kubernetes manifests will be generated automatically`,
        },
      ],
    };
  } else {
    return {
      content: [
        {
          type: 'text',
          text: `🖥️  Deploying frontend application: ${params.appName}\n\n` +
                `Steps:\n` +
                `1. Build Angular application\n` +
                `2. Upload to S3 bucket\n` +
                `3. Invalidate CloudFront cache\n` +
                `4. Update DNS (if configured)\n\n` +
                `Application will be available via CloudFront URL`,
        },
      ],
    };
  }
}

async function generateTerraformModules(args: any) {
  const { outputPath } = args;
  
  const modules = [
    'vpc - Network infrastructure',
    'eks - Kubernetes cluster',
    'ecr - Container registries', 
    'iam - Roles and policies',
    's3-cloudfront - Frontend hosting',
    'monitoring - CloudWatch setup'
  ];

  return {
    content: [
      {
        type: 'text',
        text: `🏗️  Generating Terraform modules at: ${outputPath}\n\n` +
              `Modules to create:\n${modules.map(m => `- ${m}`).join('\n')}\n\n` +
              `Structure:\n` +
              `${outputPath}/\n` +
              `├── modules/\n` +
              `│   ├── vpc/\n` +
              `│   ├── eks/\n` +
              `│   ├── ecr/\n` +
              `│   └── s3-cloudfront/\n` +
              `├── environments/\n` +
              `│   ├── dev/\n` +
              `│   ├── staging/\n` +
              `│   └── prod/\n` +
              `└── main.tf\n\n` +
              `Next: Execute terraform init && terraform plan`,
      },
    ],
  };
}

async function setupCICDPipelines(args: any) {
  const { projectPath } = args;
  
  const pipelines = [
    'Backend: Build → Test → Docker → ECR → EKS Deploy',
    'Frontend A: Build → Test → S3 Upload → CloudFront Invalidate',
    'Frontend B: Build → Test → S3 Upload → CloudFront Invalidate', 
    'Feature Flags: Build → Test → S3 Upload → CloudFront Invalidate',
    'Infrastructure: Terraform Plan → Apply (on merge)'
  ];

  return {
    content: [
      {
        type: 'text',
        text: `⚙️  Setting up CI/CD pipelines for: ${projectPath}\n\n` +
              `Pipelines to create:\n${pipelines.map(p => `- ${p}`).join('\n')}\n\n` +
              `GitHub Actions workflows will be generated for:\n` +
              `- Automated testing\n` +
              `- Docker image building\n` +
              `- ECR push\n` +
              `- EKS deployment\n` +
              `- S3 upload for frontends\n` +
              `- CloudFront invalidation\n\n` +
              `Secrets needed in GitHub:\n` +
              `- AWS_ACCESS_KEY_ID\n` +
              `- AWS_SECRET_ACCESS_KEY\n` +
              `- AWS_REGION\n` +
              `- ECR_REGISTRY`,
      },
    ],
  };
}

async function setupBackstageIntegration(args: any) {
  const { projectPath, githubOrg } = args;
  
  const components = [
    'Service Catalog - Auto-discovery de repositorios',
    'Software Templates - Templates para microservicios y frontends',
    'TechDocs - Documentación técnica integrada',
    'GitHub Integration - Sync automático con repositorios'
  ];

  const structure = [
    `${projectPath}/backstage/`,
    `├── app-config.yaml`,
    `├── catalog/`,
    `│   ├── all.yaml`,
    `│   ├── systems/`,
    `│   ├── components/`,
    `│   └── resources/`,
    `├── scaffolder-templates/`,
    `└── techdocs/`
  ];

  return {
    content: [
      {
        type: 'text',
        text: `🎭 Setting up Backstage integration for: ${projectPath}\n` +
              `GitHub Organization: ${githubOrg}\n\n` +
              `Components to configure:\n${components.map(c => `- ${c}`).join('\n')}\n\n` +
              `Directory structure:\n${structure.join('\n')}\n\n` +
              `Next steps:\n` +
              `1. Generate catalog files\n` +
              `2. Configure GitHub integration\n` +
              `3. Setup software templates\n` +
              `4. Configure TechDocs publisher`,
      },
    ],
  };
}

async function generateSoftwareTemplates(args: any) {
  const { templateTypes } = args;
  
  const templates = {
    microservice: 'Java/Spring Boot microservice with Docker and K8s manifests',
    frontend: 'Angular microfrontend with Module Federation',
    infrastructure: 'OpenTofu infrastructure module'
  };

  const selectedTemplates = templateTypes.map(type => `- ${type}: ${templates[type]}`);

  return {
    content: [
      {
        type: 'text',
        text: `🎭 Generating Backstage software templates\n\n` +
              `Templates to create:\n${selectedTemplates.join('\n')}\n\n` +
              `Each template will include:\n` +
              `- Scaffolder template YAML\n` +
              `- Cookiecutter template structure\n` +
              `- GitHub Actions workflow\n` +
              `- Documentation template\n` +
              `- Catalog-info.yaml\n\n` +
              `Templates will be stored in:\n` +
              `- /templates/cookiecutter/{template-name}/\n` +
              `- /backstage/scaffolder-templates/{template-name}.yaml`,
      },
    ],
  };
}

async function configureTechDocs(args: any) {
  const { s3Bucket, region } = args;
  
  const config = [
    'MkDocs configuration for documentation',
    'S3 publisher for static site hosting',
    'GitHub integration for auto-sync',
    'Custom theme and plugins'
  ];

  return {
    content: [
      {
        type: 'text',
        text: `📚 Configuring TechDocs integration\n` +
              `Region: ${region}\n` +
              `S3 Bucket: ${s3Bucket || 'billpay-techdocs-' + region}\n\n` +
              `Configuration includes:\n${config.map(c => `- ${c}`).join('\n')}\n\n` +
              `Files to create:\n` +
              `- backstage/techdocs/mkdocs.yml\n` +
              `- backstage/app-config.yaml (techdocs section)\n` +
              `- docs/ structure for each service\n\n` +
              `Documentation will be available at:\n` +
              `https://backstage.billpay.com/docs/`,
      },
    ],
  };
}

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
