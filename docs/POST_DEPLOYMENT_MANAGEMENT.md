# 🔧 Post-Deployment Management Guide

## 🎯 ¿Cómo funciona Backstage después del primer deploy?

### **Flujo Inicial**
```
Backstage Template → Nuevo Repo GitHub → GitHub Actions → AWS Deploy
```

### **¿Qué pasa después?**
El repositorio creado es **independiente** del template original. Los cambios se manejan de 3 formas:

## 🔄 **Estrategias de Actualización**

### **1. GitOps (Recomendado) - Automático**
```bash
# Clonar repo desplegado
git clone https://github.com/giovanemere/billpay-demo-nuevo
cd billpay-demo-nuevo

# Hacer cambios
vim .github/workflows/deploy.yml  # Cambiar configuración
vim README.md                     # Actualizar documentación

# Push activa CI/CD automáticamente
git add .
git commit -m "feat: update infrastructure config"
git push origin main  # ← Esto ejecuta GitHub Actions automáticamente
```

### **2. Backstage Management Actions - Manual**
```
Backstage → Create → "BillPay Management Actions"
├── 🏗️ Update Infrastructure
├── 📈 Scale Resources  
├── 🔧 Update Environment Variables
├── 🚀 Redeploy Applications
└── 📊 View Deployment Status
```

### **3. GitHub Actions Manual - Directo**
```
GitHub Repo → Actions → "BillPay Management" → Run workflow
```

## 🛠️ **Acciones de Gestión Disponibles**

### **🏗️ Update Infrastructure**
- Modifica recursos AWS (EKS, S3, CloudFront)
- Re-ejecuta Terragrunt/OpenTofu
- Aplica cambios de configuración

### **📈 Scale Resources**
- Cambia tamaños de instancias
- Ajusta número de nodos EKS
- Modifica capacidad de recursos

### **🔧 Update Environment Variables**
- Actualiza configuración de aplicaciones
- Cambia variables de entorno
- Refresca configuración runtime

### **🚀 Redeploy Applications**
- Reconstruye imágenes Docker
- Redespliega servicios en Kubernetes
- Actualiza aplicaciones sin cambiar infraestructura

### **📊 View Deployment Status**
- Muestra estado actual del deployment
- Lista URLs de servicios
- Reporta salud de componentes

## 🎯 **Flujo Recomendado**

### **Para Cambios Menores (Configuración)**
```bash
# 1. Clonar repo
git clone https://github.com/giovanemere/tu-proyecto

# 2. Modificar archivos
# 3. Push (activa CI/CD automático)
git push origin main
```

### **Para Cambios Mayores (Infraestructura)**
```
# 1. Usar Backstage Management Actions
Backstage → Create → "BillPay Management Actions"

# 2. Seleccionar "Update Infrastructure"
# 3. Especificar cambios
# 4. Ejecutar
```

## 📋 **Archivos Clave en Repos Desplegados**

### **`.github/workflows/deploy.yml`**
- Workflow principal de deployment
- Configura variables de proyecto
- Define tipo de deployment (simulation/real)

### **`.github/workflows/manage.yml`**
- Workflow de gestión post-deployment
- Permite actualizaciones sin recrear repo
- Integrado con Backstage Management Actions

### **`catalog-info.yaml`**
- Registro en Backstage Catalog
- Metadatos del servicio
- Enlaces a documentación y monitoreo

## 🔗 **Integración con Backstage**

### **Catalog View**
- Todos los repos desplegados aparecen en el catálogo
- Enlaces directos a GitHub, AWS Console, URLs de aplicación
- Estado de salud y métricas

### **TechDocs**
- Documentación automática generada
- Arquitectura y guías de deployment
- Runbooks y troubleshooting

### **Actions**
- Acciones personalizadas para gestión
- Integración con GitHub Actions
- Workflows de mantenimiento

## 🎉 **Ventajas del Enfoque**

### **✅ Pros**
- **Autonomía**: Cada repo es independiente
- **GitOps**: Cambios versionados y auditables  
- **Flexibilidad**: Múltiples formas de actualizar
- **Integración**: Backstage como centro de control
- **Escalabilidad**: Cada proyecto evoluciona independientemente

### **⚠️ Consideraciones**
- **Template Updates**: No se propagan automáticamente
- **Consistency**: Requiere governance para mantener estándares
- **Learning Curve**: Equipos deben entender GitOps

## 🚀 **Próximos Pasos**

1. **Crear proyecto** con template
2. **Clonar repositorio** generado
3. **Hacer cambios** según necesidades
4. **Usar Management Actions** para actualizaciones mayores
5. **Monitorear** via Backstage Catalog

---

**💡 Tip**: El repositorio generado es tuyo. Modifícalo libremente usando GitOps o Backstage Management Actions.
