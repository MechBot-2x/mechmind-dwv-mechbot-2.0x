import jwt
from datetime import datetime, timedelta
from typing import Dict, Any

class JWTAuthService:
    def __init__(self, key_manager):
        self.key_manager = key_manager
        
    def generate_token(self, payload: Dict[str, Any]) -> str:
        """Versión simplificada para pruebas"""
        payload.update({
            'iat': datetime.utcnow(),
            'exp': datetime.utcnow() + timedelta(hours=1)
        })
        return jwt.encode(
            payload,
            self.key_manager.key_versions['current'][1],
            algorithm='HS256'
        )
        
    def verify_token(self, token: str) -> Dict[str, Any]:
        """Versión simplificada para pruebas"""
        return jwt.decode(
            token,
            self.key_manager.key_versions['current'][1],
            algorithms=['HS256']
        )
