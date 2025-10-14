from flask import Flask
from core.auth.key_manager import JWTKeyManager
from core.auth.jwt_service import JWTAuthService

def create_app():
    app = Flask(__name__)
    
    # Configuración básica
    app.config.from_pyfile('config.py')
    app.config.update({
        'JWT_ALGORITHM': 'HS256',
        'JWT_EXPIRE_HOURS': 24
    })
    
    # Inicializa servicios
    key_manager = JWTKeyManager(vault_enabled=False)
    key_manager.initialize()
    
    # Configura el auth service
    auth_service = JWTAuthService()
    auth_service.configure(
        algorithm=app.config['JWT_ALGORITHM'],
        expire_hours=app.config['JWT_EXPIRE_HOURS']
    )
    
    # Registra blueprints
    from app.auth.views import auth_bp
    app.register_blueprint(auth_bp)
    
    # Guarda las instancias en el app context
    app.key_manager = key_manager
    app.auth_service = auth_service
    
    return app

app = create_app()
