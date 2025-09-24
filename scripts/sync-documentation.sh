#!/bin/bash

echo "🔄 SINCRONIZANDO DOCUMENTACIÓN BILLPAY"
echo "====================================="

BASE_DIR="/home/giovanemere/periferia/billpay"

# Función para actualizar repositorio
update_repo_docs() {
    local repo_name=$1
    local repo_path="$BASE_DIR/repositories/$repo_name"
    
    echo "📝 Actualizando $repo_name..."
    
    if [ -d "$repo_path" ]; then
        # Verificar si hay cambios
        cd "$repo_path"
        if git status --porcelain | grep -q .; then
            echo "  ✅ Cambios detectados en $repo_name"
            
            # Agregar cambios
            git add .
            git commit -m "docs: update documentation and catalog integration"
            
            echo "  📤 Cambios committeados en $repo_name"
        else
            echo "  ℹ️  No hay cambios en $repo_name"
        fi
    else
        echo "  ❌ Repositorio $repo_name no encontrado"
    fi
}

# Actualizar repositorios principales
echo "🔄 Actualizando repositorios..."
update_repo_docs "poc-billpay-back"
update_repo_docs "poc-billpay-front-a"
update_repo_docs "poc-billpay-front-b"
update_repo_docs "poc-billpay-front-feature-flags"
update_repo_docs "templates_backstage"

# Verificar template de Backstage
echo "🎭 Verificando template de Backstage..."
TEMPLATE_PATH="$BASE_DIR/repositories/templates_backstage/billpay-complete-stack/template.yaml"
if [ -f "$TEMPLATE_PATH" ]; then
    echo "  ✅ Template encontrado"
    
    # Verificar que tiene los parámetros correctos
    if grep -q "cloud_provider" "$TEMPLATE_PATH"; then
        echo "  ✅ Parámetros multi-cloud configurados"
    else
        echo "  ❌ Parámetros multi-cloud NO configurados"
    fi
else
    echo "  ❌ Template NO encontrado"
fi

# Verificar catálogo principal
echo "📚 Verificando catálogo principal..."
CATALOG_PATH="$BASE_DIR/repositories/templates_backstage/catalog-info.yaml"
if [ -f "$CATALOG_PATH" ]; then
    echo "  ✅ Catálogo principal encontrado"
else
    echo "  ❌ Catálogo principal NO encontrado"
fi

# Verificar API specs
echo "📖 Verificando API specifications..."
API_SPEC_PATH="$BASE_DIR/repositories/poc-billpay-back/docs/api-spec.yaml"
if [ -f "$API_SPEC_PATH" ]; then
    echo "  ✅ API spec encontrado"
else
    echo "  ❌ API spec NO encontrado"
fi

echo ""
echo "🎉 SINCRONIZACIÓN COMPLETADA"
echo "=========================="
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "1. Refrescar catálogo en Backstage"
echo "2. Verificar que el template aparece actualizado"
echo "3. Probar creación de nuevo componente"
echo ""
echo "🔗 ACCESOS:"
echo "- Backstage: http://localhost:3000"
echo "- Templates: http://localhost:3000/create"
echo "- Catálogo: http://localhost:3000/catalog"
