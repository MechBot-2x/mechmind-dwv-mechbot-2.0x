import random

class QuantumSimulator:
    @staticmethod
    def diagnose(error_code):
        issues = {
            'P0172': 'Fuel system too rich',
            'P0300': 'Random cylinder misfire'
        }
        return {
            'error': error_code,
            'confidence': random.uniform(0.7, 0.99),
            'solution': issues.get(error_code, 'Unknown error')
        }
