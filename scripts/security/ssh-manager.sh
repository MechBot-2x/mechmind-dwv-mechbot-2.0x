#!/bin/bash
# scripts/security/ssh-manager.sh

set -e

echo "🔐 GESTOR INTERACTIVO DE SSH SEGURO"
echo "==================================="

ssh_main_menu() {
    while true; do
        echo ""
        echo "1. 🔑 Generar par de claves SSH"
        echo "2. 🛡️  Configurar servidor SSH seguro"
        echo "3. 🔄 Rotar claves SSH"
        echo "4. 📋 Verificar configuración SSH"
        echo "5. 🚪 Salir"
        echo ""
        read -p "Selecciona una opción [1-5]: " choice

        case $choice in
            1) generate_ssh_keys ;;
            2) configure_ssh_server ;;
            3) rotate_ssh_keys ;;
            4) verify_ssh_config ;;
            5) echo "¡Hasta luego! 🔒"; exit 0 ;;
            *) echo "❌ Opción inválida" ;;
        esac
    done
}

generate_ssh_keys() {
    echo ""
    echo "🔑 GENERACIÓN DE CLAVES SSH SEGURAS"
    echo "=================================="
    
    read -p "Tipo de clave [ed25519/rsa/ecdsa]: " key_type
    key_type=${key_type:-ed25519}
    
    read -p "Nombre del keypair [id_mechbot]: " key_name
    key_name=${key_name:-id_mechbot}
    
    read -p "Bits de seguridad [4096 para rsa, 256 para ed25519]: " key_bits
    
    case $key_type in
        rsa)
            key_bits=${key_bits:-4096}
            ssh-keygen -t rsa -b $key_bits -f ~/.ssh/$key_name -N "" -C "mechbot-$(date +%Y%m%d)"
            ;;
        ed25519)
            ssh-keygen -t ed25519 -f ~/.ssh/$key_name -N "" -C "mechbot-$(date +%Y%m%d)"
            ;;
        ecdsa)
            key_bits=${key_bits:-521}
            ssh-keygen -t ecdsa -b $key_bits -f ~/.ssh/$key_name -N "" -C "mechbot-$(date +%Y%m%d)"
            ;;
        *)
            echo "❌ Tipo de clave no soportado"
            return
            ;;
    esac
    
    echo "✅ Claves SSH generadas:"
    echo "   🔒 Privada: ~/.ssh/$key_name"
    echo "   🔓 Pública: ~/.ssh/$key_name.pub"
    
    # Mostrar fingerprint
    echo "📇 Fingerprint:"
    ssh-keygen -lf ~/.ssh/$key_name
    
    # Preguntar si crear secret en Kubernetes
    read -p "¿Crear Secret en Kubernetes con la clave? (s/n): " create_k8s_secret
    if [[ $create_k8s_secret == "s" ]]; then
        kubectl create secret generic ssh-key-secret -n mechbot-prod \
            --from-file=ssh-privatekey=~/.ssh/$key_name \
            --from-file=ssh-publickey=~/.ssh/$key_name.pub
        
        echo "✅ Secret 'ssh-key-secret' creado en Kubernetes"
    fi
}

configure_ssh_server() {
    echo ""
    echo "🛡️  CONFIGURACIÓN SEGURA DE SERVIDOR SSH"
    echo "========================================"
    
    # Crear configuración SSH segura
    cat > /tmp/sshd_config_secure << EOF
# Configuración SSH Segura MechBot 2.0x
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

# Autenticación
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# Configuración de seguridad
X11Forwarding no
PrintMotd no
PrintLastLog yes
IgnoreRhosts yes
RhostsRSAAuthentication no

# Cifrados seguros
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com

# Limites de conexión
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2

# Users allowlist
AllowUsers mechbot
EOF

    echo "✅ Configuración SSH segura generada en /tmp/sshd_config_secure"
    echo "📋 Resumen de configuración:"
    echo "   🔒 Solo clave pública (sin password)"
    echo "   🚫 Root login deshabilitado"
    echo   "   🛡️  Cifrados modernos habilitados"
    echo "   📉 Límites de conexión establecidos"
}

rotate_ssh_keys() {
    echo ""
    echo "🔄 ROTACIÓN DE CLAVES SSH"
    echo "========================"
    
    read -p "¿Rotar claves SSH existentes? (s/n): " rotate_keys
    if [[ $rotate_keys == "s" ]]; then
        # Hacer backup de claves existentes
        BACKUP_DIR="$HOME/.ssh/backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p $BACKUP_DIR
        cp $HOME/.ssh/id_* $BACKUP_DIR/ 2>/dev/null || true
        
        echo "📦 Backup creado en: $BACKUP_DIR"
        
        # Generar nuevas claves
        generate_ssh_keys
        
        echo "✅ Rotación completada"
        echo "⚠️  No olvides actualizar las claves públicas en todos los servidores"
    fi
}

verify_ssh_config() {
    echo ""
    echo "📋 VERIFICACIÓN DE CONFIGURACIÓN SSH"
    echo "==================================="
    
    echo "1. 🔍 Verificando claves SSH existentes..."
    ls -la ~/.ssh/id_* 2>/dev/null || echo "❌ No se encontraron claves SSH"
    
    echo ""
    echo "2. 📊 Verificando conexiones SSH activas..."
    netstat -tulpn | grep :22 || echo "ℹ️  Servidor SSH no detectado en puerto 22"
    
    echo ""
    echo "3. 🔑 Verificando Secrets SSH en Kubernetes..."
    kubectl get secrets -n mechbot-prod | grep ssh || echo "ℹ️  No hay secrets SSH en Kubernetes"
    
    echo ""
    echo "✅ Verificación completada"
}

# Ejecutar menú principal
ssh_main_menu
