#!/bin/bash

# Script para arreglar permisos de buckets S3 existentes
# Uso: ./fix-s3-permissions.sh [bucket-name]

set -e

BUCKET_NAME=${1:-"billpay-bucket-s3-dev-frontend-a"}
REGION=${2:-"us-east-1"}

echo "🔧 Arreglando permisos S3 para: $BUCKET_NAME"
echo "🌎 Región: $REGION"
echo ""

# Verificar si el bucket existe
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null; then
    echo "❌ Bucket $BUCKET_NAME no existe o no tienes acceso"
    exit 1
fi

echo "✅ Bucket encontrado: $BUCKET_NAME"
echo ""

# 1. Remover bloqueo de acceso público
echo "🔓 Removiendo bloqueo de acceso público..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false" \
    --region "$REGION"

echo "✅ Bloqueo de acceso público removido"

# 2. Habilitar website hosting
echo "🌐 Habilitando website hosting..."
aws s3 website "s3://$BUCKET_NAME" \
    --index-document index.html \
    --error-document error.html \
    --region "$REGION"

echo "✅ Website hosting habilitado"

# 3. Aplicar política de bucket público
echo "📋 Aplicando política de acceso público..."
cat > /tmp/bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy \
    --bucket "$BUCKET_NAME" \
    --policy file:///tmp/bucket-policy.json \
    --region "$REGION"

echo "✅ Política de acceso público aplicada"

# 4. Configurar CORS
echo "🔗 Configurando CORS..."
cat > /tmp/cors-config.json << EOF
{
    "CORSRules": [
        {
            "AllowedHeaders": ["*"],
            "AllowedMethods": ["GET", "HEAD"],
            "AllowedOrigins": ["*"],
            "ExposeHeaders": ["ETag"],
            "MaxAgeSeconds": 3000
        }
    ]
}
EOF

aws s3api put-bucket-cors \
    --bucket "$BUCKET_NAME" \
    --cors-configuration file:///tmp/cors-config.json \
    --region "$REGION"

echo "✅ CORS configurado"

# Limpiar archivos temporales
rm -f /tmp/bucket-policy.json /tmp/cors-config.json

echo ""
echo "🎉 ¡Configuración completada!"
echo "🌐 URL del website: http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
echo ""
echo "💡 El bucket ahora es accesible públicamente"
echo "📝 Puedes subir archivos con: aws s3 sync ./dist s3://$BUCKET_NAME"
