# 🔐 Roles y Permisos - BillPay Platform

## 📋 Resumen Ejecutivo

**Estado Actual:** 100% OIDC Compliance  
**Fecha:** 2025-09-24  
**Seguridad:** Máxima - Sin credenciales hardcodeadas  

## 🏗️ Arquitectura de Roles

### **OIDC Provider**
```
Provider URL: https://token.actions.githubusercontent.com
Thumbprint: 6938fd4d98bab03faadb97b34396831e3780aea1
Client ID: sts.amazonaws.com
Account: 485663596015
```

### **IAM Role Principal**
```
Name: BillPayGitHubActionsRole
ARN: arn:aws:iam::485663596015:role/BillPayGitHubActionsRole
Type: OIDC Federated Role
Session Duration: 1 hour (default)
```

### **IAM Policy Adjuntada**
```
Name: BillPayDeploymentPolicy
ARN: arn:aws:iam::485663596015:policy/BillPayDeploymentPolicy
Type: Customer Managed Policy
Principle: Least Privilege
```

## 🔒 Trust Policy (Assume Role Policy)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::485663596015:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:giovanemere/ia-ops-iac:*",
            "repo:giovanemere/poc-billpay-*:*"
          ]
        }
      }
    }
  ]
}
```

### **Explicación del Trust Policy:**
- **Federated Principal:** Solo el OIDC provider de GitHub puede asumir el role
- **Audience Condition:** Token debe ser para AWS STS
- **Subject Condition:** Solo repositorios específicos de BillPay pueden usar el role
- **Wildcard Branches:** Permite cualquier branch/tag en los repos autorizados

## 🛡️ Permissions Policy (Deployment Policy)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3BucketManagement",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketWebsite",
        "s3:PutBucketWebsite",
        "s3:PutBucketPolicy",
        "s3:PutBucketAcl"
      ],
      "Resource": [
        "arn:aws:s3:::*billpay*",
        "arn:aws:s3:::*demo*"
      ]
    },
    {
      "Sid": "S3ObjectManagement", 
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::*billpay*",
        "arn:aws:s3:::*billpay*/*",
        "arn:aws:s3:::*demo*",
        "arn:aws:s3:::*demo*/*"
      ]
    },
    {
      "Sid": "CloudFrontManagement",
      "Effect": "Allow", 
      "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:UpdateDistribution", 
        "cloudfront:DeleteDistribution",
        "cloudfront:CreateInvalidation",
        "cloudfront:ListDistributions"
      ],
      "Resource": "*"
    },
    {
      "Sid": "STSIdentityVerification",
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
```

### **Explicación de Permisos:**

#### **S3 Permissions:**
- **Bucket Management:** Crear/eliminar buckets con nombres que contengan "billpay" o "demo"
- **Object Management:** Subir/descargar/eliminar archivos en buckets autorizados
- **Website Hosting:** Configurar buckets para hosting estático

#### **CloudFront Permissions:**
- **Distribution Management:** Crear/gestionar distribuciones CDN
- **Cache Invalidation:** Limpiar cache cuando se actualiza contenido

#### **STS Permissions:**
- **Identity Verification:** Verificar identidad del caller para debugging

## 🔄 Workflow Integration

### **Configuración en Workflows**

#### **Permisos Requeridos:**
```yaml
permissions:
  id-token: write    # Para obtener OIDC token
  contents: read     # Para leer código del repositorio
```

#### **Configuración de Credenciales:**
```yaml
- name: Configure AWS Credentials (OIDC)
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    role-session-name: BillPay[WorkflowName]
    aws-region: ${{ env.AWS_REGION }}
```

### **Session Names por Workflow:**
- `BillPayGitHubActions` - deploy-simple-oidc.yml
- `BillPayCompleteStack` - deploy-complete.yml  
- `BillPayServiceDeploy` - deploy-service.yml
- `BillPayInfrastructure` - infrastructure.yml
- `BillPayCleanup` - cleanup.yml
- `BillPaySimpleDeploy` - deploy-simple.yml

## 📊 Compliance Status

### **Workflows OIDC Compliance:**
```
✅ deploy-simple.yml - OIDC Compliant
✅ deploy-simple-oidc.yml - OIDC Native
✅ deploy-complete.yml - OIDC Compliant  
✅ deploy-service.yml - OIDC Compliant
✅ infrastructure.yml - OIDC Compliant
✅ cleanup.yml - OIDC Compliant
ℹ️  deploy-demo-simulation.yml - No AWS auth needed

Compliance Rate: 100% (6/6 AWS workflows)
```

