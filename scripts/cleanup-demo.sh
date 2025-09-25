#!/bin/bash

echo "🧹 BillPay Demo Cleanup"
echo "======================"

# List all billpay buckets
echo "🔍 Buscando buckets de BillPay..."
BUCKETS=$(aws s3 ls | grep billpay | awk '{print $3}')

if [ -z "$BUCKETS" ]; then
    echo "✅ No hay buckets de BillPay para eliminar"
    exit 0
fi

echo "📋 Buckets encontrados:"
echo "$BUCKETS"
echo ""

read -p "¿Eliminar todos los buckets de BillPay? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    for bucket in $BUCKETS; do
        echo "🗑️  Eliminando: $bucket"
        aws s3 rb s3://$bucket --force
    done
    echo "✅ Cleanup completado"
else
    echo "❌ Cleanup cancelado"
fi
