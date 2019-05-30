"""
Classes for holding and analyzing data
"""
import pandas as pd
import numpy as np
import dataprocessing as dp
import imputation
import statmethods as sm

class comp_pair:
    def __init__(self, p, n):
        self.pair = dp.peptide_pair(p, n)
    
    def analyze(self, min_p_reps, min_n_reps, min_peptides):
        self.norm = dp.preprocess(self.pair, min_p_reps, min_n_reps, min_peptides)
        self.prepared_data = dp.peptide_pair(*[imputation.impute(data) for data in self.norm])
        self.p = sm.stats_test(self.prepared_data)
        self.q = sm.fdr_correction(self.p)
        self.fc = sm.fold_change(self.prepared_data)
        
class data:
    def __init__(self, conf):
        self.peptides = pd.pivot_table(pd.read_csv(conf['User']['peptides']), index = ['Protein', 'Sequence']).replace(0, np.nan)
        self.experiments = pd.read_csv(conf['User']['experiments'], index_col = 0)
        self.comparisons = pd.DataFrame(pd.read_csv(conf['User']['comparisons']))
        self.min_peptides = int(conf['User']['min_peptides'])
        self.min_p_reps = int(conf['User']['min_probe_replicates'])
        self.min_n_reps = int(conf['User']['min_noprobe_replicates'])
        self.pair = {}
        
        for comp in self.comparisons.iterrows():
            p_name = comp[1].loc['Probe']
            n_name = comp[1].loc['NoProbe']
            p = self.peptides[self.experiments.loc[p_name]]
            n = self.peptides[self.experiments.loc[n_name]]
            vs_name = p_name + '_vs_' + n_name
            vs_data = comp_pair(p, n)
            vs_data.analyze(self.min_p_reps, self.min_n_reps, self.min_peptides)
            self.pair[vs_name] = vs_data
