import os
import logging
import hvac
from datetime import datetime, timedelta
from typing import Tuple, Dict, Optional, List

class JWTKeyManager:
    def __init__(self, vault_enabled=True):
        self.logger = logging.getLogger(__name__)
        self.vault_enabled = vault_enabled
        self.key_versions = {
            'current': (None, None),
            'previous': (None, None),
            'valid_from': None
        }
        
        if self.vault_enabled:
            self._init_vault()
        else:
            self._init_local()

    def _init_vault(self):
        """Intenta conectar con Vault"""
        try:
            self.vault_client = hvac.Client(
                url=os.getenv('VAULT_ADDR'),
                token=os.getenv('VAULT_TOKEN')
            )
            
            if not self.vault_client.sys.is_initialized():
                self.logger.warning("Vault no está inicializado, usando almacenamiento local")
                self.vault_enabled = False
                self._init_local()
                
        except Exception as e:
            self.logger.error(f"Error conectando a Vault: {str(e)}")
            self.vault_enabled = False
            self._init_local()

    def _init_local(self):
        """Configuración local sin Vault"""
        from hashlib import sha256
        from base64 import b64encode
        import secrets
        
        secret = secrets.token_hex(32)
        key_id = f"local_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.key_versions = {
            'current': (key_id, secret),
            'previous': (None, None),
            'valid_from': datetime.utcnow()
        }
        self.logger.info("Configurado almacenamiento local de claves")

    def initialize(self) -> bool:
        """Inicializa el servicio de claves"""
        try:
            if self.vault_enabled:
                return self._init_with_vault()
            return True
        except Exception as e:
            self.logger.error(f"Error inicializando: {str(e)}")
            return False

    def _init_with_vault(self) -> bool:
        """Intenta cargar claves desde Vault"""
        try:
            if not self.vault_client.sys.is_sealed():
                # Implementar lógica real de carga desde Vault aquí
                return True
            return False
        except Exception as e:
            self.logger.error(f"Error con Vault: {str(e)}")
            return False

    # ... (resto de métodos permanecen igual)
