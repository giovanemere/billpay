# BillPay - Estructura Completa del Proyecto

## 🏗️ ESTRUCTURA FINAL DEL PROYECTO

```
billpay/ (REPOSITORIO CENTRAL - git@github.com:giovanemere/billpay.git)
├── .github/                       # 🔄 GitHub Actions Centralizadas
│   ├── workflows/                 # Workflows compartidos
│   │   ├── deploy-infrastructure.yml
│   │   ├── sync-repositories.yml
│   │   └── backstage-catalog-sync.yml
│   └── templates/                 # Issue/PR templates
├── repositories/                  # 📦 REPOSITORIOS CLONADOS (git submodules)
│   ├── poc-billpay-back/          # Backend API
│   ├── poc-billpay-front-a/       # Frontend Principal
│   ├── poc-billpay-front-b/       # Frontend Secundario
│   ├── poc-billpay-front-feature-flags/ # Feature Flags
│   ├── templates_backstage/       # Templates Backstage
│   └── ia-ops-iac/               # Infrastructure as Code
├── infrastructure/                # 🛠️ HERRAMIENTAS IAC
│   ├── terragrunt/                # Terragrunt DRY configs
│   │   ├── terragrunt.hcl         # Config global
│   │   ├── environments/          # Por ambiente
│   │   │   ├── dev/
│   │   │   ├── staging/
│   │   │   └── prod/
│   │   └── modules/               # Módulos reutilizables
│   ├── opentofu/                  # OpenTofu modules
│   │   ├── modules/               # Módulos base
│   │   │   ├── vpc/
│   │   │   ├── eks/
│   │   │   ├── ecr/
│   │   │   └── s3-cloudfront/
│   │   └── environments/          # Configuraciones por ambiente
│   ├── python-scripts/            # Scripts dinámicos
│   │   ├── generate-configs.py
│   │   ├── environment-setup.py
│   │   └── resource-calculator.py
│   └── mcp-tools/                # Herramientas MCP existentes
├── templates/                     # 🎭 TEMPLATE ENGINE
│   ├── cookiecutter/              # Service templates
│   │   ├── microservice/          # Template para nuevos microservicios
│   │   ├── frontend/              # Template para nuevos frontends
│   │   └── infrastructure/        # Template para nueva infra
│   ├── jinja2/                    # IaC templates
│   │   ├── terraform/
│   │   ├── kubernetes/
│   │   └── github-actions/
│   └── backstage-integration/     # 🆕 BACKSTAGE INTEGRATION
│       ├── catalog-templates/     # Templates de catálogo
│       ├── software-templates/    # Templates de software
│       ├── techdocs-templates/    # Templates de documentación
│       └── scaffolder-actions/    # Acciones personalizadas
├── backstage/                     # 🎭 BACKSTAGE CONFIGURATION
│   ├── app-config.yaml           # Configuración principal
│   ├── catalog/                  # Catálogo de servicios
│   │   ├── all.yaml             # Importa todos los servicios
│   │   ├── systems/             # Definición de sistemas
│   │   ├── components/          # Componentes individuales
│   │   └── resources/           # Recursos de infraestructura
│   ├── techdocs/                # Documentación técnica
│   │   ├── mkdocs.yml
│   │   └── docs/
│   ├── scaffolder-templates/    # Templates del scaffolder
│   └── plugins/                 # Plugins personalizados
├── docs/                        # 📚 DOCUMENTACIÓN CENTRAL
│   ├── architecture/            # Documentación arquitectural
│   │   ├── decisions/           # ADRs (Architecture Decision Records)
│   │   ├── diagrams/            # Diagramas de arquitectura
│   │   └── patterns/            # Patrones de diseño
│   ├── runbooks/               # Runbooks operacionales
│   ├── api/                    # Documentación de APIs
│   ├── deployment/             # Guías de despliegue
│   └── guidelines/             # Lineamientos y buenas prácticas
├── scripts/                    # 🔧 SCRIPTS DE AUTOMATIZACIÓN
│   ├── setup/                  # Scripts de configuración inicial
│   ├── deployment/             # Scripts de despliegue
│   ├── maintenance/            # Scripts de mantenimiento
│   └── utilities/              # Utilidades varias
├── monitoring/                 # 📊 CONFIGURACIÓN DE MONITORING
│   ├── prometheus/             # Configuración Prometheus
│   ├── grafana/               # Dashboards Grafana
│   └── alerts/                # Configuración de alertas
└── security/                  # 🔒 CONFIGURACIÓN DE SEGURIDAD
    ├── policies/              # Políticas de seguridad
    ├── rbac/                  # Configuración RBAC
    └── secrets/               # Templates de secrets (sin valores)
```

## 📋 LINEAMIENTOS POR FASE

### **FASE 1: PREPARACIÓN** ✅
**Input para IA**: Análisis de repositorios existentes
**Guidelines**:
- Documentar arquitectura actual
- Identificar dependencias
- Mapear servicios AWS requeridos
- Crear herramientas MCP

### **FASE 2A: INFRAESTRUCTURA BASE**
**Input para IA**: 
```yaml
project_name: billpay
environment: dev
region: us-east-1
vpc_cidr: 10.0.0.0/16
services_required:
  - vpc
  - eks
  - ecr
  - s3
  - cloudfront
```

