from flask import Blueprint, jsonify, request, current_app
from functools import wraps

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization', '').split('Bearer ')[-1]
        if not token:
            return jsonify({'message': 'Token is missing'}), 401
            
        try:
            # Usamos el auth_service desde current_app
            signing_key = current_app.key_manager.get_signing_key()
            current_user = current_app.auth_service.verify_token(signing_key, token)
            request.current_user = current_user
        except Exception as e:
            current_app.logger.error(f"Token verification failed: {str(e)}")
            return jsonify({'message': 'Token is invalid', 'error': str(e)}), 401
            
        return f(*args, **kwargs)
    return decorated

@auth_bp.route('/login', methods=['POST'])
def login():
    """Endpoint de autenticación para MechBot"""
    try:
        auth_data = request.get_json()
        
        # Lógica de autenticación
        if auth_data.get('username') == 'mechbot' and auth_data.get('password') == 'securepassword':
            signing_key = current_app.key_manager.get_signing_key()
            token = current_app.auth_service.generate_token(
                signing_key,
                {
                    'bot_id': 'mechbot-001',
                    'roles': ['operator'],
                    'facility': 'production'
                }
            )
            return jsonify({
                'token': token,
                'bot_id': 'mechbot-001'
            })
        else:
            return jsonify({'message': 'Invalid credentials'}), 401
            
    except Exception as e:
        current_app.logger.error(f"Login error: {str(e)}")
        return jsonify({'message': 'Login failed', 'error': str(e)}), 500

@auth_bp.route('/protected', methods=['GET'])
@token_required
def protected_route():
    """Ruta protegida que requiere autenticación"""
    return jsonify({
        'message': 'Access granted',
        'bot': request.current_user
    })
