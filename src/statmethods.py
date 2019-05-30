"""
Statistical methods for obtaining FDR-adjusted combined p-values
"""
import numpy as np
import pandas as pd
import EmpiricalBrownsMethod as bm
from scipy.stats import ttest_rel, ttest_ind
from statsmodels.stats.multitest import multipletests

def check_for_negative(t_statistic, p_value):
    if t_statistic < 0:
        return 1 - p_value
    else:
        return p_value

def ebm(p, data):
    return [(bm.EmpiricalBrownsMethod(np.array(data.loc[protein]), np.array(p.loc[protein]))) for protein in p.index]

def fdr_correction(p_values, method='fdr_by'):
    return pd.Series(multipletests(p_values, method=method)[1], index=p_values.index)

def stats_test(data, one_sided=True, paired=False, method='fisher'):
    if paired == True:
        t_test = ttest_rel(*data, axis=1)
    else:
        t_test = ttest_ind(*data, axis=1, equal_var=False)     
    if one_sided == True:
        p_vals = list(map(check_for_negative, t_test[0], t_test[1]))
    else:
        p_vals = list(t_test[1])
    p = pd.Series(p_vals, index = data[0].index)
    
    p_unstack = p.unstack()
    p_list = pd.Series([p[~np.isnan(p)] for p in np.array(p_unstack)], index=p_unstack.index)
    combined = pd.Series(ebm(p_list, pd.concat(data, axis=1)), index=p_unstack.index)
    return combined

def fold_change(data):
    fc = np.mean(data.p, axis=1) - np.mean(data.n, axis=1)
    return np.mean(fc.unstack(), axis=1)