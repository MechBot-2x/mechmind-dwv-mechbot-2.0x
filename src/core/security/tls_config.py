# src/core/security/tls_config.py - CORREGIDO

"""
Configuración TLS para MechBot 2.0x
"""

# Cifrados TLS 1.3 recomendados
CIPHERS = [
    'TLS_AES_256_GCM_SHA384',
    'TLS_CHACHA20_POLY1305_SHA256',
    'TLS_AES_128_GCM_SHA256'
]

# Configuración de protocolos
TLS_VERSION_MIN = 'TLSv1.3'
TLS_VERSION_FALLBACK = False

# Configuración para conexiones seguras
SECURE_CONFIG = {
    'cert_reqs': 'CERT_REQUIRED',
    'ssl_version': 'PROTOCOL_TLS',
    'ciphers': ':'.join(CIPHERS)
}

def get_secure_context():
    """Retorna contexto SSL seguro"""
    import ssl
    context = ssl.create_default_context()
    context.set_ciphers(':'.join(CIPHERS))
    context.check_hostname = True
    context.verify_mode = ssl.CERT_REQUIRED
    return context

if __name__ == "__main__":
    print("✅ Configuración TLS cargada correctamente")
    print(f"Cifrados: {CIPHERS}")