**Guidelines**:
- Usar OpenTofu en lugar de Terraform
- Configurar Terragrunt para DRY
- Implementar remote state en S3
- Seguir naming conventions: `billpay-{service}-{env}`
- Aplicar tags estándar en todos los recursos

### **FASE 2B: IAC AUTOMATION STACK**
**Input para IA**:
```yaml
template_engine:
  cookiecutter:
    templates:
      - microservice
      - frontend
      - infrastructure
  jinja2:
    templates:
      - terraform_modules
      - kubernetes_manifests
      - github_workflows

terragrunt:
  environments: [dev, staging, prod]
  remote_state: s3
  dry_principle: true

python_scripts:
  - environment_setup
  - resource_calculator
  - config_generator
```

**Guidelines**:
- Templates deben ser idempotentes
- Usar variables de entorno para configuración
- Implementar validación de inputs
- Documentar cada template con README

### **FASE 3-8: APLICACIONES Y BACKSTAGE**
**Input para IA**:
```yaml
backstage_integration:
  catalog:
    auto_discovery: true
    github_integration: true
  techdocs:
    builder: mkdocs
    publisher: s3
  scaffolder:
    custom_actions: true
  
applications:
  backend:
    type: microservice
    runtime: java
    deployment: kubernetes
  frontends:
    type: spa
    framework: angular
    deployment: s3_cloudfront
```

## 🎭 INTEGRACIÓN BACKSTAGE (FALTANTE EN MCP)

### **Componentes Backstage a Implementar**:

#### **1. Catalog Integration**
```yaml
# backstage/catalog/all.yaml
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: billpay-services
spec:
  targets:
    - ./systems/billpay-system.yaml
    - ./components/backend-api.yaml
    - ./components/frontend-a.yaml
    - ./components/frontend-b.yaml
    - ./components/feature-flags.yaml
    - ./resources/aws-infrastructure.yaml
```

#### **2. Software Templates**
```yaml
# backstage/scaffolder-templates/microservice-template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: billpay-microservice
  title: BillPay Microservice
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Service Information
      properties:
        name:
          title: Name
          type: string
        description:
          title: Description
          type: string
```

#### **3. TechDocs Integration**
```yaml
# backstage/techdocs/mkdocs.yml
site_name: BillPay Documentation
nav:
  - Home: index.md
  - Architecture: architecture/
  - APIs: api/
  - Runbooks: runbooks/
plugins:
  - techdocs-core
```

## 🔧 ACTUALIZACIÓN MCP TOOLS

### **Nuevo MCP: Backstage Integration**
```typescript
// infrastructure/mcp-tools/mcp-backstage-integration/src/index.ts
const tools = [
  {
    name: 'setup_backstage_catalog',
    description: 'Setup Backstage service catalog',
  },
  {
    name: 'generate_software_templates',
    description: 'Generate Backstage software templates',
  },
  {
    name: 'configure_techdocs',
    description: 'Configure TechDocs integration',
  },
  {
    name: 'sync_github_catalog',
    description: 'Sync GitHub repositories to Backstage catalog',
  }
];
```

## 📚 BUENAS PRÁCTICAS POR REPOSITORIO

### **REPOSITORIO CENTRAL (billpay)**
- **Propósito**: Orquestación y documentación
- **Estructura**: Monorepo con git submodules
- **CI/CD**: GitHub Actions para infraestructura
- **Documentación**: Arquitectural y operacional

### **REPOSITORIOS DE APLICACIÓN**
- **Propósito**: Código fuente específico
- **Estructura**: Estándar por tecnología
- **CI/CD**: Build → Test → Deploy
- **Documentación**: README + API docs

### **REPOSITORIO IAC (ia-ops-iac)**
- **Propósito**: Infraestructura como código
- **Estructura**: Módulos reutilizables
- **CI/CD**: Plan → Apply con aprobación
- **Documentación**: Módulos y ejemplos

### **REPOSITORIO BACKSTAGE (templates_backstage)**
- **Propósito**: Templates y configuración IDP
- **Estructura**: Templates + catalog
- **CI/CD**: Sync automático con Backstage
- **Documentación**: Guías de uso

## 🎯 INPUT PARA IA GENERATIVA

### **Prompt Template para Cada Fase**:
```
Contexto: Proyecto BillPay - Plataforma de pagos microservicios
Fase: {fase_nombre}
Objetivo: {objetivo_especifico}
Tecnologías: {stack_tecnologico}
Estructura: {estructura_esperada}
Guidelines: {lineamientos_especificos}
Output esperado: {deliverables}
```

### **Ejemplo Fase 2B**:
```
Contexto: BillPay - Implementación IaC Automation Stack
Fase: 2B - Template Engine + Terragrunt + OpenTofu
Objetivo: Crear sistema de templates y automatización IaC
Tecnologías: Cookiecutter, Jinja2, Terragrunt, OpenTofu, Python
Estructura: /templates/, /infrastructure/terragrunt/, /infrastructure/opentofu/
Guidelines: DRY principle, idempotencia, validación inputs
Output: Templates funcionales + configuración Terragrunt + módulos OpenTofu
```

¿Procedemos a implementar esta estructura completa con la integración de Backstage?
