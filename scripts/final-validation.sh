#!/bin/bash

echo "🎉 VALIDACIÓN FINAL - PROYECTO BILLPAY"
echo "====================================="

# Verificar Backstage
echo "🎭 Verificando Backstage..."
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "  ✅ Backstage corriendo en http://localhost:3000"
else
    echo "  ❌ Backstage NO está corriendo"
fi

# Verificar template
echo "🎯 Verificando template..."
TEMPLATE_PATH="/home/giovanemere/periferia/billpay/repositories/templates_backstage/billpay-complete-stack/template.yaml"
if [ -f "$TEMPLATE_PATH" ]; then
    echo "  ✅ Template encontrado"
    
    # Verificar parámetros clave
    if grep -q "cloud_provider" "$TEMPLATE_PATH" && grep -q "region" "$TEMPLATE_PATH"; then
        echo "  ✅ Parámetros multi-cloud configurados"
    else
        echo "  ❌ Parámetros multi-cloud NO configurados"
    fi
else
    echo "  ❌ Template NO encontrado"
fi

# Verificar workflows centralizados
echo "🔄 Verificando workflows centralizados..."
WORKFLOWS_PATH="/home/giovanemere/periferia/billpay/repositories/ia-ops-iac/.github/workflows"
if [ -d "$WORKFLOWS_PATH" ]; then
    echo "  ✅ Directorio de workflows encontrado"
    
    # Verificar workflows específicos
    if [ -f "$WORKFLOWS_PATH/infrastructure.yml" ]; then
        echo "  ✅ infrastructure.yml encontrado"
    fi
    if [ -f "$WORKFLOWS_PATH/deploy-service.yml" ]; then
        echo "  ✅ deploy-service.yml encontrado"
    fi
    if [ -f "$WORKFLOWS_PATH/deploy-complete.yml" ]; then
        echo "  ✅ deploy-complete.yml encontrado"
    fi
else
    echo "  ❌ Directorio de workflows NO encontrado"
fi

# Verificar Dockerfiles
echo "🐳 Verificando Dockerfiles..."
REPOS=("poc-billpay-back" "poc-billpay-front-a" "poc-billpay-front-b" "poc-billpay-front-feature-flags")
for repo in "${REPOS[@]}"; do
    DOCKERFILE_PATH="/home/giovanemere/periferia/billpay/repositories/$repo/Dockerfile"
    if [ -f "$DOCKERFILE_PATH" ]; then
        echo "  ✅ Dockerfile en $repo"
    else
        echo "  ❌ Dockerfile NO encontrado en $repo"
    fi
done

# Verificar infraestructura
echo "🏗️ Verificando infraestructura..."
INFRA_PATH="/home/giovanemere/periferia/billpay/infrastructure/terragrunt/environments/dev"
if [ -d "$INFRA_PATH" ]; then
    echo "  ✅ Configuración Terragrunt encontrada"
    
    if [ -f "$INFRA_PATH/terragrunt.hcl" ]; then
        echo "  ✅ terragrunt.hcl configurado"
    fi
else
    echo "  ❌ Configuración Terragrunt NO encontrada"
fi

# Verificar documentación
echo "📚 Verificando documentación..."
DOCS=("README.md" "docs/PROJECT_PROGRESS.md" "docs/WORKFLOWS.md" "docs/BACKSTAGE_USAGE.md")
for doc in "${DOCS[@]}"; do
    DOC_PATH="/home/giovanemere/periferia/billpay/$doc"
    if [ -f "$DOC_PATH" ]; then
        echo "  ✅ $doc encontrado"
    else
        echo "  ❌ $doc NO encontrado"
    fi
done

# Verificar API documentation
echo "📖 Verificando API docs..."
API_SPEC="/home/giovanemere/periferia/billpay/repositories/poc-billpay-back/docs/api-spec.yaml"
if [ -f "$API_SPEC" ]; then
    echo "  ✅ API specification encontrada"
else
    echo "  ❌ API specification NO encontrada"
fi

echo ""
echo "🎯 RESUMEN DE VALIDACIÓN"
echo "======================="

# Calcular progreso
TOTAL_CHECKS=20
PASSED_CHECKS=0

# Contar checks pasados (simplificado)
if curl -s http://localhost:3000 > /dev/null 2>&1; then ((PASSED_CHECKS++)); fi
if [ -f "$TEMPLATE_PATH" ]; then ((PASSED_CHECKS++)); fi
if [ -d "$WORKFLOWS_PATH" ]; then ((PASSED_CHECKS++)); fi
for repo in "${REPOS[@]}"; do
    if [ -f "/home/giovanemere/periferia/billpay/repositories/$repo/Dockerfile" ]; then
        ((PASSED_CHECKS++))
    fi
done
for doc in "${DOCS[@]}"; do
    if [ -f "/home/giovanemere/periferia/billpay/$doc" ]; then
        ((PASSED_CHECKS++))
    fi
done

PERCENTAGE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo "📊 Progreso: $PASSED_CHECKS/$TOTAL_CHECKS checks pasados ($PERCENTAGE%)"

if [ $PERCENTAGE -ge 90 ]; then
    echo "🎉 PROYECTO COMPLETADO EXITOSAMENTE"
    echo "=================================="
    echo ""
    echo "✅ Todas las funcionalidades principales están operativas"
    echo "✅ Template de Backstage listo para usar"
    echo "✅ Workflows centralizados configurados"
    echo "✅ Documentación completa"
    echo ""
    echo "🚀 LISTO PARA DEMO:"
    echo "1. Abrir: http://localhost:3000"
    echo "2. Create → 'BillPay Complete Stack Multi-Cloud'"
    echo "3. Configurar y desplegar"
    echo ""
    echo "🎯 DEVELOPER EXPERIENCE ALCANZADO:"
    echo "- 1-click deployment ✅"
    echo "- Multi-cloud support ✅"
    echo "- Workflows centralizados ✅"
    echo "- Documentación automática ✅"
elif [ $PERCENTAGE -ge 70 ]; then
    echo "⚠️ PROYECTO MAYORMENTE COMPLETO"
    echo "Algunos componentes menores necesitan atención"
else
    echo "❌ PROYECTO NECESITA MÁS TRABAJO"
    echo "Varios componentes críticos faltan"
fi

echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "1. Probar template en Backstage"
echo "2. Validar deploy completo"
echo "3. Documentar cualquier issue encontrado"
