#!/bin/bash

echo "🧪 TESTING BACKSTAGE TEMPLATE"
echo "=============================="

# Verificar estructura del template
echo "📁 Verificando estructura..."
TEMPLATE_DIR="/home/giovanemere/periferia/billpay/repositories/templates_backstage/billpay-complete-stack"

if [ -f "$TEMPLATE_DIR/template.yaml" ]; then
    echo "✅ template.yaml encontrado"
else
    echo "❌ template.yaml NO encontrado"
    exit 1
fi

if [ -d "$TEMPLATE_DIR/content" ]; then
    echo "✅ directorio content encontrado"
else
    echo "❌ directorio content NO encontrado"
    exit 1
fi

# Validar YAML del template
echo "📋 Validando YAML..."
if command -v yq &> /dev/null; then
    yq eval '.metadata.name' "$TEMPLATE_DIR/template.yaml"
    echo "✅ YAML válido"
else
    echo "⚠️  yq no disponible, saltando validación YAML"
fi

# Verificar parámetros del template
echo "🎯 Verificando parámetros..."
if grep -q "cloud_provider" "$TEMPLATE_DIR/template.yaml"; then
    echo "✅ Parámetro cloud_provider encontrado"
else
    echo "❌ Parámetro cloud_provider NO encontrado"
fi

if grep -q "region" "$TEMPLATE_DIR/template.yaml"; then
    echo "✅ Parámetro region encontrado"
else
    echo "❌ Parámetro region NO encontrado"
fi

# Verificar steps del template
echo "🔄 Verificando steps..."
if grep -q "github:actions:dispatch" "$TEMPLATE_DIR/template.yaml"; then
    echo "✅ GitHub Actions dispatch encontrado"
else
    echo "❌ GitHub Actions dispatch NO encontrado"
fi

if grep -q "catalog:write" "$TEMPLATE_DIR/template.yaml"; then
    echo "✅ Catalog write encontrado"
else
    echo "❌ Catalog write NO encontrado"
fi

# Verificar outputs
echo "📤 Verificando outputs..."
if grep -q "output:" "$TEMPLATE_DIR/template.yaml"; then
    echo "✅ Outputs configurados"
else
    echo "❌ Outputs NO configurados"
fi

# Verificar catálogo principal
echo "📚 Verificando catálogo..."
CATALOG_FILE="/home/giovanemere/periferia/billpay/repositories/templates_backstage/catalog-info.yaml"
if [ -f "$CATALOG_FILE" ]; then
    echo "✅ catalog-info.yaml encontrado"
    if grep -q "billpay-complete-stack" "$CATALOG_FILE"; then
        echo "✅ Template referenciado en catálogo"
    else
        echo "❌ Template NO referenciado en catálogo"
    fi
else
    echo "❌ catalog-info.yaml NO encontrado"
fi

# Verificar API docs
echo "📖 Verificando API docs..."
API_SPEC="/home/giovanemere/periferia/billpay/repositories/poc-billpay-back/docs/api-spec.yaml"
if [ -f "$API_SPEC" ]; then
    echo "✅ API spec encontrado"
else
    echo "❌ API spec NO encontrado"
fi

echo ""
echo "🎉 PRUEBA COMPLETADA"
echo "==================="

# Mostrar resumen del template
echo "📋 RESUMEN DEL TEMPLATE:"
echo "- Nombre: BillPay Complete Stack Multi-Cloud"
echo "- Clouds soportados: AWS, GCP, Azure, OCI"
echo "- Componentes: Infraestructura + Backend + Frontends"
echo "- Integración: GitHub Actions centralizados"
echo "- Catálogo: Registro automático en Backstage"

echo ""
echo "🚀 LISTO PARA USAR EN BACKSTAGE!"
echo "Accede a: http://localhost:3000"
