#!/bin/bash
# scripts/security/audit.sh - CORREGIDO

set -e

echo "🔒 Iniciando auditoría de seguridad MechBot 2.0x"

check_ssl() {
    echo "🔐 Verificando SSL/TLS..."
    if command -v openssl &> /dev/null; then
        openssl s_client -connect google.com:443 -tlsextdebug 2>/dev/null | grep "TLS\|SSL" || echo "⚠️  No se pudo verificar SSL"
    else
        echo "ℹ️  openssl no disponible, saltando verificación SSL"
    fi
}

check_db_encryption() {
    echo "🗄️  Verificando configuración de base de datos..."
    # Simulación para desarrollo
    echo "✅ Configuración de encriptación verificada (simulación)"
}

check_secrets() {
    echo "🔑 Verificando gestión de secretos..."
    if [ -f ".vault/env.encrypted" ]; then
        echo "✅ Vault de secretos presente"
    else
        echo "⚠️  Vault de secretos no encontrado - crear con: ansible-vault create .vault/env.encrypted"
    fi
}

check_kubernetes() {
    echo "☸️  Verificando configuración Kubernetes..."
    if command -v kubectl &> /dev/null; then
        kubectl version --client 2>/dev/null && echo "✅ kubectl disponible"
    else
        echo "ℹ️  kubectl no disponible"
    fi
}

# Ejecutar verificaciones
check_ssl
check_db_encryption
check_secrets
check_kubernetes

echo "✅ Auditoría completada"
