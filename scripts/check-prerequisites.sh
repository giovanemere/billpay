#!/bin/bash

echo "🔍 BillPay - Verificación de Prerequisitos"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

check_command() {
    local cmd=$1
    local name=$2
    local required_version=$3
    
    if command -v $cmd &> /dev/null; then
        local version=$(eval "$cmd --version 2>/dev/null | head -n1")
        echo -e "✅ ${GREEN}$name${NC}: $version"
        ((PASSED++))
    else
        echo -e "❌ ${RED}$name${NC}: No encontrado"
        if [ ! -z "$required_version" ]; then
            echo -e "   📋 Instalar: $required_version"
        fi
        ((FAILED++))
    fi
}

check_aws_config() {
    echo "🔐 Verificando configuración AWS..."
    
    if aws sts get-caller-identity &> /dev/null; then
        local account=$(aws sts get-caller-identity --query Account --output text)
        local user=$(aws sts get-caller-identity --query Arn --output text)
        echo -e "✅ ${GREEN}AWS CLI${NC}: Configurado"
        echo -e "   📋 Account: $account"
        echo -e "   👤 User: $user"
        ((PASSED++))
    else
        echo -e "❌ ${RED}AWS CLI${NC}: No configurado o sin permisos"
        echo -e "   📋 Ejecutar: aws configure"
        ((FAILED++))
    fi
}

check_github_access() {
    echo "🐙 Verificando acceso GitHub..."
    
    if gh auth status &> /dev/null; then
        local user=$(gh api user --jq .login 2>/dev/null)
        echo -e "✅ ${GREEN}GitHub CLI${NC}: Autenticado como $user"
        ((PASSED++))
    else
        echo -e "❌ ${RED}GitHub CLI${NC}: No autenticado"
        echo -e "   📋 Ejecutar: gh auth login"
        ((FAILED++))
    fi
    
    # Check SSH access
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo -e "✅ ${GREEN}GitHub SSH${NC}: Configurado"
        ((PASSED++))
    else
        echo -e "⚠️  ${YELLOW}GitHub SSH${NC}: Verificar configuración"
        echo -e "   📋 Generar SSH key si es necesario"
        ((WARNINGS++))
    fi
}

check_docker() {
    echo "🐳 Verificando Docker..."
    
    if docker ps &> /dev/null; then
        local version=$(docker --version)
        echo -e "✅ ${GREEN}Docker${NC}: $version"
        ((PASSED++))
    else
        echo -e "❌ ${RED}Docker${NC}: No está corriendo"
        echo -e "   📋 Iniciar Docker daemon"
        ((FAILED++))
    fi
}

check_repositories() {
    echo "📁 Verificando repositorios..."
    
    local repos=(
        "poc-billpay-back"
        "poc-billpay-front-a" 
        "poc-billpay-front-b"
        "poc-billpay-front-feature-flags"
        "templates_backstage"
        "ia-ops-iac"
    )
    
    for repo in "${repos[@]}"; do
        if [ -d "/home/giovanemere/periferia/billpay/repositories/$repo" ]; then
            echo -e "✅ ${GREEN}$repo${NC}: Clonado"
            ((PASSED++))
        else
            echo -e "❌ ${RED}$repo${NC}: No encontrado"
            ((FAILED++))
        fi
    done
}

check_system_resources() {
    echo "💻 Verificando recursos del sistema..."
    
    # RAM
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    if [ $ram_gb -ge 16 ]; then
        echo -e "✅ ${GREEN}RAM${NC}: ${ram_gb}GB (suficiente)"
        ((PASSED++))
    else
        echo -e "⚠️  ${YELLOW}RAM${NC}: ${ram_gb}GB (recomendado: 16GB+)"
        ((WARNINGS++))
    fi
    
    # Disk space
    local disk_gb=$(df -BG . | awk 'NR==2{print $4}' | sed 's/G//')
    if [ $disk_gb -ge 100 ]; then
        echo -e "✅ ${GREEN}Disk Space${NC}: ${disk_gb}GB disponible"
        ((PASSED++))
    else
        echo -e "⚠️  ${YELLOW}Disk Space${NC}: ${disk_gb}GB (recomendado: 100GB+)"
        ((WARNINGS++))
    fi
}

echo "1️⃣  HERRAMIENTAS BÁSICAS"
echo "======================="
check_command "node" "Node.js" "v18+"
check_command "npm" "npm" "v9+"
check_command "git" "Git" "v2+"
check_command "docker" "Docker" "v24+"
check_command "kubectl" "kubectl" "v1.28+"
echo ""

echo "2️⃣  HERRAMIENTAS IaC"
echo "==================="
check_command "tofu" "OpenTofu" "v1.6+"
check_command "terragrunt" "Terragrunt" "v0.55+"
check_command "python3" "Python" "v3.9+"
check_command "cookiecutter" "Cookiecutter" "v2.5+"
echo ""

echo "3️⃣  CONFIGURACIONES"
echo "==================="
check_aws_config
echo ""
check_github_access
echo ""
check_docker
echo ""

echo "4️⃣  REPOSITORIOS"
echo "================"
check_repositories
echo ""

echo "5️⃣  RECURSOS SISTEMA"
echo "===================="
check_system_resources
echo ""

echo "📊 RESUMEN"
echo "=========="
echo -e "✅ ${GREEN}Pasaron${NC}: $PASSED"
echo -e "❌ ${RED}Fallaron${NC}: $FAILED"
echo -e "⚠️  ${YELLOW}Advertencias${NC}: $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "🎉 ${GREEN}¡Todos los prerequisitos críticos están listos!${NC}"
    echo "✅ Puedes proceder con la implementación"
    exit 0
else
    echo -e "🚨 ${RED}Hay $FAILED prerequisitos faltantes${NC}"
    echo "❌ Resolver antes de continuar"
    exit 1
fi
