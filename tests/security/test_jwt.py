import unittest
from core.auth.key_manager import JWTKeyManager
from core.auth.jwt_service import JWTAuthService

class TestJWTIntegration(unittest.TestCase):
    def setUp(self):
        self.key_manager = JWTKeyManager()
        self.key_manager.initialize()
        self.auth_service = JWTAuthService(self.key_manager)

    def test_token_generation_and_verification(self):
        test_payload = {'user_id': 123, 'role': 'admin'}
        token = self.auth_service.generate_token(test_payload)
        decoded = self.auth_service.verify_token(token)
        
        self.assertEqual(decoded['user_id'], 123)
        self.assertEqual(decoded['role'], 'admin')

if __name__ == '__main__':
    unittest.main()
