"""Módulo cuántico simplificado para Termux"""
from qiskit import QuantumCircuit, Aer

def diagnose(error_code):
    """Simulador cuántico básico"""
    simulator = Aer.get_backend('qasm_simulator')
    qc = QuantumCircuit(2)
    qc.h(0)
    qc.cx(0,1)
    qc.measure_all()
    return {'error': error_code, 'circuit': qc}
