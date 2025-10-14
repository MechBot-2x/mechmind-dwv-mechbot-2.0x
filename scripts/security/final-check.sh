#!/bin/bash
# scripts/security/final-check.sh

echo "=== VERIFICACIÓN FINAL DEL SISTEMA DE SEGURIDAD MECHBOT 2.0x ==="

# Función para verificar YAML
check_yaml() {
    local file=$1
    local name=$2
    if kubectl create --dry-run=client -f "$file" &>/dev/null; then
        echo "✅ $name: YAML válido"
        return 0
    else
        echo "❌ $name: YAML inválido"
        return 1
    fi
}

# Verificar todos los YAMLs
echo "1. Validando archivos YAML/Kubernetes:"
check_yaml "kubernetes/policies/pod-security-policy.yaml" "Pod Security Policy"
check_yaml "kubernetes/secrets/templates/secret-template.yaml" "Secret Template" 
check_yaml "deploy/network/security-groups.prod.yaml" "Network Security Groups"

# Verificar scripts
echo ""
echo "2. Validando scripts de seguridad:"
if [ -x "scripts/security/audit.sh" ]; then
    ./scripts/security/audit.sh --test &>/dev/null && echo "✅ audit.sh: Ejecutable y funcional" || echo "⚠️  audit.sh: Ejecutable pero con warnings"
else
    echo "❌ audit.sh: No ejecutable"
fi

# Verificar configuración Python
echo ""
echo "3. Validando configuración Python:"
python3 -c "from src.core.security.tls_config import get_secure_context; print('✅ TLS Config: Importación exitosa')" 2>/dev/null || echo "❌ TLS Config: Error en importación"

# Verificar bases de datos
echo ""
echo "4. Validando configuración de bases de datos:"
[ -f "deploy/postgres/postgres-hardening.sql" ] && echo "✅ PostgreSQL: Script presente" || echo "❌ PostgreSQL: Script faltante"
[ -f "config/cassandra/security.yaml" ] && echo "✅ Cassandra: Configuración presente" || echo "❌ Cassandra: Configuración faltante"

# Verificar monitoreo
echo ""
echo "5. Validando sistema de monitoreo:"
[ -f "monitoring/siem/alerts-rules.yml" ] && echo "✅ Alertas SIEM: Configuración presente" || echo "❌ Alertas SIEM: Configuración faltante"
[ -f "deploy/efk/security-dashboard.ndjson" ] && echo "✅ Dashboard EFK: Configuración presente" || echo "❌ Dashboard EFK: Configuración faltante"

# Verificar documentación
echo ""
echo "6. Validando documentación:"
[ -f "docs/security/GUIDELINES.md" ] && echo "✅ GUIDELINES: Documentación presente" || echo "❌ GUIDELINES: Documentación faltante"
[ -f "docs/security/INCIDENT_RESPONSE.md" ] && echo "✅ INCIDENT_RESPONSE: Documentación presente" || echo "❌ INCIDENT_RESPONSE: Documentación faltante"

echo ""
echo "=== VERIFICACIÓN COMPLETADA ==="
