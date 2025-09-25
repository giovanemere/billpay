# MCP Template Manager

MCP Server para gestión estandarizada de templates de Backstage en BillPay.

## 🎯 Propósito

Estandarizar la creación, validación y mantenimiento de templates de Backstage siguiendo las mejores prácticas de BillPay.

## 🔧 Herramientas Disponibles

### `create_template`
Crea un nuevo template siguiendo estándares BillPay.

**Parámetros:**
- `template_name`: Nombre del template (sin prefijo billpay-)
- `template_type`: Tipo de template (repository-creation, simple-deployment, complete-stack)
- `description`: Descripción del template
- `cloud_providers`: Proveedores cloud soportados (default: ["aws"])
- `deployment_types`: Tipos de deployment (default: ["simulation", "real-aws-oidc"])

### `validate_template`
Valida template existente contra estándares BillPay.

### `fix_template_branches`
Corrige inconsistencias de ramas en templates.

### `rename_template`
Renombra template siguiendo convenciones de naming.

### `list_templates`
Lista todos los templates con su estado.

## 📋 Tipos de Templates

### `repository-creation`
- **Propósito**: Crear nuevo repositorio con deployment básico
- **Pasos**: fetch → publish → register → trigger-deployment
- **Crea repo**: Sí
- **Target**: deploy-demo.yml

### `simple-deployment`
- **Propósito**: Deployment simple sin EKS (S3, Lambda, etc)
- **Pasos**: fetch → publish → register → trigger-deployment
- **Crea repo**: Sí
- **Target**: deploy-simple.yml

### `complete-stack`
- **Propósito**: Deployment multi-cloud completo con EKS/GKE/AKS
- **Pasos**: trigger-deployment → register
- **Crea repo**: No
- **Target**: deploy-complete.yml

## 🏗️ Estándares Aplicados

### Naming Convention
- Formato: `billpay-{purpose}`
- Ejemplos: `billpay-repository-creation`, `billpay-simple-deployment`

### Archivos Requeridos
- `template.yaml`
- `skeleton/catalog-info.yaml`
- `skeleton/README.md`
- `skeleton/.github/workflows/deploy.yml`

### Configuración de Ramas
- **ia-ops-iac**: Siempre `trunk`
- **Nuevos proyectos**: Siempre `main`
- **Workflows**: Aceptan `[main, trunk]`

### Parámetros Estándar
- `name`: Nombre del proyecto
- `deployment_type`: Tipo de deployment
- `environment`: Entorno de deployment

## 🚀 Uso

```bash
# Crear template de creación de repositorio
create_template repository-creation "Create new BillPay repository"

# Crear template de deployment simple
create_template simple-deployment "Simple deployment without EKS"

# Validar template existente
validate_template billpay-demo-simple

# Corregir ramas
fix_template_branches billpay-complete-stack

# Renombrar template
rename_template billpay-demo-simple repository-creation

# Listar todos los templates
list_templates
```

## 🔄 Plan de Implementación

### Paso 1: Renombrar Templates Existentes
```bash
rename_template billpay-demo-simple repository-creation
```

### Paso 2: Crear Template Simple
```bash
create_template simple-deployment "Simple BillPay deployment without EKS"
```

### Paso 3: Validar y Corregir
```bash
validate_template billpay-repository-creation
fix_template_branches billpay-complete-stack
```

### Paso 4: Actualizar Catálogo
Actualizar `catalog-info.yaml` con los nuevos templates.

## ✅ Beneficios

- **Consistencia**: Todos los templates siguen los mismos estándares
- **Automatización**: Generación automática de archivos estándar
- **Validación**: Verificación automática de cumplimiento de estándares
- **Mantenimiento**: Corrección automática de problemas comunes
- **Escalabilidad**: Fácil creación de nuevos templates
