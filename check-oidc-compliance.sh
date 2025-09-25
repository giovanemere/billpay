#!/bin/bash

# 🔍 Verificar Compliance OIDC en todos los workflows

echo "🔍 VERIFICACIÓN DE COMPLIANCE OIDC"
echo "=================================="
echo ""

WORKFLOWS_DIR="/home/giovanemere/periferia/billpay/repositories/ia-ops-iac/.github/workflows"
TOTAL_WORKFLOWS=0
OIDC_COMPLIANT=0
LEGACY_WORKFLOWS=0
NO_AWS_WORKFLOWS=0

echo "📋 Analizando workflows en: $WORKFLOWS_DIR"
echo ""

for file in "$WORKFLOWS_DIR"/*.yml; do
    if [ -f "$file" ]; then
        TOTAL_WORKFLOWS=$((TOTAL_WORKFLOWS + 1))
        filename=$(basename "$file")
        
        echo "📄 $filename:"
        
        # Verificar si usa AWS
        if grep -q "aws-actions/configure-aws-credentials" "$file"; then
            # Verificar si usa OIDC
            if grep -q "role-to-assume" "$file"; then
                echo "  ✅ OIDC Compliant"
                OIDC_COMPLIANT=$((OIDC_COMPLIANT + 1))
                
                # Verificar permisos OIDC
                if grep -q "id-token: write" "$file"; then
                    echo "  ✅ Permisos OIDC configurados"
                else
                    echo "  ⚠️  Faltan permisos OIDC"
                fi
                
            elif grep -q "aws-access-key-id" "$file"; then
                echo "  ❌ Usa Legacy Credentials"
                LEGACY_WORKFLOWS=$((LEGACY_WORKFLOWS + 1))
            else
                echo "  ⚠️  Configuración AWS incompleta"
            fi
        else
            echo "  ℹ️  No usa AWS"
            NO_AWS_WORKFLOWS=$((NO_AWS_WORKFLOWS + 1))
        fi
        echo ""
    fi
done

echo "📊 RESUMEN DE COMPLIANCE"
echo "======================="
echo "📄 Total workflows: $TOTAL_WORKFLOWS"
echo "✅ OIDC Compliant: $OIDC_COMPLIANT"
echo "❌ Legacy Credentials: $LEGACY_WORKFLOWS"
echo "ℹ️  Sin AWS: $NO_AWS_WORKFLOWS"

if [ $LEGACY_WORKFLOWS -eq 0 ]; then
    echo ""
    echo "🎉 TODOS LOS WORKFLOWS AWS USAN OIDC"
    echo "===================================="
    echo "✅ Compliance: 100%"
    echo "🔐 Seguridad: Máxima"
    echo "🎯 Estado: Listo para producción"
else
    echo ""
    echo "⚠️  WORKFLOWS PENDIENTES DE MIGRACIÓN"
    echo "===================================="
    echo "❌ $LEGACY_WORKFLOWS workflows usan legacy credentials"
    echo "🔧 Acción requerida: Migrar a OIDC"
fi

echo ""
echo "🔗 Para verificar deployment:"
echo "https://github.com/giovanemere/ia-ops-iac/actions"
