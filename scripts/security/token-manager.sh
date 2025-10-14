#!/bin/bash
# scripts/security/token-manager.sh

set -e

echo "🔐 GESTOR INTERACTIVO DE SEGURIDAD MECHBOT 2.0x"
echo "=============================================="

main_menu() {
    while true; do
        echo ""
        echo "1. 🎫 Gestión de Tokens JWT"
        echo "2. 🔑 Gestión de Credenciales Kubernetes"
        echo "3. 🔄 Rotación Automática de Secrets"
        echo "4. 📊 Auditoría de Seguridad"
        echo "5. 🚪 Salir"
        echo ""
        read -p "Selecciona una opción [1-5]: " choice

        case $choice in
            1) jwt_menu ;;
            2) k8s_creds_menu ;;
            3) rotation_menu ;;
            4) audit_menu ;;
            5) echo "¡Hasta luego! 🔒"; exit 0 ;;
            *) echo "❌ Opción inválida" ;;
        esac
    done
}

jwt_menu() {
    echo ""
    echo "🎫 GESTIÓN DE TOKENS JWT"
    echo "========================"
    
    read -p "¿Quieres generar un nuevo token JWT? (s/n): " generate_jwt
    if [[ $generate_jwt == "s" ]]; then
        read -p "Duración del token en horas [24]: " jwt_hours
        jwt_hours=${jwt_hours:-24}
        
        # Generar token JWT seguro
        NEW_JWT_SECRET=$(openssl rand -base64 64 | tr -d '\n' | head -c 64)
        echo "✅ Nuevo JWT Secret generado: ${NEW_JWT_SECRET:0:16}..."
        
        # Actualizar secret en Kubernetes
        kubectl patch secret mechbot-secrets -n mechbot-prod \
            --type='json' -p="[{\"op\":\"replace\",\"path\":\"/data/jwt-secret\",\"value\":\"$(echo -n $NEW_JWT_SECRET | base64)\"}]"
        
        echo "✅ Token JWT actualizado en Kubernetes"
        echo "📅 Duración: $jwt_hours horas"
        echo "🔄 Próxima rotación recomendada: $(date -d "+30 days" '+%Y-%m-%d')"
    fi
}

k8s_creds_menu() {
    echo ""
    echo "🔑 GESTIÓN DE CREDENCIALES KUBERNETES"
    echo "===================================="
    
    echo "1. Crear Service Account"
    echo "2. Generar Token de Service Account"
    echo "3. Verificar permisos RBAC"
    echo "4. Volver"
    
    read -p "Selecciona [1-4]: " k8s_choice
    
    case $k8s_choice in
        1) create_service_account ;;
        2) generate_sa_token ;;
        3) check_rbac ;;
        4) return ;;
        *) echo "❌ Opción inválida" ;;
    esac
}

create_service_account() {
    read -p "Nombre del Service Account: " sa_name
    read -p "Namespace [mechbot-prod]: " namespace
    namespace=${namespace:-mechbot-prod}
    
    kubectl create serviceaccount $sa_name -n $namespace
    
    # Crear secret para el service account (token estático)
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: ${sa_name}-token
  namespace: $namespace
  annotations:
    kubernetes.io/service-account.name: $sa_name
EOF

    echo "✅ Service Account '$sa_name' creado en namespace '$namespace'"
}

generate_sa_token() {
    read -p "Nombre del Service Account: " sa_name
    read -p "Namespace [mechbot-prod]: " namespace
    namespace=${namespace:-mechbot-prod}
    read -p "Duración en segundos [3600]: " duration
    duration=${duration:-3600}
    
    echo "🔐 Generando token para $sa_name..."
    
    # Generar token de servicio de corta duración :cite[3]:cite[8]
    TOKEN=$(kubectl create token $sa_name -n $namespace --duration=${duration}s)
    
    echo "✅ Token generado exitosamente"
    echo "📋 Token (primeros 50 chars): ${TOKEN:0:50}..."
    echo "⏰ Expira en: $((duration / 3600)) horas"
    
    read -p "¿Mostrar token completo? (s/n): " show_full
    if [[ $show_full == "s" ]]; then
        echo "🔓 Token completo: $TOKEN"
    fi
}

