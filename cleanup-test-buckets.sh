#!/bin/bash

# 🧹 Cleanup Test Buckets - BillPay Platform

echo "🧹 LIMPIEZA DE BUCKETS DE PRUEBA"
echo "==============================="
echo ""

# Lista de buckets específicos a eliminar
BUCKETS=(
    "test-oidc-fixed-demo-frontend-a"
    "test-oidc-verify-demo-frontend-a"
    "test-real-aws-legacy-1758686902-demo-frontend-a"
    "test-real-aws-legacy-1758687018-demo-frontend-a"
)

# Función para eliminar bucket
cleanup_bucket() {
    local bucket_name="$1"
    echo "🗑️  Eliminando bucket: $bucket_name"
    
    # Verificar si el bucket existe
    if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
        echo "   📋 Bucket encontrado, eliminando contenido..."
        
        # Eliminar todos los objetos
        aws s3 rm s3://$bucket_name --recursive 2>/dev/null || true
        
        # Eliminar el bucket
        if aws s3 rb s3://$bucket_name 2>/dev/null; then
            echo "   ✅ Bucket eliminado exitosamente"
        else
            echo "   ⚠️  Error eliminando bucket (puede no existir)"
        fi
    else
        echo "   ℹ️  Bucket no encontrado (ya eliminado)"
    fi
    echo ""
}

# Eliminar buckets específicos
echo "🎯 Eliminando buckets específicos..."
echo ""
for bucket in "${BUCKETS[@]}"; do
    cleanup_bucket "$bucket"
done

# Buscar y eliminar otros buckets de test
echo "🔍 Buscando otros buckets de test..."
TEST_BUCKETS=$(aws s3 ls | grep -E "(test-|demo-)" | awk '{print $3}' || true)

if [ -n "$TEST_BUCKETS" ]; then
    echo "📋 Buckets de test encontrados:"
    echo "$TEST_BUCKETS"
    echo ""
    
    read -p "¿Eliminar todos los buckets de test? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$TEST_BUCKETS" | while read bucket; do
            if [ -n "$bucket" ]; then
                cleanup_bucket "$bucket"
            fi
        done
    else
        echo "ℹ️  Limpieza automática cancelada"
    fi
else
    echo "✅ No se encontraron buckets de test adicionales"
fi

echo ""
echo "🎉 LIMPIEZA COMPLETADA"
echo "====================="
echo "✅ Buckets específicos procesados"
echo "🔍 Buckets adicionales verificados"
echo ""
echo "💡 Para verificar buckets restantes:"
echo "aws s3 ls"
