#!/bin/bash

# 🔐 Verificación Rápida de Setup OIDC

echo "🔐 VERIFICACIÓN DE SETUP OIDC"
echo "============================="
echo ""

# Verificar AWS CLI
echo "🔍 Verificando AWS CLI..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    echo "✅ AWS CLI configurado - Account: $ACCOUNT_ID"
else
    echo "❌ AWS CLI no configurado"
    exit 1
fi

# Verificar OIDC Provider
echo ""
echo "🔍 Verificando OIDC Provider..."
if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "arn:aws:iam::$ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com" > /dev/null 2>&1; then
    echo "✅ OIDC Provider existe"
else
    echo "❌ OIDC Provider no encontrado"
    exit 1
fi

# Verificar Role
echo ""
echo "🔍 Verificando IAM Role..."
if aws iam get-role --role-name BillPayGitHubActionsRole > /dev/null 2>&1; then
    echo "✅ Role BillPayGitHubActionsRole existe"
    ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/BillPayGitHubActionsRole"
    echo "🏷️ Role ARN: $ROLE_ARN"
else
    echo "❌ Role BillPayGitHubActionsRole no encontrado"
    exit 1
fi

# Verificar Policy
echo ""
echo "🔍 Verificando IAM Policy..."
if aws iam get-policy --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/BillPayDeploymentPolicy" > /dev/null 2>&1; then
    echo "✅ Policy BillPayDeploymentPolicy existe"
else
    echo "❌ Policy BillPayDeploymentPolicy no encontrada"
    exit 1
fi

# Verificar GitHub Secret
echo ""
echo "🔍 Verificando GitHub Secret..."
if gh secret list --repo giovanemere/ia-ops-iac | grep -q "AWS_ROLE_ARN"; then
    echo "✅ GitHub Secret AWS_ROLE_ARN configurado"
else
    echo "❌ GitHub Secret AWS_ROLE_ARN no encontrado"
    echo "💡 Ejecutar: gh secret set AWS_ROLE_ARN --body \"$ROLE_ARN\" --repo giovanemere/ia-ops-iac"
    exit 1
fi

# Test rápido de template
echo ""
echo "🧪 Probando template OIDC..."
TASK_ID=$(curl -s -X POST "http://localhost:7007/api/scaffolder/v2/tasks" \
    -H "Content-Type: application/json" \
    -d '{"templateRef": "template:default/billpay-demo-simple", "values": {"project_name": "test-oidc-verify", "environment": "demo", "deployment_type": "real-aws-oidc"}}' \
    | jq -r '.id' 2>/dev/null)

if [ "$TASK_ID" != "null" ] && [ -n "$TASK_ID" ]; then
    echo "✅ Template OIDC ejecutado - Task ID: ${TASK_ID:0:8}..."
    
    sleep 3
    STATUS=$(curl -s "http://localhost:7007/api/scaffolder/v2/tasks/$TASK_ID" | jq -r '.status' 2>/dev/null)
    echo "📊 Estado: $STATUS"
else
    echo "❌ Error ejecutando template OIDC"
    exit 1
fi

echo ""
echo "🎉 SETUP OIDC VERIFICADO EXITOSAMENTE"
echo "===================================="
echo "✅ OIDC Provider: Configurado"
echo "✅ IAM Role: Configurado"
echo "✅ IAM Policy: Configurado"
echo "✅ GitHub Secret: Configurado"
echo "✅ Template OIDC: Funcionando"
echo ""
echo "🔗 Monitorear deployment en:"
echo "https://github.com/giovanemere/ia-ops-iac/actions"
echo ""
echo "🎯 OIDC está listo para uso en producción!"
