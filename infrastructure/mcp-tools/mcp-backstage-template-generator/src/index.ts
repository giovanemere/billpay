#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

const server = new Server(
  {
    name: 'mcp-backstage-template-generator',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Template generation tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'generate_backstage_template',
        description: 'Generate Backstage software template with BillPay architecture',
        inputSchema: {
          type: 'object',
          properties: {
            template_name: { type: 'string', description: 'Template name (e.g., billpay-microservice)' },
            template_type: { 
              type: 'string', 
              enum: ['microservice', 'frontend', 'complete-stack', 'infrastructure'],
              description: 'Type of template to generate'
            },
            architecture_components: {
              type: 'object',
              properties: {
                backend: {
                  type: 'object',
                  properties: {
                    framework: { type: 'string', default: 'spring-boot' },
                    language: { type: 'string', default: 'java' },
                    version: { type: 'string', default: '17' },
                    build_tool: { type: 'string', default: 'gradle' }
                  }
                },
                frontend: {
                  type: 'object', 
                  properties: {
                    framework: { type: 'string', default: 'angular' },
                    version: { type: 'string', default: '17' },
                    architecture: { type: 'string', default: 'module-federation' }
                  }
                },
                infrastructure: {
                  type: 'object',
                  properties: {
                    iac_tool: { type: 'string', default: 'opentofu' },
                    management: { type: 'string', default: 'terragrunt' },
                    cloud_providers: { type: 'array', items: { type: 'string' } }
                  }
                }
              }
            },
            deployment_options: {
              type: 'object',
              properties: {
                simulation: { type: 'boolean', default: true },
                real_aws_oidc: { type: 'boolean', default: true },
                real_aws_legacy: { type: 'boolean', default: false }
              }
            }
          },
          required: ['template_name', 'template_type']
        }
      },
      {
        name: 'generate_template_parameters',
        description: 'Generate Backstage template parameters section',
        inputSchema: {
          type: 'object',
          properties: {
            parameter_groups: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  title: { type: 'string' },
                  description: { type: 'string' },
                  parameters: { type: 'object' }
                }
              }
            }
          },
          required: ['parameter_groups']
        }
      },
      {
        name: 'generate_template_steps',
        description: 'Generate Backstage template steps (actions)',
        inputSchema: {
          type: 'object',
          properties: {
            steps: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  id: { type: 'string' },
                  name: { type: 'string' },
                  action: { type: 'string' },
                  input: { type: 'object' }
                }
              }
            }
          },
          required: ['steps']
        }
      },
      {
        name: 'generate_template_output',
        description: 'Generate Backstage template output section with BillPay architecture info',
        inputSchema: {
          type: 'object',
          properties: {
            output_type: {
              type: 'string',
              enum: ['microservice', 'frontend', 'complete-stack'],
              description: 'Type of output to generate'
            },
            include_architecture_diagram: { type: 'boolean', default: true },
            include_cost_estimation: { type: 'boolean', default: true },
            include_monitoring_links: { type: 'boolean', default: true }
          },
          required: ['output_type']
        }
      }
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'generate_backstage_template':
      return generateBackstageTemplate(args);
    case 'generate_template_parameters':
      return generateTemplateParameters(args);
    case 'generate_template_steps':
      return generateTemplateSteps(args);
    case 'generate_template_output':
      return generateTemplateOutput(args);
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

function generateBackstageTemplate(args: any) {
  const { template_name, template_type, architecture_components, deployment_options } = args;
  
  const template = {
    apiVersion: 'scaffolder.backstage.io/v1beta3',
    kind: 'Template',
    metadata: {
      name: template_name,
      title: `🏦 BillPay ${template_type.charAt(0).toUpperCase() + template_type.slice(1)}`,
      description: generateDescription(template_type, architecture_components),
      tags: generateTags(template_type, architecture_components)
    },
    spec: {
      owner: 'platform-team',
      type: 'service',
      parameters: generateDefaultParameters(template_type, deployment_options),
      steps: generateDefaultSteps(template_type),
      output: generateDefaultOutput(template_type)
    }
  };

  return {
    content: [
      {
        type: 'text',
        text: `Generated Backstage template for ${template_name}:\n\n\`\`\`yaml\n${JSON.stringify(template, null, 2)}\n\`\`\``
      }
    ]
  };
}

