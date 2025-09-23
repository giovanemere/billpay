# BillPay - Plataforma de Pagos con Arquitectura de Microservicios

## 📁 Estructura del Proyecto

```
billpay/
├── repositories/                   # Código fuente de aplicaciones
│   ├── poc-billpay-back/          # API Backend
│   ├── poc-billpay-front-a/       # Frontend Principal
│   ├── poc-billpay-front-b/       # Frontend Secundario
│   ├── poc-billpay-front-feature-flags/ # Gestión de Features
│   ├── templates_backstage/       # Templates IDP
│   └── ia-ops-iac/               # Infrastructure as Code
├── infrastructure/                # Herramientas de infraestructura
│   ├── terraform/                 # Módulos Terraform
│   └── mcp-tools/                # Herramientas MCP
│       ├── mcp-project-analyzer/  # Análisis de proyecto
│       └── mcp-billpay-deploy/   # Automatización deploy
├── docs/                         # Documentación
│   ├── analysis/                 # Análisis técnico
│   ├── architecture.md           # Arquitectura del sistema
│   └── deployment-plan.md        # Plan de implementación
└── scripts/                      # Scripts de automatización
    ├── setup-project.sh          # Configuración inicial
    └── deploy-infrastructure.sh  # Despliegue AWS
```

## 🎯 ¿Qué Vamos a Implementar?

### Arquitectura Objetivo
**Plataforma de pagos con microfrontends y microservicios en AWS**

### Componentes Principales
1. **Backend API** - Servicios de negocio en contenedores
2. **Microfrontends** - 3 aplicaciones Angular independientes
3. **Feature Flags** - Gestión dinámica de funcionalidades
4. **Developer Portal** - Backstage para autoservicio

### Infraestructura AWS
- **EKS** - Orquestación de contenedores
- **S3 + CloudFront** - Hosting de frontends
- **ECR** - Registry de imágenes
- **ALB** - Load balancing

## 🚀 Plan de Trabajo

### Fase 1: Preparación ✅
- [x] Análisis de repositorios
- [x] Definición de arquitectura
- [x] Creación de herramientas MCP

### Fase 2: Infraestructura Base (Próximo)
- [ ] Crear módulos Terraform
- [ ] Provisionar VPC y networking
- [ ] Configurar EKS cluster

### Fase 3: Aplicaciones
- [ ] Configurar CI/CD pipelines
- [ ] Deploy de backend a EKS
- [ ] Deploy de frontends a S3/CloudFront

### Fase 4: Integración
- [ ] Configurar Backstage
- [ ] Implementar feature flags
- [ ] Monitoring y observabilidad

## 📋 Próximos Pasos
1. Revisar arquitectura propuesta
2. Crear módulos Terraform
3. Ejecutar despliegue de infraestructura
4. Configurar pipelines CI/CD
