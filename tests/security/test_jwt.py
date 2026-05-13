import unittest
from core.auth.key_manager import JWTKeyManager
from core.auth.jwt_service import JWTAuthService

class TestJWTIntegration(unittest.TestCase):
    def setUp(self):
        self.key_manager = JWTKeyManager(vault_enabled=False)
        self.key_manager.initialize()
        self.auth_service = JWTAuthService()
        self.auth_service.configure(algorithm='HS256', expire_hours=24)

    def test_token_generation_and_verification(self):
        signing_key = self.key_manager.get_signing_key()
        test_payload = {'user_id': 123, 'role': 'admin'}
        token = self.auth_service.generate_token(signing_key, test_payload)
        decoded = self.auth_service.verify_token(signing_key, token)

        self.assertEqual(decoded['user_id'], 123)
        self.assertEqual(decoded['role'], 'admin')

if __name__ == '__main__':
    unittest.main()
