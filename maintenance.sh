#!/bin/bash

# 🔧 Script de Mantenimiento - BillPay Platform

echo "🔧 MANTENIMIENTO BILLPAY PLATFORM"
echo "================================="
echo ""

# Función para mostrar menú
show_menu() {
    echo "📋 Opciones de Mantenimiento:"
    echo "1. 🔍 Validación completa del sistema"
    echo "2. 🔄 Reiniciar Backstage"
    echo "3. 📥 Actualizar repositorios"
    echo "4. 🧹 Limpiar recursos AWS demo"
    echo "5. 🗑️  Limpiar buckets de test específicos"
    echo "6. 📊 Ver logs de Backstage"
    echo "6. 🧪 Test de funcionalidad"
    echo "7. 📋 Estado de GitHub Actions"
    echo "8. 🚪 Salir"
    echo ""
}

# Función de validación
validate_system() {
    echo "🔍 Ejecutando validación completa..."
    ./validate-current-state.sh
}

# Función para reiniciar Backstage
restart_backstage() {
    echo "🔄 Reiniciando Backstage..."
    pkill -f backstage 2>/dev/null
    sleep 2
    cd /home/giovanemere/ia-ops/ia-ops-backstage
    ./start-with-github-auth.sh &
    echo "✅ Backstage reiniciado"
}

# Función para actualizar repos
update_repos() {
    echo "📥 Actualizando repositorios..."
    
    echo "📦 Actualizando repositorio principal..."
    git pull origin master
    
    echo "📦 Actualizando ia-ops-iac..."
    cd repositories/ia-ops-iac && git pull origin trunk && cd ../..
    
    echo "📦 Actualizando templates..."
    cd repositories/templates_backstage && git pull origin trunk && cd ../..
    
    echo "✅ Repositorios actualizados"
}

# Función para limpiar buckets específicos
cleanup_test_buckets() {
    echo "🗑️  Ejecutando limpieza de buckets de test..."
    ./cleanup-test-buckets.sh
}
cleanup_aws() {
    echo "🧹 Limpiando recursos AWS demo..."
    
    echo "📋 Buckets de demo encontrados:"
    aws s3 ls | grep -E "(demo|test)" || echo "No se encontraron buckets de demo"
    
    read -p "¿Eliminar buckets de demo? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aws s3 ls | grep -E "(demo|test)" | awk '{print $3}' | while read bucket; do
            echo "🗑️ Eliminando bucket: $bucket"
            aws s3 rb s3://$bucket --force
        done
        echo "✅ Limpieza completada"
    else
        echo "ℹ️ Limpieza cancelada"
    fi
}

# Función para ver logs
view_logs() {
    echo "📊 Mostrando logs de Backstage (Ctrl+C para salir)..."
    tail -f /home/giovanemere/ia-ops/ia-ops-backstage/backstage.log
}

# Función de test
test_functionality() {
    echo "🧪 Ejecutando test de funcionalidad..."
    
    TASK_ID=$(curl -s -X POST "http://localhost:7007/api/scaffolder/v2/tasks" \
        -H "Content-Type: application/json" \
        -d '{"templateRef": "template:default/billpay-demo-simple", "values": {"project_name": "test-maintenance", "environment": "demo", "deployment_type": "simulation"}}' \
        | jq -r '.id' 2>/dev/null)
    
    if [ "$TASK_ID" != "null" ] && [ -n "$TASK_ID" ]; then
        echo "✅ Template ejecutado exitosamente"
        echo "📋 Task ID: $TASK_ID"
        echo "🔗 Monitor: https://github.com/giovanemere/ia-ops-iac/actions"
    else
        echo "❌ Error ejecutando template"
    fi
}

# Función para estado GitHub Actions
github_status() {
    echo "📋 Estado de GitHub Actions..."
    echo "🔗 URL: https://github.com/giovanemere/ia-ops-iac/actions"
    
    # Intentar obtener estado via API si gh está disponible
    if command -v gh &> /dev/null; then
        echo "📊 Últimas ejecuciones:"
        gh run list --repo giovanemere/ia-ops-iac --limit 5 2>/dev/null || echo "ℹ️ No se pudo obtener estado via API"
    else
        echo "ℹ️ Instalar 'gh' CLI para ver estado automático"
    fi
}

# Loop principal
while true; do
    show_menu
    read -p "Selecciona una opción (1-8): " choice
    echo ""
    
    case $choice in
        1) validate_system ;;
        2) restart_backstage ;;
        3) update_repos ;;
        4) cleanup_aws ;;
        5) cleanup_test_buckets ;;
        6) view_logs ;;
        7) test_functionality ;;
        8) github_status ;;
        9) echo "👋 Saliendo..."; exit 0 ;;
        *) echo "❌ Opción inválida" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
    echo ""
done
