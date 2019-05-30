"""
Post-analysis
"""
import pandas as pd

def combine(comp):
    combined = pd.concat((comp.p, comp.q, comp.fc), axis=1)
    combined.columns = ['p_value', 'q_value', 'fold_change']
    return combined




