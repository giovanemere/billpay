# 🔧 Guía de Troubleshooting - BillPay Platform

## 🚨 Problemas Comunes y Soluciones

### **1. Template Execution Fails**

#### Error: `Template action with ID 'github:actions:get' is not registered`
**Solución:**
```bash
cd /home/giovanemere/ia-ops/ia-ops-backstage
./start-with-github-auth.sh
```

#### Error: `Workflow was not found`
**Solución:**
```bash
# Verificar workflows existen
ls /home/giovanemere/periferia/billpay/repositories/ia-ops-iac/.github/workflows/
# Debe mostrar: deploy-simple.yml, deploy-demo-simulation.yml
```

### **2. AWS Credentials Issues**

#### Error: `Credentials could not be loaded`
**Solución:**
1. Ir a: https://github.com/giovanemere/ia-ops-iac/settings/secrets/actions
2. Agregar secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

#### Error: `The request signature we calculated does not match`
**Solución:**
1. Generar nuevas credenciales AWS
2. Verificar permisos S3
3. Actualizar secrets en GitHub

### **3. Backstage Connection Issues**

#### Error: `Failed to connect to localhost port 3000/7007`
**Solución:**
```bash
cd /home/giovanemere/ia-ops/ia-ops-backstage
./start-with-github-auth.sh
```

#### Error: Templates no cargan
**Solución:**
```bash
# Verificar templates
curl -s "http://localhost:7007/api/catalog/entities?filter=kind=template"
```

### **4. GitHub Actions Failures**

#### Error: Workflow no se ejecuta
**Solución:**
1. Verificar GitHub token válido
2. Comprobar permisos del token
3. Revisar workflow syntax

#### Error: S3 bucket creation fails
**Solución:**
1. Verificar región AWS
2. Comprobar nombre único del bucket
3. Validar permisos IAM

## 🔍 Comandos de Diagnóstico

### **Validación Completa:**
```bash
cd /home/giovanemere/periferia/billpay
./validate-current-state.sh
```

### **Estado de Servicios:**
```bash
# Backstage Frontend
curl -s http://localhost:3000 > /dev/null && echo "✅ Frontend OK" || echo "❌ Frontend DOWN"

# Backstage Backend  
curl -s http://localhost:7007/api/catalog/entities > /dev/null && echo "✅ Backend OK" || echo "❌ Backend DOWN"
```

### **Verificar Templates:**
```bash
curl -s "http://localhost:7007/api/catalog/entities?filter=kind=template" | jq '.[] | .metadata.name'
```

### **Test Template Execution:**
```bash
curl -X POST "http://localhost:7007/api/scaffolder/v2/tasks" \
  -H "Content-Type: application/json" \
  -d '{"templateRef": "template:default/billpay-demo-simple", "values": {"project_name": "test", "environment": "demo", "deployment_type": "simulation"}}'
```

## 🛠️ Procedimientos de Recovery

### **Recovery Completo:**
```bash
# 1. Parar servicios
pkill -f backstage

# 2. Limpiar procesos
pkill -f node

# 3. Reiniciar Backstage
cd /home/giovanemere/ia-ops/ia-ops-backstage
./start-with-github-auth.sh

# 4. Validar
sleep 10
./validate-current-state.sh
```

### **Recovery de Templates:**
```bash
# 1. Actualizar templates
cd /home/giovanemere/ia-ops/ia-ops-backstage/templates_backstage
git pull origin trunk

# 2. Reiniciar Backstage
cd /home/giovanemere/ia-ops/ia-ops-backstage
./start-with-github-auth.sh
```

### **Recovery de Workflows:**
```bash
# 1. Verificar workflows
cd /home/giovanemere/periferia/billpay/repositories/ia-ops-iac
git pull origin trunk

# 2. Verificar archivos
ls .github/workflows/
```

## 📊 Logs y Monitoreo

### **Logs de Backstage:**
```bash
tail -f /home/giovanemere/ia-ops/ia-ops-backstage/backstage.log
```

### **Logs de Template Execution:**
```bash
# Obtener task ID del template ejecutado
TASK_ID="<task-id>"
curl -s "http://localhost:7007/api/scaffolder/v2/tasks/$TASK_ID/events" | jq '.[] | .body.message'
```

### **GitHub Actions Logs:**
- URL: https://github.com/giovanemere/ia-ops-iac/actions
- Buscar workflow por nombre del proyecto

## 🚀 Mantenimiento Preventivo

### **Verificación Diaria:**
```bash
cd /home/giovanemere/periferia/billpay
./validate-current-state.sh
```

### **Actualización de Repositorios:**
```bash
cd /home/giovanemere/periferia/billpay
git pull origin master

cd repositories/ia-ops-iac && git pull origin trunk
cd ../templates_backstage && git pull origin trunk
```

### **Limpieza de Recursos AWS:**
```bash
# Listar buckets de demo
aws s3 ls | grep demo

# Eliminar bucket específico
aws s3 rb s3://bucket-name --force
```

## 📞 Escalación

### **Nivel 1 - Self Service:**
1. Ejecutar `./validate-current-state.sh`
2. Seguir procedimientos de recovery
3. Verificar logs

### **Nivel 2 - Reinicio Completo:**
1. Recovery completo de servicios
2. Validación end-to-end
3. Test de funcionalidad

### **Nivel 3 - Investigación:**
1. Revisar logs detallados
2. Verificar configuración
3. Contactar soporte técnico

---

**Última actualización:** 2025-09-24  
**Versión:** 1.0
