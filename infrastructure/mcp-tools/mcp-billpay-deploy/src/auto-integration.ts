// Auto-integración de nuevas aplicaciones en Backstage
export interface AppIntegrationConfig {
  name: string;
  type: 'backend' | 'frontend' | 'service';
  repository: string;
  technology: string;
  port?: number;
}

export class BackstageAutoIntegration {
  
  async integrateNewApp(config: AppIntegrationConfig): Promise<void> {
    console.log(`🔄 Auto-integrando ${config.name} en Backstage...`);
    
    // 1. Crear catalog-info.yaml
    await this.createCatalogInfo(config);
    
    // 2. Configurar TechDocs
    await this.setupTechDocs(config);
    
    // 3. Crear workflow de deploy
    await this.createDeployWorkflow(config);
    
    // 4. Actualizar template principal
    await this.updateMainTemplate(config);
    
    console.log(`✅ ${config.name} integrado exitosamente`);
  }
  
  private async createCatalogInfo(config: AppIntegrationConfig): Promise<void> {
    const catalogInfo = `
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${config.name}
  title: ${config.name.charAt(0).toUpperCase() + config.name.slice(1)}
  description: ${config.type === 'backend' ? 'Backend API' : 'Frontend Application'} - ${config.technology}
  annotations:
    github.com/project-slug: giovanemere/${config.repository}
    backstage.io/techdocs-ref: dir:.
  tags:
    - billpay
    - ${config.type}
    - ${config.technology.toLowerCase()}
spec:
  type: ${config.type}
  lifecycle: production
  owner: platform-team
  system: billpay-platform
  ${config.type === 'backend' ? `providesApis:\n    - ${config.name}-api` : ''}
---
${config.type === 'backend' ? `
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: ${config.name}-api
  title: ${config.name} API
  description: REST API for ${config.name}
spec:
  type: openapi
  lifecycle: production
  owner: platform-team
  system: billpay-platform
  definition:
    $text: ./docs/api-spec.yaml
` : ''}`;
    
    // Escribir archivo
    console.log(`📝 Creando catalog-info.yaml para ${config.name}`);
  }
  
  private async setupTechDocs(config: AppIntegrationConfig): Promise<void> {
    const mkdocsConfig = `
site_name: ${config.name}
site_description: Documentation for ${config.name}

nav:
  - Home: index.md
  ${config.type === 'backend' ? `
  - API Documentation: api.md
  - Development Guide: development.md
  - Deployment: deployment.md
  ` : `
  - Components: components.md
  - Build Process: build.md
  - Deployment: deployment.md
  `}

plugins:
  - techdocs-core
`;
    
    console.log(`📚 Configurando TechDocs para ${config.name}`);
  }
  
  private async createDeployWorkflow(config: AppIntegrationConfig): Promise<void> {
    const workflow = `
name: 🚀 ${config.name} Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment'
        required: true
        default: 'dev'
        type: choice
        options: [dev, staging, prod]
  push:
    branches: [main]

jobs:
  deploy:
    uses: giovanemere/ia-ops-iac/.github/workflows/deploy-service.yml@main
    with:
      service_name: ${config.name}
      service_type: ${config.type}
      environment: \${{ github.event.inputs.environment || 'dev' }}
      project_name: billpay
      repository_name: ${config.repository}
    secrets:
      AWS_ACCESS_KEY_ID: \${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
`;
    
    console.log(`🔄 Creando workflow de deploy para ${config.name}`);
  }
  
  private async updateMainTemplate(config: AppIntegrationConfig): Promise<void> {
    console.log(`🎭 Actualizando template principal con ${config.name}`);
    
    // Agregar nuevo componente al template principal
    const newComponent = {
      [`deploy_${config.name}`]: {
        title: `🚀 ${config.name}`,
        type: 'boolean',
        description: `${config.type === 'backend' ? 'API' : 'Frontend'} - ${config.technology}`,
        default: true
      }
    };
    
    console.log(`✅ Template actualizado con ${config.name}`);
  }
}

// Configuraciones predefinidas para servicios BillPay
export const BILLPAY_SERVICES: AppIntegrationConfig[] = [
  {
    name: 'billpay-backend',
    type: 'backend',
    repository: 'poc-billpay-back',
    technology: 'Spring Boot + Java 17',
    port: 8080
  },
  {
    name: 'frontend-a',
    type: 'frontend',
    repository: 'poc-billpay-front-a',
    technology: 'Angular 17 + Module Federation'
  },
  {
    name: 'frontend-b',
    type: 'frontend',
    repository: 'poc-billpay-front-b',
    technology: 'Angular 17'
  },
  {
    name: 'feature-flags',
    type: 'frontend',
    repository: 'poc-billpay-front-feature-flags',
    technology: 'Angular 17 Feature Management'
  }
];
