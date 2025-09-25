#!/bin/bash

# 🔍 Validación del Estado Actual - BillPay Platform

echo "🔍 VALIDACIÓN DEL ESTADO ACTUAL - BILLPAY PLATFORM"
echo "=================================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contadores
PASSED=0
FAILED=0
WARNINGS=0

# Función para checks
check_status() {
    local description="$1"
    local command="$2"
    local critical="$3"
    
    echo -n "🔍 $description... "
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((PASSED++))
        return 0
    else
        if [ "$critical" = "critical" ]; then
            echo -e "${RED}❌ FAIL (CRÍTICO)${NC}"
            ((FAILED++))
        else
            echo -e "${YELLOW}⚠️  WARNING${NC}"
            ((WARNINGS++))
        fi
        return 1
    fi
}

echo "📋 VERIFICANDO COMPONENTES BÁSICOS..."
echo "------------------------------------"

# Backstage
check_status "Backstage Frontend (puerto 3000)" "curl -s http://localhost:3000 > /dev/null" "critical"
check_status "Backstage Backend (puerto 7007)" "curl -s http://localhost:7007/api/catalog/entities > /dev/null" "critical"

# Templates
check_status "Templates cargados en Backstage" "curl -s 'http://localhost:7007/api/catalog/entities?filter=kind=template' | jq -e '.[] | select(.metadata.name == \"billpay-demo-simple\")' > /dev/null" "critical"

# GitHub Auth
check_status "Variables GitHub configuradas" "[ -n \"$GITHUB_TOKEN\" ] && [ -n \"$AUTH_GITHUB_CLIENT_ID\" ]" "warning"

echo ""
echo "📋 VERIFICANDO REPOSITORIOS..."
echo "------------------------------"

# Repositorios
REPOS=("ia-ops-iac" "poc-billpay-back" "poc-billpay-front-a" "templates_backstage")
for repo in "${REPOS[@]}"; do
    check_status "Repositorio $repo existe" "[ -d \"/home/giovanemere/periferia/billpay/repositories/$repo/.git\" ]" "critical"
done

echo ""
echo "📋 VERIFICANDO WORKFLOWS..."
echo "---------------------------"

# Workflows
check_status "Workflow deploy-simple.yml existe" "[ -f \"/home/giovanemere/periferia/billpay/repositories/ia-ops-iac/.github/workflows/deploy-simple.yml\" ]" "critical"
check_status "Workflow deploy-demo-simulation.yml existe" "[ -f \"/home/giovanemere/periferia/billpay/repositories/ia-ops-iac/.github/workflows/deploy-demo-simulation.yml\" ]" "critical"

echo ""
echo "📋 PROBANDO FUNCIONALIDAD..."
echo "----------------------------"

# Test template execution with OIDC
echo -n "🧪 Probando ejecución de template OIDC... "
TASK_ID=$(curl -s -X POST "http://localhost:7007/api/scaffolder/v2/tasks" \
    -H "Content-Type: application/json" \
    -d '{"templateRef": "template:default/billpay-demo-simple", "values": {"project_name": "test-validation-oidc", "environment": "demo", "deployment_type": "real-aws-oidc"}}' \
    | jq -r '.id' 2>/dev/null)

if [ "$TASK_ID" != "null" ] && [ -n "$TASK_ID" ]; then
    echo -e "${GREEN}✅ PASS${NC} (Task ID: ${TASK_ID:0:8}...)"
    ((PASSED++))
    
    # Wait and check task status
    sleep 3
    echo -n "🔍 Verificando estado de la tarea OIDC... "
    TASK_STATUS=$(curl -s "http://localhost:7007/api/scaffolder/v2/tasks/$TASK_ID" | jq -r '.status' 2>/dev/null)
    
    if [ "$TASK_STATUS" = "completed" ] || [ "$TASK_STATUS" = "processing" ]; then
        echo -e "${GREEN}✅ PASS${NC} (Status: $TASK_STATUS)"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  WARNING${NC} (Status: $TASK_STATUS)"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌ FAIL${NC}"
    ((FAILED++))
fi

echo ""
echo "📊 RESUMEN DE VALIDACIÓN"
echo "========================"
echo -e "✅ Pasaron: ${GREEN}$PASSED${NC}"
echo -e "⚠️  Advertencias: ${YELLOW}$WARNINGS${NC}"
echo -e "❌ Fallaron: ${RED}$FAILED${NC}"

TOTAL=$((PASSED + WARNINGS + FAILED))
SUCCESS_RATE=$((PASSED * 100 / TOTAL))

echo ""
echo "📈 Tasa de éxito: $SUCCESS_RATE%"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 SISTEMA FUNCIONAL - Listo para continuar${NC}"
    EXIT_CODE=0
elif [ $FAILED -le 2 ]; then
    echo -e "${YELLOW}⚠️  SISTEMA PARCIALMENTE FUNCIONAL - Revisar errores críticos${NC}"
    EXIT_CODE=1
else
    echo -e "${RED}❌ SISTEMA CON PROBLEMAS CRÍTICOS - Requiere corrección inmediata${NC}"
    EXIT_CODE=2
fi

echo ""
echo "📋 PRÓXIMOS PASOS RECOMENDADOS:"
echo "------------------------------"

if [ $FAILED -gt 0 ]; then
    echo "1. 🔧 Corregir errores críticos identificados"
    echo "2. 🔄 Reiniciar servicios si es necesario"
    echo "3. 🧪 Re-ejecutar validación"
else
    echo "1. 🚀 Continuar con implementación de logs en tiempo real"
    echo "2. 🔑 Configurar AWS credentials para testing real"
    echo "3. 📊 Implementar métricas de monitoreo"
fi

echo ""
echo "🔗 Enlaces útiles:"
echo "- Backstage: http://localhost:3000"
echo "- GitHub Actions: https://github.com/giovanemere/ia-ops-iac/actions"
echo "- Plan completo: /home/giovanemere/periferia/billpay/PLAN_CORRECCION_ERRORES.md"

exit $EXIT_CODE
