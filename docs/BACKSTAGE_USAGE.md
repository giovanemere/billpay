# 🎭 GUÍA DE USO - BACKSTAGE TEMPLATE

## 🚀 CÓMO USAR EL TEMPLATE

### **Paso 1: Iniciar Backstage**
```bash
cd /home/giovanemere/ia-ops/ia-ops-backstage
./scripts/start-development.sh

# Acceder a: http://localhost:3000
```

### **Paso 2: Acceder al Template**
1. **Ir a "Create"** en la navegación principal
2. **Buscar:** "BillPay Complete Stack Multi-Cloud"
3. **Click "Choose"**

### **Paso 3: Configurar Deployment**

#### **☁️ Cloud Configuration**
- **Cloud Provider:** 
  - AWS (Amazon Web Services) ✅ Listo
  - GCP (Google Cloud Platform) 🔄 Próximamente
  - Azure (Microsoft Azure) 🔄 Próximamente
  - OCI (Oracle Cloud) 🔄 Próximamente
- **Region:** Selecciona según el cloud
- **Environment:** dev/staging/prod

#### **🎯 Project Configuration**
- **Project Name:** billpay (o personalizado)

#### **🏗️ Infrastructure Components**
- ✅ **VPC/Network** - Red virtual privada
- ✅ **Kubernetes Cluster** - EKS/GKE/AKS/OKE
- ✅ **Container Registry** - ECR/GCR/ACR/OCIR
- ✅ **Object Storage + CDN** - S3+CloudFront/GCS+CDN/etc
- ✅ **Load Balancer** - ALB/GLB/Azure LB/OCI LB

#### **🚀 Application Components**
- ✅ **Backend API** - Spring Boot + Java 17
- ✅ **Frontend Principal** - Angular 17 + Module Federation
- ✅ **Frontend Secundario** - Angular 17
- ✅ **Feature Flags** - Sistema de feature flags

### **Paso 4: Deploy**
1. **Review** configuración
2. **Click "Create"**
3. **Automáticamente se ejecuta:**
   ```
   Backstage → GitHub Actions → ia-ops-iac → Cloud Deploy
   ```

### **Paso 5: Monitorear**
- **GitHub Actions:** Ver progreso del deploy
- **Backstage Catalog:** Componente registrado automáticamente
- **Cloud Console:** Recursos creados

## 📊 QUÉ SE DESPLIEGA

### **AWS (Ejemplo con todas las opciones)**
```
🏗️ INFRAESTRUCTURA:
├── VPC (10.0.0.0/16)
│   ├── Public Subnets (2 AZs)
│   └── Private Subnets (2 AZs)
├── EKS Cluster
│   ├── Node Group (t3.medium, 2-4 nodes)
│   └── Add-ons (VPC CNI, CoreDNS, kube-proxy)
├── ECR Repositories (4 repos)
│   ├── billpay-backend
│   ├── frontend-a
│   ├── frontend-b
│   └── feature-flags
├── S3 + CloudFront (3 distributions)
│   ├── Frontend A
│   ├── Frontend B
│   └── Feature Flags
└── Application Load Balancer

🚀 APLICACIONES:
├── Backend API
│   ├── Deployment (2 replicas)
│   ├── Service (ClusterIP)
│   └── Ingress (ALB)
├── Frontend A (S3 + CloudFront)
├── Frontend B (S3 + CloudFront)
└── Feature Flags (S3 + CloudFront)
```

## 🔗 URLS DE ACCESO

Después del deploy exitoso:
```
Backend API: http://billpay-[env]-alb-[id].us-east-1.elb.amazonaws.com
Frontend A:  https://[distribution-id].cloudfront.net
Frontend B:  https://[distribution-id].cloudfront.net
Feature Flags: https://[distribution-id].cloudfront.net

API Docs: [Backend URL]/swagger-ui.html
Health Check: [Backend URL]/actuator/health
```

## 📚 DOCUMENTACIÓN AUTOMÁTICA

### **En Backstage Catalog:**
- **Component:** Aplicación registrada
- **API:** Documentación OpenAPI
- **TechDocs:** Documentación técnica
- **Dependencies:** Relaciones entre componentes

### **Monitoreo:**
- **GitHub Actions:** Historial de deploys
- **Cloud Console:** Estado de recursos
- **Kubernetes:** Pods y servicios

## 🛠️ DESARROLLO POST-DEPLOY

### **Hacer Cambios:**
```bash
# 1. Clonar repositorio
git clone https://github.com/giovanemere/poc-billpay-back.git

# 2. Hacer cambios
# ... editar código ...

# 3. Push automático deploy
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main

# 4. ✅ Deploy automático via GitHub Actions
```

### **Deploy Manual:**
```bash
# Desde cualquier repositorio
gh workflow run deploy.yml -f environment=dev
```

## 🎯 CASOS DE USO

### **Desarrollo:**
- Environment: `dev`
- Todas las opciones habilitadas
- Recursos mínimos para testing

### **Staging:**
- Environment: `staging`
- Réplica de producción
- Testing de integración

### **Producción:**
- Environment: `prod`
- Alta disponibilidad
- Monitoreo completo

## 🔧 TROUBLESHOOTING

### **Template no aparece:**
- Verificar catalog-info.yaml en templates_backstage
- Refrescar catálogo en Backstage

### **Deploy falla:**
- Verificar secrets AWS en GitHub
- Revisar logs en GitHub Actions
- Validar permisos IAM

### **Aplicación no accesible:**
- Verificar security groups
- Validar DNS/Load Balancer
- Revisar logs de pods

---
**🎉 ¡Disfruta tu plataforma BillPay desplegada en minutos!**
