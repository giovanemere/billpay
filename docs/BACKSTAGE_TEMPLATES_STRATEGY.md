# 🎭 Estrategia de Templates Backstage - BillPay

## 🚨 Problema Actual
Templates desorganizados, mezclando genéricos con específicos de BillPay.

## 🎯 Estrategia de Reorganización

### **Estructura Propuesta**
```
templates_backstage/
├── billpay/                    # 🎯 TEMPLATES BILLPAY ESPECÍFICOS
│   ├── complete-stack/         # Stack completo BillPay
│   ├── infrastructure/         # Solo infraestructura
│   ├── backend-service/        # Solo backend Java
│   ├── frontend-app/           # Solo frontend Angular
│   └── feature-flags/          # Solo feature flags
├── generic/                    # 🔧 TEMPLATES GENÉRICOS
│   ├── aws-infrastructure/     # AWS genérico
│   ├── gcp-storage/           # GCP genérico
│   ├── azure-messaging/       # Azure genérico
│   ├── oci-networking/        # OCI genérico
│   └── kubernetes-deployment/ # K8s genérico
└── shared/                     # 📦 COMPONENTES COMPARTIDOS
    ├── actions/               # Actions reutilizables
    ├── parameters/            # Parámetros comunes
    └── validators/            # Validadores
```

## 🎯 Templates BillPay Específicos

### **1. billpay-complete-stack** (PRIORITARIO)
```yaml
# Template maestro que despliega todo BillPay
metadata:
  name: billpay-complete-stack
  title: BillPay Complete Platform
  description: Despliega plataforma BillPay completa (infra + apps)

parameters:
  - cloud_provider: [aws, gcp, azure, oci]
  - environment: [dev, staging, prod]
  - enable_monitoring: boolean
  - enable_feature_flags: boolean

steps:
  1. Crear infraestructura (ia-ops-iac)
  2. Configurar backend (poc-billpay-back)
  3. Configurar frontend-a (poc-billpay-front-a)
  4. Configurar frontend-b (poc-billpay-front-b)
  5. Configurar feature-flags (poc-billpay-front-feature-flags)
  6. Setup CI/CD pipelines
  7. Deploy automático
```

### **2. billpay-infrastructure** (ACTUAL - MEJORAR)
```yaml
# Solo infraestructura BillPay
metadata:
  name: billpay-infrastructure
  title: BillPay Infrastructure Only

steps:
  1. Generar código OpenTofu/Terragrunt
  2. Crear repositorio ia-ops-iac
  3. Setup GitHub Actions para infra
```

### **3. billpay-backend-service**
```yaml
# Solo microservicio backend
metadata:
  name: billpay-backend-service
  title: BillPay Backend Microservice

steps:
  1. Generar código Java/Spring Boot
  2. Crear Dockerfile
  3. Crear manifiestos K8s
  4. Setup CI/CD pipeline
```

### **4. billpay-frontend-app**
```yaml
# Solo aplicación frontend
metadata:
  name: billpay-frontend-app
  title: BillPay Frontend Application

parameters:
  - frontend_type: [main, secondary, feature-flags]
  - module_federation: boolean

steps:
  1. Generar código Angular 17
  2. Configurar Module Federation
  3. Crear Dockerfile
  4. Setup S3 + CloudFront
  5. Setup CI/CD pipeline
```

## 🔄 Plan de Migración

### **Fase 1: Reorganizar Estructura** (1 día)
```bash
# Mover templates existentes
mkdir -p templates_backstage/{billpay,generic,shared}
mv aws-infrastructure/ generic/
mv gcp-storage/ generic/
mv azure-messaging/ generic/
mv oci-networking/ generic/
mv kubernetes-deployment/ generic/
mv billpay-infrastructure/ billpay/infrastructure/
```

### **Fase 2: Crear Template Maestro** (2 días)
```bash
# Crear billpay-complete-stack
templates_backstage/billpay/complete-stack/
├── template.yaml           # Template principal
├── content/               # Código generado
│   ├── ia-ops-iac/       # Infraestructura
│   ├── backend/          # Backend config
│   ├── frontends/        # Frontends config
│   └── ci-cd/           # Pipelines
└── actions/              # Actions custom
```

### **Fase 3: Integrar con IaC Real** (1 día)
```bash
# Conectar templates con código real
- Template genera código OpenTofu funcional
- Crea repositorios con código real
- Setup pipelines que funcionan
```

## 🎭 Backstage Configuration

### **app-config.yaml**
```yaml
# Configuración Backstage actualizada
catalog:
  locations:
    - type: file
      target: ../repositories/templates_backstage/billpay/*/template.yaml
    - type: file  
      target: ../repositories/templates_backstage/generic/*/template.yaml

scaffolder:
  defaultAuthor:
    name: BillPay Platform Team
  defaultCommitMessage: 'Initial commit from BillPay template'
```

### **Catálogo Organizado**
```yaml
# Los developers verán:
📁 BillPay Templates
  ├── 🚀 BillPay Complete Stack      # Template principal
  ├── 🏗️ BillPay Infrastructure     # Solo infra
  ├── ⚙️ BillPay Backend Service     # Solo backend
  ├── 🎨 BillPay Frontend App        # Solo frontend
  └── 🚩 BillPay Feature Flags       # Solo flags

📁 Generic Templates  
  ├── 🟠 AWS Infrastructure
  ├── 🔵 GCP Storage
  ├── 🟦 Azure Messaging
  ├── 🔴 OCI Networking
  └── ☸️ Kubernetes Deployment
```

## ✅ Criterios de Éxito

### **Templates BillPay**
- ✅ Generan código OpenTofu/Terragrunt funcional
- ✅ Crean repositorios con estructura correcta
- ✅ Setup CI/CD pipelines automáticos
- ✅ Integración con repositorios existentes
- ✅ Documentación automática

### **Developer Experience**
- ✅ 1 clic → Infraestructura completa desplegada
- ✅ Templates organizados por propósito
- ✅ Parámetros claros y validados
- ✅ Feedback en tiempo real del progreso

## 🚀 Próximos Pasos

1. **Reorganizar estructura** de templates
2. **Crear billpay-complete-stack** template
3. **Integrar con ia-ops-iac** real
4. **Probar flujo completo** Developer Self-Service

---
**Objetivo**: Developer hace 1 clic en Backstage → BillPay completo desplegado en AWS
