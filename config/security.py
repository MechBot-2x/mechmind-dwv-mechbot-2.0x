import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv('FLASK_SECRET_KEY', 'dev-key-temporal')
    JWT_ALGORITHM = 'HS256'
    JWT_EXPIRE_HOURS = 24
    VAULT_ENABLED = False  # Cambiar a True para usar Vault
