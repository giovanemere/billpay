# 🔄 WORKFLOWS CENTRALIZADOS - BILLPAY

## 🎯 ARQUITECTURA

### **Centralización en ia-ops-iac**
Todos los workflows están centralizados en el repositorio `ia-ops-iac` para:
- ✅ **DRY** - No duplicar código
- ✅ **Mantenimiento** - Un solo lugar para actualizar
- ✅ **Reutilización** - Cualquier proyecto puede usar
- ✅ **Consistencia** - Misma lógica en todos los repos

## 📁 ESTRUCTURA

```
ia-ops-iac/.github/workflows/
├── infrastructure.yml      # 🏗️ Reutilizable para infraestructura
├── deploy-service.yml      # 🚀 Reutilizable para servicios
└── deploy-complete.yml     # 🎯 Reutilizable para deploy completo

billpay/.github/workflows/
└── deploy.yml             # 📞 Simple invocación

poc-billpay-back/.github/workflows/
└── deploy.yml             # 📞 Simple invocación

poc-billpay-front-*/.github/workflows/
└── deploy.yml             # 📞 Simple invocación
```

## 🔧 WORKFLOWS CENTRALIZADOS

### 1. **infrastructure.yml** 🏗️
**Propósito:** Deploy/destroy de infraestructura AWS
**Inputs:**
- `environment`: dev/staging/prod
- `action`: plan/apply/destroy
- `project_name`: nombre del proyecto

**Outputs:**
- `eks_cluster_name`
- `alb_dns_name`
- `ecr_repositories`

### 2. **deploy-service.yml** 🚀
**Propósito:** Deploy de servicios individuales
**Inputs:**
- `service_name`: nombre del servicio
- `service_type`: backend/frontend
- `environment`: dev/staging/prod
- `project_name`: nombre del proyecto
- `repository_name`: repo del código fuente

**Funcionalidades:**
- Backend: Build Docker → Push ECR → Deploy K8s
- Frontend: Build Angular → Deploy S3 → Invalidate CloudFront

### 3. **deploy-complete.yml** 🎯
**Propósito:** Deploy completo de toda la plataforma
**Secuencia:**
1. Deploy infraestructura
2. Deploy backend (paralelo con frontends)
3. Deploy frontend-a
4. Deploy frontend-b
5. Deploy feature-flags

## 📞 WORKFLOWS DE INVOCACIÓN

### **Repositorio Principal (billpay)**
```yaml
name: 🚀 BillPay Deploy
on:
  workflow_dispatch:
    inputs:
      environment: [dev, staging, prod]

jobs:
  deploy:
    uses: giovanemere/ia-ops-iac/.github/workflows/deploy-complete.yml@main
    with:
      environment: ${{ github.event.inputs.environment }}
      project_name: billpay
```

### **Repositorios de Servicios**
```yaml
name: 🚀 Service Deploy
on:
  workflow_dispatch:
  push: [main]

jobs:
  deploy:
    uses: giovanemere/ia-ops-iac/.github/workflows/deploy-service.yml@main
    with:
      service_name: [service-name]
      service_type: [backend/frontend]
      environment: dev
      project_name: billpay
      repository_name: [repo-name]
```

## 🚀 CÓMO USAR

### **Deploy Completo**
1. Ir a `billpay` repository
2. Actions → "BillPay Deploy"
3. Seleccionar environment
4. Run workflow
5. ✅ Toda la plataforma se despliega

### **Deploy Individual**
1. Ir al repositorio del servicio
2. Actions → "Service Deploy"
3. Seleccionar environment
4. Run workflow
5. ✅ Solo ese servicio se despliega

### **Deploy desde Backstage**
1. Backstage → Create → "BillPay Complete Stack"
2. Configurar parámetros
3. Create
4. ✅ Trigger automático de workflows

## 🔐 SECRETS REQUERIDOS

En cada repositorio configurar:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

## 🎯 VENTAJAS

- **Mantenimiento:** Solo actualizar en ia-ops-iac
- **Consistencia:** Misma lógica en todos los proyectos
- **Escalabilidad:** Fácil agregar nuevos servicios
- **Reutilización:** Otros proyectos pueden usar los workflows
- **Simplicidad:** Cada repo solo 10-15 líneas de YAML

---
**Documentación actualizada:** 2025-09-23 22:10 UTC
