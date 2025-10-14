import unittest
import logging
from flask import Flask
from core.auth.key_manager import JWTKeyManager
from core.auth.jwt_service import JWTAuthService

class TestAuthSystem(unittest.TestCase):
    def setUp(self):
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
    def test_vault_integration(self):
        self.logger.info("Probando con Vault...")
        try:
            key_manager = JWTKeyManager(vault_enabled=True)
            key_manager.initialize()
            self.logger.info("✅ Sistema con Vault inicializado correctamente")
        except Exception as e:
            self.logger.error(f"Error con Vault: {str(e)}")
            raise
            
    def test_local_mode(self):
        self.logger.info("Probando modo local...")
        try:
            key_manager = JWTKeyManager(vault_enabled=False)
            key_manager.initialize()
            self.logger.info("✅ Sistema local inicializado correctamente")
        except Exception as e:
            self.logger.error(f"Error en modo local: {str(e)}")
            raise

if __name__ == '__main__':
    unittest.main()
