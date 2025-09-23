#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema, } from '@modelcontextprotocol/sdk/types.js';
import { z } from 'zod';
import simpleGit from 'simple-git';
import * as fs from 'fs-extra';
import * as path from 'path';
import * as yaml from 'yaml';
const server = new Server({
    name: 'billpay-project-analyzer',
    version: '1.0.0',
});
// Schemas
const CloneRepositoriesSchema = z.object({
    baseDir: z.string().default('/home/giovanemere/periferia/billpay'),
    repositories: z.array(z.string()).optional(),
});
const AnalyzeProjectSchema = z.object({
    projectPath: z.string(),
    includeFiles: z.array(z.string()).default(['package.json', 'Dockerfile', 'docker-compose.yml', 'kubernetes', '.github', 'terraform', 'README.md']),
});
const GenerateReportSchema = z.object({
    outputPath: z.string().default('/home/giovanemere/periferia/billpay/analysis-report.md'),
});
// Default repositories from index.md
const DEFAULT_REPOS = [
    'git@github.com:giovanemere/poc-billpay-back.git',
    'git@github.com:giovanemere/poc-billpay-front-a.git',
    'git@github.com:giovanemere/poc-billpay-front-b.git',
    'git@github.com:giovanemere/poc-billpay-front-feature-flags.git',
    'git@github.com:giovanemere/templates_backstage.git',
    'git@github.com:giovanemere/ia-ops-iac.git'
];
server.setRequestHandler(ListToolsRequestSchema, async () => {
    return {
        tools: [
            {
                name: 'clone_repositories',
                description: 'Clone all BillPay project repositories for analysis',
                inputSchema: CloneRepositoriesSchema,
            },
            {
                name: 'analyze_project_structure',
                description: 'Analyze project structure, dependencies, and configurations',
                inputSchema: AnalyzeProjectSchema,
            },
            {
                name: 'scan_docker_configs',
                description: 'Scan for Docker and Kubernetes configurations',
                inputSchema: z.object({
                    projectPath: z.string(),
                }),
            },
            {
                name: 'analyze_ci_cd_pipelines',
                description: 'Analyze GitHub Actions and CI/CD configurations',
                inputSchema: z.object({
                    projectPath: z.string(),
                }),
            },
            {
                name: 'generate_architecture_report',
                description: 'Generate comprehensive architecture and deployment report',
                inputSchema: GenerateReportSchema,
            },
            {
                name: 'identify_aws_requirements',
                description: 'Identify specific AWS services and configurations needed',
                inputSchema: z.object({
                    projectPath: z.string(),
                }),
            },
        ],
    };
});
server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;
    try {
        switch (name) {
            case 'clone_repositories':
                return await cloneRepositories(args);
            case 'analyze_project_structure':
                return await analyzeProjectStructure(args);
            case 'scan_docker_configs':
                return await scanDockerConfigs(args);
            case 'analyze_ci_cd_pipelines':
                return await analyzeCICDPipelines(args);
            case 'generate_architecture_report':
                return await generateArchitectureReport(args);
            case 'identify_aws_requirements':
                return await identifyAWSRequirements(args);
            default:
                throw new Error(`Unknown tool: ${name}`);
        }
    }
    catch (error) {
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
async function cloneRepositories(args) {
    const params = CloneRepositoriesSchema.parse(args);
    const repos = params.repositories || DEFAULT_REPOS;
    const results = [];
    await fs.ensureDir(params.baseDir);
    for (const repoUrl of repos) {
        try {
            const repoName = path.basename(repoUrl, '.git');
            const targetDir = path.join(params.baseDir, repoName);
            if (await fs.pathExists(targetDir)) {
                results.push(`✓ ${repoName} - Already exists, pulling latest changes`);
                const git = simpleGit(targetDir);
                await git.pull();
            }
            else {
                results.push(`✓ ${repoName} - Cloning repository`);
                const git = simpleGit();
                await git.clone(repoUrl, targetDir);
            }
        }
        catch (error) {
            results.push(`✗ ${repoUrl} - Error: ${error instanceof Error ? error.message : String(error)}`);
        }
    }
    return {
        content: [
            {
                type: 'text',
                text: `Repository cloning completed:\n\n${results.join('\n')}\n\nNext: Run analyze_project_structure to examine the codebase`,
            },
        ],
    };
}
async function analyzeProjectStructure(args) {
    const params = AnalyzeProjectSchema.parse(args);
    const analysis = {
        repositories: {},
        technologies: new Set(),
        deploymentConfigs: [],
        dependencies: {},
    };
    const repos = await fs.readdir(params.projectPath);
    for (const repo of repos) {
        const repoPath = path.join(params.projectPath, repo);
        const stat = await fs.stat(repoPath);
        if (stat.isDirectory() && !repo.startsWith('.')) {
            analysis.repositories[repo] = await analyzeRepository(repoPath, params.includeFiles);
        }
    }
    return {
        content: [
            {
                type: 'text',
                text: `Project Structure Analysis:\n\n${JSON.stringify(analysis, null, 2)}`,
            },
        ],
    };
}
async function analyzeRepository(repoPath, includeFiles) {
    const repoAnalysis = {
        type: 'unknown',
        technologies: [],
        hasDockerfile: false,
        hasKubernetes: false,
        hasCICD: false,
        dependencies: {},
        ports: [],
    };
    // Check for key files
    for (const file of includeFiles) {
        const filePath = path.join(repoPath, file);
        if (await fs.pathExists(filePath)) {
            const stat = await fs.stat(filePath);
            if (stat.isFile()) {
                switch (file) {
                    case 'package.json':
                        const pkg = await fs.readJson(filePath);
                        repoAnalysis.type = 'nodejs';
                        repoAnalysis.dependencies = pkg.dependencies || {};
                        repoAnalysis.technologies.push('Node.js');
                        break;
                    case 'Dockerfile':
                        repoAnalysis.hasDockerfile = true;
                        repoAnalysis.technologies.push('Docker');
                        break;
                }
            }
            else if (stat.isDirectory()) {
                if (file === 'kubernetes' || file === 'k8s') {
                    repoAnalysis.hasKubernetes = true;
                    repoAnalysis.technologies.push('Kubernetes');
                }
                if (file === '.github') {
                    repoAnalysis.hasCICD = true;
                    repoAnalysis.technologies.push('GitHub Actions');
                }
            }
        }
    }
    return repoAnalysis;
}
async function scanDockerConfigs(args) {
    const { projectPath } = args;
    const dockerConfigs = [];
    const repos = await fs.readdir(projectPath);
    for (const repo of repos) {
        const repoPath = path.join(projectPath, repo);
        const dockerfilePath = path.join(repoPath, 'Dockerfile');
        const composePath = path.join(repoPath, 'docker-compose.yml');
        if (await fs.pathExists(dockerfilePath)) {
            const dockerfile = await fs.readFile(dockerfilePath, 'utf8');
            dockerConfigs.push({
                repository: repo,
                type: 'Dockerfile',
                content: dockerfile.split('\n').slice(0, 10).join('\n') + '...',
            });
        }
        if (await fs.pathExists(composePath)) {
            const compose = await fs.readFile(composePath, 'utf8');
            dockerConfigs.push({
                repository: repo,
                type: 'docker-compose.yml',
                content: compose,
            });
        }
    }
    return {
        content: [
            {
                type: 'text',
                text: `Docker Configurations Found:\n\n${JSON.stringify(dockerConfigs, null, 2)}`,
            },
        ],
    };
}
async function analyzeCICDPipelines(args) {
    const { projectPath } = args;
    const pipelines = [];
    const repos = await fs.readdir(projectPath);
    for (const repo of repos) {
        const githubPath = path.join(projectPath, repo, '.github', 'workflows');
        if (await fs.pathExists(githubPath)) {
            const workflows = await fs.readdir(githubPath);
            for (const workflow of workflows) {
                if (workflow.endsWith('.yml') || workflow.endsWith('.yaml')) {
                    const workflowPath = path.join(githubPath, workflow);
                    const content = await fs.readFile(workflowPath, 'utf8');
                    pipelines.push({
                        repository: repo,
                        workflow: workflow,
                        content: yaml.parse(content),
                    });
                }
            }
        }
    }
    return {
        content: [
            {
                type: 'text',
                text: `CI/CD Pipelines Analysis:\n\n${JSON.stringify(pipelines, null, 2)}`,
            },
        ],
    };
}
async function identifyAWSRequirements(args) {
    const { projectPath } = args;
    const awsServices = new Set();
    const requirements = [];
    // Analyze based on project structure
    const repos = await fs.readdir(projectPath);
    for (const repo of repos) {
        const repoPath = path.join(projectPath, repo);
        // Check for containerized apps
        if (await fs.pathExists(path.join(repoPath, 'Dockerfile'))) {
            awsServices.add('ECR');
            awsServices.add('EKS');
            requirements.push(`${repo}: Needs ECR repository and EKS deployment`);
        }
        // Check for frontend apps
        if (repo.includes('front')) {
            awsServices.add('CloudFront');
            awsServices.add('S3');
            requirements.push(`${repo}: Needs S3 bucket and CloudFront distribution`);
        }
        // Check for backend apps
        if (repo.includes('back')) {
            awsServices.add('ALB');
            awsServices.add('RDS');
            requirements.push(`${repo}: Needs Application Load Balancer and database`);
        }
    }
    return {
        content: [
            {
                type: 'text',
                text: `AWS Services Required:\n${Array.from(awsServices).join(', ')}\n\nDetailed Requirements:\n${requirements.join('\n')}`,
            },
        ],
    };
}
async function generateArchitectureReport(args) {
    const params = GenerateReportSchema.parse(args);
    const report = `# BillPay Project Architecture Analysis

## Generated: ${new Date().toISOString()}

## Project Overview
- **Total Repositories**: 6
- **Application Repositories**: 4
- **Infrastructure Repositories**: 2

## Technology Stack Analysis
- **Frontend**: React/Node.js applications
- **Backend**: Node.js microservices
- **Infrastructure**: Terraform/OpenTofu
- **Orchestration**: Kubernetes (EKS)
- **CI/CD**: GitHub Actions
- **Developer Portal**: Backstage

## AWS Services Required

### Core Infrastructure
- **EKS Cluster**: Container orchestration
- **VPC**: Network isolation
- **IAM**: Access management
- **ECR**: Container registry

### Application Services
- **ALB**: Load balancing
- **Route 53**: DNS management
- **CloudFront**: CDN for frontend
- **S3**: Static asset storage

### Monitoring & Security
- **CloudWatch**: Logging and monitoring
- **AWS Secrets Manager**: Secret management
- **Security Groups**: Network security

## Next Steps
1. Clone and analyze all repositories
2. Review Dockerfiles and K8s manifests
3. Create deployment automation MCP
4. Execute infrastructure provisioning
`;
    await fs.writeFile(params.outputPath, report);
    return {
        content: [
            {
                type: 'text',
                text: `Architecture report generated at: ${params.outputPath}\n\nReport includes:\n- Technology stack analysis\n- AWS services mapping\n- Deployment requirements\n- Next steps for implementation`,
            },
        ],
    };
}
async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
}
main().catch(console.error);
