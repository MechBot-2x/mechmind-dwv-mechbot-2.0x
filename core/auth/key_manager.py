import os
import logging
from datetime import datetime, timedelta
from typing import Tuple, Dict, Optional, List
from core.crypto.crypto_engine import CryptoEngine  # Ruta corregida

class JWTKeyManager:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.crypto = CryptoEngine()
        self.key_version = "v1"
        self.key_versions = {
            'current': (None, None),
            'previous': (None, None)
        }
        
    def initialize(self) -> bool:
        """Versión simplificada para pruebas"""
        if not self.crypto.initialize():
            return False
            
        # Generar una clave inicial si no existe
        if not self.key_versions['current'][1]:
            _, secret = self._generate_new_key()
            self.key_versions['current'] = ("initial_key", secret)
        return True
    
    def _generate_new_key(self) -> Tuple[str, str]:
        """Versión simplificada sin Vault"""
        key_id = f"key_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        secret = self.crypto.generate_secure_key(256)
        return key_id, secret
