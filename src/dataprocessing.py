"""
Data pre-processing
"""
import pandas as pd
import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
from collections import namedtuple

peptide_pair = namedtuple('peptide_pair', ['p', 'n'])

def vsn_normalize(data):
    r_norm_data = robjects.globalenv['vsn_normalize'](pandas2ri.py2ri(data))
    return pd.DataFrame(pandas2ri.ri2py(r_norm_data), index=data.index, columns=data.columns)

def drop_norm(pair, min_peptides):
    combined_counts = pd.concat(pair, axis=1)
    peptides_count = combined_counts.groupby(level=0).size()
    peptides_passed = peptides_count[peptides_count >= min_peptides]
    peptides_isolated = combined_counts.loc[peptides_passed.index]
    vsn_norm_counts = vsn_normalize(peptides_isolated)
    uncombined_counts = vsn_norm_counts[pair.p.columns], vsn_norm_counts[pair.n.columns]
    return peptide_pair(*uncombined_counts)

def preprocess(pair, min_p_reps, min_n_reps, min_peptides):
    p_list = pair.p.loc[pair.p.count(axis=1) >= min_p_reps].index
    n_list = pair.n.loc[pair.n.count(axis=1) >= min_n_reps].index
    combined_list = pd.Series(list(set(list(p_list) + list(n_list))))
    return drop_norm(peptide_pair(pair.p.loc[combined_list], pair.n.loc[combined_list]), min_peptides)
