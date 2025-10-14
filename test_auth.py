import os
import logging
from core.auth.key_manager import JWTKeyManager

# Configura logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def test_jwt_system():
    try:
        # Prueba con Vault
        logger.info("Probando con Vault...")
        manager_vault = JWTKeyManager(vault_enabled=True)
        if manager_vault.initialize():
            logger.info("✅ Sistema con Vault inicializado correctamente")
        else:
            logger.warning("⚠️  Falló inicialización con Vault, usando modo local")
            
        # Prueba sin Vault
        logger.info("Probando modo local...")
        manager_local = JWTKeyManager(vault_enabled=False)
        if manager_local.initialize():
            logger.info("✅ Sistema local inicializado correctamente")
            
    except Exception as e:
        logger.error(f"❌ Error: {str(e)}")

if __name__ == "__main__":
    test_jwt_system()
