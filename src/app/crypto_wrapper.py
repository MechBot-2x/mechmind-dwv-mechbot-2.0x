import ctypes
import sys

class CryptoEngine:
    def __init__(self):
        self.lib = ctypes.CDLL('./core_engine.so')
        self.lib.init_crypto_engine.restype = ctypes.c_int
        
    def initialize(self):
        result = self.lib.init_crypto_engine()
        if result != 0:
            raise RuntimeError(f"Fallo inicialización criptográfica (Código: {result})")
