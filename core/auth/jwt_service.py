import jwt
from datetime import datetime, timedelta
from typing import Dict, Any
from flask import current_app

class JWTAuthService:
    def __init__(self, algorithm='HS256', expire_hours=24):
        """Inicializa el servicio JWT sin depender de current_app"""
        self.algorithm = algorithm
        self.expire_hours = expire_hours

    def configure(self, algorithm, expire_hours):
        """Permite configurar después de la creación"""
        self.algorithm = algorithm
        self.expire_hours = expire_hours

    def generate_token(self, signing_key: str, payload: Dict[str, Any]) -> str:
        """Genera un token JWT seguro para MechBot"""
        payload.update({
            'iat': datetime.now(datetime.UTC),
            'exp': datetime.now(datetime.UTC) + timedelta(hours=self.expire_hours),
            'iss': 'mechbot-auth-service'
        })
        
        return jwt.encode(
            payload,
            signing_key,
            algorithm=self.algorithm
        )

    def verify_token(self, signing_key: str, token: str) -> Dict[str, Any]:
        """Verifica un token JWT para MechBot"""
        try:
            return jwt.decode(
                token,
                signing_key,
                algorithms=[self.algorithm],
                options={
                    'verify_exp': True,
                    'verify_iss': True,
                    'require': ['exp', 'iat', 'iss']
                }
            )
        except jwt.ExpiredSignatureError:
            current_app.logger.warning("Token expired")
            raise ValueError("Token has expired")
        except jwt.InvalidTokenError as e:
            current_app.logger.warning(f"Invalid token: {str(e)}")
            raise ValueError("Invalid token")
