# 🎭 Template Implementation Guide

## 🎯 Cómo Implementar un Nuevo Template en Backstage

### **📋 Estructura de Template**

```
templates_backstage/
├── nuevo-template/
│   ├── template.yaml          # Definición del template
│   └── skeleton/              # Archivos que se copiarán
│       ├── .github/
│       │   └── workflows/
│       │       ├── deploy.yml      # Workflow principal
│       │       └── manage.yml      # Workflow de gestión
│       ├── catalog-info.yaml       # Registro en catálogo
│       ├── README.md              # Documentación
│       └── docs/                  # Documentación adicional
└── catalog-info.yaml         # Registro del template
```

## 🔧 **Paso a Paso: Crear Nuevo Template**

### **1. Crear Estructura de Directorios**
```bash
cd /home/giovanemere/ia-ops/ia-ops-backstage/templates_backstage
mkdir mi-nuevo-template
mkdir mi-nuevo-template/skeleton
mkdir mi-nuevo-template/skeleton/.github
mkdir mi-nuevo-template/skeleton/.github/workflows
```

### **2. Crear template.yaml**
```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: mi-nuevo-template
  title: 🚀 Mi Nuevo Template
  description: Descripción del template
  tags:
    - mi-tag
    - categoria
spec:
  owner: platform-team
  type: service
  
  parameters:
    - title: 📋 Configuración
      required:
        - project_name
        - environment
      properties:
        project_name:
          title: Project Name
          type: string
          description: Nombre del proyecto
          pattern: '^[a-z0-9-]+$'
        environment:
          title: Environment
          type: string
          enum: [dev, staging, prod]
          default: dev
        deployment_type:
          title: Deployment Type
          type: string
          enum:
            - simulation
            - real-aws-oidc
            - real-aws-legacy
          enumNames:
            - '🎭 Simulation (No costs)'
            - '🔐 Real AWS OIDC (Secure)'
            - '☁️ Real AWS Legacy'
          default: simulation

  steps:
    - id: fetch-base
      name: Fetch Base Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          project_name: ${{ parameters.project_name }}
          environment: ${{ parameters.environment }}
          deployment_type: ${{ parameters.deployment_type }}

    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: github.com?owner=giovanemere&repo=${{ parameters.project_name }}
        defaultBranch: main

    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'

    - id: trigger-workflow
      name: Trigger Deployment
      action: github:actions:dispatch
      input:
        repoUrl: github.com?owner=giovanemere&repo=${{ parameters.project_name }}
        workflowId: deploy.yml
        branchOrTagName: main
        workflowInputs:
          deployment_type: ${{ parameters.deployment_type }}
          project_name: ${{ parameters.project_name }}
          environment: ${{ parameters.environment }}

  output:
    links:
      - title: 📁 Repository
        url: ${{ steps.publish.output.remoteUrl }}
      - title: 🚀 Deployment Logs
        url: ${{ steps.publish.output.remoteUrl }}/actions
```

### **3. Crear Workflow Principal (skeleton/.github/workflows/deploy.yml)**
```yaml
name: 🚀 Mi Template Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      deployment_type:
        required: true
        type: string
        default: '${{ values.deployment_type }}'
      project_name:
        required: false
        type: string
        default: '${{ values.project_name }}'
      environment:
        required: false
        type: string
        default: '${{ values.environment }}'

env:
  PROJECT_NAME: {% raw %}${{ inputs.project_name || '${{ values.project_name }}' }}{% endraw %}
  ENVIRONMENT: {% raw %}${{ inputs.environment || '${{ values.environment }}' }}{% endraw %}
  DEPLOYMENT_TYPE: {% raw %}${{ inputs.deployment_type || '${{ values.deployment_type }}' }}{% endraw %}

jobs:
  deploy:
    name: 🚀 Deploy
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout
        uses: actions/checkout@v4
        
      - name: 🎯 Deploy Starting
        run: |
          echo "🚀 Deployment Starting!"
          echo "📋 Project: ${{ env.PROJECT_NAME }}"
          echo "🌍 Environment: ${{ env.ENVIRONMENT }}"
          echo "🎭 Type: ${{ env.DEPLOYMENT_TYPE }}"
```