check_rbac() {
    echo "🔍 VERIFICANDO PERMISOS RBAC"
    
    # Verificar permisos actuales
    kubectl auth can-i get secrets -n mechbot-prod
    kubectl auth can-i create pods -n mechbot-prod
    kubectl auth can-i update deployments -n mechbot-prod
    
    # Listar Service Accounts
    echo ""
    echo "📋 SERVICE ACCOUNTS EN MECHBOT-PROD:"
    kubectl get serviceaccounts -n mechbot-prod
}

rotation_menu() {
    echo ""
    echo "🔄 ROTACIÓN AUTOMÁTICA DE SECRETS"
    echo "================================"
    
    echo "¿Qué secret quieres rotar?"
    echo "1. 🔑 Todas las credenciales"
    echo "2. 🗄️  Solo PostgreSQL"
    echo "3. 🎫 Solo JWT"
    echo "4. 🔐 Solo API Key"
    
    read -p "Selecciona [1-4]: " rotate_choice
    
    case $rotate_choice in
        1) rotate_all_secrets ;;
        2) rotate_postgres ;;
        3) rotate_jwt ;;
        4) rotate_api_key ;;
        *) echo "❌ Opción inválida" ;;
    esac
}

rotate_all_secrets() {
    echo "🔄 Rotando todas las credenciales..."
    
    # Rotar PostgreSQL
    rotate_postgres
    
    # Rotar JWT
    rotate_jwt
    
    # Rotar API Key
    rotate_api_key
    
    # Rotar Encryption Key
    NEW_ENCRYPTION_KEY=$(openssl rand -base64 32)
    kubectl patch secret mechbot-secrets -n mechbot-prod \
        --type='json' -p="[{\"op\":\"replace\",\"path\":\"/data/encryption-key\",\"value\":\"$(echo -n $NEW_ENCRYPTION_KEY | base64)\"}]"
    
    echo "✅ Todas las credenciales rotadas exitosamente"
    echo "📅 Próxima rotación programada: $(date -d "+15 days" '+%Y-%m-%d')"
}

rotate_postgres() {
    NEW_DB_PASSWORD=$(openssl rand -base64 16 | tr -d '/+' | head -c 16)
    kubectl patch secret mechbot-secrets -n mechbot-prod \
        --type='json' -p="[{\"op\":\"replace\",\"path\":\"/data/postgres-password\",\"value\":\"$(echo -n $NEW_DB_PASSWORD | base64)\"}]"
    echo "✅ Password de PostgreSQL rotado"
}

rotate_jwt() {
    NEW_JWT=$(openssl rand -base64 64 | tr -d '\n' | head -c 64)
    kubectl patch secret mechbot-secrets -n mechbot-prod \
        --type='json' -p="[{\"op\":\"replace\",\"path\":\"/data/jwt-secret\",\"value\":\"$(echo -n $NEW_JWT | base64)\"}]"
    echo "✅ JWT Secret rotado"
}

rotate_api_key() {
    NEW_API_KEY=$(openssl rand -base64 32 | tr -d '/+' | head -c 32)
    kubectl patch secret mechbot-secrets -n mechbot-prod \
        --type='json' -p="[{\"op\":\"replace\",\"path\":\"/data/api-key\",\"value\":\"$(echo -n $NEW_API_KEY | base64)\"}]"
    echo "✅ API Key rotada"
}

audit_menu() {
    echo ""
    echo "📊 AUDITORÍA DE SEGURIDAD"
    echo "========================"
    
    echo "🔍 Revisando estado de seguridad..."
    
    # Verificar secrets
    echo "1. 🔑 Verificando Secrets..."
    kubectl get secrets -n mechbot-prod
    
    # Verificar service accounts
    echo ""
    echo "2. 👤 Verificando Service Accounts..."
    kubectl get serviceaccounts -n mechbot-prod
    
    # Verificar pods en ejecución
    echo ""
    echo "3. 🐳 Verificando Pods..."
    kubectl get pods -n mechbot-prod -o wide
    
    # Verificar network policies
    echo ""
    echo "4. 🌐 Verificando Network Policies..."
    kubectl get networkpolicies -n mechbot-prod
    
    echo ""
    echo "✅ Auditoría completada - $(date)"
}

# Ejecutar menú principal
main_menu
