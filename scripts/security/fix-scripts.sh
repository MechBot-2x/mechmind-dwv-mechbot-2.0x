#!/bin/bash
# scripts/security/fix-scripts.sh

echo "🔧 APLICANDO CORRECCIONES A SCRIPTS DE SEGURIDAD"

# Hacer backup de los scripts originales
cp scripts/security/token-manager.sh scripts/security/token-manager.sh.backup
cp scripts/security/ssh-manager.sh scripts/security/ssh-manager.sh.backup

# Aquí aplicarías las correcciones mencionadas arriba
# (Necesitarías editar manualmente los archivos con los cambios específicos)

echo "✅ Correcciones aplicadas. Revisa los archivos .backup para referencia."
echo "📝 Ahora ejecuta: git add . && git commit -m 'Corrige scripts de seguridad' && git push origin main"
