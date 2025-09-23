# BillPay - Prerequisitos de Implementación

## 🎯 PREREQUISITOS OBLIGATORIOS

### 1. **Cuentas y Accesos**

#### **AWS Account**
- [ ] Cuenta AWS activa con billing habilitado
- [ ] IAM User con permisos administrativos
- [ ] AWS CLI configurado localmente
- [ ] Límites de servicio verificados (EKS, ECR, VPC)

#### **GitHub**
- [ ] Cuenta GitHub con acceso a repositorios
- [ ] GitHub CLI instalado (`gh`)
- [ ] SSH keys configuradas
- [ ] GitHub Actions habilitado

#### **Dominios (Opcional)**
- [ ] Dominio registrado para frontends
- [ ] Acceso a DNS management

### 2. **Herramientas de Desarrollo**

#### **Obligatorias**
- [ ] **Node.js** >= 18.x
- [ ] **npm** >= 9.x
- [ ] **Docker** >= 24.x
- [ ] **kubectl** >= 1.28
- [ ] **AWS CLI** >= 2.x
- [ ] **Git** >= 2.x

#### **IaC Stack**
- [ ] **OpenTofu** >= 1.6.x (reemplaza Terraform)
- [ ] **Terragrunt** >= 0.55.x
- [ ] **Python** >= 3.9 (para scripts dinámicos)

#### **Template Engine**
- [ ] **Cookiecutter** >= 2.5.x
- [ ] **Jinja2** >= 3.x

#### **CI/CD Tools**
- [ ] **GitHub Actions** (habilitado en repositorios)
- [ ] **GitHub CLI** (`gh`) configurado

### 3. **Configuraciones Locales**

#### **AWS Configuration**
```bash
# ~/.aws/credentials
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
region = us-east-1

# ~/.aws/config
[default]
region = us-east-1
output = json
```

#### **GitHub Configuration**
```bash
# SSH Key configurada
ssh -T git@github.com

# GitHub CLI autenticado
gh auth status
```

#### **Docker Configuration**
```bash
# Docker daemon corriendo
docker --version
docker ps
```

### 4. **Permisos AWS Requeridos**

#### **IAM Policies Mínimas**
- [ ] **EC2FullAccess** - Para VPC, subnets, security groups
- [ ] **EKSClusterPolicy** - Para crear clusters EKS
- [ ] **ECRFullAccess** - Para repositorios de contenedores
- [ ] **S3FullAccess** - Para buckets de frontend
- [ ] **CloudFrontFullAccess** - Para distribuciones CDN
- [ ] **IAMFullAccess** - Para crear roles y policies
- [ ] **Route53FullAccess** - Para DNS (opcional)

#### **Service Limits**
- [ ] **VPCs**: Mínimo 5 disponibles
- [ ] **EKS Clusters**: Mínimo 1 disponible
- [ ] **ECR Repositories**: Mínimo 10 disponibles
- [ ] **S3 Buckets**: Mínimo 5 disponibles
- [ ] **CloudFront Distributions**: Mínimo 5 disponibles

### 5. **Recursos de Sistema**

#### **Hardware Mínimo**
- [ ] **RAM**: 16GB mínimo (32GB recomendado)
- [ ] **CPU**: 4 cores mínimo (8 cores recomendado)
- [ ] **Disk**: 100GB libres mínimo
- [ ] **Network**: Conexión estable a internet

#### **Sistema Operativo**
- [ ] **Linux** (Ubuntu 20.04+ / CentOS 8+ / Amazon Linux 2)
- [ ] **macOS** 12+ (con Homebrew)
- [ ] **Windows** 11 (con WSL2)

### 6. **Repositorios y Código**

#### **Acceso a Repositorios**
- [ ] `git@github.com:giovanemere/billpay.git` (CENTRAL)
- [ ] `git@github.com:giovanemere/poc-billpay-back.git`
- [ ] `git@github.com:giovanemere/poc-billpay-front-a.git`
- [ ] `git@github.com:giovanemere/poc-billpay-front-b.git`
- [ ] `git@github.com:giovanemere/poc-billpay-front-feature-flags.git`
- [ ] `git@github.com:giovanemere/templates_backstage.git`
- [ ] `git@github.com:giovanemere/ia-ops-iac.git`

#### **Estructura Local**
- [ ] Proyecto clonado en `/home/giovanemere/periferia/billpay/`
- [ ] Todos los sub-repositorios clonados en `/repositories/`

### 7. **Secrets y Variables**

#### **GitHub Secrets** (Para CI/CD)
- [ ] `AWS_ACCESS_KEY_ID`
- [ ] `AWS_SECRET_ACCESS_KEY`
- [ ] `AWS_REGION`
- [ ] `ECR_REGISTRY`
- [ ] `EKS_CLUSTER_NAME`

#### **Variables de Entorno Locales**
```bash
export AWS_REGION=us-east-1
export PROJECT_NAME=billpay
export ENVIRONMENT=dev
export KUBECONFIG=~/.kube/config
```

### 8. **Validaciones Pre-Implementación**

#### **Conectividad**
```bash
# AWS CLI
aws sts get-caller-identity

# GitHub
gh auth status

# Docker
docker run hello-world

# Kubernetes (después de EKS)
kubectl version --client
```

#### **Herramientas IaC**
```bash
# OpenTofu
tofu version

# Terragrunt
terragrunt --version

# Cookiecutter
cookiecutter --version
```

## 🚨 **PREREQUISITOS CRÍTICOS**

### **ANTES DE EMPEZAR**
1. ✅ AWS Account con billing activo
2. ✅ AWS CLI configurado y funcionando
3. ✅ Docker instalado y corriendo
4. ✅ Acceso a todos los repositorios GitHub
5. ✅ Node.js 18+ instalado

### **ANTES DE FASE 2B (IaC Automation)**
1. ✅ OpenTofu instalado
2. ✅ Terragrunt instalado
3. ✅ Python 3.9+ con pip
4. ✅ Cookiecutter instalado

### **ANTES DE DEPLOY**
1. ✅ kubectl configurado
2. ✅ EKS cluster accesible
3. ✅ ECR repositories creados
4. ✅ GitHub Secrets configurados

## 📋 **CHECKLIST DE VERIFICACIÓN**

```bash
# Ejecutar este script para verificar prerequisitos
./scripts/check-prerequisites.sh
```

## 💰 **Costos Estimados**

### **AWS Resources**
- Desarrollo: $170-265/mes
- Staging: $200-300/mes
- Producción: $300-450/mes

### **Herramientas Externas**
- GitHub Actions: Gratis (2000 min/mes)
- Dominios: $10-15/año
- Certificados SSL: Gratis (Let's Encrypt/AWS)

## ⚠️ **ADVERTENCIAS**

1. **Costos AWS**: Monitorear billing diariamente
2. **Límites de Servicio**: Verificar antes de crear recursos
3. **Permisos**: Usar principio de menor privilegio
4. **Backup**: Configurar backup de estados Terraform/OpenTofu
5. **Secrets**: Nunca commitear credenciales en Git

---

**Última actualización**: 2025-09-23
**Versión**: 1.0
**Estado**: Prerequisitos definidos - Pendiente validación
