#!/bin/bash
# scripts/security/deploy-security.sh

set -e

echo "🚀 DESPLIEGUE AUTOMATIZADO DE SEGURIDAD MECHBOT"
echo "=============================================="

deploy_menu() {
    echo ""
    echo "1. 🛡️  Desplegar toda la infraestructura de seguridad"
    echo "2. 🔑 Configurar solo Secrets"
    echo "3. 🌐 Configurar solo Network Policies"
    echo "4. 📊 Verificar despliegue"
    echo "5. 🧹 Limpiar y reinstalar"
    
    read -p "Selecciona una opción [1-5]: " choice
    
    case $choice in
        1) deploy_full_security ;;
        2) deploy_secrets_only ;;
        3) deploy_network_only ;;
        4) verify_deployment ;;
        5) cleanup_and_redeploy ;;
        *) echo "❌ Opción inválida" ;;
    esac
}

deploy_full_security() {
    echo "🛡️  INICIANDO DESPLIEGUE COMPLETO DE SEGURIDAD..."
    
    # Verificar cluster
    echo "1. 🔍 Verificando cluster Kubernetes..."
    kubectl cluster-info
    
    # Crear namespace si no existe
    echo "2. 📁 Creando namespace mechbot-prod..."
    kubectl create namespace mechbot-prod --dry-run=client -o yaml | kubectl apply -f -
    
    # Desplegar secrets
    deploy_secrets_only
    
    # Desplegar network policies
    deploy_network_only
    
    # Desplegar políticas de seguridad
    echo "5. 📜 Desplegando políticas de seguridad..."
    kubectl apply -f kubernetes/policies/namespace-security.yaml
    kubectl apply -f kubernetes/policies/pod-security-policy.yaml
    
    echo "✅ DESPLIEGUE COMPLETADO EXITOSAMENTE"
    echo "📊 Resumen:"
    kubectl get all,secrets,networkpolicies -n mechbot-prod
}

deploy_secrets_only() {
    echo "🔑 CONFIGURANDO SECRETS..."
    
    # Generar secrets seguros
    generate_secure_secrets
    
    echo "✅ Secrets configurados y listos"
}

generate_secure_secrets() {
    # Generar valores seguros
    PG_PASSWORD=$(openssl rand -base64 16 | tr -d '/+' | head -c 16)
    JWT_SECRET=$(openssl rand -base64 64 | tr -d '\n' | head -c 64)
    API_KEY=$(openssl rand -base64 32 | tr -d '/+' | head -c 32)
    ENCRYPTION_KEY=$(openssl rand -base64 32)
    
    # Crear o actualizar secret
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: mechbot-secrets
  namespace: mechbot-prod
type: Opaque
stringData:
  postgres-password: "$PG_PASSWORD"
  jwt-secret: "$JWT_SECRET"
  api-key: "$API_KEY"
  encryption-key: "$ENCRYPTION_KEY"
EOF

    echo "✅ Secrets seguros generados y almacenados"
}

deploy_network_only() {
    echo "🌐 CONFIGURANDO NETWORK POLICIES..."
    
    kubectl apply -f deploy/network/security-groups.prod.yaml
    
    echo "✅ Network policies configuradas"
}

verify_deployment() {
    echo "📊 VERIFICANDO DESPLIEGUE..."
    
    ./scripts/security/audit.sh
    ./scripts/security/cluster-diagnostic.sh
    
    echo "✅ Verificación completada"
}

cleanup_and_redeploy() {
    echo "🧹 LIMPIANDO Y REINSTALANDO..."
    
    read -p "¿Estás seguro de que quieres limpiar el despliegue? (s/n): " confirm
    if [[ $confirm == "s" ]]; then
        kubectl delete secret mechbot-secrets -n mechbot-prod --ignore-not-found
        kubectl delete -f kubernetes/policies/ --ignore-not-found
        kubectl delete -f deploy/network/ --ignore-not-found
        
        echo "🔄 Reinstalando..."
        deploy_full_security
    fi
}

# Ejecutar menú de despliegue
deploy_menu
