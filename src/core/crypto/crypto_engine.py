import ctypes
import os
from ctypes.util import find_library

class CryptoEngine:
    def __init__(self):
        # Configurar búsqueda de bibliotecas
        lib_path = os.path.join(os.path.dirname(__file__), 'libs', 'libmechbot_core.a')
        if not os.path.exists(lib_path):
            raise RuntimeError("Biblioteca no encontrada: " + lib_path)
            
        # Cargar biblioteca estática
        self.lib = ctypes.CDLL(lib_path, mode=ctypes.RTLD_GLOBAL)
        self.lib.init_crypto_engine.restype = ctypes.c_int
        
    def initialize(self):
        result = self.lib.init_crypto_engine()
        if result != 0:
            raise RuntimeError(f"Error de inicialización (Código: {result})")
        return True
