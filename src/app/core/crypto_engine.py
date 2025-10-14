import ctypes
import os
from pathlib import Path

class CryptoEngine:
    def __init__(self):
        # Configurar rutas
        self.lib_path = Path(__file__).parent.parent/'libs'/'libmechbot_core.so'
        
        if not self.lib_path.exists():
            raise RuntimeError(f"Biblioteca no encontrada: {self.lib_path}")

        # Cargar biblioteca
        self.lib = ctypes.CDLL(str(self.lib_path))
        
        # Configurar tipos de funciones
        self.lib.init_crypto_engine.restype = ctypes.c_int

    def initialize(self) -> bool:
        """Inicializa el motor criptográfico"""
        result = self.lib.init_crypto_engine()
        if result != 0:
            raise RuntimeError(f"Error de inicialización (Código: {result})")
        return True
