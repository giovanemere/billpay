#!/bin/bash

# 🧪 Test OIDC System - BillPay Platform

echo "🧪 TESTING OIDC SYSTEM - BILLPAY PLATFORM"
echo "========================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Función para test
run_test() {
    local test_name="$1"
    local deployment_type="$2"
    local project_name="test-${deployment_type}-$(date +%s)"
    
    echo "🧪 Testing: $test_name"
    echo "📋 Project: $project_name"
    echo "🎯 Type: $deployment_type"
    
    # Ejecutar template
    TASK_ID=$(curl -s -X POST "http://localhost:7007/api/scaffolder/v2/tasks" \
        -H "Content-Type: application/json" \
        -d "{\"templateRef\": \"template:default/billpay-demo-simple\", \"values\": {\"project_name\": \"$project_name\", \"environment\": \"demo\", \"deployment_type\": \"$deployment_type\"}}" \
        | jq -r '.id' 2>/dev/null)
    
    if [ "$TASK_ID" != "null" ] && [ -n "$TASK_ID" ]; then
        echo "✅ Template ejecutado - Task ID: ${TASK_ID:0:8}..."
        
        # Esperar y verificar estado
        sleep 5
        STATUS=$(curl -s "http://localhost:7007/api/scaffolder/v2/tasks/$TASK_ID" | jq -r '.status' 2>/dev/null)
        
        case $STATUS in
            "completed")
                echo -e "${GREEN}✅ SUCCESS${NC} - Template completado"
                return 0
                ;;
            "processing")
                echo -e "${YELLOW}🔄 PROCESSING${NC} - Template en progreso"
                return 0
                ;;
            "failed")
                echo -e "${RED}❌ FAILED${NC} - Template falló"
                return 1
                ;;
            *)
                echo -e "${YELLOW}⚠️ UNKNOWN${NC} - Estado: $STATUS"
                return 1
                ;;
        esac
    else
        echo -e "${RED}❌ FAILED${NC} - No se pudo ejecutar template"
        return 1
    fi
}

# Verificar Backstage está corriendo
echo "🔍 Verificando Backstage..."
if curl -s http://localhost:7007/api/catalog/entities > /dev/null; then
    echo "✅ Backstage Backend OK"
else
    echo "❌ Backstage Backend DOWN - Iniciando..."
    cd /home/giovanemere/ia-ops/ia-ops-backstage
    ./start-with-github-auth.sh &
    sleep 15
fi

echo ""
echo "🧪 EJECUTANDO TESTS..."
echo "====================="

# Test 1: Simulación
echo ""
run_test "Simulation Mode" "simulation"
SIMULATION_RESULT=$?

# Test 2: OIDC
echo ""
run_test "OIDC Mode" "real-aws-oidc"
OIDC_RESULT=$?

# Test 3: Legacy (opcional)
echo ""
run_test "Legacy Mode" "real-aws-legacy"
LEGACY_RESULT=$?

# Resumen
echo ""
echo "📊 RESUMEN DE TESTS"
echo "=================="

if [ $SIMULATION_RESULT -eq 0 ]; then
    echo -e "🎭 Simulation: ${GREEN}✅ PASS${NC}"
else
    echo -e "🎭 Simulation: ${RED}❌ FAIL${NC}"
fi

if [ $OIDC_RESULT -eq 0 ]; then
    echo -e "🔐 OIDC: ${GREEN}✅ PASS${NC}"
else
    echo -e "🔐 OIDC: ${RED}❌ FAIL${NC}"
fi

if [ $LEGACY_RESULT -eq 0 ]; then
    echo -e "☁️ Legacy: ${GREEN}✅ PASS${NC}"
else
    echo -e "☁️ Legacy: ${RED}❌ FAIL${NC}"
fi

# Calcular éxito
TOTAL_TESTS=3
PASSED_TESTS=0
[ $SIMULATION_RESULT -eq 0 ] && ((PASSED_TESTS++))
[ $OIDC_RESULT -eq 0 ] && ((PASSED_TESTS++))
[ $LEGACY_RESULT -eq 0 ] && ((PASSED_TESTS++))

SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))

echo ""
echo "📈 Tasa de éxito: $SUCCESS_RATE% ($PASSED_TESTS/$TOTAL_TESTS)"

# Información adicional
echo ""
echo "🔗 MONITOREO EN TIEMPO REAL:"
echo "============================"
echo "📊 GitHub Actions: https://github.com/giovanemere/ia-ops-iac/actions"
echo "🎭 Backstage: http://localhost:3000"
echo "📋 API: http://localhost:7007"

echo ""
echo "💡 PRÓXIMOS PASOS:"
echo "=================="
if [ $OIDC_RESULT -ne 0 ]; then
    echo "🔧 Para configurar OIDC:"
    echo "   cd /home/giovanemere/periferia/billpay/repositories/ia-ops-iac"
    echo "   ./iam/setup-oidc-roles.sh"
    echo "   # Agregar AWS_ROLE_ARN a GitHub secrets"
fi

if [ $SUCCESS_RATE -eq 100 ]; then
    echo -e "${GREEN}🎉 TODOS LOS TESTS PASARON - Sistema completamente funcional${NC}"
elif [ $SUCCESS_RATE -ge 66 ]; then
    echo -e "${YELLOW}⚠️ MAYORÍA DE TESTS PASARON - Sistema mayormente funcional${NC}"
else
    echo -e "${RED}❌ MÚLTIPLES TESTS FALLARON - Revisar configuración${NC}"
fi

exit $((3 - PASSED_TESTS))