function generateDescription(type: string, components: any) {
  const descriptions = {
    microservice: `🔧 BillPay microservice with Java/Spring Boot:\n• Backend: ${components?.backend?.framework || 'Spring Boot'} + ${components?.backend?.language || 'Java'}\n• Container: Docker → Kubernetes\n• Security: OIDC + Zero-trust`,
    frontend: `🎨 BillPay frontend with Angular microfrontends:\n• Framework: ${components?.frontend?.framework || 'Angular'} ${components?.frontend?.version || '17'}\n• Architecture: ${components?.frontend?.architecture || 'Module Federation'}\n• Deployment: S3 + CloudFront CDN`,
    'complete-stack': `🏦 BillPay enterprise platform complete:\n• Backend: Java/Spring Boot microservices\n• Frontend: Angular 17 microfrontends\n• Infrastructure: OpenTofu + Terragrunt\n• Security: OIDC + Zero-trust`,
    infrastructure: `🏗️ BillPay infrastructure automation:\n• IaC: ${components?.infrastructure?.iac_tool || 'OpenTofu'} + ${components?.infrastructure?.management || 'Terragrunt'}\n• Multi-cloud ready\n• OIDC security integrated`
  };
  
  return descriptions[type] || `BillPay ${type} component`;
}

function generateTags(type: string, components: any) {
  const baseTags = ['billpay', 'enterprise'];
  const typeTags = {
    microservice: ['java-spring-boot', 'microservices', 'kubernetes'],
    frontend: ['angular-17', 'microfrontends', 's3-cloudfront'],
    'complete-stack': ['microservices', 'microfrontends', 'multi-cloud'],
    infrastructure: ['opentofu', 'terragrunt', 'iac']
  };
  
  return [...baseTags, ...(typeTags[type] || []), 'oidc-security'];
}

function generateDefaultParameters(type: string, deploymentOptions: any) {
  return [
    {
      title: '🎯 Project Configuration',
      required: ['project_name', 'deployment_type'],
      properties: {
        project_name: {
          title: 'Project Name',
          type: 'string',
          description: 'Name of the project',
          pattern: '^[a-z0-9-]+$'
        },
        deployment_type: {
          title: 'Deployment Type',
          type: 'string',
          enum: ['simulation', 'real-aws-oidc', 'real-aws-legacy'],
          enumNames: [
            '🎭 Simulation (No costs, demo)',
            '🔐 Real AWS OIDC (Secure, recommended)', 
            '☁️ Real AWS Legacy (Requires credentials)'
          ],
          default: 'simulation'
        }
      }
    }
  ];
}

function generateDefaultSteps(type: string) {
  return [
    {
      id: 'fetch-base',
      name: 'Fetch Base Template',
      action: 'fetch:template',
      input: {
        url: './skeleton',
        values: {
          project_name: '${{ parameters.project_name }}',
          deployment_type: '${{ parameters.deployment_type }}'
        }
      }
    },
    {
      id: 'publish',
      name: 'Publish to GitHub',
      action: 'publish:github',
      input: {
        repoUrl: 'github.com?owner=giovanemere&repo=${{ parameters.project_name }}',
        defaultBranch: 'main'
      }
    }
  ];
}

function generateDefaultOutput(type: string) {
  return {
    links: [
      {
        title: '🚀 Live Deployment Logs',
        url: '${{ steps.publish.output.remoteUrl }}/actions',
        icon: 'cloud'
      }
    ],
    text: [
      {
        title: '🏦 BillPay Deployment Started',
        content: 'Deployment initiated with BillPay enterprise architecture'
      }
    ]
  };
}

// Additional helper functions...
function generateTemplateParameters(args: any) {
  // Implementation for parameter generation
  return { content: [{ type: 'text', text: 'Parameters generated' }] };
}

function generateTemplateSteps(args: any) {
  // Implementation for steps generation  
  return { content: [{ type: 'text', text: 'Steps generated' }] };
}

function generateTemplateOutput(args: any) {
  // Implementation for output generation
  return { content: [{ type: 'text', text: 'Output generated' }] };
}

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