### **4. Crear Workflow de Gestión (skeleton/.github/workflows/manage.yml)**
```yaml
name: 🔧 Mi Template Management

on:
  workflow_dispatch:
    inputs:
      action_type:
        required: true
        type: string
      environment:
        required: true
        type: string
        default: 'dev'

env:
  PROJECT_NAME: '${{ values.project_name }}'
  ACTION_TYPE: {% raw %}${{ inputs.action_type }}{% endraw %}

jobs:
  management:
    runs-on: ubuntu-latest
    steps:
      - name: 🎯 Execute Action
        run: |
          echo "🔧 Management Action: ${{ env.ACTION_TYPE }}"
          echo "📋 Project: ${{ env.PROJECT_NAME }}"
```

### **5. Crear catalog-info.yaml (skeleton/catalog-info.yaml)**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.project_name }}
  description: ${{ values.description }}
  annotations:
    github.com/project-slug: giovanemere/${{ values.project_name }}
spec:
  type: service
  lifecycle: experimental
  owner: platform-team
```

### **6. Registrar Template en Catálogo**
Editar `templates_backstage/catalog-info.yaml`:
```yaml
spec:
  targets:
    - ./billpay-demo-simple/template.yaml
    - ./billpay-complete-stack/template.yaml
    - ./billpay-management/template.yaml
    - ./mi-nuevo-template/template.yaml  # ← Agregar aquí
```

## 🎯 **Variables Obligatorias**

### **Variables Mínimas Requeridas:**
- `project_name`: Nombre del proyecto
- `environment`: Ambiente (dev/staging/prod)
- `deployment_type`: Tipo de deployment (simulation/real-aws-oidc/real-aws-legacy)

### **Variables Opcionales Comunes:**
- `description`: Descripción del proyecto
- `cloud_provider`: Proveedor de nube (aws/gcp/azure/oci)
- `region`: Región de despliegue
- `include_monitoring`: Incluir monitoreo
- `include_cdn`: Incluir CDN

## 🔄 **Sintaxis de Variables en Skeleton**

### **En archivos YAML:**
```yaml
name: ${{ values.project_name }}
environment: ${{ values.environment }}
```

### **En workflows (con raw):**
```yaml
env:
  PROJECT_NAME: {% raw %}${{ inputs.project_name || '${{ values.project_name }}' }}{% endraw %}
```

### **En archivos de texto:**
```markdown
# ${{ values.project_name }}
Environment: ${{ values.environment }}
```

## 🚀 **Deployment del Template**

### **1. Crear Backup**
```bash
cd /home/giovanemere/ia-ops/ia-ops-backstage
./scripts/create-backup.sh "nuevo-template"
```

### **2. Subir Cambios**
```bash
cd templates_backstage
git add .
git commit -m "feat: Add nuevo template"
git push origin trunk
```

### **3. Reiniciar Backstage**
```bash
cd /home/giovanemere/ia-ops/ia-ops-backstage
yarn backstage-cli repo clean
./scripts/start-development.sh
```

## 📋 **Checklist de Template**

### **✅ Archivos Obligatorios:**
- [ ] `template.yaml` - Definición del template
- [ ] `skeleton/.github/workflows/deploy.yml` - Workflow principal
- [ ] `skeleton/.github/workflows/manage.yml` - Workflow de gestión
- [ ] `skeleton/catalog-info.yaml` - Registro en catálogo
- [ ] `skeleton/README.md` - Documentación

### **✅ Variables Obligatorias:**
- [ ] `project_name` - Nombre del proyecto
- [ ] `environment` - Ambiente
- [ ] `deployment_type` - Tipo de deployment

### **✅ Funcionalidades:**
- [ ] Simulation mode (sin costos)
- [ ] Real deployment con OIDC
- [ ] Variables dinámicas correctas
- [ ] Workflow de gestión post-deploy
- [ ] Registro en catálogo automático

### **✅ Testing:**
- [ ] Template aparece en Backstage UI
- [ ] Creación de repositorio funciona
- [ ] Variables se sustituyen correctamente
- [ ] Workflows se ejecutan sin errores
- [ ] Management actions funcionan

## 🎉 **Ejemplos de Templates**

### **Templates Existentes para Referencia:**
1. **BillPay Demo Simple** - Template básico con opciones simulation/real
2. **BillPay Complete Stack** - Template avanzado multi-cloud con opciones
3. **BillPay Management** - Template para gestión post-deployment

### **Casos de Uso Comunes:**
- **Microservicio Simple** - Backend + Base de datos
- **Frontend SPA** - React/Angular + S3 + CloudFront
- **API Gateway** - Lambda + API Gateway + DynamoDB
- **Data Pipeline** - ETL + S3 + Glue + Athena
- **Monitoring Stack** - Prometheus + Grafana + AlertManager

---

**💡 Tip**: Siempre crear backup antes de modificar templates y probar en modo simulation primero.