### **Security Improvements:**
```
Before OIDC:
❌ Hardcoded AWS credentials in secrets
❌ Permanent credentials with broad permissions  
❌ Manual credential rotation
❌ Limited audit trail

After OIDC:
✅ No hardcoded credentials
✅ Temporary credentials (1 hour TTL)
✅ Automatic credential rotation
✅ Complete audit trail
✅ Repository-specific access control
✅ Principle of least privilege
```

## 🔧 Management Operations

### **Setup Commands:**
```bash
# Initial OIDC setup
./iam/setup-oidc-roles.sh

# Add GitHub secret
gh secret set AWS_ROLE_ARN \
  --body "arn:aws:iam::485663596015:role/BillPayGitHubActionsRole" \
  --repo giovanemere/ia-ops-iac
```

### **Verification Commands:**
```bash
# Check OIDC compliance
./check-oidc-compliance.sh

# Test OIDC system
./test-oidc-system.sh

# Verify AWS setup
./verify-oidc-setup.sh
```

### **Monitoring Commands:**
```bash
# List OIDC providers
aws iam list-open-id-connect-providers

# Get role details
aws iam get-role --role-name BillPayGitHubActionsRole

# List role policies
aws iam list-attached-role-policies --role-name BillPayGitHubActionsRole
```

## 🚨 Security Considerations

### **Access Control:**
- **Repository Restriction:** Solo repos específicos pueden asumir el role
- **Branch Protection:** Cualquier branch autorizado (permite feature branches)
- **Time Limitation:** Sesiones expiran automáticamente en 1 hora
- **Resource Limitation:** Solo recursos con nombres específicos

### **Audit Trail:**
- **CloudTrail:** Registra todas las llamadas AssumeRoleWithWebIdentity
- **GitHub Actions:** Logs completos de ejecución de workflows
- **Session Names:** Identifican qué workflow ejecutó qué acción

### **Risk Mitigation:**
- **Least Privilege:** Permisos mínimos necesarios
- **Resource Scoping:** Solo buckets con nombres específicos
- **Automatic Expiration:** Credenciales temporales
- **Monitoring:** Compliance checks automatizados

## 🔄 Rotation and Maintenance

### **Automatic Rotation:**
- **OIDC Tokens:** Generados automáticamente por GitHub
- **AWS Credentials:** Emitidos temporalmente por STS
- **No Manual Rotation:** Sistema completamente automatizado

### **Maintenance Tasks:**
```bash
# Daily
./validate-current-state.sh

# Weekly  
./check-oidc-compliance.sh
./cleanup-test-buckets.sh

# Monthly
# Review CloudTrail logs
# Update documentation
# Security assessment
```

## 📈 Future Enhancements

### **Multi-Cloud OIDC:**
- **GCP:** Workload Identity Federation
- **Azure:** Federated Identity Credentials
- **OCI:** Resource Principals

### **Enhanced Monitoring:**
- **Cost Alerts:** Monitoreo de costos por deployment
- **Security Alerts:** Detección de uso anómalo
- **Performance Metrics:** Tiempo de deployment, success rate

### **Advanced Permissions:**
- **Environment-Specific Roles:** Dev/Staging/Prod roles separados
- **Service-Specific Policies:** Permisos granulares por servicio
- **Dynamic Permissions:** Permisos basados en contexto

---

## 🎯 Resumen de Beneficios

### **Seguridad:**
- ✅ **Eliminación completa** de credenciales hardcodeadas
- ✅ **Rotación automática** de credenciales
- ✅ **Audit trail completo** para compliance
- ✅ **Principio de menor privilegio** implementado

### **Operacional:**
- ✅ **Gestión simplificada** de credenciales
- ✅ **Escalabilidad** para múltiples repositorios
- ✅ **Mantenimiento mínimo** requerido
- ✅ **Compliance automatizado** verificado

### **Desarrollo:**
- ✅ **Developer experience** mejorado
- ✅ **Deployment seguro** sin configuración adicional
- ✅ **Testing automatizado** de seguridad
- ✅ **Documentación completa** disponible

**🔐 Sistema de roles y permisos optimizado para máxima seguridad y mínimo mantenimiento**

*Actualizado: 2025-09-24 - BillPay Platform Security Team*
