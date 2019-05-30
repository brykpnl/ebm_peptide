"""
Perform analysis
"""
import configparser
import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
from dataobjects import data
import postanalysis as pa

def run(conf_path):
    pandas2ri.activate()
    robjects.r('''source('r_stats.r')''')
    conf = configparser.ConfigParser()
    conf.read(conf_path)
    analysis_obj = data(conf)
    return analysis_obj

#Configuration file
conf = '../user_options.cfg'

#Set to True to export q-values, p-values, and fold-changes for each comparison.
export = True

#Output path directory
outpath = '../examples/CPTAC/output/'
if __name__ == "__main__":
    out = run(conf).pair
    if export == True:
        for comp in out:
            combined = pa.combine(out[comp])
            combined.to_csv(outpath + comp + '.csv', header=True)
        
        

        